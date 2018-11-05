''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           DownloadProcessor.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Runs a thread that periodically checks the PendingDownloads database table
''                  and downloads the files located there.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports System.Net
Imports CraalDatabase
Imports System.Threading
Imports CraalDatabase.Database
Imports System.Collections.ObjectModel

Public Class DownloadProcessor
    ' The database object used to store results
    Private pDatabase As New Database(Settings.DatabaseConnectionString)

    ' The download thread object, stop , and stopped signals
    Private pDownloadingThread As Thread
    Private pStopDownloading As Boolean = False
    Private pStoppedDownloading As Boolean = False

    ' The delay between download runs
    Private Const NextRunTime As Integer = 300

    ''' <summary>
    ''' Starts the download thread.
    ''' </summary>
    Public Sub StartProcessing()
        ' Create the downloading thread if it doesn't already exist
        If pDownloadingThread Is Nothing Then
            pDownloadingThread = New Thread(AddressOf DownloadingThread)
        End If

        ' Start the downloading thread if its not already running
        If pDownloadingThread.ThreadState <> ThreadState.Running Then
            Call pDownloadingThread.Start()
        End If
    End Sub

    ''' <summary>
    ''' Stops the download thread. This call blocks until the thread is stopped.
    ''' </summary>
    Public Sub StopProcessing()
        ' Check to see whether the download thread exists
        If Not pDownloadingThread Is Nothing Then
            ' If the thread is running, stop it
            If pDownloadingThread.ThreadState = ThreadState.Running Then
                pStopDownloading = True
                While Not pStoppedDownloading
                    Call Thread.Yield()
                    Call Thread.Sleep(50)
                End While

                ' Destroy the thread
                Call pDownloadingThread.Abort()
                pDownloadingThread = Nothing
            End If
        End If
    End Sub

    ''' <summary>
    ''' This thread checks the PendingDownloads table and downloads any files found. The raw content from those
    ''' files are updated in the content table under the entry for the file to download.
    ''' </summary>
    Private Sub DownloadingThread()
        Dim Database As New Database(Settings.DatabaseConnectionString)
        Dim NextExecution As DateTime = Now

        ' Do the following until told to stop
        While Not pStopDownloading
            ' Get the list of all pending downloads from the database
            Dim Downloads As Collection(Of ContentItem) = Database.GetPendingDownloads()

            ' Check to see whether the list is empty or whether we should stop downloading
            While (Not Downloads Is Nothing) And Not pStopDownloading
                For i = 0 To Downloads.Count - 1
                    ' If we're supposed to stop then get out of this loop
                    If pStopDownloading Then
                        Exit For
                    End If

                    ' Download the file data, update the database, and upon successful download and
                    ' update delete the record of the file to download
                    If Database.UpdateContent(Downloads(i).SourceURL, Downloads(i).Hash, DownloadFileData(Downloads(i).SourceURL)) Then
                        Call Database.DeletePendingDownload(Downloads(i).SourceURL)
                    End If

                    ' Stop downloading after this file if asked
                    If pStopDownloading Then
                        Exit For
                    End If
                Next

                ' All of the downloads from the previous retrieval were fetched, see if there are more waiting or
                ' if we Then should wait For more downloads to appear
                Downloads = Database.GetPendingDownloads()
            End While

            ' Wait for five minutes to run the loop again, checking whether
            ' the thread needs to stop every quarter second
            NextExecution = Now.AddSeconds(NextRunTime)
            While (Now < NextExecution) And Not pStopDownloading
                Call Thread.Sleep(250)
            End While
        End While

        ' The thread has stopped
        pStoppedDownloading = True
    End Sub

    ''' <summary>
    ''' Downloads data from the passed URL and returns it as an array of Bytes.
    ''' </summary>
    ''' <param name="URL">The URL to download</param>
    ''' <returns>An array of Bytes representing the file, or Nothing on failure.</returns>
    Private Function DownloadFileData(ByVal URL As String) As Byte()
        Dim QuerySuccess As Boolean = False
        Dim Data As MemoryStream = Nothing

        ' Attempt to download this file until successful or told to stop
        While Not QuerySuccess And Not pStopDownloading
            Try
                ' Attempt to download the file
                Data = New MemoryStream((New WebClient).DownloadData(URL))
                QuerySuccess = True
            Catch ex As WebException
                ' If there's no response then something weird happened - try again immediately
                If Not ex.Response Is Nothing Then
                    If DirectCast(ex.Response, HttpWebResponse).StatusCode = 429 Then
                        ' If the response code is 429 there's a Retry-After header. Sleep for that number of seconds
                        ' and then try to get the file again.
                        Call Threading.Thread.Sleep((ex.Response.Headers.Item("Retry-After") + 1) * 1000)
                    ElseIf DirectCast(ex.Response, HttpWebResponse).StatusCode = 404 Then
                        ' If the response code is 404 then the file is gone, but that's not the same as encounter a
                        ' problem downloading the file. We'll just quit here.
                        QuerySuccess = True
                    End If
                End If
            End Try
        End While

        ' If the file was downloaded copy it  out of the memory stream and return the bytes.
        If Not Data Is Nothing Then
            Dim DataBytes(Data.Length - 1) As Byte
            Call Data.Read(DataBytes, 0, Data.Length)
            Return DataBytes
        End If

        ' The file wasn't downloaded for some reason.
        Return Nothing
    End Function
End Class
