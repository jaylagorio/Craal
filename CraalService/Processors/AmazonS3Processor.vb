''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           AmazonS3Processor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Handles indexing, processing, and queuing for download files from Amazon
''                  S3 Buckets.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports Amazon.S3
Imports CraalDatabase
Imports Amazon.S3.Model
Imports System.Threading
Imports CraalDatabase.Database
Imports System.Collections.ObjectModel

Public Class AmazonS3Processor
    ' The database object used to store results
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The data source ID corresponding to S3 Bucket content
    Private pDataSourceID As Integer

    ' The processing thread object, stop, and stopped signals
    Private pProcessingThread As Thread
    Private pStopProcessing As Boolean = False
    Private pStoppedProcessing As Boolean = False

    ' Amazon AWS key pair created to test against non-specific Authenticated Users being allowed to access Buckets.
    Private pGenericAWSAccessKey As String = Settings.GenericAWSAccessKey
    Private pGenericAWSSecretKey As String = Settings.GenericAWSSecretKey

    ' The delay between search and download run
    Private Const NextRunTime As Integer = 300

    ''' <summary>
    ''' Creates an instance of the class.
    ''' </summary>
    ''' <param name="DataSourceID">Used to find the keywords associated with the search process and marked on stored results.</param>
    Sub New(ByVal DataSourceID As Integer)
        ' Record the data source ID
        pDataSourceID = DataSourceID
    End Sub

    ''' <summary>
    ''' Starts the processing and download threads.
    ''' </summary>
    Public Sub StartProcessing()
        ' Create the search thread if it doesn't already exist
        If pProcessingThread Is Nothing Then
            pProcessingThread = New Thread(AddressOf ProcessingThread)
        End If

        ' Start the search thread if it's not already running
        If pProcessingThread.ThreadState <> ThreadState.Running Then
            Call pProcessingThread.Start()
        End If
    End Sub

    ''' <summary>
    ''' Stops the processing thread. This call blocks until the thread is stopped.
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
            Call ProcessAmazonS3Buckets()

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
    ''' This thread dumps Amazon S3 Buckets that are in the table of Buckets to retrieve. It adds files that
    ''' need to be downloaded to the table of things to download.
    ''' </summary>
    ''' <returns>True if no errors occur, False otherwise.</returns>
    Private Function ProcessAmazonS3Buckets() As Boolean
        ' See if any automated processes have located Buckets and add them to the pending download list
        Dim DiscoveredBuckets As Collection(Of Database.StorageContainer) = pDatabase.GetDiscoveredContainers(True)
        Call EventLog.WriteEntry("CraalService", "New Discovered Buckets: " & DiscoveredBuckets.Count, EventLogEntryType.Information)
        For i = 0 To DiscoveredBuckets.Count - 1
            If pDatabase.InsertPendingContainer(DiscoveredBuckets(i).ContainerName, DiscoveredBuckets(i).AccessKey, DiscoveredBuckets(i).SecretKey, ContainerType.S3Bucket) Then
                If Not pDatabase.MarkDiscoveredContainerQueued(DiscoveredBuckets(i).ContainerName, ContainerType.S3Bucket) Then
                    Call EventLog.WriteEntry("CraalService", "Couldn't mark discovered bucket queued", EventLogEntryType.Information)
                    Return False
                End If
            Else
                Call EventLog.WriteEntry("CraalService", "Couldn't pend the discovered bucket", EventLogEntryType.Information)
                Return False
            End If
        Next

        ' Get the full pending download list
        Dim Buckets As Collection(Of Database.StorageContainer) = pDatabase.GetPendingContainers()

        For i = 0 To Buckets.Count - 1
            ' Stop this process if told to do so
            If pStopProcessing Then
                Exit For
            End If

            Dim S3ListRequest As New ListObjectsRequest
            Dim S3ListResponse As ListObjectsResponse
            Dim S3Client As AmazonS3Client
            Dim BucketWasDumped As Boolean

            ' Set up the request to get the contents of the Bucket. If this succeeds, the Bucket is likely unprotected.
            S3ListRequest.BucketName = Buckets(i).ContainerName

            ' If we have creds for this Bucket in particular, attempt to dump the bucket with these keys
            If Buckets(i).AccessKey <> "" And Buckets(i).SecretKey <> "" Then
                S3Client = New AmazonS3Client(New Amazon.Runtime.BasicAWSCredentials(Buckets(i).AccessKey, Buckets(i).SecretKey), Amazon.RegionEndpoint.USEast1)
                S3ListResponse = S3Client.ListObjects(S3ListRequest)
                If S3ListResponse.HttpStatusCode = 200 Then
                    BucketWasDumped = DumpBucket(S3Client, S3ListRequest, S3ListResponse)
                End If
            End If

            ' If we didn't dump the Bucket with the creds we had for it (if we had any) they may have been rotated. That
            ' doesn't mean the Bucket isn't poorly secured, the owner may allow all Authenticated Users to read the Bucket
            ' but those old credentials aren't valid. Use the provided credentials here.
            If Not BucketWasDumped Then
                S3Client = New AmazonS3Client(New Amazon.Runtime.BasicAWSCredentials(pGenericAWSAccessKey, pGenericAWSSecretKey), Amazon.RegionEndpoint.USEast1)
                Try
                    S3ListResponse = S3Client.ListObjects(S3ListRequest)
                Catch ex As Exception
                    ' Forbidden responses cause an exception to be raised for some reason.
                    S3ListResponse = Nothing
                End Try
                If Not S3ListResponse Is Nothing Then
                    If S3ListResponse.HttpStatusCode = 200 Then
                        BucketWasDumped = DumpBucket(S3Client, S3ListRequest, S3ListResponse)
                    End If
                End If
            End If

            ' Last chance - try to dump the Bucket anonymously.
            If Not BucketWasDumped Then
                S3Client = New AmazonS3Client(New Amazon.Runtime.AnonymousAWSCredentials(), Amazon.RegionEndpoint.USEast1)
                Try
                    S3ListResponse = S3Client.ListObjects(S3ListRequest)
                Catch ex As Exception
                    ' Forbidden responses cause an exception to be raised for some reason.
                    S3ListResponse = Nothing
                End Try
                If Not S3ListResponse Is Nothing Then
                    If S3ListResponse.HttpStatusCode = 200 Then
                        BucketWasDumped = DumpBucket(S3Client, S3ListRequest, S3ListResponse)
                    End If
                End If
            End If

            ' Delete the Bucket from the list of Buckets to download but only if it was successfully
            ' dumped. If you get something like a 403 error keep the Bucket in the list just in case
            ' it becomes public later.
            If BucketWasDumped Then
                Call pDatabase.DeletePendingContainer(Buckets(i).ContainerName, ContainerType.S3Bucket)
            End If
        Next

        Return True
    End Function

    ''' <summary>
    ''' Attempts to dump a Bucket using the provided S3Client, checking against the Keywords assigned to the data source.
    ''' </summary>
    ''' <param name="S3Client">An S3Client with or without authentication tokens.</param>
    ''' <param name="S3ListRequest">An S3ListRequest, containing the Bucket name, used to make the initial request.</param>
    ''' <param name="S3ListResponse">The S3ListRequest from the initial request.</param>
    ''' <returns>True if the Bucket was accessible and was dumped, False otherwise.</returns>
    Private Function DumpBucket(S3Client As AmazonS3Client, S3ListRequest As ListObjectsRequest, S3ListResponse As ListObjectsResponse) As Boolean
        ' The keywords in this case are file names of interest (including wildcards)
        Dim Keywords() As String = pDatabase.GetKeywords(pDataSourceID)

        While S3ListResponse.HttpStatusCode = 200
            Dim LastKeyFound As String = ""
            For j = 0 To S3ListResponse.S3Objects.Count - 1
                For k = 0 To Keywords.Count - 1
                    If (S3ListResponse.S3Objects(j).Key <> "") And (S3ListResponse.S3Objects(j).Key Like Keywords(k)) Then
                        ' Deduplicate results across this and all other keywords
                        If Not pDatabase.PreviousMatch(S3ListResponse.S3Objects(j).ETag) Then
                            LastKeyFound = S3ListResponse.S3Objects(j).Key

                            ' Get the common properties across all changed files for the found item
                            Dim ContentItem As New ContentItem
                            ContentItem.CollectedTime = Now
                            ContentItem.DataSource = pDataSourceID
                            ContentItem.Keywords = Keywords(k)
                            ContentItem.Hash = S3ListResponse.S3Objects(j).ETag
                            ContentItem.SourceURL = "http://" & S3ListRequest.BucketName & ".s3.amazonaws.com/" & S3ListResponse.S3Objects(j).Key
                            ContentItem.Data = Text.UTF8Encoding.UTF8.GetBytes(ContentItem.SourceURL)

                            ' Insert the committed file into the database with place holder data that the other thread will
                            ' come along and update with actual content
                            Call pDatabase.InsertContent(ContentItem)

                            ' The database field limit is 2 GB so if the file is smaller than that queue it for download
                            If S3ListResponse.S3Objects(j).Size < 2147483648 Then
                                ' Put the URL and hash in the table to be picked up by the download process later.
                                Call pDatabase.InsertPendingDownload(ContentItem.SourceURL, ContentItem.Hash)
                            End If
                        End If
                    End If
                Next
            Next

            ' If there were more items in the Bucket than were downloaded this time rerun the request
            ' with the marker to pick up where we left off
            If S3ListResponse.IsTruncated Then
                S3ListRequest.Marker = LastKeyFound
                S3ListResponse = S3Client.ListObjects(S3ListRequest)
            End If

            Return True
        End While

        Return False
    End Function
End Class
