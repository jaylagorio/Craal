USE [master]
GO
/****** Object:  Database [Craal]    Script Date: 2/23/2018 10:35:19 PM ******/
CREATE DATABASE [Craal]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Craal', FILENAME = N'D:\SQLData\MSSQL13.MSSQLSERVER\MSSQL\DATA\Craal.mdf' , SIZE = 139264KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Craal_log', FILENAME = N'D:\SQLData\MSSQL13.MSSQLSERVER\MSSQL\DATA\Craal_log.ldf' , SIZE = 1318912KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Craal] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Craal].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Craal] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Craal] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Craal] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Craal] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Craal] SET ARITHABORT OFF 
GO
ALTER DATABASE [Craal] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Craal] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Craal] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Craal] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Craal] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Craal] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Craal] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Craal] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Craal] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Craal] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Craal] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Craal] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Craal] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Craal] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Craal] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Craal] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Craal] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Craal] SET RECOVERY FULL 
GO
ALTER DATABASE [Craal] SET  MULTI_USER 
GO
ALTER DATABASE [Craal] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Craal] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Craal] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Craal] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Craal] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Craal', N'ON'
GO
ALTER DATABASE [Craal] SET QUERY_STORE = OFF
GO
USE [Craal]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [Craal]
GO
/****** Object:  User [DOMAIN\CRAALSERVER$]    Script Date: 2/23/2018 10:35:20 PM ******/
CREATE USER [DOMAIN\CRAALSERVER$] FOR LOGIN [DOMAIN\CRAALSERVER$] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [DOMAIN\CRAALSERVER$]    Script Date: 2/23/2018 10:35:20 PM ******/
ALTER ROLE [db_datareader] ADD MEMBER [DOMAIN\CRAALSERVER$]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [DOMAIN\CRAALSERVER$]
GO
/****** Object:  Table [dbo].[ContainerTypes]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContainerTypes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TypeName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ContainerTypes] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Content]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Content](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[CollectedTime] [datetime] NOT NULL,
	[DataSource] [int] NOT NULL,
	[Keywords] [varchar](1024) NOT NULL,
	[SourceURL] [varchar](1024) NOT NULL,
	[Hash] [varchar](64) NOT NULL,
	[Data] [varbinary](max) NULL,
	[Viewed] [bit] NULL,
 CONSTRAINT [PK_Content] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DataSources]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DataSources](
	[ID] [int] IDENTITY(0,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_DataSources] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DiscoveredContainers]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscoveredContainers](
	[ID] [int] IDENTITY(0,1) NOT NULL,
	[ContainerName] [varchar](max) NOT NULL,
	[AccessKey] [varchar](max) NULL,
	[SecretKey] [varchar](max) NULL,
	[ContainerType] [int] NOT NULL,
	[Queued] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Keywords]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Keywords](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DataSource] [int] NOT NULL,
	[Keyword] [varchar](1024) NOT NULL,
 CONSTRAINT [PK_Keywords] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PendingContainers]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PendingContainers](
	[ID] [int] IDENTITY(0,1) NOT NULL,
	[ContainerName] [varchar](max) NOT NULL,
	[AccessKey] [varchar](max) NULL,
	[SecretKey] [varchar](max) NULL,
	[ContainerType] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PendingDownloads]    Script Date: 2/23/2018 10:35:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PendingDownloads](
	[SourceURL] [varchar](1024) NOT NULL,
	[Hash] [varchar](64) NOT NULL
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[ContainerTypes] ON 

GO
INSERT [dbo].[ContainerTypes] ([ID], [TypeName]) VALUES (1, N'Amazon S3 Bucket')
GO
INSERT [dbo].[ContainerTypes] ([ID], [TypeName]) VALUES (2, N'Azure Blob Storage')
GO
INSERT [dbo].[ContainerTypes] ([ID], [TypeName]) VALUES (3, N'DigitalOcean Space')
GO
SET IDENTITY_INSERT [dbo].[ContainerTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[DataSources] ON 

GO
INSERT [dbo].[DataSources] ([ID], [Name]) VALUES (0, N'Unknown')
GO
INSERT [dbo].[DataSources] ([ID], [Name]) VALUES (1, N'Pastebin')
GO
INSERT [dbo].[DataSources] ([ID], [Name]) VALUES (2, N'Github')
GO
INSERT [dbo].[DataSources] ([ID], [Name]) VALUES (3, N'Amazon S3 Bucket')
GO
SET IDENTITY_INSERT [dbo].[DataSources] OFF
GO
SET IDENTITY_INSERT [dbo].[Keywords] ON 

INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (1, 1, N'Hotelogix')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (2, 1, N'BEGIN EC PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (3, 1, N'BEGIN RSA PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (4, 1, N'BEGIN PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (5, 1, N'PTWEBSERVER')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (6, 1, N'PTDMO')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (7, 1, N'PSADMIN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (8, 1, N'PSSTATUS')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (9, 1, N'PSOPRDEFN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (10, 1, N'PSACCESSPRFL')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (11, 1, N'people/peop1e')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (12, 1, N'new S3Adaptor')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (13, 2, N'remove password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (14, 2, N'remove cred')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (15, 2, N'remove certificate')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (16, 2, N'secring')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (17, 2, N'id_rsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (18, 2, N'api key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (19, 2, N'apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (20, 2, N'BEGIN RSA PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (21, 2, N'BEGIN PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (22, 2, N'BEGIN EC PRIVATE KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (23, 2, N'Amazon IAM')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (24, 2, N'S3 Bucket')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (25, 2, N'PTWEBSERVER')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (26, 2, N'PTDMO')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (27, 2, N'PSADMIN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (28, 2, N'PSSTATUS')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (29, 2, N'PSOPRDEFN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (30, 2, N'PSACCESSPRFL')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (31, 2, N'people/peop1e')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (32, 2, N'extension:pem')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (33, 2, N'extension:conf ftp server')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (34, 2, N'extension:xls email')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (35, 2, N'extension:xlsx email')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (36, 2, N'awsSecretKey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (37, 2, N'secretKey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (38, 2, N'us-east-1')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (39, 2, N'otr.private_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (40, 2, N'_rsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (41, 2, N'_dsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (42, 2, N'_ed25519')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (43, 2, N'_ecdsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (44, 2, N'ssh/config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (45, 2, N'.pkcs12')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (46, 2, N'.pfx')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (47, 2, N'.p12')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (48, 2, N'.s3cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (49, 2, N'aws/credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (50, 2, N'.ovpn')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (51, 2, N'secret_token.rb')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (52, 2, N'omniauth.rb')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (53, 2, N'carrierwave.rb')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (54, 2, N'.kdb')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (55, 2, N'.agilekeychain')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (56, 2, N'jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (57, 2, N'credentials.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (58, 2, N'.htpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (59, 2, N'gem/credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (60, 2, N'.tugboat')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (61, 2, N'proftpdpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (62, 2, N'robomongo.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (63, 2, N'filezilla.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (64, 2, N'extension:php "eval(preg_replace("')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (65, 2, N'new S3Adaptor')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (66, 1, N'access_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (67, 1, N'refresh_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (68, 1, N'client_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (69, 2, N'access_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (70, 2, N'refresh_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (71, 2, N'client_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (72, 1, N'aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (73, 1, N'rds.amazonaws.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (74, 1, N'thread injection')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (75, 1, N'inject thread')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (76, 1, N'remote code execution')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (77, 2, N'aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (78, 2, N'rds.amazonaws.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (79, 2, N'mailchimp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (80, 2, N'PT_TOKEN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (81, 2, N'conn.login')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (82, 2, N'SF_USERNAME')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (83, 2, N'irc_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (84, 2, N'WFClient')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (85, 2, N'JEKYLL_GITHUB_TOKEN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (86, 2, N'npmrc_auth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (87, 2, N'.ppk')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (88, 2, N'wp-config.php')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (89, 2, N'.git-credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (90, 2, N'idea.key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (91, 2, N'config.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (92, 2, N'connections.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (93, 2, N'.pgpass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (94, 2, N'ventrilo_srv.ini')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (95, 2, N'sever.cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (96, 2, N'sshd_config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (97, 2, N'mysql_history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (98, 2, N'psql_history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (99, 2, N'accounts.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (100, 2, N'.trc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (101, 2, N'.gitrobrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (102, 1, N'access_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (103, 2, N'access_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (104, 1, N's3.amazonaws.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (105, 2, N's3.amazonaws.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (106, 3, N'student.json')
GO
SET IDENTITY_INSERT [dbo].[Keywords] OFF
GO
ALTER TABLE [dbo].[Content]  WITH CHECK ADD  CONSTRAINT [FK_Content_DataSources] FOREIGN KEY([DataSource])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[Content] CHECK CONSTRAINT [FK_Content_DataSources]
GO
ALTER TABLE [dbo].[DataSources]  WITH CHECK ADD  CONSTRAINT [FK_DataSources_DataSources] FOREIGN KEY([ID])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[DataSources] CHECK CONSTRAINT [FK_DataSources_DataSources]
GO
ALTER TABLE [dbo].[DiscoveredContainers]  WITH CHECK ADD  CONSTRAINT [FK_DiscoveredContainers_ContainerTypes] FOREIGN KEY([ContainerType])
REFERENCES [dbo].[ContainerTypes] ([ID])
GO
ALTER TABLE [dbo].[DiscoveredContainers] CHECK CONSTRAINT [FK_DiscoveredContainers_ContainerTypes]
GO
ALTER TABLE [dbo].[Keywords]  WITH CHECK ADD  CONSTRAINT [FK_Keywords_Keywords] FOREIGN KEY([DataSource])
REFERENCES [dbo].[DataSources] ([ID])
GO
ALTER TABLE [dbo].[Keywords] CHECK CONSTRAINT [FK_Keywords_Keywords]
GO
ALTER TABLE [dbo].[PendingContainers]  WITH CHECK ADD  CONSTRAINT [FK_PendingContainers_ContainerTypes] FOREIGN KEY([ContainerType])
REFERENCES [dbo].[ContainerTypes] ([ID])
GO
ALTER TABLE [dbo].[PendingContainers] CHECK CONSTRAINT [FK_PendingContainers_ContainerTypes]
GO
USE [master]
GO
ALTER DATABASE [Craal] SET  READ_WRITE 
GO
