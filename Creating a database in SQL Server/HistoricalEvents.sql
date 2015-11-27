CREATE DATABASE HistoricalEvents
ON (NAME = 'HistoricalEvents_Data', FILENAME = N'E:\SQL_Server_Practice\SQL_Excercies\Creating a database in SQL Server\HistoricalEvents_Data.mdf', SIZE = 5 MB, FILEGROWTH = 8)
LOG ON (NAME = 'HistoricalEvents_LogData', FILENAME = N'E:\SQL_Server_Practice\SQL_Excercies\Creating a database in SQL Server\HistoricalEvents_LogData.ldf', SIZE = 2 MB, FILEGROWTH = 96)
GO

USE HistoricalEvents;
GO

CREATE TABLE Country
(CountryID int IDENTITY(1,1) NOT NULL,
CountryName nvarchar(255) NOT NULL,
CONSTRAINT PK_CountryID PRIMARY KEY CLUSTERED (CountryID)
) ON [PRIMARY];
GO


CREATE TABLE [Event]
(EventID int IDENTITY(1,1) NOT NULL ,
EventName nvarchar(255) NULL,
EventDate Datetime NULL,
[Description] nvarchar(1000) NULL,
CountryID int NOT NULL
CONSTRAINT FK_CountryID FOREIGN KEY CountryID REFERENCES Country(CountryID),
CONSTRAINT PK_EventID PRIMARY KEY CLUSTERED (EventID)
) ON [PRIMARY];
GO
 

INSERT INTO Country
VALUES('China'),('USA'), ('Russia'), ('England');

INSERT INTO [Event](EventName, EventDate, [Description], CountryID)
VALUES('Football game', '20051023', 'Eagle won the game', 4),
		('Basketball game', '20051107', 'Eagle won the game', 4);

