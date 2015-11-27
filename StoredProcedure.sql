CREATE PROCEDURE spEventsBetweenDates
AS
SELECT EventName, FORMAT(EventDate, 'd', 'en-US') AS [Date of devent]
FROM tblEvent
WHERE EventDate >= '19700101' AND EventDate <= '19701231'

EXEC spEventsBetweenDates
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

--When join multiple tables, it is important to include all collumns in group by for aggregate function.
CREATE PROC spSummariseEpisodes 
AS
SELECT   TOP 3     tblCompanion.CompanionName, COUNT(tblEpisodeCompanion.CompanionId) AS Episodes
FROM            tblCompanion INNER JOIN
                         tblEpisodeCompanion ON tblCompanion.CompanionId = tblEpisodeCompanion.CompanionId
GROUP BY tblEpisodeCompanion.CompanionId, tblCompanion.CompanionName
ORDER BY Episodes DESC

SELECT   TOP 3     tblEnemy.EnemyName, COUNT(tblEpisodeEnemy.EnemyId) AS Episodes
FROM            tblEnemy INNER JOIN
                         tblEpisodeEnemy ON tblEnemy.EnemyId = tblEpisodeEnemy.EnemyId
GROUP BY tblEpisodeEnemy.EnemyId, tblEnemy.EnemyName
ORDER BY Episodes DESC

CREATE PROC spListEpisodes (@Series int = NULL)
AS
IF @Series IS NULL
BEGIN
	SELECT Title
	FROM tblEpisode
END
ELSE
BEGIN
	SELECT Title
	FROM tblEpisode
	WHERE SeriesNumber = @Series
END

DROP PROC spCalculateAge
CREATE PROCEDURE spCalculateAge 
AS
DECLARE @Age int
SET @Age = DATEDIFF(YEAR,'19770108', GETDATE())
PRINT 'You are ' + CONVERT(VARCHAR(3),@Age) + ' years old.'
GO


-- Choose the second parameter by setting @CourseName = 
ALTER PROC spListDelegates @CompanyName varchar(255) = NULL, 
							@CourseName varchar(255) = NULL
--							@CourseContains varchar(255) OUTPUT
AS
IF @CompanyName IS NULL AND @CourseName IS NULL
BEGIN
SELECT  DISTINCT      tblPerson.FirstName + ' ' + tblPerson.LastName AS People
FROM            tblPerson INNER JOIN
							tblCourse INNER JOIN
							tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
							tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId ON tblPerson.Personid = tblDelegate.PersonId INNER JOIN
							tblOrg ON tblPerson.OrgId = tblOrg.OrgId
END
ELSE IF @CourseName IS NULL
BEGIN
SELECT    DISTINCT   tblPerson.FirstName + ' ' + tblPerson.LastName AS People
FROM            tblPerson INNER JOIN
							tblCourse INNER JOIN
							tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
							tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId ON tblPerson.Personid = tblDelegate.PersonId INNER JOIN
							tblOrg ON tblPerson.OrgId = tblOrg.OrgId
WHERE tblOrg.OrgName LIKE '%' +  @CompanyName + '%'
END
ELSE IF @CompanyName IS NULL
BEGIN
SELECT    DISTINCT   tblPerson.FirstName + ' ' + tblPerson.LastName AS People
FROM            tblPerson INNER JOIN
							tblCourse INNER JOIN
							tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
							tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId ON tblPerson.Personid = tblDelegate.PersonId INNER JOIN
							tblOrg ON tblPerson.OrgId = tblOrg.OrgId
WHERE tblCourse.CourseName LIKE '%' +  @CourseName + '%'
END
ELSE
BEGIN
SELECT  DISTINCT      tblPerson.FirstName + ' ' + tblPerson.LastName AS People
FROM            tblPerson INNER JOIN
							tblCourse INNER JOIN
							tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
							tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId ON tblPerson.Personid = tblDelegate.PersonId INNER JOIN
							tblOrg ON tblPerson.OrgId = tblOrg.OrgId
WHERE  tblOrg.OrgName =  @CompanyName  AND tblCourse.CourseName LIKE '%' +  @CourseName + '%'	
END

spListDelegates 'Lloyds', 'ASP.NET'

spListDelegates 'bp'

spListDelegates @CourseName = 'WORD'

