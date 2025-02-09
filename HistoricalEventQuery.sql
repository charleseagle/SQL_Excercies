/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [EventId]
      ,[EventName]
      ,CONVERT(varchar(10),[EventDate],101) AS EventDate
FROM [HistoricalEvents].[dbo].[tblEvent]

SELECT EventName, EventDate
FROM [tblEvent]
ORDER BY EventDate DESC;

SELECT EventName, EventDate, LEN([Description]) AS [Lenght of description]
FROM [tblEvent]
ORDER BY [Lenght of description] DESC;

SELECT a.CountryID, a.CountryName, b.ContinentId AS Continent
FROM tblCountry AS a INNER JOIN tblContinent AS b 
ON a.ContinentId = b.ContinentId
ORDER BY a.CountryName DESC;

SELECT CountryId, CountryName, IIF(ContinentId IS NULL, 0, ContinentId) AS Continent
FROM tblCountry
ORDER BY CountryName DESC

SELECT CountryId, CountryName, ISNULL(ContinentId, 0) AS Continent
FROM tblCountry
ORDER BY CountryName DESC

SELECT CountryId, CountryName, COALESCE(ContinentId, 0) AS Continent
FROM tblCountry
ORDER BY CountryName DESC

SELECT TOP 50 PERCENT CountryID, CountryName
FROM tblCountry
ORDER BY CountryID;

SELECT b.EventDate, b.EventName, b.CountryID, [Type of Event] =
CASE 
	WHEN a.CountryID = 18 THEN 'United States'
	WHEN a.CountryID = 17 THEN 'UK'
	ELSE 'Somewhere else'
END
FROM tblCountry AS a 
INNER JOIN tblEvent AS b
ON a.CountryId = b.CountryId;


PRINT 'Great events in history'
PRINT '------------------------'
PRINT 'EventName'
PRINT '-----------------------------------------'

SET NOCOUNT ON
DECLARE @Name varchar(255)

DECLARE @Event_Cusor CURSOR
SET @Event_Cusor = CURSOR FOR 
SELECT EventName FROM tblEvent

OPEN @Event_Cusor
FETCH NEXT FROM @Event_Cusor 
INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Name
	FETCH NEXT FROM @Event_Cusor INTO @Name
END
CLOSE @Event_Cusor
DEALLOCATE @Event_Cusor
PRINT '---------------------------------'
PRINT 'EventDate'
PRINT '---------------------------------'
DECLARE @Date datetime
DECLARE @Date_Cursor CURSOR
SET @Date_Cursor = CURSOR FOR
SELECT EventDate FROM tblEvent
OPEN @Date_Cursor
FETCH NEXT FROM @Date_Cursor
INTO @Date
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Date
	FETCH NEXT FROM @Date_Cursor
	INTO @Date
END
CLOSE @Date_Cursor
DEALLOCATE @Date_Cursor


SELECT CountryName + ' has ' + 
	CONVERT(varchar(50), LEN(CountryName)) + ' letters' AS [Country description]
FROM tblCountry

SELECT TOP 5 EventName AS [EarliesT event], EventDate AS [Date]
FROM tblEvent
ORDER BY EventName ASC

SELECT TOP 5 EventName AS [Latest event], EventDate AS [Date]
FROM tblEvent
ORDER BY EventName DESC

SELECT EventName, CONVERT(varchar(10), EventDate, 101) AS [Date of event],
	DATEDIFF(YEAR, EventDate, GETDATE()) AS [Years ago]
FROM tblEvent
ORDER BY EventDate DESC;

SELECT EventDate, EventName 
FROM tblEvent
WHERE CountryID = 7 AND EventDate >'19400101' AND EventDate < '19491231';

SELECT EventName, CONVERT(varchar(10), EventDate, 101) AS [Date of event],
	ABS(DATEDIFF(DAY, '19770108', EventDate)) AS [Days away]
FROM tblEvent
ORDER BY [Days away]

SELECT EventDate, EventName, CountryID
FROM tblEvent
WHERE [Description] LIKE '%Concorde%' 

SELECT EventDate, EventName, [Description]
FROM tblEvent
WHERE [Description] LIKE '%Concorde%' 
AND CountryID = 6

SELECT EventName, FORMAT(EventDate, 'D', 'en-US') AS [Full date]
FROM tblEvent
WHERE DATEPART(weekday, EventDate) <> 6 AND DATEPART(day,EventDate) <> 13

SELECT EventName, FORMAT(EventDate, 'D', 'en-US') AS [Full date]
FROM tblEvent
WHERE DATEPART(weekday, EventDate) = 5 AND DATEPART(day, EventDate) = 13

SELECT EventName, FORMAT(EventDate, 'D', 'en-US') AS [Full date]
FROM tblEvent
WHERE DATEPART(weekday, EventDate) = 7 AND DATEPART(day, EventDate) = 13

SELECT CountryName, CountryId FROM tblCountry
WHERE CountryId IS NOT NULL

SELECT EventName FROM tblEvent
WHERE EventName LIKE '%TV%' AND EventName NOT LIKE '%BBC%'

SELECT EventName, EventDate FROM tblEvent
WHERE DATEPART(month, EventDate) = 1

SELECT EventName, [Description]
FROM tblEvent
WHERE [Description] LIKE '%Pope%' OR [Description] LIKE '%Islam%'

SELECT a.CountryName, b.ContinentName
FROM tblCountry AS a INNER JOIN tblContinent AS b
ON a.ContinentId = b.ContinentId
WHERE b.ContinentId <> 3


SELECT a.EventName, CONVERT(varchar(10), a.EventDate, 101) AS [Formatted date], b.CountryName
FROM tblEvent AS a INNER JOIN tblCountry AS b ON a.CountryId = b.CountryId
INNER JOIN tblContinent AS c ON b.ContinentId = c.ContinentId
WHERE c.ContinentId = 1

SELECT EventName FROM tblEvent
WHERE EventDate >
(SELECT MAX(EventDate) FROM tblEvent
WHERE EventName LIKE '%European Union%')

SELECT a.ContinentName
FROM tblContinent AS a LEFT OUTER JOIN
tblCountry AS b ON a.ContinentId = b.ContinentId
WHERE a.ContinentId NOT IN (SELECT a.ContinentId FROM tblContinent AS a iNNER JOIN
tblCountry AS b ON a.ContinentId = b.ContinentId)


SELECT a.CountryName 
FROM tblCountry AS a LEFT OUTER JOIN
tblEvent AS b ON a.CountryId = b.CountryId
WHERE a.CountryId NOT IN (SELECT CountryId FROM tblEvent) 
GO


CREATE FUNCTION fnWeekDay (@Week varchar(10))
RETURNS int
AS
BEGIN
	DECLARE @Number AS int
	SELECT @Number = COUNT(EventID) 
	FROM tblEvent
	WHERE DATENAME(WEEKDAY,EventDate) = @Week
	RETURN @Number
END
GO

SELECT DATENAME(WEEKDAY,EventDate) AS [Day of week], dbo.fnWeekDay(DATENAME(WEEKDAY,EventDate)) AS [Number of events]
FROM tblEvent
GROUP BY DATENAME(WEEKDAY,EventDate)
ORDER BY [Number of events] DESC


SELECT DATENAME(WEEKDAY,EventDate) AS [Day of week], COUNT(EventID) AS [Number of events]
FROM tblEvent
GROUP BY DATENAME(WEEKDAY,EventDate)
ORDER BY [Number of events] DESC

SELECT A.CountryName, COUNT(B.EventID) AS NumberEvents
FROM tblCountry AS A 
INNER JOIN
tblEvent AS B
ON A.CountryId = B.CountryId
GROUP BY A.CountryName
ORDER BY NumberEvents DESC
GO 


CREATE FUNCTION fnPunk (@Date datetime)
RETURNS varchar(10)
AS
BEGIN
	DECLARE @Puck varchar(10)
	SET @Puck = 
	(SELECT DISTINCT
		CASE		
			WHEN EventDate > '19791231' THEN 'Post-Punk'
			WHEN EventDate < '19750101' THEN 'Pre-Punk'
			ELSE 'Punk'		
		END		
	FROM tblEvent
	WHERE EventDate = @Date) -- becuase of duplicate date, cannot put @Puck inside query
	RETURN @Puck
END
GO

SELECT dbo.fnPunk(EventDate) AS [Puck Era], COUNT(EventID) AS [Number of events]
FROM tblEvent
GROUP BY dbo.fnPunk(EventDate)
ORDER BY [Number of events] DESC

DROP FUNCTION dbo.fnPunk

SELECT A.CountryName, COUNT(B.EventID) AS [Number of events]
FROM tblCountry AS A INNER JOIN
tblEvent AS B ON A.CountryId = B.CountryId
WHERE EventDate > '19900101'
GROUP BY A.CountryName
HAVING COUNT(B.EventID) >= 5

SELECT LEN(EventName) AS [Numbers of characters], COUNT(EventID) AS [Number of evetns]
FROM tblEvent
GROUP BY LEN(EventName)
ORDER BY [Number of evetns] DESC
GO

CREATE FUNCTION fnExtraText (@Name varchar(255), @Text varchar(255))
RETURNS varchar(3)
AS
BEGIN
	DECLARE @Judge varchar(3)
	SET @Judge = 
	(SELECT 
		CASE
			WHEN LEN([Description]) > LEN(EventName) THEN 'Yes'
			ELSE 'No'
		END
	FROM tblEvent
	WHERE EventName = @Name AND [Description] = @Text)
	RETURN @Judge
END
GO



SELECT EventName, Description, 
		dbo.fnExtraText(EventName, Description) AS [Extra text]
FROM tblEvent
ORDER BY [Extra text] DESC

WITH Decade_CTE (Decade, EventId) AS
(SELECT 
	CASE
		WHEN '19500101' > EventDate AND EventDate > '19301231' THEN 'Decade 1 - forties'
		WHEN '19600101' > EventDate AND EventDate > '19401231' THEN 'Decade 2 - fifties'
		WHEN '19700101' > EventDate AND EventDate > '19501231' THEN 'Decade 3 - sixties'
		WHEN '19800101' > EventDate AND EventDate > '19601231' THEN 'Decade 4 - seventies'
		WHEN '19900101' > EventDate AND EventDate > '19701231' THEN 'Decade 5 - eighties'
		WHEN '20000101' > EventDate AND EventDate > '19801231' THEN 'Decade 6 - ninties'
		ELSE 'Decade 7 - noughties'
	END,
	EventId
FROM tblEvent
)
SELECT Decade, COUNT(EventId) AS [Number of events]
FROM Decade_CTE
GROUP BY Decade
GO

CREATE FUNCTION fnNiceDate (@Date datetime)
RETURNS varchar(50)
AS 
BEGIN
	DECLARE @NiceDate varchar(50)
	SET @NiceDate =
		(SELECT DISTINCT DATENAME(WEEKDAY, EventDate) + ' ' + CONVERT(varchar(2),DATEPART(DAY, EventDate))

		+ ' ' + DATENAME(MONTH, EventDate) + ' ' + CONVERT(varchar(4), DATEPART(YEAR, EventDate))
		FROM tblEvent
		WHERE EventDate = @Date)
	RETURN @NiceDate
END
GO

SELECT EventName, EventDate, dbo.fnNiceDate(EventDate) AS [Nice Day]
FROM tblEvent
ORDER BY EventDate DESC
GO


CREATE PROCEDURE spEventsBetweenDates
AS
SELECT EventName, FORMAT(EventDate, 'd', 'en-US') AS [Date of devent]
FROM tblEvent
WHERE EventDate >= '19700101' AND EventDate <= '19701231'

EXEC spEventsBetweenDates

SELECT DATEPART(YEAR, EventDate) AS EventYear, DATEPART(MONTH, EventDate) AS EventMonth,
	COUNT(EventId) AS [Number of events]
FROM tblEvent
GROUP BY DATEPART(YEAR, EventDate), DATEPART(MONTH, EventDate)
ORDER BY EventYear DESC, EventMonth DESC

SELECT DATEPART(YEAR, EventDate) AS EventYear, DATEPART(MONTH, EventDate) AS EventMonth,
	COUNT(EventId) AS [Number of events]
FROM tblEvent
GROUP BY DATEPART(YEAR, EventDate), DATEPART(MONTH, EventDate) WITH CUBE 
ORDER BY EventYear DESC, EventMonth DESC

SELECT DATEPART(YEAR, EventDate) AS EventYear, DATEPART(MONTH, EventDate) AS EventMonth,
	COUNT(EventId) AS [Number of events]
FROM tblEvent
GROUP BY DATEPART(YEAR, EventDate), DATEPART(MONTH, EventDate) WITH ROLLUP
ORDER BY EventYear DESC, EventMonth DESC
GO

INSERT INTO tblEvent (EventName, EventDate, Description, CountryId)
VALUES ('Cyril Smith dies',
		'03/09/2010',
		'Cyril Smith dies (MP for Rochdale)',
		17)
SELECT * FROM tblEvent
ORDER BY EventDate DESC
GO

CREATE PROCEDURE spAddEvent (@Date datetime NULL,
							@Name varchar(100) NULL,
							@Event varchar(255) NULL,
							@CountryID int = 17)
AS
INSERT INTO tblEvent (EventName, EventDate, Description, CountryId)
VALUES (@Name, @Date, @Event, @CountryID)

EXEC dbo.spAddEvent '06/05/2010', 'General Election', 
				'Tories win general election 2010'

EXEC dbo.spAddEvent '11/07/2010', 'Spain won world cup',
					'Spain defeat the Netherlands', 14

CREATE VIEW vwSingleYear
AS
SELECT EventName, EventDate
FROM tblEvent
WHERE EventDate <= '20001231' AND EventDate >='20000101'
GO

CREATE PROCEDURE dbo.spEvent (@Letter1 varchar(1), @Letter2 varchar(8) = 'NULL')
AS
IF @Letter2 = 'NULL'
	SELECT EventName, FORMAT(EventDate, 'd', 'en-US') AS [Date of event]
	FROM tblEvent
	WHERE LEFT(EventName,1) = @Letter1
ELSE
	SELECT EventName, FORMAT(EventDate, 'd', 'en-US') AS [Date of event]
	FROM tblEvent
	WHERE LEFT(EventName,1) = @Letter1 AND RIGHT(EventName,1) = @Letter2

EXEC dbo.spEvent 'k', 's'
GO

