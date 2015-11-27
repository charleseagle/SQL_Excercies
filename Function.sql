CREATE FUNCTION fnWeekDay (@Week varchar(10))
RETURNS int
AS
BEGIN
	DECLARE @Number AS int
	SET @Number = (SELECT COUNT(EventID) 
	FROM tblEvent
	WHERE DATENAME(WEEKDAY,EventDate) = @Week)
	RETURN @Number
END
GO

SELECT DATENAME(WEEKDAY,EventDate) AS [Day of week], dbo.fnWeekDay(DATENAME(WEEKDAY,EventDate)) AS [Number of events]
FROM tblEvent
GROUP BY DATENAME(WEEKDAY,EventDate)
ORDER BY [Number of events] DESC
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

SELECT dbo.fnPunk(EventDate) AS [Puck Era], EventName
FROM tblEvent
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




