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
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (107, 2, N'.mlab.com password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (108, 2, N'WFClient Password extension:ica')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (109, 2, N'access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (110, 2, N'access_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (111, 2, N'admin_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (112, 2, N'admin_user')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (113, 2, N'algolia_admin_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (114, 2, N'algolia_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (115, 2, N'alias_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (116, 2, N'alicloud_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (117, 2, N'amazon_secret_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (118, 2, N'amazonaws')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (119, 2, N'ansible_vault_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (120, 2, N'aos_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (121, 2, N'api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (122, 2, N'api_key_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (123, 2, N'api_key_sid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (124, 2, N'api_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (125, 2, N'api.googlemaps AIza')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (126, 2, N'apidocs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (127, 2, N'apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (128, 2, N'apiSecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (129, 2, N'app_debug')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (130, 2, N'app_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (131, 2, N'app_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (132, 2, N'app_log_level')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (133, 2, N'app_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (134, 2, N'appkey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (135, 2, N'appkeysecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (136, 2, N'application_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (137, 2, N'appsecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (138, 2, N'appspot')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (139, 2, N'auth_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (140, 2, N'authorizationToken')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (141, 2, N'authsecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (142, 2, N'aws_access')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (143, 2, N'aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (144, 2, N'aws_bucket')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (145, 2, N'aws_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (146, 2, N'aws_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (147, 2, N'aws_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (148, 2, N'aws_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (149, 2, N'AWSSecretKey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (150, 2, N'b2_app_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (151, 2, N'bashrc password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (152, 2, N'bintray_apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (153, 2, N'bintray_gpg_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (154, 2, N'bintray_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (155, 2, N'bintraykey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (156, 2, N'bluemix_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (157, 2, N'bluemix_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (158, 2, N'browserstack_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (159, 2, N'bucket_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (160, 2, N'bucketeer_aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (161, 2, N'bucketeer_aws_secret_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (162, 2, N'built_branch_deploy_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (163, 2, N'bx_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (162, 2, N'cache_driver')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (163, 2, N'cache_s3_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (164, 2, N'cattle_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (165, 2, N'cattle_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (166, 2, N'certificate_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (167, 2, N'ci_deploy_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (168, 2, N'client_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (169, 2, N'client_zpk_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (170, 2, N'clojars_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (171, 2, N'cloud_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (172, 2, N'cloud_watch_aws_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (173, 2, N'cloudant_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (174, 2, N'cloudflare_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (175, 2, N'cloudflare_auth_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (176, 2, N'cloudinary_api_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (177, 2, N'cloudinary_name')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (178, 2, N'codecov_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (179, 2, N'config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (180, 2, N'conn.login')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (181, 2, N'connectionstring')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (182, 2, N'consumer_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (183, 2, N'consumer_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (184, 2, N'credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (185, 2, N'cypress_record_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (186, 2, N'database_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (187, 2, N'database_schema_test')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (188, 2, N'datadog_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (189, 2, N'datadog_app_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (190, 2, N'db_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (191, 2, N'db_server')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (192, 2, N'db_username')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (193, 2, N'dbpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (194, 2, N'dbpassword')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (195, 2, N'dbuser')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (196, 2, N'deploy_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (197, 2, N'digitalocean_ssh_key_body')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (198, 2, N'digitalocean_ssh_key_ids')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (199, 2, N'docker_hub_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (200, 2, N'docker_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (201, 2, N'docker_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (202, 2, N'docker_passwd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (203, 2, N'docker_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (204, 2, N'dockerhub_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (205, 2, N'dockerhubpassword')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (206, 2, N'dot-files')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (207, 2, N'dotfiles')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (208, 2, N'droplet_travis_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (209, 2, N'dynamoaccesskeyid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (210, 2, N'dynamosecretaccesskey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (211, 2, N'elastica_host')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (212, 2, N'elastica_port')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (213, 2, N'elasticsearch_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (214, 2, N'encryption_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (215, 2, N'encryption_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (216, 2, N'env.heroku_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (217, 2, N'env.sonatype_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (218, 2, N'eureka.awssecretkey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (219, 2, N'extension:avastlic support.avast.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (220, 2, N'extension:bat')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (221, 2, N'extension:cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (222, 2, N'extension:dbeaver-data-sources.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (223, 2, N'extension:env')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (224, 2, N'extension:exs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (225, 2, N'extension:ini')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (226, 2, N'extension:json api.forecast.io')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (227, 2, N'extension:json googleusercontent client_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (228, 2, N'extension:json mongolab.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (229, 2, N'extension:pem')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (230, 2, N'extension:pem private')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (231, 2, N'extension:ppk')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (232, 2, N'extension:ppk private')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (233, 2, N'extension:properties')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (234, 2, N'extension:sh')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (235, 2, N'extension:sls')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (236, 2, N'extension:sql')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (237, 2, N'extension:sql mysql dump')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (238, 2, N'extension:sql mysql dump password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (239, 2, N'extension:yaml mongolab.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (240, 2, N'extension:zsh')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (241, 2, N'fabricApiSecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (242, 2, N'facebook_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (243, 2, N'fb_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (244, 2, N'filename:_netrc password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (245, 2, N'filename:.bash_history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (246, 2, N'filename:.bash_profile aws')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (247, 2, N'filename:.bashrc mailchimp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (248, 2, N'filename:.bashrc password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (249, 2, N'filename:.cshrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (250, 2, N'filename:.dockercfg auth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (251, 2, N'filename:.env DB_USERNAME NOT homestead')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (252, 2, N'filename:.env MAIL_HOSTsmtp.gmail.com')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (253, 2, N'filename:.esmtprc password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (254, 2, N'filename:.ftpconfig')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (255, 2, N'filename:.git-credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (256, 2, N'filename:.history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (257, 2, N'filename:.htpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (258, 2, N'filename:.netrc password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (259, 2, N'filename:.npmrc _auth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (260, 2, N'filename:.pgpass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (261, 2, N'filename:.remote-sync.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (262, 2, N'filename:.s3cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (263, 2, N'filename:.sh_history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (264, 2, N'filename:.tugboat NOT _tugboat')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (265, 2, N'filename:bash')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (266, 2, N'filename:bash_history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (267, 2, N'filename:bash_profile')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (268, 2, N'filename:bashrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (269, 2, N'filename:beanstalkd.yml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (270, 2, N'filename:CCCam.cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (271, 2, N'filename:composer.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (272, 2, N'filename:config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (273, 2, N'filename:config irc_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (274, 2, N'filename:config.json auths')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (275, 2, N'filename:config.php dbpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (276, 2, N'filename:configuration.php JConfig password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (277, 2, N'filename:connections')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (278, 2, N'filename:connections.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (279, 2, N'filename:constants')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (280, 2, N'filename:credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (281, 2, N'filename:credentials aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (282, 2, N'filename:cshrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (283, 2, N'filename:database')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (284, 2, N'filename:dbeaver-data-sources.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (285, 2, N'filename:deploy.rake')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (286, 2, N'filename:deployment-config.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (287, 2, N'filename:dhcpd.conf')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (288, 2, N'filename:dockercfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (289, 2, N'filename:env')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (290, 2, N'filename:environment')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (291, 2, N'filename:express.conf')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (292, 2, N'filename:express.conf path:.openshift')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (293, 2, N'filename:filezilla.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (294, 2, N'filename:filezilla.xml Pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (295, 2, N'filename:git-credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (296, 2, N'filename:gitconfig')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (297, 2, N'filename:global')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (298, 2, N'filename:history')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (299, 2, N'filename:htpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (300, 2, N'filename:hub oauth_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (301, 2, N'filename:id_dsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (302, 2, N'filename:id_rsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (303, 2, N'filename:id_rsa or filename:id_dsa')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (304, 2, N'filename:idea14.key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (305, 2, N'filename:known_hosts')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (306, 2, N'filename:logins.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (307, 2, N'filename:makefile')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (308, 2, N'filename:master.key path:config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (309, 2, N'filename:netrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (310, 2, N'filename:npmrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (311, 2, N'filename:pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (312, 2, N'filename:passwd path:etc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (313, 2, N'filename:pgpass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (314, 2, N'filename:prod.exs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (315, 2, N'filename:prod.exs NOT prod.secret.exs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (316, 2, N'filename:prod.secret.exs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (317, 2, N'filename:proftpdpasswd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (318, 2, N'filename:recentservers.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (319, 2, N'filename:recentservers.xml Pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (320, 2, N'filename:robomongo.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (321, 2, N'filename:s3cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (322, 2, N'filename:secrets.yml password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (323, 2, N'filename:server.cfg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (324, 2, N'filename:server.cfg rcon password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (325, 2, N'filename:settings')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (326, 2, N'filename:settings.py SECRET_KEY')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (327, 2, N'filename:sftp-config.json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (328, 2, N'filename:sftp.json path:.vscode')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (329, 2, N'filename:shadow')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (330, 2, N'filename:shadow path:etc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (331, 2, N'filename:spec')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (332, 2, N'filename:sshd_config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (333, 2, N'filename:tugboat')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (334, 2, N'filename:ventrilo_srv.ini')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (335, 2, N'filename:WebServers.xml')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (336, 2, N'filename:wp-config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (337, 2, N'filename:wp-config.php')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (338, 2, N'filename:zhrc')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (339, 2, N'firebase')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (340, 2, N'flickr_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (341, 2, N'fossa_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (342, 2, N'ftp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (343, 2, N'ftp_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (344, 2, N'gatsby_wordpress_base_url')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (345, 2, N'gatsby_wordpress_client_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (346, 2, N'gatsby_wordpress_user')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (347, 2, N'gh_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (348, 2, N'gh_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (349, 2, N'ghost_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (350, 2, N'github_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (351, 2, N'github_deploy_hb_doc_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (352, 2, N'github_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (353, 2, N'github_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (354, 2, N'github_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (355, 2, N'github_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (356, 2, N'gitlab')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (357, 2, N'gmail_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (358, 2, N'gmail_username')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (359, 2, N'google_maps_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (360, 2, N'google_private_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (361, 2, N'google_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (362, 2, N'google_server_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (363, 2, N'gpg_key_name')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (364, 2, N'gpg_keyname')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (365, 2, N'gpg_passphrase')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (366, 2, N'HEROKU_API_KEY language:json')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (367, 2, N'HEROKU_API_KEY language:shell')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (368, 2, N'heroku_oauth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (369, 2, N'heroku_oauth_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (370, 2, N'heroku_oauth_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (371, 2, N'heroku_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (372, 2, N'heroku_secret_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (373, 2, N'herokuapp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (374, 2, N'HOMEBREW_GITHUB_API_TOKEN language:shell')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (375, 2, N'htaccess_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (376, 2, N'htaccess_user')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (377, 2, N'incident_channel_name')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (378, 2, N'internal')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (379, 2, N'irc_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (380, 2, N'JEKYLL_GITHUB_TOKEN')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (381, 2, N'jsforce extension:js conn.login')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (382, 2, N'jwt_client_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (383, 2, N'jwt_lookup_secert_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (384, 2, N'jwt_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (385, 2, N'jwt_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (386, 2, N'jwt_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (387, 2, N'jwt_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (388, 2, N'jwt_user')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (389, 2, N'jwt_web_secert_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (390, 2, N'jwt_xmpp_secert_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (391, 2, N'key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (392, 2, N'keyPassword')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (393, 2, N'language:yaml -filename:travis')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (394, 2, N'ldap_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (395, 2, N'ldap_username')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (396, 2, N'linux_signing_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (397, 2, N'll_shared_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (398, 2, N'location_protocol')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (399, 2, N'log_channel')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (400, 2, N'login')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (401, 2, N'lottie_happo_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (402, 2, N'lottie_happo_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (403, 2, N'lottie_s3_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (404, 2, N'lottie_s3_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (405, 2, N'magento password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (406, 2, N'mail_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (407, 2, N'mail_port')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (408, 2, N'mailchimp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (409, 2, N'mailchimp_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (410, 2, N'mailchimp_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (411, 2, N'mailgun')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (412, 2, N'mailgun apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (413, 2, N'mailgun_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (414, 2, N'mailgun_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (415, 2, N'mailgun_priv_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (416, 2, N'mailgun_secret_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (417, 2, N'manage_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (418, 2, N'mandrill_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (419, 2, N'mapbox api key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (420, 2, N'master_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (421, 2, N'mg_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (422, 2, N'mg_public_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (423, 2, N'mh_apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (424, 2, N'mh_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (425, 2, N'mile_zero_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (426, 2, N'minio_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (427, 2, N'minio_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (428, 2, N'mix_pusher_app_cluster')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (429, 2, N'mix_pusher_app_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (430, 2, N'msg nickserv identify filename:config')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (431, 2, N'mydotfiles')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (432, 2, N'mysql')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (433, 2, N'mysql password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (434, 2, N'mysql_root_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (435, 2, N'netlify_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (436, 2, N'nexus password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (437, 2, N'nexus_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (438, 2, N'node_env')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (439, 2, N'node_pre_gyp_accesskeyid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (440, 2, N'node_pre_gyp_secretaccesskey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (441, 2, N'npm_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (442, 2, N'npm_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (443, 2, N'npm_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (444, 2, N'npmrc _auth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (445, 2, N'nuget_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (446, 2, N'nuget_apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (447, 2, N'nuget_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (448, 2, N'oauth_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (449, 2, N'object_storage_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (450, 2, N'octest_app_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (451, 2, N'octest_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (452, 2, N'okta_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (453, 2, N'omise_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (454, 2, N'onesignal_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (456, 2, N'onesignal_user_auth_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (457, 2, N'openwhisk_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (458, 2, N'org_gradle_project_sonatype_nexus_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (459, 2, N'org_project_gradle_sonatype_nexus_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (460, 2, N'os_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (461, 2, N'ossrh_jira_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (462, 2, N'ossrh_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (463, 2, N'ossrh_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (464, 2, N'pagerduty_apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (465, 2, N'parse_js_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (466, 2, N'pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (467, 2, N'passwd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (468, 2, N'password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (469, 2, N'password travis')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (470, 2, N'passwords')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (471, 2, N'path:sites databases password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (472, 2, N'paypal_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (473, 2, N'paypal_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (474, 2, N'pem private')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (475, 2, N'personal_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (476, 2, N'playbooks_url')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (477, 2, N'plotly_apikey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (478, 2, N'plugin_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (479, 2, N'postgres_env_postgres_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (480, 2, N'postgresql_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (481, 2, N'preprod')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (482, 2, N'private')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (483, 2, N'private -language:java')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (484, 2, N'private_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (485, 2, N'private_signing_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (486, 2, N'prod')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (487, 2, N'prod_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (488, 2, N'prod.access.key.id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (489, 2, N'prod.secret.key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (490, 2, N'PT_TOKEN language:bash')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (491, 2, N'publish_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (492, 2, N'pusher_app_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (493, 2, N'pwd')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (494, 2, N'queue_driver')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (495, 2, N'rabbitmq_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (496, 2, N'rds.amazonaws.com password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (497, 2, N'redis_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (498, 2, N'response_auth_jwt_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (499, 2, N'rest_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (500, 2, N'rinkeby_private_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (501, 2, N'root_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (502, 2, N'ropsten_private_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (503, 2, N'route53_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (504, 2, N'rtd_key_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (505, 2, N'rtd_store_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (506, 2, N's3_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (507, 2, N's3_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (508, 2, N's3_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (509, 2, N's3_key_app_logs')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (510, 2, N's3_key_assets')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (511, 2, N's3_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (512, 2, N'salesforce_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (513, 2, N'sandbox_aws_access_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (514, 2, N'sandbox_aws_secret_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (515, 2, N'sauce_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (516, 2, N'secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (517, 2, N'secret access key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (518, 2, N'secret_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (519, 2, N'secret_bearer')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (520, 2, N'secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (521, 2, N'secret_key_base')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (522, 2, N'secret_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (523, 2, N'secret.password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (524, 2, N'secretaccesskey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (525, 2, N'secretkey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (526, 2, N'secrets')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (527, 2, N'secure')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (528, 2, N'security_credentials')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (529, 2, N'send_keys')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (530, 2, N'send.keys')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (531, 2, N'sendgrid_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (532, 2, N'sendgrid_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (533, 2, N'sendgrid_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (534, 2, N'sendkeys')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (535, 2, N'ses_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (536, 2, N'ses_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (537, 2, N'setdstaccesskey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (538, 2, N'setsecretkey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (539, 2, N'sf_username')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (540, 2, N'SF_USERNAME salesforce')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (541, 2, N'shodan_api_key language:python')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (542, 2, N'sid_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (543, 2, N'signing_key_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (544, 2, N'signing_key_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (545, 2, N'slack_api')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (546, 2, N'slack_channel')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (547, 2, N'slack_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (548, 2, N'slack_outgoing_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (549, 2, N'slack_signing_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (550, 2, N'slack_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (551, 2, N'slack_webhook')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (552, 2, N'slash_developer_space_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (553, 2, N'snoowrap_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (554, 2, N'socrata_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (555, 2, N'sonar_organization_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (556, 2, N'sonar_project_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (557, 2, N'sonatype_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (558, 2, N'sonatype_token_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (559, 2, N'soundcloud_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (560, 2, N'sql_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (561, 2, N'sqsaccesskey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (562, 2, N'square_access_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (563, 2, N'square_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (564, 2, N'squareSecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (565, 2, N'ssh')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (566, 2, N'ssh2_auth_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (567, 2, N'sshpass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (568, 2, N'staging')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (569, 2, N'stg')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (570, 2, N'storePassword')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (571, 2, N'stormpath_api_key_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (572, 2, N'stormpath_api_key_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (573, 2, N'strip_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (574, 2, N'strip_secret_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (575, 2, N'stripe')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (576, 2, N'stripe_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (577, 2, N'stripe_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (578, 2, N'stripToken')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (579, 2, N'svn_pass')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (580, 2, N'swagger')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (581, 2, N'tesco_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (582, 2, N'tester_keys_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (583, 2, N'testuser')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (584, 2, N'thera_oss_access_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (585, 2, N'token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (586, 2, N'trusted_hosts')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (587, 2, N'twilio_account_sid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (588, 2, N'twilio_accountsid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (589, 2, N'twilio_api_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (590, 2, N'twilio_api_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (591, 2, N'twilio_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (592, 2, N'twilio_secret_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (593, 2, N'TWILIO_SID NOT env')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (594, 2, N'twilio_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (595, 2, N'twilioapiauth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (596, 2, N'twiliosecret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (597, 2, N'twine_password')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (598, 2, N'twitter_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (599, 2, N'twitterKey')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (600, 2, N'x-api-key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (601, 2, N'xoxb ')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (602, 2, N'xoxp')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (603, 2, N'zen_tkn')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (604, 2, N'zen_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (605, 2, N'zendesk_url')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (606, 2, N'twilio secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (607, 2, N'twilio_account_id')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (608, 2, N'twilio_account_secret')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (609, 2, N'twilio_acount_sid NOT env')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (610, 2, N'twilio_api')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (611, 2, N'twilio_api_auth')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (612, 2, N'twilio_api_sid')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (613, 2, N'twilio_api_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (614, 2, N'zen_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (615, 2, N'zendesk_api_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (616, 2, N'zendesk_key')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (617, 2, N'zendesk_token')
GO
INSERT [dbo].[Keywords] ([ID], [DataSource], [Keyword]) VALUES (618, 2, N'zendesk_username')
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
