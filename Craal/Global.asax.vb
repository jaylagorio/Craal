
Public Class Global_asax
    Inherits HttpApplication

    Sub Application_Start(sender As Object, e As EventArgs)
        ' Fires when the application is started

        Dim rootWebConfig As System.Configuration.Configuration
        rootWebConfig = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("/Craal")
        Dim connString As System.Configuration.ConnectionStringSettings
        If (rootWebConfig.ConnectionStrings.ConnectionStrings.Count > 0) Then
            connString = rootWebConfig.ConnectionStrings.ConnectionStrings("CraalConnectionString")
            If Not connString.ConnectionString Is Nothing Then
                Application("ConnectionString") = connString.ConnectionString
            End If
        End If
    End Sub
End Class