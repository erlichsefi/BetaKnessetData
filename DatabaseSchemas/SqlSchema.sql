/****** Object:  Database [BetaKnesset]    Script Date: 2/26/2021 23:28:10 ******/
CREATE DATABASE [BetaKnesset]  (EDITION = 'Standard', SERVICE_OBJECTIVE = 'S1', MAXSIZE = 250 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS;
GO
ALTER DATABASE [BetaKnesset] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE [BetaKnesset] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BetaKnesset] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BetaKnesset] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BetaKnesset] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BetaKnesset] SET ARITHABORT OFF 
GO
ALTER DATABASE [BetaKnesset] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BetaKnesset] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BetaKnesset] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BetaKnesset] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BetaKnesset] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BetaKnesset] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BetaKnesset] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BetaKnesset] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BetaKnesset] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [BetaKnesset] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BetaKnesset] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [BetaKnesset] SET  MULTI_USER 
GO
ALTER DATABASE [BetaKnesset] SET ENCRYPTION ON
GO
ALTER DATABASE [BetaKnesset] SET QUERY_STORE = ON
GO
ALTER DATABASE [BetaKnesset] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
/*** The scripts of database scoped configurations in Azure should be executed inside the target database connection. ***/
GO
-- ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
GO
/****** Object:  FullTextCatalog [KNS_FullText]    Script Date: 2/26/2021 23:28:10 ******/
CREATE FULLTEXT CATALOG [KNS_FullText] WITH ACCENT_SENSITIVITY = OFF
GO
/****** Object:  Table [dbo].[KNS_PlenumSession]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_PlenumSession](
	[PlenumSessionID] [int] NOT NULL,
	[Number] [int] NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[StartDate] [datetime2](7) NULL,
	[FinishDate] [datetime2](7) NULL,
	[IsSpecialMeeting] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PlenumSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_PlmSessionItem]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_PlmSessionItem](
	[plmPlenumSessionID] [int] NOT NULL,
	[ItemID] [int] NULL,
	[PlenumSessionID] [int] NULL,
	[ItemTypeID] [int] NULL,
	[ItemTypeDesc] [varchar](125) NULL,
	[Ordinal] [bigint] NULL,
	[Name] [varchar](255) NULL,
	[StatusID] [int] NULL,
	[IsDiscussion] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[plmPlenumSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentPlenumSession]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentPlenumSession](
	[DocumentPlenumSessionID] [bigint] NOT NULL,
	[PlenumSessionID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentPlenumSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AUG_PlenumSchedule]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_PlenumSchedule] WITH SCHEMABINDING AS
SELECT
i.plmPlenumSessionID,
i.Name AS PlenumSessionItemName,
i.Ordinal,
i.ItemTypeID,
i.StatusID,
d.FilePath,
d.DocumentPlenumSessionID,
d.LastUpdatedDate AS DocumentPlenumSessionLastUpdatedDate,
s.PlenumSessionID, 
s.[Number] AS PlenumSessionNumber, 
s.KnessetNum,
s.Name AS PlenumSessionName, 
s.StartDate AS PlenumSessionStartDate, 
s.FinishDate AS PlenumSessionFinishDate, 
s.IsSpecialMeeting, 
s.LastUpdatedDate AS PlenumSessionLastUpdatedDate
FROM [dbo].KNS_PlenumSession s 
JOIN [dbo].KNS_DocumentPlenumSession d 
	ON d.PlenumSessionID = s.PlenumSessionID
		AND d.ApplicationID = 1 -- doc
		AND d.GroupTypeID = 28 -- divrey knesset
		AND s.StartDate >= '2015-01-01' -- documents started to be in relevant format
JOIN [dbo].KNS_PlmSessionItem i
	ON i.PlenumSessionID = s.PlenumSessionID 
GO
/****** Object:  View [dbo].[AUG_PlenumRelevantDocuments]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_PlenumRelevantDocuments] AS
SELECT s.StartDate, d.DocumentPlenumSessionID, d.FilePath 
FROM KNS_PlenumSession s
JOIN KNS_DocumentPlenumSession d on d.PlenumSessionID = s.PlenumSessionID 
WHERE d.ApplicationID = 1
AND d.GroupTypeID = 28
AND s.StartDate > DATEADD(MONTH, -1, GETDATE())
GO
/****** Object:  Table [dbo].[KNS_CommitteeSession]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_CommitteeSession](
	[CommitteeSessionID] [int] NOT NULL,
	[Number] [int] NULL,
	[KnessetNum] [int] NULL,
	[TypeID] [int] NULL,
	[TypeDesc] [varchar](125) NULL,
	[CommitteeID] [int] NULL,
	[StatusID] [int] NULL,
	[StatusDesc] [varchar](50) NULL,
	[Location] [nvarchar](500) NULL,
	[SessionUrl] [nvarchar](500) NULL,
	[BroadcastUrl] [nvarchar](500) NULL,
	[StartDate] [datetime2](7) NULL,
	[FinishDate] [datetime2](7) NULL,
	[Note] [varchar](500) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[CommitteeSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentCommitteeSession]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentCommitteeSession](
	[DocumentCommitteeSessionID] [bigint] NOT NULL,
	[CommitteeSessionID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentCommitteeSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AUG_CommitteeRelevantDocuments]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_CommitteeRelevantDocuments] AS
SELECT s.StartDate, d.DocumentCommitteeSessionID, d.FilePath 
FROM KNS_CommitteeSession s
JOIN KNS_DocumentCommitteeSession d on d.CommitteeSessionID = s.CommitteeSessionID 
WHERE d.ApplicationID = 1
AND d.GroupTypeID = 23
AND s.StartDate > DATEADD(MONTH, -1, GETDATE())
GO
/****** Object:  View [dbo].[AUG_PlenumMissingQuotes]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_PlenumMissingQuotes] AS
SELECT s.StartDate, d.DocumentPlenumSessionID, d.FilePath 
FROM KNS_PlenumSession s
JOIN KNS_DocumentPlenumSession d on d.PlenumSessionID = s.PlenumSessionID 
LEFT JOIN AUG_PlenumQuotes q on q.DocumentPlenumSessionID = d.DocumentPlenumSessionID 
WHERE d.ApplicationID = 1
AND d.GroupTypeID = 28
AND s.StartDate > '2015-01-01'
AND q.PlenumQuoteID IS NULL
GO
/****** Object:  View [dbo].[AUG_CommitteeMissingQuotes]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_CommitteeMissingQuotes] AS
SELECT s.StartDate, d.DocumentCommitteeSessionID, d.FilePath 
FROM KNS_CommitteeSession s
JOIN KNS_DocumentCommitteeSession d on d.CommitteeSessionID = s.CommitteeSessionID 
LEFT JOIN AUG_CommitteeQuotes q on q.DocumentCommitteeSessionID = d.DocumentCommitteeSessionID 
WHERE d.ApplicationID = 1
AND d.GroupTypeID = 23
AND s.StartDate > '2015-01-01'
AND q.CommitteeQuoteID IS NULL
GO
/****** Object:  Table [dbo].[KNS_Person]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Person](
	[PersonID] [int] NOT NULL,
	[LastName] [varchar](50) NULL,
	[FirstName] [varchar](50) NULL,
	[GenderID] [int] NULL,
	[GenderDesc] [varchar](125) NULL,
	[Email] [varchar](100) NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AUG_GovernmentPersonalData]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUG_GovernmentPersonalData](
	[﻿MkID] [int] NOT NULL,
	[LastName] [varchar](1024) NULL,
	[FirstName] [varchar](1024) NULL,
	[FullName] [varchar](1024) NULL,
	[BirthDate] [date] NULL,
	[YearDate] [real] NULL,
	[BirthDateHeb] [varchar](1024) NULL,
	[DeathDate] [date] NULL,
	[DeathDateHeb] [varchar](1024) NULL,
	[YearDeathDate] [real] NULL,
	[ImmigrationDate] [varchar](1024) NULL,
	[BirthCountry] [varchar](1024) NULL,
	[CityName] [varchar](1024) NULL,
	[FamilyStatus] [varchar](1024) NULL,
	[ChildrenNumber] [real] NULL,
	[imgPath] [varchar](1024) NULL,
	[FK_MKStatus] [int] NULL,
	[FirstLetter] [varchar](1024) NULL,
	[LU_Gender] [int] NULL,
 CONSTRAINT [AUG_GovernmentPersonalData_PK] PRIMARY KEY CLUSTERED 
(
	[﻿MkID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AUG_PersonIdToMkId]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUG_PersonIdToMkId](
	[PersonID] [int] NOT NULL,
	[MkID] [int] NOT NULL,
 CONSTRAINT [AUG_PersonIdToMkId_PK] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[MkID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AUG_Person]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Create new view
CREATE VIEW [dbo].[AUG_Person] 
with SCHEMABINDING 
AS
SELECT
 p.PersonID, p.LastName, p.FirstName, p.GenderID, p.GenderDesc, p.Email, p.IsCurrent, p.LastUpdatedDate,
mk.[﻿MkID] AS MkID,
mk.FirstName AS Mk_FirstName, 
mk.LastName AS Mk_LastName,
mk.FullName AS Mk_FullName,
mk.BirthDate AS Mk_BirthDate,
mk.YearDate  AS Mk_YearDate,
mk.BirthDateHeb AS Mk_BirthDateHeb,
mk.DeathDate AS Mk_DeathDate,
mk.DeathDateHeb AS Mk_DeathDateHeb,
mk.YearDeathDate AS Mk_YearDeathDate,
mk.ImmigrationDate AS Mk_ImmigrationDate,
mk.BirthCountry AS Mk_BirthCountry,
mk.CityName AS Mk_CityName,
mk.FamilyStatus AS Mk_FamilyStatus,
mk.ChildrenNumber AS Mk_ChildrenNumber,
mk.imgPath AS Mk_imgPath,
mk.FirstLetter AS Mk_FirstLetter,
mk.LU_Gender AS Mk_LU_Gender
FROM [dbo].[KNS_Person] p
LEFT JOIN [dbo].[AUG_PersonIdToMkId] x ON x.PersonID = p.PersonID 
LEFT JOIN [dbo].[AUG_GovernmentPersonalData] mk ON x.MkID = mk.[MkID] 

GO
/****** Object:  View [dbo].[AUG_PlenumQuotesJoinned]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_PlenumQuotesJoinned] AS
SELECT
p.PersonID, 
p.LastName,
p.FirstName, 
p.Mk_imgPath,
q.PlenumQuoteID,
q.[Index], 
q.Speaker, 
q.[Text],
q.DocumentPlenumSessionID, 
d.FilePath, 
d.LastUpdatedDate AS DocumentPlenumSessionLastUpdatedDate,
s.PlenumSessionID, 
s.[Number] AS PlenumSessionNumber, 
s.KnessetNum,
s.Name AS PlenumSessionName, 
s.StartDate AS PlenumSessionStartDate, 
s.FinishDate AS PlenumSessionFinishDate, 
s.IsSpecialMeeting, 
s.LastUpdatedDate AS PlenumSessionLastUpdatedDate
FROM [dbo].[AUG_PlenumQuotes] q
LEFT JOIN [dbo].[AUG_Person] p ON p.PersonID = q.PersonID 
JOIN [dbo].[KNS_DocumentPlenumSession] d ON d.DocumentPlenumSessionID = q.DocumentPlenumSessionID 
JOIN [dbo].[KNS_PlenumSession] s ON s.PlenumSessionID = d.PlenumSessionID 
GO
/****** Object:  Table [dbo].[KNS_PersonToPosition]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_PersonToPosition](
	[PersonToPositionID] [int] NOT NULL,
	[PersonID] [int] NULL,
	[PositionID] [int] NULL,
	[KnessetNum] [int] NULL,
	[StartDate] [datetime2](7) NULL,
	[FinishDate] [datetime2](7) NULL,
	[GovMinistryID] [int] NULL,
	[GovMinistryName] [varchar](50) NULL,
	[DutyDesc] [varchar](250) NULL,
	[FactionID] [int] NULL,
	[FactionName] [varchar](50) NULL,
	[GovernmentNum] [int] NULL,
	[CommitteeID] [int] NULL,
	[CommitteeName] [varchar](250) NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonToPositionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Position]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Position](
	[PositionID] [int] NOT NULL,
	[Description] [varchar](250) NULL,
	[GenderID] [int] NULL,
	[GenderDesc] [varchar](125) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[PositionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AUG_PersonPositions]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUG_PersonPositions]
AS
SELECT  per.*, 
pos.Description AS PositionDescription,
x.PersonToPositionID,
x.PositionID,
x.KnessetNum,
x.StartDate,
x.FinishDate,
x.GovMinistryID,
x.GovMinistryName,
x.DutyDesc,
x.FactionID,
x.FactionName,
x.GovernmentNum,
x.CommitteeID,
x.CommitteeName,
x.IsCurrent AS PositionIsCurrent,
x.LastUpdatedDate AS PositionLastUpdatedDate
FROM dbo.KNS_PersonToPosition x
JOIN dbo.AUG_Person per ON x.PersonID = per.PersonID 
JOIN dbo.KNS_Position pos ON x.PositionID = pos.PositionID
GO
/****** Object:  Table [dbo].[AUG_CommitteeFinishDates]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUG_CommitteeFinishDates](
	[DocumentCommitteeSessionID] [bigint] NOT NULL,
	[FinishDate] [datetime2](7) NULL,
 CONSTRAINT [AUG_CommitteeFinishDates_PK] PRIMARY KEY CLUSTERED 
(
	[DocumentCommitteeSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AUG_PersonToPosition]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUG_PersonToPosition](
	[PersonID] [int] NOT NULL,
	[PositionID] [int] NOT NULL,
	[PersonToPositionID] [int] NOT NULL,
 CONSTRAINT [AUG_PersonToPosition_PK] PRIMARY KEY CLUSTERED 
(
	[PersonToPositionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AUG_WordCloud]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUG_WordCloud](
	[PersonID] [int] NOT NULL,
	[WordCloud] [nvarchar](max) NULL,
 CONSTRAINT [AUG_WordCloud_PK] PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Agenda]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Agenda](
	[AgendaID] [int] NOT NULL,
	[Number] [int] NULL,
	[ClassificationID] [int] NULL,
	[ClassificationDesc] [varchar](125) NULL,
	[LeadingAgendaID] [int] NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[SubTypeID] [int] NULL,
	[SubTypeDesc] [varchar](125) NULL,
	[StatusID] [int] NULL,
	[InitiatorPersonID] [int] NULL,
	[GovRecommendationID] [int] NULL,
	[GovRecommendationDesc] [varchar](125) NULL,
	[PresidentDecisionDate] [datetime2](7) NULL,
	[PostopenmentReasonID] [int] NULL,
	[PostopenmentReasonDesc] [varchar](125) NULL,
	[CommitteeID] [int] NULL,
	[RecommendCommitteeID] [int] NULL,
	[MinisterPersonID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[AgendaID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Bill]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Bill](
	[BillID] [int] NOT NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[SubTypeID] [int] NULL,
	[SubTypeDesc] [varchar](125) NULL,
	[PrivateNumber] [int] NULL,
	[CommitteeID] [int] NULL,
	[StatusID] [int] NULL,
	[Number] [int] NULL,
	[PostponementReasonID] [int] NULL,
	[PostponementReasonDesc] [varchar](125) NULL,
	[PublicationDate] [datetime2](7) NULL,
	[MagazineNumber] [int] NULL,
	[PageNumber] [int] NULL,
	[IsContinuationBill] [bit] NULL,
	[SummaryLaw] [varchar](8000) NULL,
	[PublicationSeriesID] [int] NULL,
	[PublicationSeriesDesc] [varchar](125) NULL,
	[PublicationSeriesFirstCall] [nvarchar](255) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_BillHistoryInitiator]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_BillHistoryInitiator](
	[BillHistoryInitiatorID] [int] NOT NULL,
	[BillID] [int] NULL,
	[PersonID] [int] NULL,
	[IsInitiator] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[ReasonID] [int] NULL,
	[ReasonDesc] [varchar](125) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillHistoryInitiatorID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_BillInitiator]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_BillInitiator](
	[BillInitiatorID] [int] NOT NULL,
	[BillID] [int] NULL,
	[PersonID] [int] NULL,
	[IsInitiator] [bit] NULL,
	[Ordinal] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillInitiatorID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_BillName]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_BillName](
	[BillNameID] [int] NOT NULL,
	[BillID] [int] NULL,
	[Name] [varchar](500) NULL,
	[NameHistoryTypeID] [int] NULL,
	[NameHistoryTypeDesc] [varchar](125) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillNameID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_BillSplit]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_BillSplit](
	[BillSplitID] [int] NOT NULL,
	[MainBillID] [int] NULL,
	[SplitBillID] [int] NULL,
	[Name] [varchar](250) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillSplitID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_BillUnion]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_BillUnion](
	[BillUnionID] [int] NOT NULL,
	[MainBillID] [int] NULL,
	[UnionBillID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[BillUnionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_CmtSessionItem]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_CmtSessionItem](
	[CmtSessionItemID] [int] NOT NULL,
	[ItemID] [int] NULL,
	[CommitteeSessionID] [int] NULL,
	[Ordinal] [int] NULL,
	[StatusID] [int] NULL,
	[Name] [varchar](255) NULL,
	[ItemTypeID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[CmtSessionItemID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_CmtSiteCode]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_CmtSiteCode](
	[CmtSiteCode] [bigint] NOT NULL,
	[KnsID] [int] NULL,
	[SiteId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[CmtSiteCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Committee]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Committee](
	[CommitteeID] [int] NOT NULL,
	[Name] [varchar](250) NULL,
	[CategoryID] [smallint] NULL,
	[CategoryDesc] [varchar](150) NULL,
	[KnessetNum] [int] NULL,
	[CommitteeTypeID] [int] NULL,
	[CommitteeTypeDesc] [varchar](125) NULL,
	[Email] [varchar](254) NULL,
	[StartDate] [datetime2](7) NULL,
	[FinishDate] [datetime2](7) NULL,
	[AdditionalTypeID] [int] NULL,
	[AdditionalTypeDesc] [varchar](125) NULL,
	[ParentCommitteeID] [int] NULL,
	[CommitteeParentName] [varchar](250) NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[CommitteeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentAgenda]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentAgenda](
	[DocumentAgendaID] [bigint] NOT NULL,
	[AgendaID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentAgendaID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentBill]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentBill](
	[DocumentBillID] [bigint] NOT NULL,
	[BillID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentBillID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentIsraelLaw]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentIsraelLaw](
	[DocumentIsraelLawID] [bigint] NOT NULL,
	[IsraelLawID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentIsraelLawID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentLaw]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentLaw](
	[DocumentLawID] [bigint] NOT NULL,
	[LawID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentLawID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_DocumentQuery]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_DocumentQuery](
	[DocumentQueryID] [bigint] NOT NULL,
	[QueryID] [int] NULL,
	[GroupTypeID] [tinyint] NULL,
	[GroupTypeDesc] [varchar](100) NULL,
	[ApplicationID] [tinyint] NULL,
	[ApplicationDesc] [varchar](10) NULL,
	[FilePath] [varchar](600) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[DocumentQueryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Faction]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Faction](
	[FactionID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[KnessetNum] [int] NULL,
	[StartDate] [datetime2](7) NULL,
	[FinishDate] [datetime2](7) NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[FactionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_GovMinistry]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_GovMinistry](
	[GovMinistryID] [int] NOT NULL,
	[Name] [varchar](50) NULL,
	[IsActive] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[GovMinistryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_IsraelLaw]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_IsraelLaw](
	[IsraelLawID] [int] NOT NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[IsBasicLaw] [bit] NULL,
	[IsFavoriteLaw] [bit] NULL,
	[PublicationDate] [datetime2](7) NULL,
	[LatestPublicationDate] [datetime2](7) NULL,
	[IsBudgetLaw] [bit] NULL,
	[LawValidityID] [int] NULL,
	[LawValidityDesc] [varchar](125) NULL,
	[ValidityStartDate] [datetime2](7) NULL,
	[ValidityStartDateNotes] [varchar](500) NULL,
	[ValidityFinishDate] [datetime2](7) NULL,
	[ValidityFinishDateNotes] [varchar](500) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[IsraelLawID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_IsraelLawBinding]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_IsraelLawBinding](
	[IsraelLawBinding] [int] NOT NULL,
	[IsraelLawID] [int] NULL,
	[IsraelLawReplacedID] [int] NULL,
	[LawID] [int] NULL,
	[LawTypeID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[IsraelLawBinding] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_IsraelLawClassificiation]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_IsraelLawClassificiation](
	[LawClassificiationID] [int] NOT NULL,
	[IsraelLawID] [int] NULL,
	[ClassificiationID] [int] NULL,
	[ClassificiationDesc] [varchar](50) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[LawClassificiationID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_IsraelLawMinistry]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_IsraelLawMinistry](
	[LawMinistryID] [int] NOT NULL,
	[IsraelLawID] [int] NULL,
	[GovMinistryID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[LawMinistryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_IsraelLawName]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_IsraelLawName](
	[IsraelLawNameID] [int] NOT NULL,
	[IsraelLawID] [int] NULL,
	[LawID] [int] NULL,
	[LawTypeID] [int] NULL,
	[Name] [varchar](500) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[IsraelLawNameID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_ItemType]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_ItemType](
	[ItemTypeID] [int] NOT NULL,
	[Desc] [varchar](125) NULL,
	[TableName] [varchar](19) NULL,
PRIMARY KEY CLUSTERED 
(
	[ItemTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_JointCommittee]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_JointCommittee](
	[JointCommitteeID] [bigint] NOT NULL,
	[CommitteeID] [int] NULL,
	[ParticipantCommitteeID] [int] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[JointCommitteeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_KnessetDates]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_KnessetDates](
	[KnessetDateID] [int] NOT NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](50) NULL,
	[Assembly] [int] NULL,
	[Plenum] [int] NULL,
	[PlenumStart] [datetime2](7) NULL,
	[PlenumFinish] [datetime2](7) NULL,
	[IsCurrent] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[KnessetDateID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Law]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Law](
	[LawID] [int] NOT NULL,
	[TypeID] [int] NULL,
	[TypeDesc] [varchar](125) NULL,
	[SubTypeID] [int] NULL,
	[SubTypeDesc] [varchar](125) NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[PublicationDate] [datetime2](7) NULL,
	[PublicationSeriesID] [int] NULL,
	[PublicationSeriesDesc] [varchar](125) NULL,
	[MagazineNumber] [varchar](50) NULL,
	[PageNumber] [varchar](50) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[LawID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_LawBinding]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_LawBinding](
	[LawBindingID] [int] NOT NULL,
	[LawID] [int] NULL,
	[IsraelLawID] [int] NULL,
	[ParentLawID] [int] NULL,
	[LawTypeID] [int] NULL,
	[LawParentTypeID] [int] NULL,
	[BindingType] [int] NULL,
	[BindingTypeDesc] [varchar](125) NULL,
	[PageNumber] [varchar](50) NULL,
	[AmendmentType] [int] NULL,
	[AmendmentTypeDesc] [varchar](125) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[LawBindingID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_MkSiteCode]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_MkSiteCode](
	[MKSiteCode] [bigint] NOT NULL,
	[KnsID] [int] NULL,
	[SiteId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MKSiteCode] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Query]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Query](
	[QueryID] [int] NOT NULL,
	[Number] [int] NULL,
	[KnessetNum] [int] NULL,
	[Name] [varchar](255) NULL,
	[TypeID] [int] NULL,
	[TypeDesc] [varchar](125) NULL,
	[StatusID] [int] NULL,
	[PersonID] [int] NULL,
	[GovMinistryID] [int] NULL,
	[SubmitDate] [datetime2](7) NULL,
	[ReplyMinisterDate] [datetime2](7) NULL,
	[ReplyDatePlanned] [datetime2](7) NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[QueryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KNS_Status]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KNS_Status](
	[StatusID] [int] NOT NULL,
	[Desc] [varchar](50) NULL,
	[TypeID] [int] NULL,
	[TypeDesc] [varchar](125) NULL,
	[OrderTransition] [int] NULL,
	[IsActive] [bit] NULL,
	[LastUpdatedDate] [datetime2](7) NULL,
PRIMARY KEY CLUSTERED 
(
	[StatusID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Votes]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Votes](
	[﻿Name] [varchar](1024) NULL,
	[Party] [varchar](1024) NULL,
	[Vote] [varchar](1024) NULL,
	[Rule] [varchar](1024) NULL,
	[Date] [datetime] NULL,
	[Committee] [real] NULL,
	[Meeting] [int] NULL,
	[Id] [varchar](1024) NULL,
	[Type] [varchar](1024) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [votes_index_by_id]    Script Date: 2/26/2021 23:28:10 ******/
CREATE CLUSTERED INDEX [votes_index_by_id] ON [dbo].[Votes]
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Votes_Interesting]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Votes_Interesting](
	[﻿ID] [int] NULL,
	[SubjectID] [int] NULL,
	[Subject] [varchar](1024) NULL,
	[LawName] [varchar](1024) NULL,
	[Link] [varchar](1024) NULL,
	[Description] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [Votes_Interesing_by_ID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE CLUSTERED INDEX [Votes_Interesing_by_ID_IDX] ON [dbo].[Votes_Interesting]
(
	[﻿ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Votes_PartyLogo]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Votes_PartyLogo](
	[﻿Party] [varchar](1024) NULL,
	[party_logo_link] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Votes_Person2Code]    Script Date: 2/26/2021 23:28:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Votes_Person2Code](
	[﻿Name] [varchar](1024) NULL,
	[Code] [int] NULL,
	[Faction] [varchar](1024) NULL,
	[PlaceInList] [int] NULL,
	[faction_picture] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [votes_personcode]    Script Date: 2/26/2021 23:28:10 ******/
CREATE CLUSTERED INDEX [votes_personcode] ON [dbo].[Votes_Person2Code]
(
	[﻿Name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AUG_CommitteeFinishDates_FinishDate_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [AUG_CommitteeFinishDates_FinishDate_IDX] ON [dbo].[AUG_CommitteeFinishDates]
(
	[FinishDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AUG_PersonIdToMkId_MkID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [AUG_PersonIdToMkId_MkID_IDX] ON [dbo].[AUG_PersonIdToMkId]
(
	[MkID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AUG_PersonIdToMkId_PersonID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [AUG_PersonIdToMkId_PersonID_IDX] ON [dbo].[AUG_PersonIdToMkId]
(
	[PersonID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AUG_PersonToPosition_PersonID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [AUG_PersonToPosition_PersonID_IDX] ON [dbo].[AUG_PersonToPosition]
(
	[PersonID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [AUG_PersonToPosition_PositionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [AUG_PersonToPosition_PositionID_IDX] ON [dbo].[AUG_PersonToPosition]
(
	[PositionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nci_wi_KNS_BillInitiator_640A3A5559B9D18132216160E2707A08]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [nci_wi_KNS_BillInitiator_640A3A5559B9D18132216160E2707A08] ON [dbo].[KNS_BillInitiator]
(
	[PersonID] ASC,
	[IsInitiator] ASC
)
INCLUDE([BillID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CmtSessionItem_CommitteeSessionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CmtSessionItem_CommitteeSessionID_IDX] ON [dbo].[KNS_CmtSessionItem]
(
	[CommitteeSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CmtSessionItem_ItemID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CmtSessionItem_ItemID_IDX] ON [dbo].[KNS_CmtSessionItem]
(
	[ItemID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CmtSessionItem_ItemTypeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CmtSessionItem_ItemTypeID_IDX] ON [dbo].[KNS_CmtSessionItem]
(
	[ItemTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_Committee_AdditionalTypeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_Committee_AdditionalTypeID_IDX] ON [dbo].[KNS_Committee]
(
	[AdditionalTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_Committee_CategoryID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_Committee_CategoryID_IDX] ON [dbo].[KNS_Committee]
(
	[CategoryID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_Committee_CommitteeTypeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_Committee_CommitteeTypeID_IDX] ON [dbo].[KNS_Committee]
(
	[CommitteeTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_Committee_StartDate_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_Committee_StartDate_IDX] ON [dbo].[KNS_Committee]
(
	[StartDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_CommitteeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_CommitteeID_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[CommitteeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_CommitteeSessionID_CommitteeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_CommitteeSessionID_CommitteeID_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[CommitteeSessionID] ASC
)
INCLUDE([CommitteeID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_FinishDate_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_FinishDate_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[FinishDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_KnessetNum_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_KnessetNum_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[KnessetNum] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_StartDate_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_StartDate_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[StartDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_CommitteeSession_TypeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_CommitteeSession_TypeID_IDX] ON [dbo].[KNS_CommitteeSession]
(
	[TypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [nci_wi_KNS_DocumentBill_8F4DE56187FD8857F0CD6C19F35F6A0A]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [nci_wi_KNS_DocumentBill_8F4DE56187FD8857F0CD6C19F35F6A0A] ON [dbo].[KNS_DocumentBill]
(
	[BillID] ASC
)
INCLUDE([FilePath],[GroupTypeDesc],[LastUpdatedDate]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentCommitteeSession_ApplicationID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentCommitteeSession_ApplicationID_IDX] ON [dbo].[KNS_DocumentCommitteeSession]
(
	[ApplicationID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentCommitteeSession_CommitteeSessionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentCommitteeSession_CommitteeSessionID_IDX] ON [dbo].[KNS_DocumentCommitteeSession]
(
	[CommitteeSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentCommitteeSession_DocumentCommitteeSessionID_CommitteeSessionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentCommitteeSession_DocumentCommitteeSessionID_CommitteeSessionID_IDX] ON [dbo].[KNS_DocumentCommitteeSession]
(
	[DocumentCommitteeSessionID] ASC
)
INCLUDE([CommitteeSessionID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentCommitteeSession_GroupTypeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentCommitteeSession_GroupTypeID_IDX] ON [dbo].[KNS_DocumentCommitteeSession]
(
	[GroupTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentPlenumSession_ApplicationID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentPlenumSession_ApplicationID_IDX] ON [dbo].[KNS_DocumentPlenumSession]
(
	[ApplicationID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentPlenumSession_DocumentPlenumSessionID_PlenumSessionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentPlenumSession_DocumentPlenumSessionID_PlenumSessionID_IDX] ON [dbo].[KNS_DocumentPlenumSession]
(
	[DocumentPlenumSessionID] ASC
)
INCLUDE([PlenumSessionID]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_DocumentPlenumSession_PlenumSessionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_DocumentPlenumSession_PlenumSessionID_IDX] ON [dbo].[KNS_DocumentPlenumSession]
(
	[PlenumSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_CommitteeID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_CommitteeID_IDX] ON [dbo].[KNS_PersonToPosition]
(
	[CommitteeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_FactionID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_FactionID_IDX] ON [dbo].[KNS_PersonToPosition]
(
	[FactionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_Finish_Date]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_Finish_Date] ON [dbo].[KNS_PersonToPosition]
(
	[FinishDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_PersonID_IDX]    Script Date: 2/26/2021 23:28:10 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_PersonID_IDX] ON [dbo].[KNS_PersonToPosition]
(
	[PersonID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_PositionID_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_PositionID_IDX] ON [dbo].[KNS_PersonToPosition]
(
	[PositionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PersonToPosition_StartDate_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PersonToPosition_StartDate_IDX] ON [dbo].[KNS_PersonToPosition]
(
	[StartDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PlenumSession_FinishDate_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PlenumSession_FinishDate_IDX] ON [dbo].[KNS_PlenumSession]
(
	[FinishDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PlenumSession_KnessetNum_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PlenumSession_KnessetNum_IDX] ON [dbo].[KNS_PlenumSession]
(
	[KnessetNum] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PlenumSession_StartDate_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PlenumSession_StartDate_IDX] ON [dbo].[KNS_PlenumSession]
(
	[StartDate] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PlmSessionItem_ItemID_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PlmSessionItem_ItemID_IDX] ON [dbo].[KNS_PlmSessionItem]
(
	[ItemID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [KNS_PlmSessionItem_PlenumSessionID_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [KNS_PlmSessionItem_PlenumSessionID_IDX] ON [dbo].[KNS_PlmSessionItem]
(
	[PlenumSessionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Votes_by_name_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [Votes_by_name_IDX] ON [dbo].[Votes]
(
	[﻿Name] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Votes_vote_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [Votes_vote_IDX] ON [dbo].[Votes]
(
	[Vote] ASC
)
INCLUDE([﻿Name]) WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [Votes_Interesing_by_LawLink_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [Votes_Interesing_by_LawLink_IDX] ON [dbo].[Votes_Interesting]
(
	[Link] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [Votes_person_2_code_placeinlist_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [Votes_person_2_code_placeinlist_IDX] ON [dbo].[Votes_Person2Code]
(
	[PlaceInList] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [votes_personcode_personID_IDX]    Script Date: 2/26/2021 23:28:11 ******/
CREATE NONCLUSTERED INDEX [votes_personcode_personID_IDX] ON [dbo].[Votes_Person2Code]
(
	[Code] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AUG_CommitteeFinishDates]  WITH CHECK ADD  CONSTRAINT [AUG_CommitteeFinishDates_FK] FOREIGN KEY([DocumentCommitteeSessionID])
REFERENCES [dbo].[KNS_DocumentCommitteeSession] ([DocumentCommitteeSessionID])
GO
ALTER TABLE [dbo].[AUG_CommitteeFinishDates] CHECK CONSTRAINT [AUG_CommitteeFinishDates_FK]
GO
ALTER TABLE [dbo].[AUG_PersonIdToMkId]  WITH CHECK ADD  CONSTRAINT [AUG_PersonIdToMkId_FK] FOREIGN KEY([PersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[AUG_PersonIdToMkId] CHECK CONSTRAINT [AUG_PersonIdToMkId_FK]
GO
ALTER TABLE [dbo].[AUG_PersonIdToMkId]  WITH CHECK ADD  CONSTRAINT [Mk_FK] FOREIGN KEY([MkID])
REFERENCES [dbo].[AUG_GovernmentPersonalData] ([﻿MkID])
GO
ALTER TABLE [dbo].[AUG_PersonIdToMkId] CHECK CONSTRAINT [Mk_FK]
GO
ALTER TABLE [dbo].[KNS_Agenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_Agenda_CommitteeID] FOREIGN KEY([CommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_Agenda] CHECK CONSTRAINT [KNS_Committee_KNS_Agenda_CommitteeID]
GO
ALTER TABLE [dbo].[KNS_Agenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_Agenda_RecommendCommitteeID] FOREIGN KEY([RecommendCommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_Agenda] CHECK CONSTRAINT [KNS_Committee_KNS_Agenda_RecommendCommitteeID]
GO
ALTER TABLE [dbo].[KNS_Agenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_Agenda_InitiatorPersonID] FOREIGN KEY([InitiatorPersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_Agenda] CHECK CONSTRAINT [KNS_Person_KNS_Agenda_InitiatorPersonID]
GO
ALTER TABLE [dbo].[KNS_Agenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_Agenda_MinisterPersonID] FOREIGN KEY([MinisterPersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_Agenda] CHECK CONSTRAINT [KNS_Person_KNS_Agenda_MinisterPersonID]
GO
ALTER TABLE [dbo].[KNS_Agenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_Agenda_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_Agenda] CHECK CONSTRAINT [KNS_Status_KNS_Agenda_StatusID]
GO
ALTER TABLE [dbo].[KNS_Bill]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_Committee_CommitteeID] FOREIGN KEY([CommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_Bill] CHECK CONSTRAINT [KNS_Bill_KNS_Committee_CommitteeID]
GO
ALTER TABLE [dbo].[KNS_Bill]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_Bill_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_Bill] CHECK CONSTRAINT [KNS_Status_KNS_Bill_StatusID]
GO
ALTER TABLE [dbo].[KNS_BillHistoryInitiator]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillHistoryInitiator_BillID] FOREIGN KEY([BillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillHistoryInitiator] CHECK CONSTRAINT [KNS_Bill_KNS_BillHistoryInitiator_BillID]
GO
ALTER TABLE [dbo].[KNS_BillHistoryInitiator]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_BillHistoryInitiator_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_BillHistoryInitiator] CHECK CONSTRAINT [KNS_Person_KNS_BillHistoryInitiator_PersonID]
GO
ALTER TABLE [dbo].[KNS_BillInitiator]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillInitiator_BillID] FOREIGN KEY([BillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillInitiator] CHECK CONSTRAINT [KNS_Bill_KNS_BillInitiator_BillID]
GO
ALTER TABLE [dbo].[KNS_BillInitiator]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_BillInitiator_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_BillInitiator] CHECK CONSTRAINT [KNS_Person_KNS_BillInitiator_PersonID]
GO
ALTER TABLE [dbo].[KNS_BillName]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillName_BillID] FOREIGN KEY([BillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillName] CHECK CONSTRAINT [KNS_Bill_KNS_BillName_BillID]
GO
ALTER TABLE [dbo].[KNS_BillSplit]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillSplit_MainBillID] FOREIGN KEY([MainBillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillSplit] CHECK CONSTRAINT [KNS_Bill_KNS_BillSplit_MainBillID]
GO
ALTER TABLE [dbo].[KNS_BillSplit]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillSplit_SplitBillID] FOREIGN KEY([SplitBillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillSplit] CHECK CONSTRAINT [KNS_Bill_KNS_BillSplit_SplitBillID]
GO
ALTER TABLE [dbo].[KNS_BillUnion]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillUnion_MainBillID] FOREIGN KEY([MainBillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillUnion] CHECK CONSTRAINT [KNS_Bill_KNS_BillUnion_MainBillID]
GO
ALTER TABLE [dbo].[KNS_BillUnion]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_BillUnion_UnionBillID] FOREIGN KEY([UnionBillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_BillUnion] CHECK CONSTRAINT [KNS_Bill_KNS_BillUnion_UnionBillID]
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_CommitteeSession_KNS_CmtSessionItem_CommitteeSessionID] FOREIGN KEY([CommitteeSessionID])
REFERENCES [dbo].[KNS_CommitteeSession] ([CommitteeSessionID])
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem] CHECK CONSTRAINT [KNS_CommitteeSession_KNS_CmtSessionItem_CommitteeSessionID]
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_CmtSessionItem_ItemTypeID] FOREIGN KEY([ItemTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem] CHECK CONSTRAINT [KNS_ItemType_KNS_CmtSessionItem_ItemTypeID]
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_CmtSessionItem_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_CmtSessionItem] CHECK CONSTRAINT [KNS_Status_KNS_CmtSessionItem_StatusID]
GO
ALTER TABLE [dbo].[KNS_CommitteeSession]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_CommitteeSession_CommitteeID] FOREIGN KEY([CommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_CommitteeSession] CHECK CONSTRAINT [KNS_Committee_KNS_CommitteeSession_CommitteeID]
GO
ALTER TABLE [dbo].[KNS_CommitteeSession]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_CommitteeSession_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_CommitteeSession] CHECK CONSTRAINT [KNS_Status_KNS_CommitteeSession_StatusID]
GO
ALTER TABLE [dbo].[KNS_DocumentAgenda]  WITH NOCHECK ADD  CONSTRAINT [KNS_Agenda_KNS_DocumentAgenda_AgendaID] FOREIGN KEY([AgendaID])
REFERENCES [dbo].[KNS_Agenda] ([AgendaID])
GO
ALTER TABLE [dbo].[KNS_DocumentAgenda] CHECK CONSTRAINT [KNS_Agenda_KNS_DocumentAgenda_AgendaID]
GO
ALTER TABLE [dbo].[KNS_DocumentBill]  WITH NOCHECK ADD  CONSTRAINT [KNS_Bill_KNS_DocumentBill_BillID] FOREIGN KEY([BillID])
REFERENCES [dbo].[KNS_Bill] ([BillID])
GO
ALTER TABLE [dbo].[KNS_DocumentBill] CHECK CONSTRAINT [KNS_Bill_KNS_DocumentBill_BillID]
GO
ALTER TABLE [dbo].[KNS_DocumentCommitteeSession]  WITH NOCHECK ADD  CONSTRAINT [KNS_CommitteeSession_KNS_DocumentCommitteeSession_CommitteeSessionID] FOREIGN KEY([CommitteeSessionID])
REFERENCES [dbo].[KNS_CommitteeSession] ([CommitteeSessionID])
GO
ALTER TABLE [dbo].[KNS_DocumentCommitteeSession] CHECK CONSTRAINT [KNS_CommitteeSession_KNS_DocumentCommitteeSession_CommitteeSessionID]
GO
ALTER TABLE [dbo].[KNS_DocumentIsraelLaw]  WITH CHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_DocumentIsraelLaw_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_DocumentIsraelLaw] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_DocumentIsraelLaw_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_DocumentLaw]  WITH NOCHECK ADD  CONSTRAINT [KNS_Law_KNS_DocumentLaw_LawID] FOREIGN KEY([LawID])
REFERENCES [dbo].[KNS_Law] ([LawID])
GO
ALTER TABLE [dbo].[KNS_DocumentLaw] CHECK CONSTRAINT [KNS_Law_KNS_DocumentLaw_LawID]
GO
ALTER TABLE [dbo].[KNS_DocumentPlenumSession]  WITH NOCHECK ADD  CONSTRAINT [KNS_PlenumSession_KNS_DocumentPlenumSession_PlenumSessionID] FOREIGN KEY([PlenumSessionID])
REFERENCES [dbo].[KNS_PlenumSession] ([PlenumSessionID])
GO
ALTER TABLE [dbo].[KNS_DocumentPlenumSession] CHECK CONSTRAINT [KNS_PlenumSession_KNS_DocumentPlenumSession_PlenumSessionID]
GO
ALTER TABLE [dbo].[KNS_DocumentQuery]  WITH NOCHECK ADD  CONSTRAINT [KNS_Query_KNS_DocumentQuery_QueryID] FOREIGN KEY([QueryID])
REFERENCES [dbo].[KNS_Query] ([QueryID])
GO
ALTER TABLE [dbo].[KNS_DocumentQuery] CHECK CONSTRAINT [KNS_Query_KNS_DocumentQuery_QueryID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawBinding_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawBinding_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawBinding_IsraelLawReplacedID] FOREIGN KEY([IsraelLawReplacedID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawBinding_IsraelLawReplacedID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_IsraelLawBinding_LawTypeID] FOREIGN KEY([LawTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawBinding] CHECK CONSTRAINT [KNS_ItemType_KNS_IsraelLawBinding_LawTypeID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawClassificiation]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawClassificiation_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawClassificiation] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawClassificiation_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawMinistry]  WITH NOCHECK ADD  CONSTRAINT [KNS_GovMinistry_KNS_IsraelLawMinistry_GovMinistryID] FOREIGN KEY([GovMinistryID])
REFERENCES [dbo].[KNS_GovMinistry] ([GovMinistryID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawMinistry] CHECK CONSTRAINT [KNS_GovMinistry_KNS_IsraelLawMinistry_GovMinistryID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawMinistry]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawMinistry_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawMinistry] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawMinistry_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawName]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawName_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawName] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_IsraelLawName_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_IsraelLawName]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_IsraelLawName_LawTypeID] FOREIGN KEY([LawTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_IsraelLawName] CHECK CONSTRAINT [KNS_ItemType_KNS_IsraelLawName_LawTypeID]
GO
ALTER TABLE [dbo].[KNS_JointCommittee]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_JointCommittee_CommitteeID] FOREIGN KEY([CommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_JointCommittee] CHECK CONSTRAINT [KNS_Committee_KNS_JointCommittee_CommitteeID]
GO
ALTER TABLE [dbo].[KNS_JointCommittee]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_JointCommittee_ParticipantCommitteeID] FOREIGN KEY([ParticipantCommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_JointCommittee] CHECK CONSTRAINT [KNS_Committee_KNS_JointCommittee_ParticipantCommitteeID]
GO
ALTER TABLE [dbo].[KNS_LawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_IsraelLaw_KNS_LawBinding_IsraelLawID] FOREIGN KEY([IsraelLawID])
REFERENCES [dbo].[KNS_IsraelLaw] ([IsraelLawID])
GO
ALTER TABLE [dbo].[KNS_LawBinding] CHECK CONSTRAINT [KNS_IsraelLaw_KNS_LawBinding_IsraelLawID]
GO
ALTER TABLE [dbo].[KNS_LawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_LawBinding_LawParentTypeID] FOREIGN KEY([LawParentTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_LawBinding] CHECK CONSTRAINT [KNS_ItemType_KNS_LawBinding_LawParentTypeID]
GO
ALTER TABLE [dbo].[KNS_LawBinding]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_LawBinding_LawTypeID] FOREIGN KEY([LawTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_LawBinding] CHECK CONSTRAINT [KNS_ItemType_KNS_LawBinding_LawTypeID]
GO
ALTER TABLE [dbo].[KNS_PersonToPosition]  WITH NOCHECK ADD  CONSTRAINT [KNS_Committee_KNS_PersonToPosition_CommitteeID] FOREIGN KEY([CommitteeID])
REFERENCES [dbo].[KNS_Committee] ([CommitteeID])
GO
ALTER TABLE [dbo].[KNS_PersonToPosition] CHECK CONSTRAINT [KNS_Committee_KNS_PersonToPosition_CommitteeID]
GO
ALTER TABLE [dbo].[KNS_PersonToPosition]  WITH NOCHECK ADD  CONSTRAINT [KNS_Faction_KNS_PersonToPosition_FactionID] FOREIGN KEY([FactionID])
REFERENCES [dbo].[KNS_Faction] ([FactionID])
GO
ALTER TABLE [dbo].[KNS_PersonToPosition] CHECK CONSTRAINT [KNS_Faction_KNS_PersonToPosition_FactionID]
GO
ALTER TABLE [dbo].[KNS_PersonToPosition]  WITH NOCHECK ADD  CONSTRAINT [KNS_GovMinistry_KNS_PersonToPosition_GovMinistryID] FOREIGN KEY([GovMinistryID])
REFERENCES [dbo].[KNS_GovMinistry] ([GovMinistryID])
GO
ALTER TABLE [dbo].[KNS_PersonToPosition] CHECK CONSTRAINT [KNS_GovMinistry_KNS_PersonToPosition_GovMinistryID]
GO
ALTER TABLE [dbo].[KNS_PersonToPosition]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_PersonToPosition_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_PersonToPosition] CHECK CONSTRAINT [KNS_Person_KNS_PersonToPosition_PersonID]
GO
ALTER TABLE [dbo].[KNS_PersonToPosition]  WITH NOCHECK ADD  CONSTRAINT [KNS_Position_KNS_PersonToPosition_PositionID] FOREIGN KEY([PositionID])
REFERENCES [dbo].[KNS_Position] ([PositionID])
GO
ALTER TABLE [dbo].[KNS_PersonToPosition] CHECK CONSTRAINT [KNS_Position_KNS_PersonToPosition_PositionID]
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_ItemType_KNS_PlmSessionItem_ItemTypeID] FOREIGN KEY([ItemTypeID])
REFERENCES [dbo].[KNS_ItemType] ([ItemTypeID])
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem] CHECK CONSTRAINT [KNS_ItemType_KNS_PlmSessionItem_ItemTypeID]
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_PlenumSession_KNS_PlmSessionItem_PlenumSessionID] FOREIGN KEY([PlenumSessionID])
REFERENCES [dbo].[KNS_PlenumSession] ([PlenumSessionID])
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem] CHECK CONSTRAINT [KNS_PlenumSession_KNS_PlmSessionItem_PlenumSessionID]
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_PlmSessionItem_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_PlmSessionItem] CHECK CONSTRAINT [KNS_Status_KNS_PlmSessionItem_StatusID]
GO
ALTER TABLE [dbo].[KNS_Query]  WITH NOCHECK ADD  CONSTRAINT [KNS_GovMinistry_KNS_Query_GovMinistryID] FOREIGN KEY([GovMinistryID])
REFERENCES [dbo].[KNS_GovMinistry] ([GovMinistryID])
GO
ALTER TABLE [dbo].[KNS_Query] CHECK CONSTRAINT [KNS_GovMinistry_KNS_Query_GovMinistryID]
GO
ALTER TABLE [dbo].[KNS_Query]  WITH NOCHECK ADD  CONSTRAINT [KNS_Person_KNS_Query_PersonID] FOREIGN KEY([PersonID])
REFERENCES [dbo].[KNS_Person] ([PersonID])
GO
ALTER TABLE [dbo].[KNS_Query] CHECK CONSTRAINT [KNS_Person_KNS_Query_PersonID]
GO
ALTER TABLE [dbo].[KNS_Query]  WITH NOCHECK ADD  CONSTRAINT [KNS_Status_KNS_Query_StatusID] FOREIGN KEY([StatusID])
REFERENCES [dbo].[KNS_Status] ([StatusID])
GO
ALTER TABLE [dbo].[KNS_Query] CHECK CONSTRAINT [KNS_Status_KNS_Query_StatusID]
GO
ALTER DATABASE [BetaKnesset] SET  READ_WRITE 
GO
