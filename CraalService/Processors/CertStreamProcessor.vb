''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           CertStreamProcessor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Runs a thread that continuously receives data from CertStream (https://certstream.calidog.io/)
''                  and looks for addresses that end in ".s3.amazonaws.com" to add them to the
''                  list of discovered Buckets for later dumping.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports CraalDatabase
Imports System.Threading
Imports System.Net.WebSockets
Imports CraalDatabase.Database
Imports System.Text.UTF8Encoding
Imports System.Runtime.Serialization
Imports System.Runtime.Serialization.Json

Public Class CertStreamProcessor
    ''' <summary>
    ''' These classes are incomplete representations of the JSON returned by the CertStream endpoint. Only the members
    ''' required to do the processing are included.
    ''' </summary>
    <DataContract> Class CertStreamEndpointData
        <DataMember> Public message_type As String
        <DataMember> Public data As CertStreamData
    End Class
    <DataContract> Class CertStreamData
        <DataMember> Public update_type As String
        <DataMember> Public leaf_cert As CertStreamLeafCert
    End Class
    <DataContract> Class CertStreamLeafCert
        <DataMember> Public all_domains() As String
    End Class

    ' The database object used to store results
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The processing thread object, stop , and stopped signals
    Private pProcessingThread As Thread
    Private pStopProcessing As Boolean = False
    Private pStoppedProcessing As Boolean = False

    ' The URL used to search by keyword
    Private Const CertStreamURL As String = "ws://certstream.calidog.io"

    ''' <summary>
    ''' Creates an instance of the class.
    ''' </summary>
    Sub New()

    End Sub

    ''' <summary>
    ''' Starts the processing thread.
    ''' </summary>
    Public Sub StartProcessing()
        ' Create the search and downloading threads if they don't already exist
        If pProcessingThread Is Nothing Then
            pProcessingThread = New Thread(AddressOf ProcessingThread)
        End If

        ' Start the search and downloading threads if they're not already running
        If pProcessingThread.ThreadState <> ThreadState.Running Then
            Call pProcessingThread.Start()
        End If
    End Sub

    ''' <summary>
    ''' Stops the processing and download threads. This call blocks until the threads are stopped.
    ''' </summary>
    Public Sub StopProcessing()
        ' Check to see whether the search thread exists
        If Not pProcessingThread Is Nothing Then
            ' If the search thread is running, stop it
            If pProcessingThread.ThreadState = ThreadState.Running Then
                pStopProcessing = True
                While Not pStoppedProcessing
                    Call Thread.Yield()
                    Call Thread.Sleep(50)
                End While

                ' Destroy the thread once stopped
                Call pProcessingThread.Abort()
                pProcessingThread = Nothing
            End If
        End If
    End Sub

    ''' <summary>
    ''' Catches exceptions and ensures the WebSocket is held open across multiple exceptions 
    ''' </summary>
    Private Async Sub ProcessingThread()
        While Not pStopProcessing
            Try
                Await ProcessData()
            Catch ex As Exception
                ' Do nothing, we want to run this until we're told not
                ' to regardless of what errors happened
            End Try
        End While
    End Sub

    ''' <summary>
    ''' Processes data off the WebSocket as it comes in
    ''' </summary>
    ''' <returns></returns>
    Private Async Function ProcessData() As Task
        Dim WebSocket As New ClientWebSocket
        Await WebSocket.ConnectAsync(New Uri(CertStreamURL), CancellationToken.None)

        While Not pStopProcessing
            Dim Certificate As CertStreamEndpointData = Nothing
            Dim CertStreamSerializer As New DataContractJsonSerializer(GetType(CertStreamEndpointData))

            Dim StreamBuffer As String = ""
            Dim EntityProcessed As Boolean = False
            While Not EntityProcessed
                ' Allocate 10K to store the data from the WebSocket and then request the next data segment. Append any data
                ' from the endpoint to a buffer that collects the data over multiple calls to WebSocket.ReceiveAsync.
                Dim ReceiveBytes(10240) As Byte
                Dim ReceiveBuffer = New ArraySegment(Of Byte)(ReceiveBytes)
                Dim ReceiveResult As WebSocketReceiveResult = Await WebSocket.ReceiveAsync(ReceiveBuffer, CancellationToken.None)
                StreamBuffer &= UTF8.GetString(ReceiveBuffer.Skip(ReceiveBuffer.Offset).Take(ReceiveResult.Count).ToArray())

                ' If the EndOfMessage property is set to True then we should have a fully formed JSON object that will allow
                ' us to deserialize using the CertStreamSerializer.
                If ReceiveResult.EndOfMessage Then
                    Dim CertStream As New MemoryStream(UTF8.GetBytes(StreamBuffer))

                    Try
                        ' If the entity is successfully processed then we'll move onto reading the content of the JSON object.
                        Certificate = CertStreamSerializer.ReadObject(CertStream)
                        EntityProcessed = True
                    Catch ex As Exception
                        EntityProcessed = False
                    End Try
                End If
            End While

            ' Check that this is a certificate_update message and the update type is X509LogEntry (which indicates
            ' a certificate was issued).
            If Certificate.message_type = "certificate_update" Then
                If Not Certificate.data Is Nothing Then
                    If Certificate.data.update_type = "X509LogEntry" Then
                        If Not Certificate.data.leaf_cert Is Nothing Then
                            If Not Certificate.data.leaf_cert.all_domains Is Nothing Then
                                For j = 0 To Certificate.data.leaf_cert.all_domains.Count - 1

                                    ' If a domain on the certificate is a Bucket then insert the Bucket name into the database. Since there
                                    ' might be more than one Bucket on the certificate cycle through all the domains.
                                    If Certificate.data.leaf_cert.all_domains(j).Contains(".s3.amazonaws.com") Then
                                        Call pDatabase.InsertDiscoveredContainer(Certificate.data.leaf_cert.all_domains(j).Substring(0, Certificate.data.leaf_cert.all_domains(j).IndexOf(".s3.amazonaws.com")), "", "", ContainerType.S3Bucket)
                                    ElseIf Certificate.data.leaf_cert.all_domains(j).Contains(".blob.core.windows.net") Then
                                        Call pDatabase.InsertDiscoveredContainer(Certificate.data.leaf_cert.all_domains(j).Substring(0, Certificate.data.leaf_cert.all_domains(j).IndexOf(".blob.core.windows.net")), "", "", ContainerType.AzureBlob)
                                    ElseIf Certificate.data.leaf_cert.all_domains(j).Contains(".nyc3.digitaloceanspaces.com") Then
                                        Call pDatabase.InsertDiscoveredContainer(Certificate.data.leaf_cert.all_domains(j).Substring(0, Certificate.data.leaf_cert.all_domains(j).IndexOf(".nyc3.digitaloceanspaces.com")), "", "", ContainerType.DigitalOceanSpace)
                                    End If
                                Next
                            End If
                        End If
                    End If
                End If
            End If
        End While

        ' Processing has stopped
        pStoppedProcessing = True
    End Function
End Class
