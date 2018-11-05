''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''  File:           Database.vb
''  Author:         Jay Lagorio
''  Date:           03NOV2018
''  Description:    Handles database interactions for client applications that consume this
''                  library.
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Imports System.Data.SqlClient
Imports System.Collections.ObjectModel

Public Class Database
    Public Enum ContainerType
        S3Bucket = 1
        AzureBlob = 2
        DigitalOceanSpace = 3
    End Enum

    ' Describes a datasource using the name and ID number from the DataSources table
    Public Structure DataSource
        Dim ID As Integer   ' ID of the data source
        Dim Name As String  ' Name of the data source
    End Structure

    ' Describes a container type with a name and ID from the ContainerTypes table
    Public Structure ContainerTypeData
        Dim ID As Integer   ' ID of the container type
        Dim Name As String  ' Name of the container type
    End Structure

    ' Describes an entry in the Content table from the SQL database
    Public Structure ContentItem
        Dim ID As Integer               ' ID of the content item
        Dim CollectedTime As DateTime   ' Time the item was added to the database
        Dim DataSource As Integer       ' The type of data source, mapped to the ID of the DataSources table
        Dim Keywords As String          ' Any keywords that were matched that caused the entry to be added
        Dim SourceURL As String         ' The URL the file was downloaded from
        Dim Hash As String              ' The unique ID of the file as presented by the source system (SHA1, Pastebin ID, etc)
        Dim Data() As Byte              ' The raw bytes that make up the content of the file that was downloaded
    End Structure

    ' Describes any storage containers (Buckets, Blobs, Spaces, etc) that are queued for download
    Public Structure StorageContainer
        Dim ContainerName As String         ' The name of the Bucket
        Dim AccessKey As String             ' The AWS Access Key needed to access the Bucket (optional)
        Dim SecretKey As String             ' The AWS Secret Key needed to access the Bucket (optional)
        Dim ContainerType As ContainerType  ' The index into the ContainerTypes array that has the name of the container type

        Shared Operator =(ByVal Item1 As StorageContainer, ByVal Item2 As StorageContainer) As Boolean
            If Item1.ContainerName = Item2.ContainerName Then
                If Item1.ContainerType = Item2.ContainerType Then
                    Return True
                End If
            End If

            Return False
        End Operator
        Shared Operator <>(ByVal Item1 As StorageContainer, ByVal Item2 As StorageContainer) As Boolean
            Return Not (Item1 = Item2)
        End Operator
        Public Overrides Function Equals(obj As Object) As Boolean
            If obj.ContainerName = ContainerName Then
                If obj.ContainerType = ContainerType Then
                    Return True
                End If
            End If

            Return False
        End Function
    End Structure

    ' Describes the size of a table in rows and as Kilobytes on disk
    Public Structure TableSizeStatistics
        Dim RowCount As Integer     ' The number of rows in the table
        Dim DataSize As String      ' The size of the data currently held, includes unit size
    End Structure

    ' The database connection string passed to the constructor, stored for later use
    Private pDatabaseConnectionString As String = ""

    ' The number of times to attempt to connect to the SQL Server before giving up
    Private Const DatabaseConnectionAttempts As Integer = 3

    ' A SQLConnection object local to this instance of the Database class
    Private pDatabase As New SqlConnection()

    ' Constants used to SELECT, DELETE, INSERT, and UPDATE the various tables maintaining the keywords, discovered data, queued downloads, and content.
    Private Const PendingDownloadSelectStatement As String = "SELECT * FROM PendingDownloads"
    Private Const PendingDownloadDeleteStatement As String = "DELETE FROM PendingDownloads WHERE SourceURL = @SourceURL"
    Private Const PendingDownloadInsertStatement As String = "INSERT INTO PendingDownloads (SourceURL, Hash) VALUES(@SourceURL, @Hash)"

    Private Const PendingContainersSelectStatement As String = "SELECT * FROM PendingContainers"
    Private Const PendingContainersDeleteStatement As String = "DELETE FROM PendingContainers WHERE ContainerName = @ContainerName AND ContainerType = @ContainerType"
    Private Const PendingContainersInsertStatement As String = "INSERT INTO PendingContainers (ContainerName, ContainerType) VALUES(@ContainerName, @ContainerType)"
    Private Const PendingContainersWithKeysInsertStatement As String = "INSERT INTO PendingContainer (ContainerName, AccessKey, SecretKey, ContainerType) VALUES(@ContainerName, @AccessKey, @SecretKey, @ContainerType)"

    Private Const DiscoveredContainersSelectStatement As String = "SELECT * FROM DiscoveredContainers"
    Private Const DiscoveredContainersSelectUncheckedStatement As String = "SELECT * FROM DiscoveredContainers WHERE (Queued IS NULL OR Queued = 0)"
    Private Const DiscoveredContainersSetQueuedUpdateStatement As String = "UPDATE DiscoveredContainers SET Queued = 1 WHERE ContainerName = @ContainerName AND ContainerType = @ContainerType"
    Private Const DiscoveredContainersInsertStatement As String = "INSERT INTO DiscoveredContainers (ContainerName, ContainerType) VALUES(@ContainerName, @ContainerType)"
    Private Const DiscoveredContainersWithKeysInsertStatement As String = "INSERT INTO DiscoveredContainers (ContainerName, AccessKey, SecretKey, ContainerType) VALUES(@ContainerName, @AccessKey, @SecretKey, @ContainerType)"

    Private Const ContentSelectStatement As String = "SELECT * FROM Content WHERE Hash = @Hash"
    Private Const ContentPreviousMatchSelectStatement As String = "SELECT Count(*) FROM Content WHERE Hash = @Hash"
    Private Const ContentInsertStatement As String = "INSERT INTO Content (CollectedTime, Keywords, DataSource, SourceURL, Hash, Data) VALUES(@CollectedTime, @Keywords, @DataSourceID, @SourceURL, @Hash, CONVERT(varbinary(MAX), @Data, 1))"
    Private Const ContentUpdateStatement As String = "UPDATE Content SET CollectedTime = @CollectedTime, Data = CONVERT(varbinary(MAX), @Data, 0) WHERE SourceURL = @SourceURL AND Hash = @Hash"
    Private Const ContentTableSize As String = "EXEC sp_spaceused N'Content'"

    Private Const ContainerTypesSelectStatement As String = "SELECT * FROM ContainerTypes"
    Private Const DataSourceSelectStatement As String = "SELECT * FROM DataSources"
    Private Const KeywordsSelectStatement As String = "SELECT * FROM Keywords WHERE DataSource = @DataSourceID"


    ''' <summary>
    ''' Creates a new instance of the Database object and automatically connects to the database.
    ''' </summary>
    Sub New(ByVal DatabaseConnectionString As String)
        pDatabaseConnectionString = DatabaseConnectionString
        ' Attempt to connect to the database, throw a generic exception if it fails.
        If Not ConnectDatabase() Then
            Throw New Exception
        End If
    End Sub

    ''' <summary>
    ''' Attempt to connect to the database if there isn't already an open connection.
    ''' </summary>
    ''' <returns>True if the connection is successful, False otherwise.</returns>
    Private Function ConnectDatabase() As Boolean
        ' Attempt to connect to the database until it works or the maximum attempts have happened
        For i = 0 To DatabaseConnectionAttempts - 1
            ' Only attempt to connect if the connection is broken or was never opened
            If pDatabase.State = ConnectionState.Broken Or pDatabase.State = ConnectionState.Closed Then
                Try
                    ' Create and open the connection
                    pDatabase = New SqlConnection(pDatabaseConnectionString)
                    Call pDatabase.Open()

                    ' If the call succeeded then we're done - exit the loop
                    Exit For
                Catch ex As Exception
                    ' Document the failure
                    Call EventLog.WriteEntry("CraalService", "Database Failure: " & ex.Message, EventLogEntryType.Error)
                End Try
            End If
        Next

        ' Return True if the connection isn't still broken or closed
        Return Not (pDatabase.State = ConnectionState.Broken Or pDatabase.State = ConnectionState.Closed)
    End Function

    ''' <summary>
    ''' Determines whether a file has been previously seen by comparing the passed hash to the Hash column of the Content database.
    ''' </summary>
    ''' <param name="Hash">A hash from one of the data sources</param>
    ''' <returns>True if the Hash appears in the Content table, False otherwise.</returns>
    Public Function PreviousMatch(ByVal Hash As String) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        If Hash Is Nothing Then
            Return False
        End If

        If Hash = "" Then
            Return False
        End If

        Dim SelectCommand As New SqlCommand(ContentPreviousMatchSelectStatement, pDatabase)
        Call SelectCommand.Parameters.Add(New SqlParameter("Hash", Hash))

        Return (SelectCommand.ExecuteScalar() > 0)
    End Function

    ''' <summary>
    ''' Returns a collection of DataSource objects built from the DataSources table.
    ''' </summary>
    ''' <returns>A Collection of DataSource objects, one from each row in the DataSources table.</returns>
    Public Function GetDataSources() As Collection(Of DataSource)
        If Not ConnectDatabase() Then
            Return New Collection(Of DataSource)
        End If

        ' Create all of the database objects needed
        Dim DataSources As New Collection(Of DataSource)
        Dim SelectCommand As New SqlCommand(DataSourceSelectStatement, pDatabase)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Attempt to populate the Collection of DataSource object
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            Dim Source As New DataSource
            For i = 0 To DatabaseTable.Rows.Count - 1

                ' These are both mandatory columns in the table
                Source.ID = DatabaseTable.Rows(i).Item("ID")
                Source.Name = DatabaseTable.Rows(i).Item("Name")

                Call DataSources.Add(Source)
            Next
        End If

        Return DataSources
    End Function

    ''' <summary>
    ''' Returns a collection of ContainerTypeData objects built from the ContainerTypes table.
    ''' </summary>
    ''' <returns>A Collection of ContainerTypeData objects, one from each row in the ContainerTypes table.</returns>
    Public Function GetContainerTypes() As Collection(Of ContainerTypeData)
        If Not ConnectDatabase() Then
            Return New Collection(Of ContainerTypeData)
        End If

        ' Create all of the database objects needed
        Dim ContainerTypes As New Collection(Of ContainerTypeData)
        Dim SelectCommand As New SqlCommand(ContainerTypesSelectStatement, pDatabase)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Attempt to populate the Collection of DataSource object
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            Dim Container As New ContainerTypeData
            For i = 0 To DatabaseTable.Rows.Count - 1

                ' These are both mandatory columns in the table
                Container.ID = DatabaseTable.Rows(i).Item("ID")
                Container.Name = DatabaseTable.Rows(i).Item("TypeName")

                Call ContainerTypes.Add(Container)
            Next
        End If

        Return ContainerTypes
    End Function

    ''' <summary>
    ''' Retrieves every keyword for a given DataSource's ID.
    ''' </summary>
    ''' <param name="DataSourceID">The ID mapping to the DataSources table for the type of keywords to return</param>
    ''' <returns>An array of strings each with one keyword, Nothing if there were none or an error occurred.</returns>
    Public Function GetKeywords(ByVal DataSourceID As Integer) As String()
        If Not ConnectDatabase() Then
            Return Nothing
        End If

        ' Create all of the database objects needed
        Dim SelectCommand As New SqlCommand(KeywordsSelectStatement, pDatabase)
        Call SelectCommand.Parameters.Add(New SqlParameter("DataSourceID", DataSourceID))
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Attempt to populate the array
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            ' Declare the array with proper sizing
            Dim Keywords(DatabaseTable.Rows.Count - 1) As String

            ' Add every keyword to the array
            For i = 0 To DatabaseTable.Rows.Count - 1
                Keywords(i) = DatabaseTable.Rows(i).Item("Keyword")
            Next

            Return Keywords
        End If

        Return Nothing
    End Function

    ''' <summary>
    ''' Deletes a Container from the PendingContainer table.
    ''' </summary>
    ''' <param name="ContainerName">The name of the Container to delete</param>
    ''' <param name="ContainerType">THe type of Container to delete</param>
    ''' <returns>True if the deletion was successful, False otherwise.</returns>
    Public Function DeletePendingContainer(ByVal ContainerName As String, ByVal ContainerType As ContainerType) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that the Bucket name was specified
        If ContainerName Is Nothing Then
            Return False
        End If

        If ContainerName = "" Then
            Return False
        End If

        Dim DeleteCommand As New SqlCommand(PendingContainersDeleteStatement, pDatabase)
        Call DeleteCommand.Parameters.Add(New SqlParameter("ContainerName", ContainerName))
        Call DeleteCommand.Parameters.Add(New SqlParameter("@ContainerType", ContainerType))


        ' If there were more than 0 affected rows, then the Bucket was deleted
        Return (DeleteCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Insert a Container into the list of pending Containers to download.
    ''' </summary>
    ''' <param name="ContainerName">The name of the Container</param>
    ''' <param name="ClientKey">An Client Key needed to access the Container, if required for access</param>
    ''' <param name="SecretKey">An Secret Key needed to access the Container, if required for access</param>
    ''' <param name="ContainerType">The type of Container to queue</param>
    ''' <returns>Returns True if the Container was queued for download, False otherwise.</returns>
    Public Function InsertPendingContainer(ByVal ContainerName As String, ByVal ClientKey As String, ByVal SecretKey As String, ByVal ContainerType As ContainerType) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that the Bucket name was specified
        If ContainerName Is Nothing Then
            Return False
        End If

        If ContainerName = "" Then
            Return False
        End If

        ' The AWS Client/Secret Keys are optional, only insert them if they're present
        Dim InsertCommand As SqlCommand
        If ClientKey <> "" And SecretKey <> "" Then
            InsertCommand = New SqlCommand(PendingContainersWithKeysInsertStatement, pDatabase)
            Call InsertCommand.Parameters.Add(New SqlParameter("AccessKey", ClientKey))
            Call InsertCommand.Parameters.Add(New SqlParameter("SecretKey", SecretKey))
        Else
            InsertCommand = New SqlCommand(PendingContainersInsertStatement, pDatabase)
        End If
        Call InsertCommand.Parameters.Add(New SqlParameter("ContainerName", ContainerName))
        Call InsertCommand.Parameters.Add(New SqlParameter("ContainerType", ContainerType))

        ' Return whether any rows were affected by the INSERT statement
        Return (InsertCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Retrieve information about Containers pending download.
    ''' </summary>
    ''' <returns>A Collection of StorageContainer entries describing the Buckets to be dumped.</returns>
    Public Function GetPendingContainers() As Collection(Of StorageContainer)
        Dim Containers As New Collection(Of StorageContainer)
        If Not ConnectDatabase() Then
            Return Nothing
        End If

        ' Create the database objects needed for the query
        Dim SelectCommand As New SqlCommand(PendingContainersSelectStatement, pDatabase)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            For i = 0 To DatabaseTable.Rows.Count - 1
                Dim NewContainer As New StorageContainer
                NewContainer.ContainerName = DatabaseTable.Rows(i).Item("ContainerName")
                NewContainer.ContainerType = DatabaseTable.Rows(i).Item("ContainerType")

                ' The following columns are optional in the table
                If Not DatabaseTable.Rows(i).IsNull("AccessKey") Then
                    NewContainer.AccessKey = DatabaseTable.Rows(i).Item("AccessKey")
                End If
                If Not DatabaseTable.Rows(i).IsNull("SecretKey") Then
                    NewContainer.SecretKey = DatabaseTable.Rows(i).Item("SecretKey")
                End If

                Call Containers.Add(NewContainer)
            Next
        End If

        Return Containers
    End Function

    ''' <summary>
    ''' Retrieve information about Containers discovered by an automated process.
    ''' </summary>
    ''' <returns>A Collection of StorageContainer entries describing the Containers that have been discovered by an automated process.</returns>
    Public Function GetDiscoveredContainers(ByVal NewContainersOnly As Boolean) As Collection(Of StorageContainer)
        Dim Containers As New Collection(Of StorageContainer)
        If Not ConnectDatabase() Then
            Return Nothing
        End If

        ' Create the database objects needed for the query
        Dim SelectCommand As SqlCommand
        If NewContainersOnly Then
            SelectCommand = New SqlCommand(DiscoveredContainersSelectUncheckedStatement, pDatabase)
        Else
            SelectCommand = New SqlCommand(DiscoveredContainersSelectStatement, pDatabase)
        End If
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            For i = 0 To DatabaseTable.Rows.Count - 1
                Dim NewContainer As New StorageContainer
                NewContainer.ContainerName = DatabaseTable.Rows(i).Item("ContainerName")
                NewContainer.ContainerType = DatabaseTable.Rows(i).Item("ContainerType")

                ' The following columns are optional in the table
                If Not DatabaseTable.Rows(i).IsNull("AccessKey") Then
                    NewContainer.AccessKey = DatabaseTable.Rows(i).Item("AccessKey")
                End If
                If Not DatabaseTable.Rows(i).IsNull("SecretKey") Then
                    NewContainer.SecretKey = DatabaseTable.Rows(i).Item("SecretKey")
                End If

                Call Containers.Add(NewContainer)
            Next
        End If

        Return Containers
    End Function

    ''' <summary>
    ''' Marks a Container discovered by an automated process as having been queued for download.
    ''' </summary>
    ''' <param name="ContainerName">The name of the container to mark as queued.</param>
    ''' <param name="ContainerType">The type of container to mark queued.</param>
    ''' <returns>True if the Bucket was marked as queued, False otherwise.</returns>
    Public Function MarkDiscoveredContainerQueued(ByVal ContainerName As String, ByVal ContainerType As ContainerType) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that the ContainerName was specified
        If ContainerName Is "" Then
            Return False
        End If

        Dim UpdateCommand As New SqlCommand(DiscoveredContainersSetQueuedUpdateStatement, pDatabase)
        Call UpdateCommand.Parameters.Add(New SqlParameter("ContainerName", ContainerName))
        Call UpdateCommand.Parameters.Add(New SqlParameter("ContainerType", ContainerType))

        ' Return whether any rows were affected
        Return (UpdateCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Insert a Container into the list of Containers discovered by an automated process.
    ''' </summary>
    ''' <param name="ContainerName">The name of the Container</param>
    ''' <param name="ClientKey">A Client Key needed to access the Container, if required for access</param>
    ''' <param name="SecretKey">A Secret Key needed to access the Container, if required for access</param>
    ''' <param name="ContainerType">The type of Container to insert</param>
    ''' <returns>Returns True if the Container was added to the list, False otherwise.</returns>
    Public Function InsertDiscoveredContainer(ByVal ContainerName As String, ByVal ClientKey As String, ByVal SecretKey As String, ByVal ContainerType As ContainerType) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that the Bucket name was specified
        If ContainerName Is Nothing Then
            Return False
        End If

        If ContainerName = "" Then
            Return False
        End If

        ' The AWS Client/Secret Keys are optional, only insert them if they're present
        Dim InsertCommand As SqlCommand
        If ClientKey <> "" And SecretKey <> "" Then
            InsertCommand = New SqlCommand(DiscoveredContainersWithKeysInsertStatement, pDatabase)
            Call InsertCommand.Parameters.Add(New SqlParameter("AccessKey", ClientKey))
            Call InsertCommand.Parameters.Add(New SqlParameter("SecretKey", SecretKey))
        Else
            InsertCommand = New SqlCommand(DiscoveredContainersInsertStatement, pDatabase)
        End If
        Call InsertCommand.Parameters.Add(New SqlParameter("ContainerName", ContainerName))
        Call InsertCommand.Parameters.Add(New SqlParameter("ContainerType", ContainerType))

        ' Return whether any rows were affected by the INSERT statement
        Return (InsertCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Adds a ContentItem entry to the Content table.
    ''' </summary>
    ''' <param name="ContentItem">A fully populated ContentItem</param>
    ''' <returns>True if the Content table was updated successfully, False otherwise.</returns>
    Public Function InsertContent(ByRef ContentItem As ContentItem) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Declare a collection and add the single ContentItem to the collection, then call the function
        ' that adds whole collections to the database
        Dim ContentItems As New Collection(Of ContentItem)
        Call ContentItems.Add(ContentItem)
        Return InsertContent(ContentItems)
    End Function

    ''' <summary>
    ''' Retrieves a ContentItem based on the passed hash value.
    ''' </summary>
    ''' <param name="Hash">A Hash value from one of the supported services</param>
    ''' <returns>A ContentItem if the content associated with the Hash was found, Nothing otherwise.</returns>
    Public Function GetContent(ByVal Hash As String) As ContentItem
        If Not ConnectDatabase() Then
            Return Nothing
        End If

        ' Check that the hash was specified
        If Hash Is Nothing Then
            Return Nothing
        End If

        If Hash = "" Then
            Return Nothing
        End If

        ' Create database objects necessary for the query
        Dim SelectCommand As New SqlCommand(ContentSelectStatement, pDatabase)
        Call SelectCommand.Parameters.Add(New SqlParameter("Hash", Hash))
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Fill the table and return the first (and hopefully only) result
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            Dim Content As New ContentItem

            ' These columns are mandatory in the table
            Content.Hash = DatabaseTable.Rows(0).Item("Hash")
            Content.Keywords = DatabaseTable.Rows(0).Item("Keywords")
            Content.DataSource = DatabaseTable.Rows(0).Item("DataSource")
            Content.SourceURL = DatabaseTable.Rows(0).Item("SourceURL")
            Content.CollectedTime = DatabaseTable.Rows(0).Item("CollectedTime")

            ' The Data column can be NULL
            If Not DatabaseTable.Rows(0).IsNull("Data") Then
                Content.Data = DatabaseTable.Rows(0).Item("Data")
            End If

            Return Content
        End If

        Return Nothing
    End Function

    ''' <summary>
    ''' Inserts a Collection of ContentItems into the database.
    ''' </summary>
    ''' <param name="ContentItems">A Collection of fully populated ContentItem objects</param>
    ''' <returns>True if all of the ContentItems were inserted into the database, False otherwise.</returns>
    Public Function InsertContent(ByRef ContentItems As Collection(Of ContentItem)) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that all items are valid and fail out if not
        For i = 0 To ContentItems.Count - 1
            If ContentItems(i).Hash = "" Or ContentItems(i).Keywords = "" Or ContentItems(i).SourceURL = "" Then
                Return False
            End If
        Next

        Dim InsertCount As Integer = 0
        For i = 0 To ContentItems.Count - 1
            Dim InsertCommand As New SqlCommand(ContentInsertStatement, pDatabase)
            Call InsertCommand.Parameters.Add(New SqlParameter("CollectedTime", ContentItems(i).CollectedTime))
            Call InsertCommand.Parameters.Add(New SqlParameter("Keywords", ContentItems(i).Keywords))
            Call InsertCommand.Parameters.Add(New SqlParameter("DataSourceID", ContentItems(i).DataSource))
            Call InsertCommand.Parameters.Add(New SqlParameter("SourceURL", ContentItems(i).SourceURL))
            Call InsertCommand.Parameters.Add(New SqlParameter("Hash", ContentItems(i).Hash))
            Call InsertCommand.Parameters.Add(New SqlParameter("Data", ContentItems(i).Data))

            ' Count the rows affected by the INSERTs for comparison at the end
            InsertCount += InsertCommand.ExecuteNonQuery()
        Next

        ' Check to see if the number of rows affected were the same as the number of items passed in
        If InsertCount = ContentItems.Count Then
            Return True
        Else
            Return False
        End If
    End Function

    ''' <summary>
    ''' Adds raw data to the Content table entry for the file indicated.
    ''' </summary>
    ''' <param name="SourceURL">The source URL where the content was downloaded from</param>
    ''' <param name="Hash">The hash of the file from the data source</param>
    ''' <param name="Data">The raw bytes that make up the file</param>
    ''' <returns>True if the Content table was updated, False otherwise.</returns>
    Public Function UpdateContent(ByVal SourceURL As String, ByVal Hash As String, ByRef Data() As Byte) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that the source URL and hash were specified
        If SourceURL Is Nothing Or Hash Is Nothing Then
            Return False
        End If

        If SourceURL = "" Or Hash = "" Then
            Return False
        End If

        ' If there isn't any data then insert the source URL 
        If Data Is Nothing Then
            Data = Text.UTF8Encoding.UTF8.GetBytes(SourceURL)
        End If

        Dim UpdateCommand As New SqlCommand(ContentUpdateStatement, pDatabase)
        Call UpdateCommand.Parameters.Add(New SqlParameter("CollectedTime", Now))
        Call UpdateCommand.Parameters.Add(New SqlParameter("SourceURL", SourceURL))
        Call UpdateCommand.Parameters.Add(New SqlParameter("Hash", Hash))
        Call UpdateCommand.Parameters.Add(New SqlParameter("Data", DBNull.Value))

        ' Return whether any rows were affected
        Return (UpdateCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Returns statisics related to the size of the Content table.
    ''' </summary>
    ''' <returns>An object containing the number of rows and size of the Content table, Nothing if an error occurs</returns>
    Public Function GetContentTableSize() As TableSizeStatistics
        Dim TableStats As New TableSizeStatistics

        If Not ConnectDatabase() Then
            Return Nothing
        End If

        ' Create database objects necessary for the query
        Dim SelectCommand As New SqlCommand(ContentTableSize, pDatabase)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Fill the table and return the first (and hopefully only) result
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            ' These columns are mandatory in the table
            TableStats.RowCount = DatabaseTable.Rows(0).Item("rows")
            TableStats.DataSize = DatabaseTable.Rows(0).Item("data")

            Return TableStats
        End If

        Return Nothing
    End Function

    ''' <summary>
    ''' Inserts a SourceURL/Hash pair into the PendingDownloads table for pickup by the download process.
    ''' </summary>
    ''' <param name="SourceURL">Source URL to download the file from</param>
    ''' <param name="Hash">Hash of the file from the data source</param>
    ''' <returns>True if the file was successfully queued for download, False otherwise.</returns>
    Public Function InsertPendingDownload(ByVal SourceURL As String, ByVal Hash As String) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        ' Check that there is a source URL and hash
        If SourceURL Is Nothing Or Hash Is Nothing Then
            Return False
        End If

        ' Doublecheck that there is a source URL and hash
        If SourceURL = "" Or Hash = "" Then
            Return False
        End If

        Dim InsertCommand As New SqlCommand(PendingDownloadInsertStatement, pDatabase)
        Call InsertCommand.Parameters.Add(New SqlParameter("SourceURL", SourceURL))
        Call InsertCommand.Parameters.Add(New SqlParameter("Hash", Hash))

        ' Return whether any rows were affected
        Return (InsertCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Delete a pending download by source URL.
    ''' </summary>
    ''' <param name="SourceURL">The URL pending download</param>
    ''' <returns>True if the URL was deleted, False otherwise.</returns>
    Public Function DeletePendingDownload(ByVal SourceURL As String) As Boolean
        If Not ConnectDatabase() Then
            Return False
        End If

        If SourceURL Is Nothing Then
            Return False
        End If

        If SourceURL = "" Then
            Return False
        End If

        Dim DeleteCommand As New SqlCommand(PendingDownloadDeleteStatement, pDatabase)
        Call DeleteCommand.Parameters.Add(New SqlParameter("SourceURL", SourceURL))

        Return (DeleteCommand.ExecuteNonQuery() > 0)
    End Function

    ''' <summary>
    ''' Return all pending downloads. This only fills in the Hash and SourceURL parameters of the ContentItems.
    ''' </summary>
    ''' <returns>A Collection of ContentItem if there are any pending downloads, Nothing if there are none or an error occurrs.</returns>
    Public Function GetPendingDownloads() As Collection(Of ContentItem)
        If Not ConnectDatabase() Then
            Return Nothing
        End If

        Dim PendingDownloads As New Collection(Of ContentItem)
        Dim SelectCommand As New SqlCommand(PendingDownloadSelectStatement, pDatabase)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        ' Attempt to get all of the items in the PendingDownload table filling in the SourceURL and Hash fields of the ContentItem.
        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            Dim Keywords(DatabaseTable.Rows.Count - 1) As String

            For i = 0 To DatabaseTable.Rows.Count - 1
                Dim Download As New ContentItem
                Download.Hash = DatabaseTable.Rows(i).Item("Hash")
                Download.SourceURL = DatabaseTable.Rows(i).Item("SourceURL")
                Call PendingDownloads.Add(Download)
            Next

            Return PendingDownloads
        Else
            Return Nothing
        End If
    End Function
End Class
