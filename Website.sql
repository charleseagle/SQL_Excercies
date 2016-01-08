SELECT TOP 10 WebsiteName, AlexaRankUK
FROM tblWebsite
WHERE AlexaRankUK IS NOT NULL
ORDER BY AlexaRankUK
GO

CREATE PROCEDURE spListTopWebsites 
AS
SELECT TOP 10 WebsiteName, AlexaRankUK
FROM tblWebsite
WHERE AlexaRankUK IS NOT NULL
ORDER BY AlexaRankUK
GO

ALTER PROCEDURE spListTopWebsites
AS
SELECT TOP 5 WebsiteName, AlexaRankUK
FROM tblWebsite
WHERE AlexaRankUK IS NOT NULL
ORDER BY AlexaRankUK
GO

ALTER PROC spWebsitesByCategory (@Category varchar(100))
AS
SELECT A.WebsiteName, B.CategoryName
FROM tblWebsite AS A INNER JOIN
tblCategory AS B ON A.CategoryId = B.CategoryId
WHERE B.CategoryName = @Category
ORDER BY A.WebsiteName 

EXEC spWebsitesByCategory 'Search engine'


ALTER PROC spRwoCount
AS
SET NOCOUNT ON
PRINT 'Summary of query'
PRINT '----------------------'
SELECT *FROM tblWebsite
PRINT 'This listed ' + CAST(@@rowcount AS VARCHAR(20)) + ' sites.'
GO

ALTER FUNCTION fnDomain (@URL varchar(100))
RETURNS varchar(20)
AS
BEGIN
	DECLARE @Domain varchar(20)
	SET @Domain =
	(SELECT    DISTINCT    
	CASE 
		WHEN CHARINDEX(tblDomain.DomainName, tblWebsite.WebsiteUrl) = 0 THEN 'Ivalid'
		WHEN CHARINDEX(REVERSE(tblDomain.DomainName), REVERSE(tblWebsite.WebsiteUrl)) = 1 
		THEN RIGHT(tblWebsite.WebsiteUrl, LEN(tblWebsite.WebsiteUrl) - CHARINDEX(tblDomain.DomainName, tblWebsite.WebsiteUrl) + 1)
		ELSE REVERSE(LEFT(REVERSE(tblWebsite.WebsiteUrl), CHARINDEX(REVERSE(tblDomain.DomainName), REVERSE(tblWebsite.WebsiteUrl)) - 1))
	END
	FROM            tblDomain INNER JOIN
                         tblWebsite ON tblDomain.DomainId = tblWebsite.DomainId
	WHERE tblWebsite.WebsiteUrl = @URL)
	RETURN @Domain
END
GO


SELECT        tblWebsite.WebsiteName, tblWebsite.WebsiteUrl, dbo.fnDomain(tblWebsite.WebsiteUrl) AS Domain, tblDomain.DomainName
FROM            tblDomain INNER JOIN
                         tblWebsite ON tblDomain.DomainId = tblWebsite.DomainId
ORDER BY tblWebsite.WebsiteName
GO

ALTER PROCEDURE spSchedules (@FromDate date = '19900101', @ToDate date = '19991231')
AS
SELECT        WebsiteName, DateOnline
FROM            tblWebsite
WHERE DateOnline >= @FromDate AND DateOnline <= @ToDate
ORDER BY DateOnline
GO

EXEC spSchedules '01/01/1991', '12/31/1991'

SET NOCOUNT ON
BEGIN TRANSACTION
	DELETE FROM  Data_at_14_Jan_2010
	WHERE Category = 'Betting' OR Category = 'Adult'
	DECLARE @Row int
	SET @Row = 
	(SELECT COUNT(*)
	FROM Data_at_14_Jan_2010)
	PRINT 'After deletion: ' + CONVERT(VARCHAR(5), @Row)
ROLLBACK TRANSACTION
	DECLARE @RowAfter int
	SET @RowAfter = 
	(SELECT COUNT(*)
	FROM Data_at_14_Jan_2010)
	PRINT 'After rollback: ' + CONVERT(VARCHAR(5), @RowAfter)

DECLARE @Text varchar(255)
DECLARE @Position int = 0
DECLARE @Website_Cursor CURSOR
SET @Website_Cursor = CURSOR FOR
SELECT WebsiteName + ' is at position ' + CONVERT(VARCHAR(5), AlexaRankWorld) + 
		' with ' + CAST(NumberLinks AS VARCHAR(10))  + ' links.'
FROM tblWebsite
ORDER BY AlexaRankWorld

OPEN @Website_Cursor
FETCH NEXT FROM @Website_Cursor
INTO @Text

WHILE @Position < 10 
BEGIN
	PRINT @Text
	SET @Position = @Position + 1
	FETCH NEXT FROM @Website_Cursor
	INTO @Text
END
CLOSE @Website_Cursor
DEALLOCATE @Website_Cursor
GO

ALTER PROC sp_CompareCountries @Country1 varchar(20),
								@Country2 varchar(20)
AS
BEGIN
	DECLARE @Sql varchar(1000)
	SELECT @Sql = 
	'WITH cte_web (WebsiteId, WebsiteName, Country1, Country2)
	AS
	(	
	SELECT a.WebsiteId,b.WebsiteName, ISNULL(a.' + @Country1 + ', 0.000) AS Country1, ISNULL(a.' + @Country2 + ', 0.000) AS Country2
	FROM 
	(SELECT WebsiteId, ' + @Country1 + ', ' + @Country2 + '
	FROM (SELECT WebsiteId, CountryName, Proportion
		FROM 
		(SELECT   DISTINCT     tblWebsite.WebsiteId AS WebsiteId, tblCountry.CountryName AS CountryName,   tblUsage.Proportion AS Proportion
		FROM            tblUsage INNER JOIN
								tblCountry ON tblUsage.CountryId = tblCountry.CountryId INNER JOIN
								tblWebsite ON tblUsage.WebsiteId = tblWebsite.WebsiteId
		) AS Prop) AS Prop1
		PIVOT (SUM(Proportion) FOR CountryName IN (' + @Country1 + ', ' + @Country2 + ')) AS pvt) AS a
		INNER JOIN
		tblWebsite AS b ON a.WebsiteId = b.WebsiteId
		) 
	SELECT WebsiteName, Country1 AS [First Country], Country2 AS [Seond Country], (Country1 + Country2) AS Total
	FROM cte_web'
	EXEC (@Sql)
END

EXEC sp_CompareCountries 'France', 'Greece'
GO

WITH cte_web (WebsiteId, WebsiteName, Country1, Country2)
	AS
	(	
	SELECT a.WebsiteId,b.WebsiteName, ISNULL(a.France, 0.000) AS Country1, ISNULL(a.Greece, 0.000) AS Country2
	FROM 
	(SELECT WebsiteId, France, Greece
	FROM (SELECT WebsiteId, CountryName, Proportion
		FROM 
		(SELECT   DISTINCT     tblWebsite.WebsiteId AS WebsiteId, tblCountry.CountryName AS CountryName,   tblUsage.Proportion AS Proportion
		FROM            tblUsage INNER JOIN
								tblCountry ON tblUsage.CountryId = tblCountry.CountryId INNER JOIN
								tblWebsite ON tblUsage.WebsiteId = tblWebsite.WebsiteId
		) AS Prop) AS Prop1
		PIVOT (SUM(Proportion) FOR CountryName IN (France, Greece)) AS pvt) AS a
		INNER JOIN
		tblWebsite AS b ON a.WebsiteId = b.WebsiteId
		) 
	SELECT WebsiteName, Country1 AS [First Country], Country2 AS [Seond Country], (Country1 + Country2) AS Total
	FROM cte_web













