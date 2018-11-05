''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           GitHubProcessor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Runs a thread that searches GitHub commits using the keywords identified 
''                  by the user and adds matching files to the list of pending downloads.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports System.Net
Imports System.Text
Imports CraalDatabase
Imports System.Threading
Imports CraalDatabase.Database
Imports System.Runtime.Serialization
Imports System.Runtime.Serialization.Json

''' <summary>
''' These classes are incomplete representations of the JSON returned by GitHub's endpoints. Only the members
''' required to do the processing are included.
''' </summary>
<DataContract> Class GitHubSearchResult
    <DataMember> Public total_count As Integer
    <DataMember> Public items() As GitHubEntry
    <DataMember> Public files() As GitHubFileEntry
End Class

<DataContract> Class GitHubEntry
    <DataMember> Public sha As String
    <DataMember> Public html_url As String
    <DataMember> Public author As GitHubAuthorEntry
    <DataMember> Public repository As GitHubRepositoryEntry
End Class

<DataContract> Class GitHubFileEntry
    <DataMember> Public filename As String
    <DataMember> Public raw_url As String
End Class

<DataContract> Class GitHubAuthorEntry
    <DataMember> Public login As String
End Class

<DataContract> Class GitHubRepositoryEntry
    <DataMember> Public id As String
    <DataMember> Public name As String
    <DataMember> Public full_name As String
End Class

Public Class GitHubProcessor
    ' The database object used to store results
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The data source ID corresponding to GitHub content
    Private pDataSourceID As Integer

    ' The processing thread object, stop , and stopped signals
    Private pProcessingThread As Thread
    Private pStopProcessing As Boolean = False
    Private pStoppedProcessing As Boolean = False

    ' The personal token assigned by GitHub used to (slightly) raise the search API limits
    Private pGitHubToken As String = Settings.GitHubToken

    ' The user agent for the search process
    Private pGitHubUserAgent As String = Settings.GitHubUserAgent

    ' The URL used to search by keyword
    Private Const GitHubSearchURL As String = "https://api.GitHub.com/search/commits?q="

    ' The URL used to download content from search results
    Private Const GitHubRepoURL As String = "https://api.GitHub.com/repos/"

    ' The accept token required by GitHub's endpoints
    Private Const GitHubAcceptHeader As String = "application/vnd.GitHub.cloak-preview"

    ' The delay between search runs
    Private Const NextRunTime As Integer = 300

    ''' <summary>
    ''' Creates an instance of the class.
    ''' </summary>
    ''' <param name="DataSourceID">Used to find the keywords associated with the search process and marked on stored results</param>
    Sub New(ByVal DataSourceID As Integer)
        ' Record the data source ID
        pDataSourceID = DataSourceID
    End Sub

    ''' <summary>
    ''' Starts the processing and download threads.
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
            ' Search GitHub for keywords
            Call ProcessGitHub()

            ' Sleep for the next five minutes, checking every quarter second to see whether
            ' we're supposed to stop.
            NextExecution = Now.AddSeconds(NextRunTime)
            While (Now < NextExecution) And Not pStopProcessing
                Call Thread.Sleep(250)
            End While
        End While

        ' Processing has stopped
        pStoppedProcessing = True
    End Sub

    ''' <summary>
    ''' This thread searches GitHub based on the keywords in the database. It adds files that need to be downloaded
    ''' to the table of things to download.
    ''' </summary>
    ''' <returns>True if no errors occur, False otherwise.</returns>
    Private Function ProcessGitHub() As Boolean
        ' Get the keywords to search for
        Dim Keywords() As String = pDatabase.GetKeywords(pDataSourceID)
        For i = 0 To Keywords.Count - 1
            ' Stop this process if told to do so
            If pStopProcessing Then
                Exit For
            End If

            ' Get the search results for the current keyword
            Dim GitHubSearchResults As GitHubSearchResult = DownloadGitHubData(GitHubSearchURL & WebUtility.UrlEncode(Keywords(i)))
            If Not GitHubSearchResults Is Nothing Then
                For j = 0 To GitHubSearchResults.items.Count - 1
                    ' Deduplicate results across this and all other keywords
                    If Not pDatabase.PreviousMatch(GitHubSearchResults.items(j).sha) Then
                        ' Get the common properties across all changed files for the found item
                        Dim ContentItem As New ContentItem
                        ContentItem.CollectedTime = Now
                        ContentItem.DataSource = pDataSourceID
                        ContentItem.Keywords = Keywords(i)
                        ContentItem.Hash = GitHubSearchResults.items(j).sha
                        ContentItem.SourceURL = GitHubSearchResults.items(j).html_url
                        ContentItem.Data = UTF8Encoding.UTF8.GetBytes(ContentItem.SourceURL)

                        ' Write the file to download into the PendingDownloads table for processing by the other thread later
                        Call pDatabase.InsertPendingDownload(ContentItem.SourceURL, ContentItem.Hash)

                        ' Insert the committed file into the database with place holder data that the other thread will
                        ' come along and update with actual content
                        Call pDatabase.InsertContent(ContentItem)

                        ' Get the commit data for this result
                        'Dim GitHubCommitData As GitHubSearchResult = DownloadGitHubData(GitHubRepoURL & GitHubSearchResults.items(j).repository.full_name & "/commits/" & GitHubSearchResults.items(j).sha)
                        'If Not GitHubCommitData Is Nothing Then
                        '    For k = 0 To GitHubCommitData.files.Count - 1
                        '        ' Copy the common properties from the commit to the committed file
                        '        Dim CommittedFile As ContentItem = ContentItem
                        '        If Not GitHubCommitData.files(k).raw_url Is Nothing Then
                        '            ' Copy the raw URL into the source URL and the data field as a place holder
                        '            CommittedFile.SourceURL = GitHubCommitData.files(k).raw_url
                        '            CommittedFile.Data = UTF8Encoding.UTF8.GetBytes(CommittedFile.SourceURL)

                        '            ' Write the file to download into the PendingDownloads table for processing by the other thread later
                        '            Call pDatabase.InsertPendingDownload(CommittedFile.SourceURL, CommittedFile.Hash)
                        '        Else
                        '            ' For some reason the URL for this file was blank so put the URL from the commit into the data
                        '            CommittedFile.Data = UTF8Encoding.UTF8.GetBytes(CommittedFile.SourceURL)
                        '        End If

                        '        ' Insert the committed file into the database with place holder data that the other thread will
                        '        ' come along and update with actual content
                        '        Call pDatabase.InsertContent(CommittedFile)
                        '    Next
                        'End If
                    End If
                Next
            End If
        Next

        Return True
    End Function

    ''' <summary>
    ''' Does the search for GitHub data and returns the results as an array of GitHubSearchResults.
    ''' </summary>
    ''' <param name="URL">The URL used to search, including URL-encoded keywords</param>
    ''' <returns>An array of GitHubSearchResults, or Nothing on failure</returns>
    Private Function DownloadGitHubData(ByVal URL As String) As GitHubSearchResult
        Dim QuerySuccess As Boolean = False
        Dim ResponseStream As Stream = Nothing

        ' Attempt this operation until serialization works or told to stop
        While Not pStopProcessing
            ' Attempt this download until it works or told to stop processing
            While (Not QuerySuccess) And (Not pStopProcessing)
                Try
                    ' Formulate the request and attach the relevant headers
                    Dim GitHubRequest As HttpWebRequest = HttpWebRequest.Create(URL)
                    Call GitHubRequest.Headers.Add("Authorization", "token " & pGitHubToken)
                    GitHubRequest.Accept = GitHubAcceptHeader
                    GitHubRequest.UserAgent = pGitHubUserAgent

                    ' Make the search request and get the response stream
                    Dim SearchRequest As HttpWebResponse = GitHubRequest.GetResponse()
                    ResponseStream = SearchRequest.GetResponseStream()
                    QuerySuccess = True
                Catch ex As WebException
                    ' If there's no response in the exception then just try again
                    If Not ex.Response Is Nothing Then
                        If DirectCast(ex.Response, HttpWebResponse).StatusCode = 403 Then
                            ' The 403 response code is a backoff error. The X-RateLimit-Reset header is the Unix
                            ' Epoch time at which you get more searches. Calculate that time plus one second,
                            ' sleep for that amount of time, and try again
                            Dim RateResetSeconds As Double = ex.Response.Headers.Get("X-RateLimit-Reset")
                            Dim RateResetTime As DateTime = New DateTime(1970, 1, 1).AddSeconds(RateResetSeconds + 1)
                            Dim WaitSeconds As TimeSpan = RateResetTime - (Now.ToUniversalTime)

                            ' Occasionally the calculated time is slightly less than zero. If that happens just try
                            ' again and the next request will be told to back off as well, but that calculation should
                            ' make more sense.
                            If WaitSeconds >= New TimeSpan(0) Then
                                Call Threading.Thread.Sleep(WaitSeconds.TotalMilliseconds)
                            End If
                        End If
                    End If
                End Try
            End While

            If Not ResponseStream Is Nothing Then
                Dim GitHubSearchResultSerializer As New DataContractJsonSerializer(GetType(GitHubSearchResult))
                Try
                    ' Attempt to return the serialized results. Sometimes the stream is broken so serialization 
                    ' doesn't work, so just restart the process to get a proper download and then try to serialize again.
                    Return GitHubSearchResultSerializer.ReadObject(ResponseStream)
                Catch ex As Exception
                    QuerySuccess = False
                End Try
            End If
        End While

        Return Nothing
    End Function
End Class
