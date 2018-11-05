''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           PasteBinProcessor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Runs a thread that searches new PasteBin pastes for the keywords identified 
''                  by the user and adds pastes with matching keywords to the list of pending
''                  downloads.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports System.Net
Imports System.Text
Imports CraalDatabase
Imports System.Threading
Imports CraalDatabase.Database
Imports System.Runtime.Serialization
Imports System.Runtime.Serialization.Json

' This class models a single result returned by PasteBin in JSON format. When PasteBin returns results
' it sends them down in an array of these. This class is incomplete and includes only the information
' required for this process.
<DataContract> Class PastebinEntry
    <DataMember> Public key As String
    <DataMember> Public full_url As String
    <DataMember> Public scrape_url As String
End Class

Public Class PasteBinProcessor
    ' Used to deduplicate and store data
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The ID used to get relevant keywords and store results
    Private pDataSourceID As Integer

    ' The thread object and signals used to stop and indicate stoppage of processing
    Private pProcessingThread As Thread
    Private pStopProcessing As Boolean = False
    Private pStoppedProcessing As Boolean = False

    ' The URL used to get new pastes
    Private Const PasteBinSearchURL As String = "https://scrape.pastebin.com/api_scraping.php?limit=250"

    ' The number of seconds between cycles
    Private Const NextRunTime As Integer = 120

    ' The number of milliseconds between scrape attempts after exceptions or being told to slow down
    Private Const ScrapeAttemptTime As Integer = 60000

    ' This message is returned (raw) by the PasteBin endpoint when you hammer it too hard.
    Private Const SlowPasteRequestMessage As String = "Please slow down, you are hitting our servers unnecessarily hard! No more than 1000 requests per 10 minutes. Please wait a few minutes before trying again."

    ''' <summary>
    ''' Creates an instance of the class.
    ''' </summary>
    ''' <param name="DataSourceID">Used to find the keywords associated with the search process and marked on stored results</param>
    Sub New(ByVal DataSourceID As Integer)
        ' Store the data source ID
        pDataSourceID = DataSourceID
    End Sub

    ''' <summary>
    ''' Starts the processing thread.
    ''' </summary>
    Public Sub StartProcessing()
        ' Create the thread if it doesn't already exist
        If pProcessingThread Is Nothing Then
            pProcessingThread = New Thread(AddressOf ProcessingThread)
        End If

        ' Start the thread if it isn't already running
        If pProcessingThread.ThreadState <> ThreadState.Running Then
            Call pProcessingThread.Start()
        End If
    End Sub

    ''' <summary>
    ''' Stops the processing thread. This call blocks until the thread is stopped.
    ''' </summary>
    Public Sub StopProcessing()
        ' If the thread doesn't exist, exit
        If pProcessingThread Is Nothing Then
            Exit Sub
        End If

        ' If the thread is already stopped, exit
        If pProcessingThread.ThreadState <> ThreadState.Running Then
            Exit Sub
        End If

        ' Signal the thread to stop processing and wait for it
        ' to indicate that it stopped
        pStopProcessing = True
        While Not pStoppedProcessing
            Call Thread.Yield()
            Call Thread.Sleep(50)
        End While

        ' Kill the thread and the object
        Call pProcessingThread.Abort()
        pProcessingThread = Nothing
    End Sub

    ''' <summary>
    ''' Calls the data processor and manages waiting between run periods.
    ''' </summary>
    Private Sub ProcessingThread()
        Dim NextExecution As DateTime = Now

        ' Run this loop until being told to stop
        While Not pStopProcessing
            ' Download and process new pastes
            Call ProcessPastebin()

            ' The next time this process will run is in two minutes. Wait for
            ' this time period to elapse, checking ever quarter second that we
            ' haven't been told to stop entirely.
            NextExecution = Now.AddSeconds(NextRunTime)
            While (Now < NextExecution) And Not pStopProcessing
                Call Thread.Sleep(250)
            End While
        End While

        ' The thread stopped processing and is ready to be destroyed.
        pStoppedProcessing = True
    End Sub

    ''' <summary>
    ''' Data processor and downloader for Pastebin content.
    ''' </summary>
    ''' <returns>True if no errors occurred.</returns>
    Private Function ProcessPastebin() As Boolean
        Dim WebClient As New WebClient()

        ' Get the keywords for this data source using the ID passed in at instantiation
        Dim Keywords() As String = pDatabase.GetKeywords(pDataSourceID)

        ' Attempt to get the latest pastes. Exceptions should be transient so if they or Please Slow Down messages
        ' happen just try again in a minute. 
        Dim Response As String = ""
        While Response = "" Or Response.Contains(SlowPasteRequestMessage)
            Try
                Response = WebClient.DownloadString(PasteBinSearchURL)
            Catch ex As Exception
                Call Thread.Sleep(ScrapeAttemptTime)
                Response = ""
            End Try
        End While

        ' Turn the received bytes into a stream and use the JSON processor (and PasteBinEntry class) to deserialize
        Dim ResponseStream As New MemoryStream(UTF8Encoding.UTF8.GetBytes(Response))
        Dim PastebinEntrySerializer As New DataContractJsonSerializer(GetType(PastebinEntry()))
        Dim ResponseArray() As PastebinEntry = Nothing
        Try
            ResponseArray = PastebinEntrySerializer.ReadObject(ResponseStream)
        Catch ex As Exception
            ' If a serialization exception happens it's very likely you didn't properly whitelist your IP address or something
            ' in the scraping API has changed. Check the output in the Event Log.
            Call EventLog.WriteEntry("CraalService", "Serialization Failure: " & ex.Message & vbCrLf & vbCrLf & Response, EventLogEntryType.Error)
        End Try

        If Not ResponseArray Is Nothing Then
            For i = 0 To ResponseArray.Count - 1
                ' Deduplicate results
                If Not pDatabase.PreviousMatch(ResponseArray(i).key) Then
                    Dim MatchingKeywords As String = ""

                    ' As above, watch for exceptions or requests to slow down
                    Dim ContentString As String = ""
                    While ContentString = "" Or ContentString.Contains(SlowPasteRequestMessage)
                        Try
                            ContentString = WebClient.DownloadString(ResponseArray(i).scrape_url)
                        Catch ex As Exception
                            Call Thread.Sleep(ScrapeAttemptTime)
                            ContentString = ""
                        End Try
                    End While

                    ' Check to see whether new pastes match any keywords
                    For j = 0 To Keywords.Count - 1
                        If ContentString.ToLower.Contains(Keywords(j).ToLower) Then
                            If MatchingKeywords = "" Then
                                MatchingKeywords = Keywords(j)
                            Else
                                MatchingKeywords &= ", " & Keywords(j)
                            End If
                        End If
                    Next

                    ' Insert the content into the database if there are any matches
                    If MatchingKeywords <> "" Then
                        Dim ContentItem As New ContentItem
                        ContentItem.CollectedTime = Now
                        ContentItem.DataSource = pDataSourceID
                        ContentItem.Keywords = MatchingKeywords
                        ContentItem.Hash = ResponseArray(i).key
                        ContentItem.SourceURL = ResponseArray(i).full_url
                        ContentItem.Data = UTF8Encoding.UTF8.GetBytes(ContentString)

                        Call pDatabase.InsertContent(ContentItem)
                    End If
                End If
            Next
        End If

        Return True
    End Function
End Class
