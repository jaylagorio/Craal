<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="viewitem.aspx.vb" Inherits="Craal.viewitem" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <asp:Panel ID="pnlHeader" runat="server" BorderColor="LightGray" Width="100%" BorderWidth="3">
            URL: <asp:HyperLink ID="lblURL" runat="server">HyperLink</asp:HyperLink><br />
            Keywords: <asp:Label ID="lblKeywords" runat="server" Text=""></asp:Label><br />
            Date Collected: <asp:Label ID="lblCollectedTime" runat="server" Text=""></asp:Label>
        </asp:Panel>
    </div>
    <div>&nbsp;</div>
    <div>
        <asp:Panel ID="pnlContent" runat="server" Wrap="true" Font-Names="Courier New" Width="100%" Height="100%" BorderWidth="3" BorderColor="White">
            <asp:Label ID="lblContent" runat="server" Text=""></asp:Label>
        </asp:Panel>
    </div>
    </form>
</body>
</html>
