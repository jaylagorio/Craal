<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="index.aspx.vb" Inherits="Craal.index" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .content {
            margin: 10px 15px 10px 10px;
        }

        .tab {
            margin: 0px 0px 10px 10px;
            text-align: center;
            vertical-align: central;
            background-color: lightgreen;
            color: white;
            float: left;
        }

        .lasttab {
            clear: left;
        }
    </style>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <div class="content">
            <asp:UpdatePanel ID="UpdatePanel" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Panel runat="server" BorderWidth="1" BorderColor="LightGray">
                        <div class="tab">
                            <asp:LinkButton ID="cmdSearchTab" runat="server">Search</asp:LinkButton>
                        </div>
                        <div class="tab">
                            <asp:LinkButton ID="cmdQueueContainerTab" runat="server">Queue Container</asp:LinkButton>
                        </div>
                        <div class="tab">
                            <asp:LinkButton ID="cmdProcessDNSLogsTab" runat="server">Process DNS Logs</asp:LinkButton>
                        </div>
                        <div class="lasttab"></div>

                        <asp:Panel ID="pnlSearch" runat="server">
                            <div style="vertical-align: middle; margin-left: 10px;">
                                <div style="float: left;">
                                    <div>
                                        Keywords:
                                    </div>
                                    <div>
                                        <asp:TextBox ID="txtKeywords" runat="server" Width="250"></asp:TextBox>
                                    </div>
                                </div>
                                <div style="float: left; margin-left: 10px;">
                                    <div>
                                        Search:
                                    </div>
                                    <div>
                                        <asp:Button ID="cmdSearch" Text="Search" runat="server" />
                                    </div>
                                </div>
                                <div style="clear: left;" />
                                    Data Sources:
                                    <asp:CheckBoxList ID="chkDataSources" runat="server" RepeatDirection="Horizontal">
                                        <asp:ListItem Selected="True" Value="1">PasteBin</asp:ListItem>
                                        <asp:ListItem Selected="True" Value="2">GitHub</asp:ListItem>
                                        <asp:ListItem Selected="True" Value="3">Amazon S3</asp:ListItem>
                                    </asp:CheckBoxList>
                                </div>
                            </div>
                        </asp:Panel>
                        <asp:Panel ID="pnlQueueContainer" runat="server" Visible="False">
                            Container Name:
                            <asp:TextBox ID="txtBucketName" runat="server"></asp:TextBox><br />
                            Client Key:
                            <asp:TextBox ID="txtClientKey" runat="server"></asp:TextBox><br />
                            Secret Key:
                            <asp:TextBox ID="txtSecretKey" runat="server"></asp:TextBox><br />
                            <asp:Button ID="cmdSubmitContainer" runat="server" Text="Submit" />
                        </asp:Panel>
                        <asp:Panel ID="pnlProcessDNSLogs" runat="server" Visible="False">
                            Microsoft DNS Server Log:
                            <asp:FileUpload ID="txtDNSLogs" runat="server" /><asp:Button ID="cmdSubmitDNS" runat="server" Text="Submit" />
                            <br />
                            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
                        </asp:Panel>
                    </asp:Panel>
                </ContentTemplate>
            </asp:UpdatePanel>
            <p />
            <asp:DataGrid ID="DataGrid" runat="server" AllowPaging="True" AutoGenerateColumns="False" PageSize="25">
                <Columns>
                    <asp:BoundColumn DataField="DataSource" HeaderText="Data Source"></asp:BoundColumn>
                    <asp:TemplateColumn HeaderText="Source URL">
                        <ItemTemplate>
                            <a href="viewitem.aspx?id=<%# Container.DataItem("Hash") %>" target="_blank"><%# Container.DataItem("SourceURL") %></a>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                    <asp:BoundColumn DataField="Keywords" HeaderText="Keywords"></asp:BoundColumn>
                    <asp:BoundColumn DataField="CollectedTime" HeaderText="Collected Time"></asp:BoundColumn>
                    <asp:TemplateColumn HeaderText="Size">
                        <ItemTemplate>
                            <%# Craal.index.GetDataSize(Container.DataItem("ContentSize")) %>
                        </ItemTemplate>
                    </asp:TemplateColumn>
                </Columns>
                <HeaderStyle BackColor="Gray" Font-Bold="False" Font-Italic="False" Font-Overline="False" Font-Strikeout="False" Font-Underline="False" />
                <PagerStyle NextPageText="Next &amp;gt;" PrevPageText="&amp;lt; Prev" Position="Bottom" />
            </asp:DataGrid>
            <asp:Label ID="ContentTableSize" runat="server"></asp:Label>
        </div>
    </form>
</body>
</html>
