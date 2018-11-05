''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           Settings.vb
''  Author:         Jay Lagorio
''  Date:           November 4, 2018
''  Description:    Makes the settings in config.json accessible to the rest of the application.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.IO
Imports System.Runtime.Serialization.Json
Imports System.Runtime.Serialization

Public Class Settings
    ' Indicates whether settings have been loaded from config.json
    Private Shared pLoaded As Boolean = False

    ' Stores the settings loaded from config.json
    Private Shared pSettingsEntries As pSettingsObject = Nothing

    ' A structure representing the config.json file, marked up for easy JSON processing.
    <DataContract> Private Structure pSettingsObject
        ' Controls whether to start the PasteBin data processor
        <DataMember(EmitDefaultValue:=True)> Public Property StartPasteBinProcessor As Boolean
        ' Controls whether to start the GitHub data processor
        <DataMember(EmitDefaultValue:=True)> Public Property StartGitHubProcessor As Boolean
        ' Controls whether to start the Protoxin data processor
        <DataMember(EmitDefaultValue:=True)> Public Property StartProtoxinProcessor As Boolean
        ' Controls whether to start the CertStream data processor
        <DataMember(EmitDefaultValue:=True)> Public Property StartCertStreamProcessor As Boolean
        ' Controls whether to start the Amazon S3 data processor
        <DataMember(EmitDefaultValue:=True)> Public Property StartAmazonS3Processor As Boolean
        ' Controls whether to start the data downloader
        <DataMember(EmitDefaultValue:=True)> Public Property StartDownloadProcessor As Boolean
        ' The connection string to the SQL database
        <DataMember(EmitDefaultValue:=True)> Public Property DatabaseConnectionString As String
        ' The token assigned by GitHub to allow querying their API
        <DataMember(EmitDefaultValue:=True)> Public Property GitHubToken As String
        ' The user agent string querying the GitHub API
        <DataMember(EmitDefaultValue:=True)> Public Property GitHubUserAgent As String
        ' An Amazon AWS Access Key used to validate whether Authenticated Users can access a Bucket
        <DataMember(EmitDefaultValue:=True)> Public Property GenericAWSAccessKey As String
        ' An Amazon AWS Secret Key used to validate whether Authenticated Users can access a Bucket
        <DataMember(EmitDefaultValue:=True)> Public Property GenericAWSSecretKey As String
    End Structure

    ''' <summary>
    ''' Loads the settings from the config.json file located in the same directory as the service executable.
    ''' </summary>
    Private Shared Sub LoadSettings()
        If pLoaded Then Exit Sub

        Dim EntrySerializer As New DataContractJsonSerializer(GetType(pSettingsObject))
        Dim JsonStream As FileStream = Nothing

        Try
            JsonStream = New FileStream(AppDomain.CurrentDomain.BaseDirectory & "\config.json", FileMode.Open)
            pSettingsEntries = EntrySerializer.ReadObject(JsonStream)
        Catch ex As Exception
            pSettingsEntries = New pSettingsObject
        End Try

        If Not JsonStream Is Nothing Then
            Call JsonStream.Close()
        End If

        pLoaded = True
    End Sub

    ''' <summary>
    ''' Dictates whether to start the PasteBin data processor.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartPasteBinProcessor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartPasteBinProcessor
        End Get
    End Property

    ''' <summary>
    ''' Dictates whether to start the GitHub data processor.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartGitHubProcessor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartGitHubProcessor
        End Get
    End Property

    ''' <summary>
    ''' Dictates whether to start the Protoxin data processor.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartProtoxinProcessor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartProtoxinProcessor
        End Get
    End Property

    ''' <summary>
    ''' Dictates whether to start the CertStream data processor.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartCertStreamProcessor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartCertStreamProcessor
        End Get
    End Property

    ''' <summary>
    ''' Dictates whether to start the Amazon S3 data processor.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartAmazonS3Processor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartAmazonS3Processor
        End Get
    End Property

    ''' <summary>
    ''' Dictates whether to start the data downloader.
    ''' </summary>
    ''' <returns>True if it should start, False otherwise.</returns>
    Public Shared ReadOnly Property StartDownloadProcessor As Boolean
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.StartDownloadProcessor
        End Get
    End Property

    ''' <summary>
    ''' The database connection string to connect to the SQL Server.
    ''' </summary>
    ''' <returns>A string used to connect to the database.</returns>
    Public Shared ReadOnly Property DatabaseConnectionString As String
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.DatabaseConnectionString
        End Get
    End Property

    ''' <summary>
    ''' An Amazon AWS Access Key used to test for insecure S3 Buckets.
    ''' </summary>
    ''' <returns>The Access Key as a string.</returns>
    Public Shared ReadOnly Property GenericAWSAccessKey As String
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.GenericAWSAccessKey
        End Get
    End Property

    ''' <summary>
    ''' An Amazon AWS Secret Key used to test for insecure S3 Buckets.
    ''' </summary>
    ''' <returns>The Secret Key as a string.</returns>
    Public Shared ReadOnly Property GenericAWSSecretKey As String
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.GenericAWSSecretKey
        End Get
    End Property

    ''' <summary>
    ''' A GitHub API token used to query the API.
    ''' </summary>
    ''' <returns>The API Key as a string.</returns>
    Public Shared ReadOnly Property GitHubToken As String
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.GitHubToken
        End Get
    End Property

    ''' <summary>
    ''' The user agent used to query the GitHub API.
    ''' </summary>
    ''' <returns>The user agent sent to the GitHub API.</returns>
    Public Shared ReadOnly Property GitHubUserAgent As String
        Get
            If Not pLoaded Then Call LoadSettings()

            Return pSettingsEntries.GitHubUserAgent
        End Get
    End Property
End Class
