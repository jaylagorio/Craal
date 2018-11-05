''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           ProtoxinProcessor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Runs a thread that retrieves the list of S3 Buckets discovered by Protoxin
''                  (http://www.protoxin.net), checkes them against Buckets already discovered,
''                  and adds them to the list of Buckets that should be checked.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports System.Net
Imports CraalDatabase
Imports System.Threading
Imports CraalDatabase.Database
Imports System.Runtime.Serialization
Imports System.Collections.ObjectModel
Imports System.Runtime.Serialization.Json

Public Class ProtoxinProcessor
    ''' <summary>
    ''' These classes are incomplete representations of the JSON returned by the Protoxin S3 endpoint. Only the members
    ''' required to do the processing are included.
    ''' </summary>
    <DataContract> Class ProtoxinEndpointData
        <DataMember> Public data() As ProtoxinBucketData
    End Class
    <DataContract> Class ProtoxinBucketData
        <DataMember> Public bucket_url As String
        <DataMember> Public [public] As String
    End Class

    ' The database object used to store results
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The processing thread object, stop , and stopped signals
    Private pProcessingThread As Thread
    Private pStopProcessing As Boolean = False
    Private pStoppedProcessing As Boolean = False

    ' The URL used to search by keyword
    Private Const ProtoxinURL As String = "https://api.protoxin.net/s3/"

    ' The delay between search runs
    Private Const NextRunTime As Integer = 86400

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
    ''' Calls the data processor and manages waiting between run periods.
    ''' </summary>
    Private Sub ProcessingThread()
        Dim NextExecution As DateTime = Now

        ' Run the following process until told to stop
        While Not pStopProcessing
            ' Grab the Protoxin list and search it for new entries
            Call ProcessProtoxin()

            ' Sleep for 24 hours, checking every minute to see whether
            ' we're supposed to stop.
            NextExecution = Now.AddSeconds(NextRunTime)
            While (Now < NextExecution) And Not pStopProcessing
                Call Thread.Sleep(60000)
            End While
        End While

        ' Processing has stopped
        pStoppedProcessing = True
    End Sub

    ''' <summary>
    ''' This thread downloads the Buckets that Protoxin has discovered and adds them to the list of Buckets discovered
    ''' through automated processes.
    ''' </summary>
    ''' <returns>True if no errors occur, False otherwise.</returns>
    Private Function ProcessProtoxin() As Boolean
        ' Get the existing list of discovered buckets
        Dim ExistingBucketList As Collection(Of StorageContainer) = pDatabase.GetDiscoveredContainers(False)

        Dim QuerySuccess As Boolean = False
        Dim ResponseStream As Stream = Nothing

        ' Attempt this operation until serialization works or told to stop
        While Not pStopProcessing And Not QuerySuccess
            ' Attempt this download until it works or told to stop processing
            While (Not QuerySuccess) And (Not pStopProcessing)
                Try
                    ' Formulate the request and attach the relevant headers
                    Dim ProtoxinRequest As HttpWebRequest = HttpWebRequest.Create(ProtoxinURL)

                    ' Make the search request and get the response stream
                    Dim SearchRequest As HttpWebResponse = ProtoxinRequest.GetResponse()
                    ResponseStream = SearchRequest.GetResponseStream()
                    QuerySuccess = True
                Catch ex As WebException
                    ' If there's no response in the exception then just try again
                    If Not ex.Response Is Nothing Then
                        Call Threading.Thread.Sleep(250)
                    End If
                End Try
            End While

            If Not ResponseStream Is Nothing Then
                Dim ProtoxinResultSerializer As New DataContractJsonSerializer(GetType(ProtoxinEndpointData))
                Try
                    ' Attempt to return the serialized results. Sometimes the stream is broken so serialization 
                    ' doesn't work, so just restart the process to get a proper download and then try to serialize again.
                    Dim ProtoxinResult As ProtoxinEndpointData = ProtoxinResultSerializer.ReadObject(ResponseStream)
                    Dim BucketComparator As New StorageContainer
                    BucketComparator.ContainerType = ContainerType.S3Bucket

                    ' Go through the entire list that was downloaded and add new ones to the discovered Bucket list
                    For i = 0 To ProtoxinResult.data.Count - 1
                        BucketComparator.ContainerName = ProtoxinResult.data(i).bucket_url.Substring(0, ProtoxinResult.data(i).bucket_url.IndexOf(".s3.amazonaws.com"))
                        BucketComparator.ContainerType = ContainerType.S3Bucket

                        If Not ExistingBucketList.Contains(BucketComparator) Then
                            If pDatabase.InsertDiscoveredContainer(BucketComparator.ContainerName, "", "", ContainerType.S3Bucket) Then
                                ' To improve performance, add the Bucket to the list of existing buckets without hitting the database
                                Call ExistingBucketList.Add(BucketComparator)
                            Else
                                Throw New Exception
                            End If
                        End If

                        ' Break out of what could be a very long operation if asked to stop processing
                        If pStopProcessing Then
                            Exit For
                        End If
                    Next

                    QuerySuccess = True
                Catch ex As Exception
                    QuerySuccess = False
                End Try
            End If
        End While

        Return Nothing
    End Function

    '
    '  {
    '"data": [
    '  {
    '    "bucket_url": "zxy-test.s3.amazonaws.com", 
    '    "public": "Y"
    '  }, 
    '  {
    '    "bucket_url": "zwilling.s3.amazonaws.com", 
    '    "public": "Y"
    '  }, 

    ' On the Database side, it adds to a "BucketList"

End Class
