''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           CraalService.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Initializes and terminates all of the connections, data processors, and
''                  other processes depending on commands from the Service Manager.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports CraalDatabase
Imports System.ServiceProcess
Imports System.Collections.ObjectModel
Public Class CraalService

    Inherits ServiceBase

    ' Used to get the list of data sources
    Private pDatabase As Database = Nothing

    ' The list of data sources
    Private pDataSources As New Collection(Of Database.DataSource)

    ' Data source processors
    Private pPasteBin As PasteBinProcessor
    Private pGitHub As GitHubProcessor
    Private pAmazonS3 As AmazonS3Processor
    Private pProtoxin As ProtoxinProcessor
    Private pCertStream As CertStreamProcessor
    Private pDownload As DownloadProcessor

    Protected Overrides Sub OnStart(ByVal args() As String)
        ' Wait 10 seconds before doing anything to allow debuggers to attach to the service
        Threading.Thread.Sleep(10000)

        Dim StartedProcessors As Integer = 0

        ' Get the list of data sources and attempt to instantiate their processors if configured to 
        ' do so, passing the ID they'll use to correllate stored results. Instantiating the classes is
        ' enough to test for activation and write Event Logs later.
        Try
            pDatabase = New Database(Settings.DatabaseConnectionString)
            pDataSources = pDatabase.GetDataSources()
        Catch ex As Exception
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service could not open a connection to the SQL Server or enumerate data sources. The service will stop now.", EventLogEntryType.Error)
            Call Me.Stop()
        End Try

        For i = 0 To pDataSources.Count - 1
            Select Case pDataSources(i).Name.ToLower
                Case "pastebin"
                    If Settings.StartPasteBinProcessor Then
                        pPasteBin = New PasteBinProcessor(pDataSources(i).ID)
                    End If
                Case "github"
                    If Settings.StartGitHubProcessor Then
                        pGitHub = New GitHubProcessor(pDataSources(i).ID)
                    End If
                Case "amazon s3 bucket"
                    If Settings.StartAmazonS3Processor Then
                        pAmazonS3 = New AmazonS3Processor(pDataSources(i).ID)
                    End If
            End Select
        Next

        If Settings.StartProtoxinProcessor Then
            pProtoxin = New ProtoxinProcessor
        End If

        If Settings.StartCertStreamProcessor Then
            pCertStream = New CertStreamProcessor
        End If

        If Settings.StartDownloadProcessor Then
            pDownload = New DownloadProcessor
        End If

        ' Start the PasteBin processor
        If Not pPasteBin Is Nothing Then
            Call pPasteBin.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the PasteBin processor.", EventLogEntryType.Information)
        End If

        ' Start the GitHub processor
        If Not pGitHub Is Nothing Then
            Call pGitHub.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the GitHub processor.", EventLogEntryType.Information)
        End If

        ' Start the Amazon S3 processor
        If Not pAmazonS3 Is Nothing Then
            Call pAmazonS3.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the S3 Bucket processor.", EventLogEntryType.Information)
        End If

        ' Start the Protoxin processor
        If Not pProtoxin Is Nothing Then
            Call pProtoxin.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the Protoxin processor.", EventLogEntryType.Information)
        End If

        ' Start the CertStream processor
        If Not pCertStream Is Nothing Then
            Call pCertStream.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the CertStream processor.", EventLogEntryType.Information)
        End If

        ' Start the Download processor
        If Not pDownload Is Nothing Then
            Call pDownload.StartProcessing()
            StartedProcessors += 1
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started the Download processor.", EventLogEntryType.Information)
        End If

        Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has started. " & StartedProcessors & " data processors loaded.", EventLogEntryType.Information)
    End Sub

    Protected Overrides Sub OnStop()
        ' Stop PasteBin processing
        If Not pPasteBin Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the PasteBin processor.", EventLogEntryType.Information)
            Call pPasteBin.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the PasteBin processor.", EventLogEntryType.Information)
        End If

        ' Stop GitHub processing
        If Not pGitHub Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the GitHub processor.", EventLogEntryType.Information)
            Call pGitHub.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the GitHub processor.", EventLogEntryType.Information)
        End If

        ' Stop Amazon S3 processing
        If Not pAmazonS3 Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the Amazon S3 processor.", EventLogEntryType.Information)
            Call pAmazonS3.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the Amazon S3 processor.", EventLogEntryType.Information)
        End If

        ' Stop Protoxin processing
        If Not pProtoxin Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the Protoxin processor.", EventLogEntryType.Information)
            Call pProtoxin.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the Protoxin processor.", EventLogEntryType.Information)
        End If

        ' Stop CertStream processing
        If Not pCertStream Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the CertStream processor.", EventLogEntryType.Information)
            Call pCertStream.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the CertStream processor.", EventLogEntryType.Information)
        End If

        ' Stop Download processing
        If Not pDownload Is Nothing Then
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service is stopping the Download processor.", EventLogEntryType.Information)
            Call pDownload.StopProcessing()
            Call EventLog.WriteEntry(Me.ServiceName, "The Craal Service has stopped the Download processor.", EventLogEntryType.Information)
        End If
    End Sub

End Class
