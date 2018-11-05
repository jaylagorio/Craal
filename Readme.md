# Craal
Automating search and retrieval of data you think is interesting

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Data Processors](#dataprocessors)
- [Database Tables](#databasetables)

<a name="introduction"></a>

## Introduction
Everyone is putting all of their data in the cloud, and many are putting interesting data there without properly locking it down. There's too much interesting data to search for manually, so I built an automated system that could find files of interest from multiple sources and catalog them easily. For bonus points I built a rudimentary display system although not being a front-end web developer the keyword here really is "rudimentary." It's pretty trashy but it gets the job done somewhat.

Craal, built on the Microsoft stack, searches through Pastebin, GitHub, and Amazon S3 Buckets in as near real-time as possible and highlights data of interest based on keywords. You can look through the data that was gathered with the web interface and in some cases display the data in a pretty format. In all other cases you display the raw data in the browser or you download and display it in some other application.

The automation portion of this project is the real time saver but without data sources there would be nothing to automate, so for that I'd like to thank [protoxin](https://twitter.com/protoxin_), [Cali Dog Security](https://github.com/calidog), and [Pastebin](https://twitter.com/pastebin) for being the root causes of any value people find here.

<a name="installation"></a>

## Installation
Installation isn't really straightforward yet -  there is no Easy Button installer and some service tokens will need to be compiled into the service by the user before putting the binaries in place. Below is a list of software versions I use, but other versions may work just as well.

### Software Requirements
- [Windows Server 2016](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016)
- [IIS 8.5/ASP.NET 4.6](https://www.iis.net/) with the Web Management Service installed and enabled
- [Microsoft Web Platform Installer 5.0](https://www.microsoft.com/web/downloads/platform.aspx) to install Web Deploy 3.6
- [Microsoft SQL Server 2016](https://www.microsoft.com/en-us/sql-server/sql-server-2016)
- [Visual Studio 2017](https://www.visualstudio.com/vs/professional/)
- [Windows 10 SDK](https://developer.microsoft.com/en-US/windows/downloads/windows-10-sdk)
- [.NET Framework 4.6](https://blogs.msdn.microsoft.com/dotnet/2015/07/20/announcing-net-framework-4-6/)

### Service Requirements
Some of the services being searched require API tokens and/or a subscription. If you don't want to use a particular service it can be easily disabled in source code before compiling for your environment.

- [GitHub](https://github.com/): API Token (<https://github.com/blog/1509-personal-api-tokens>).
- [Pastebin](https://pastebin.com/): Subscription (<https://pastebin.com/pro>), then whitelist your IP address.
- S3 Buckets: No requirements (other than access tokens you might need to access individual Buckets).
- [Protoxin](https://protoxin.net/api/): No requirements.
- [CertStream](certstream.calidog.io/): No requirements.

### Change the ``config.json``, ``web.config``, and ``InitializeDatabase.sql`` Files
There are several constants, service settings, or script modifications that need to be made so your system can query the service.

1. After you sign up for Pastebin you'll need to [whitelist your IP address](https://pastebin.com/api_scraping_faq).
1. Change the ``CraalConnectionString`` item in ``web.config`` item to point to your SQL Server instance.
1. Change the ``DatabaseConnectionString`` in ``config.json`` item to point to your SQL Server instance.
1. Add your ``GitHubToken`` and modify the ``GitHubUserAgent`` string to include your GitHub username. Both of these need to be changed to include your GitHub personal token and your username in the User Agent.
1. Update ``GenericAWSAccessKey`` and ``GenericAWSSecretKey`` to a pair you create on Amazon AWS. They don't have to have capabilities assigned to them, they just have to successfully authenticate to the service.
1. The ``InitializeDatabase.sql`` script has hard-coded paths to SQL Server files that will store the database in the ``CREATE DATABASE`` statement. Change these files to suit your environment.
1. The ``InitializeDatabase.sql`` script has hard-coded computer names with ``db_datareader`` and ``db_datawriter`` permissions in the ``CREATE USER`` and ``ALTER ROLE`` statements. Change these to suit your environment.
1. The ``msdb.dbo.sp_add_job`` call in ``InitializeDatabase.sql`` script has a ``@owner_login_name`` variable that needs to be changed to a user who can make modifications to the database.

Once all code changes are made use the Build Solution function to build.

### Deploy to Servers
This project was made for flexibility in deployment scenarios. As long as the service and the web application can each access the SQL Server it doesn't matter if they're on the same or different servers. They don't have explicit dependencies on each other, but they do require identical copies of the ``CraalDatabase`` library included in the solution.

#### Database setup
1. Install  SQL Server and ensure SQL Server Agent is installed and running.
1. Run the ``InitializeDatabase.sql`` script in a new query window in the SQL Server Management Studio.
1. Give the Computer Account of the system running the Craal Service read/write access to the Craal database. This isn't intuitive, so run this command: `CREATE LOGIN 'DOMAIN\Computer$' FROM WINDOWS;`
1. If you add authentication on the web server's Web Site or Application, give the username you plan to use read permissions on the database.

#### System service
1. Create ``C:\Program Files\Craal`` and copy ``config.json``, ``AWSSDK.Core.dll``, ``AWSSDK.S3.dll``, ``CraalDatabase.dll``, and ``CraalService.exe`` to that directory.
1. Open a command prompt window in that directory and run ``C:\Windows\Microsoft.NET\Framework\v4.0.30319\installutil.exe CraalService.exe``.
1. Run ``net start "Craal Service"`` to start the service.

#### ASP.NET application
1. In IIS Manager on the web server create a new Web Site or Application with the appropriate attributes. Make sure to add ``index.aspx`` as a file name in the Default Document feature.
1. Run the Microsoft Web Platform Installer and install Web Deploy 3.6.
1. Enable the user account you plan to deploy with by using the IIS Manager Permissions feature in the Web Site or Application configuration window.
1. In Visual Studio right-click the Craal project in the Craal solution and click Publish.
1. Click the IIS, FTP, etc button and then click the Publish button.
1. For the Web Deploy method fill out the requested data and click Save. You may need to reenter your password during the deployment process. This should be the only step necessary for future Publish operations to this server.
1. Browse to the Web Site or Application and verify that you can see the index page.

<a name="dataprocessors"></a>

## Data Processors
The goal is to automate as much data ingestion and identification as possible using these services. Each requires its own processing module and each can easily be disabled in the ``CraalService`` module.

### Pastebin
Pastebin allows you to subscribe to their service to hit an endpoint to scrape up to 250 newly posted pastes. After some testing it doesn't appear that more than 250 pastes are added in a 2 minute period so that's how often the endpoint is queried. Once a paste is pulled down it's checked against the ``Keywords`` database table. If a keyword is found to match the paste and the matching keywords are added to the ``Content`` table and the list of matching keywords is saved with it. You can view pastes within the front-end web app.

### GitHub
Lots of things that shouldn't be on GitHub end up on GitHub, so this data processor goes looking for them. Rather than get a firehose into what gets posted as with Pastebin, this process involves using the search interface and looking for each keyword in turn. When a search is returned all of the commits are examined for the files they contain and each file is added to the ``PendingDownloads`` table to be picked up by the ``DownloadProcessor`` module later.

### S3 Buckets
There are lots of ways to ingest S3 Buckets, but the best way is to find them automatically! Two techniques are employed to do this, plus there's an interface to manually queue them for examination when you find them yourself.

- Protoxin: Protoxin publishes an endpoint that lists all of the Buckets he has identified, about 17,700 as of this commit. Every 24 hours the ``ProtoxinProcessor`` module queries the service and compares them to the Buckets listed in the  ``DiscoveredBuckets`` table. If the Bucket name isn't in the list it gets added for later download.
- CertStream: The ``CertStreamProcessor`` module opens a ``ClientWebSocket`` to the CertStream service and watches for ``certificate_update`` messages. When one comes in it inspects the ``leaf_cert.all_domains`` array for domain names. If any end in ``.s3.amazon.com`` it strips the FQDN down to just the Bucket name and adds it to the ``DiscoveredBuckets`` database table.
- Manual: Users can add Buckets and any relevant AWS credentials to the ``PendingBuckets`` table using the web interface.

Once a Bucket has been identified, the ``AmazonS3Processor`` module. Every 5 minutes the module checks to see if the ``DiscoveredBuckets`` database table has any entries where the ``Queued`` attribute is 0 and, if it does, adds them to the ``PendingBuckets`` table. Once that operation is complete it checks the ``PendingBuckets`` table for any new downloads and, finding any, loops through all of them. It uses the ``AmazonS3Client`` to access the bucket (using AWS credentials if provided)  and checks whether there are any filenames that match the list in the ``Keywords`` table. If the file is less than 2 GB in size it queues the file for download in the ``PendingDownloads`` table, otherwise the file is skipped.

### File Downloads
Every 5 minutes the ``DownloadProcessor`` module checks the ``PendingDownloads`` table to see if there are any files to be downloaded and stored in the ``Content`` table. The queue gets worked as fetched from the database until empty and as a file arrives its entry in ``PendingDownloads`` is deleted. Once the entire queue of files has been completed at the time the list was fetched from the table the thread sleeps for 5 minutes until another check is made and the process repeats. This means that a file added to the table in the middle of a download cycle will wait until the next cycle to be downloaded. Due to the speed at which files are downloaded it may take more than 5 minutes from the start of one download cycle to the start of the next.

<a name="databasetables"></a>

## Database Tables
Storage for the system is contained solely in SQL database tables. The only functionality that isn't contained in the service is a SQL Server Agent Job, ``Purge Craal``, that deletes data from the ``Content`` table two weeks after it's been downloaded.

### DataSources
Maps a data source ID with the name of that data source so the processing module can find its keywords.

1. ``ID``: The ID number of the data source. This can be arbitrary as long as it's consistent throughout the database.
1. ``Name``: The human-readable name of the data source.

### ContainerTypes
Maps a Container's ID with the name of that Container so the processing modules that process Amazon S3 Buckets, Azure Storage Blobs, and DigitalOcean Spaces can process only the content meant for them.

1. ``ID``: The ID number of the Container type. These values must be hard-coded to the values in ``CraalDatabase.Database.ContainerType``.
1. ``TypeName``: The human-readable name of the Container type.

### Keywords
Contains the keywords that the processing modules search for. The keyword must be mapped to a data source ID so that the processor knows to use that keyword only for that data source.

1. ``ID``: The incrementing identity column used to identify an entry.
1. ``DataSource``: The ID of the data source that this keyword is used for, Foreign Key mapped to the ``ID`` column in ``DataSources``.
1. ``Keyword``: The keyword to match.

### Content
The ``Content`` table is the destination for all data determined to be of interest based on the keyword searches. Pastes, GitHub commits, and Bucket files all end up in this table for later inspection.

1. ``ID``: A unique identifier for this row in the table.
1. ``CollectedTime``: The date and time the file was found and added to the table.
1. ``DataSource``: The data source ID. This is a Foreign Key relationship to the ``ID`` column of the ``DataSources`` table.
1. ``Keywords``: A comma-separated list of keywords contained in the file that caused it to be collected.
1. ``SourceURL``: The file's download URL.
1. ``Hash``: A hash of the file. The type of hash is determined by the service hosting the original file.
1. ``Data``: If the file was identified but not yet download, this will be the URL of the file to be downloaded. Once the file is downloaded this is replaced by the raw file contents. This column can be up to 2 GB per entry.
1. ``Viewed``: If the file hasn't been viewed by someone looking for interesting files this column is ``NULL`` or 0. Once it's viewed in the web front-end it gets set to 1.

### DiscoveredBuckets
A list of all Buckets that were discovered with an automated process of some kind. Manually queued Buckets do not end up in this list.

1. ``ID``: A unique identifier for the entry.
1. ``BucketName``: The name of the Bucket.
1. ``AwsAccessKey``: The access key, if needed, to access the Bucket. This can be ``NULL``.
1. ``AwsSecretKey``: The secret key, if needed, to access the Bucket. This can be ``NULL``.
1. ``Queued``: This column is set to ``NULL`` or 0 if the Bucket has not yet been queued for download. If the Bucket has been queued for download this column is set to 1.
1. ``ContainerType``: The type of container (S3 Bucket, Azure Blob, etc). THis is a Foreign Key relationship to the ``ID`` column of the ``ContainerTypes`` table.

### PendingBuckets
This is a list of Buckets whose content will be searched and downloaded on the next cycle.

1. ``ID``: A unique identifier for the entry.
1. ``BucketName``: The name of the Bucket.
1. ``AwsAccessKey``: The access key, if needed, to access the Bucket. This can be ``NULL``.
1. ``AwsSecretKey``: The secret key, if needed, to access the Bucket. This can be ``NULL``.
1. ``ContainerType``: The type of container (S3 Bucket, Azure Blob, etc). THis is a Foreign Key relationship to the ``ID`` column of the ``ContainerTypes`` table.

### PendingDownloads
This table contains a list of all files remaining to be downloaded to the ``Content`` table.

1. ``SourceURL``:  The URL of the file to download.
1. ``Hash``: The hash of the file. Exactly which type of hash will depend on the service the file was found on. Used to locate the entry in the ``Content`` table to store the data once it's retrieved.
