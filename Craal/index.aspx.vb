Imports CraalDatabase
Imports System.Data.SqlClient
Imports System.Collections.ObjectModel

Public Class index
    Inherits System.Web.UI.Page

    Private pDatabaseConnection As SqlConnection
    Private pDatabase As Database
    Private pDataset As New DataSet
    Private Const DATASOURCE_SELECT_STATEMENT As String = "SELECT * FROM DataSources"
    Private Const CONTENT_SELECT_STATEMENT As String = "SELECT TOP 1000 (SELECT Name FROM DataSources WHERE ID = DataSource) As DataSource, SourceURL, Hash, Keywords, CollectedTime, DATALENGTH(Data) As ContentSize FROM [Content] ORDER BY CollectedTime DESC"
    Private Const CONTENT_KEYWORD_SELECT_STATEMENT As String = "SELECT TOP 1000 (SELECT Name FROM DataSources WHERE ID = DataSource) As DataSource, SourceURL, Hash, Keywords, CollectedTime, DATALENGTH(Data) As ContentSize FROM [Content] WHERE CONTAINS(Keywords, @Keyword) ORDER BY CollectedTime DESC"
    Private pDataSources As Collection(Of DataSource)

    Public Structure DataSource
        Dim ID As Integer
        Dim Name As String
    End Structure

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        pDatabaseConnection = New SqlConnection(Application("ConnectionString"))
        pDatabase = New Database(Application("ConnectionString"))
        Call pDatabaseConnection.Open()

        Dim TableStats As Database.TableSizeStatistics = pDatabase.GetContentTableSize()
        Try
            ContentTableSize.Text = TableStats.RowCount & " rows, " & TableStats.DataSize
        Catch ex As NullReferenceException
            ContentTableSize.Text = "Couldn't get Content table size"
        End Try

        If Not Page.IsPostBack Then
            Session("LastRefresh") = Now.AddSeconds(1)
            Call cmdSearch_Click(Nothing, Nothing)
        End If
    End Sub

    Public Function GetDataSources() As Collection(Of DataSource)
        If pDatabaseConnection.State <> ConnectionState.Open Then
            Return New Collection(Of DataSource)
        End If

        Dim DataSources As New Collection(Of DataSource)
        Dim SelectCommand As New SqlCommand(DATASOURCE_SELECT_STATEMENT, pDatabaseConnection)
        Dim DatabaseAdaptor As New SqlDataAdapter(SelectCommand)
        Dim DatabaseTable As New DataTable

        If DatabaseAdaptor.Fill(DatabaseTable) > 0 Then
            Dim Source As New DataSource
            For i = 0 To DatabaseTable.Rows.Count - 1
                Source.ID = DatabaseTable.Rows(i).Item("ID")
                Source.Name = DatabaseTable.Rows(i).Item("Name")
                Call DataSources.Add(Source)
            Next
        End If

        Return DataSources
    End Function

    Private Sub DataGrid_PageIndexChanged(source As Object, e As DataGridPageChangedEventArgs) Handles DataGrid.PageIndexChanged
        DataGrid.CurrentPageIndex = e.NewPageIndex
    End Sub

    Private Sub DataGrid_ItemDataBound(sender As Object, e As DataGridItemEventArgs) Handles DataGrid.ItemDataBound
        If Not e.Item.DataItem Is Nothing Then
            If e.Item.DataItem.Row.ItemArray(4) > Session("LastRefresh") Then
                e.Item.BackColor = Drawing.Color.Green
            End If
        End If
    End Sub

    Public Shared Function GetDataSize(ByVal SizeInBytes As Object) As String
        If IsDBNull(SizeInBytes) Then
            Return "0 B"
        End If

        Dim Measurements() As String = {" B", " KB", " MB", " GB", " TB"}
        Dim Divisions As Integer = 0
        While SizeInBytes > 900 And Divisions < 5
            SizeInBytes /= 1024
            Divisions += 1
        End While

        Return SizeInBytes & Measurements(Divisions)
    End Function

    Private Sub cmdSubmitContainer_Click(sender As Object, e As EventArgs) Handles cmdSubmitContainer.Click
        ' Check to make sure there's a Bucket name
        If txtBucketName.Text <> "" Then
            ' Insert the Bucket name (and AWS authentication data if any) and redirect to the index upon success
            If pDatabase.InsertPendingContainer(txtBucketName.Text, txtClientKey.Text, txtSecretKey.Text, Database.ContainerType.S3Bucket) Then
                txtBucketName.Text = ""
                txtClientKey.Text = ""
                txtSecretKey.Text = ""
            End If
        End If
    End Sub

    Private Sub cmdSubmitDNS_Click(sender As Object, e As EventArgs) Handles cmdSubmitDNS.Click
        ''TODO
    End Sub

    Private Sub cmdSearchTab_Click(sender As Object, e As EventArgs) Handles cmdSearchTab.Click
        pnlSearch.Visible = True
        pnlQueueContainer.Visible = False
        pnlProcessDNSLogs.Visible = False
    End Sub

    Private Sub cmdQueueContainerTab_Click(sender As Object, e As EventArgs) Handles cmdQueueContainerTab.Click
        pnlSearch.Visible = False
        pnlQueueContainer.Visible = True
        pnlProcessDNSLogs.Visible = False
    End Sub

    Private Sub cmdProcessDNSLogsTab_Click(sender As Object, e As EventArgs) Handles cmdProcessDNSLogsTab.Click
        pnlSearch.Visible = False
        pnlQueueContainer.Visible = False
        pnlProcessDNSLogs.Visible = True
    End Sub

    Private Sub cmdSearch_Click(sender As Object, e As EventArgs) Handles cmdSearch.Click
        Dim WhereClause As String = ""
        If Not (chkDataSources.Items(0).Selected And chkDataSources.Items(1).Selected And chkDataSources.Items(2).Selected) Then
            DataGrid.Visible = False
            If chkDataSources.Items(0).Selected Then
                WhereClause = "WHERE DataSource = 1 "
            Else
                WhereClause = "WHERE DataSource <> 1 "
            End If

            If chkDataSources.Items(1).Selected Then
                If WhereClause = "" Then
                    WhereClause = "WHERE "
                Else
                    WhereClause &= "OR "
                End If
                WhereClause &= "DataSource = 2 "
            Else
                If WhereClause = "" Then
                    WhereClause = "WHERE "
                Else
                    WhereClause &= "OR "
                End If
                WhereClause &= "DataSource <> 2 "
            End If

            If chkDataSources.Items(2).Selected Then
                If WhereClause = "" Then
                    WhereClause = "WHERE "
                Else
                    WhereClause &= "OR "
                End If
                WhereClause &= "DataSource = 3 "
            Else
                If WhereClause = "" Then
                    WhereClause = "WHERE "
                Else
                    WhereClause &= "OR "
                End If
                WhereClause &= "DataSource <> 3 "
            End If
        End If

        Dim DataAdaptor As SqlDataAdapter
        If txtKeywords.Text = "" Then
            DataAdaptor = New SqlDataAdapter(New SqlCommand(CONTENT_SELECT_STATEMENT & " " & WhereClause, pDatabaseConnection))
        Else
            Dim SelectStatement As New SqlCommand(CONTENT_KEYWORD_SELECT_STATEMENT & " " & WhereClause, pDatabaseConnection)
            SelectStatement.Parameters.Add(New SqlParameter("Keyword", txtKeywords.Text))
            DataAdaptor = New SqlDataAdapter(SelectStatement)
        End If
        Call DataAdaptor.Fill(pDataset)

        DataGrid.DataSource = pDataset
        Call DataGrid.DataBind()
    End Sub
End Class