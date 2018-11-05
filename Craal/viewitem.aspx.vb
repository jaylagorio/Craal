Imports CraalDatabase
Imports CraalDatabase.Database

Public Class viewitem
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        If Request.QueryString("ID") <> "" Then
            Dim Database As New Database(Application("ConnectionString"))
            Dim ContentItem As ContentItem = Database.GetContent(Request.QueryString("id"))
            If ContentItem.Hash <> "" Then
                lblURL.Text = ContentItem.SourceURL
                lblURL.NavigateUrl = ContentItem.SourceURL
                lblURL.Target = "_blank"

                lblKeywords.Text = ContentItem.Keywords
                lblCollectedTime.Text = ContentItem.CollectedTime

                If Not ContentItem.Data Is Nothing Then
                    lblContent.Text = System.Text.UTF8Encoding.UTF8.GetString(ContentItem.Data)
                Else
                    lblContent.Text = "No data."
                End If
            Else
                Response.Redirect(Request.ApplicationPath)
            End If
        End If
    End Sub
End Class