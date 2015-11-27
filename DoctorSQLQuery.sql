SELECT DoctorID, DoctorName, BirthDate
FROM tblDoctor
ORDER BY BirthDate;
GO

CREATE PROCEDURE spMattSmithEpisodes
AS
SELECT        tblDoctor.DoctorName, tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblEpisode.Title, tblEpisode.EpisodeDate
FROM            tblDoctor INNER JOIN
                         tblEpisode ON tblDoctor.DoctorId = tblEpisode.DoctorId
WHERE        (tblDoctor.DoctorName = N'Matt Smith')
ORDER BY tblEpisode.EpisodeDate 
GO

ALTER PROCEDURE spMattSmithEpisodes
AS
SELECT        tblDoctor.DoctorName, tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblEpisode.Title, tblEpisode.EpisodeDate
FROM            tblDoctor INNER JOIN
                         tblEpisode ON tblDoctor.DoctorId = tblEpisode.DoctorId
WHERE        (tblDoctor.DoctorName = N'Matt Smith') AND (YEAR(tblEpisode.EpisodeDate) = 2012)
ORDER BY tblEpisode.EpisodeDate 
GO

CREATE PROCEDURE spMoffats 
AS
SELECT        tblEpisode.Title
FROM            tblAuthor INNER JOIN
                         tblEpisode ON tblAuthor.AuthorId = tblEpisode.AuthorId
WHERE        (tblAuthor.AuthorName = 'Steven Moffat')
ORDER BY tblEpisode.EpisodeDate DESC
GO

ALTER PROCEDURE spMoffats 
AS
SELECT        tblEpisode.Title
FROM            tblAuthor INNER JOIN
                         tblEpisode ON tblAuthor.AuthorId = tblEpisode.AuthorId
WHERE        (tblAuthor.AuthorName = 'Russell T. Davies')
ORDER BY tblEpisode.EpisodeDate DESC
GO


CREATE PROCEDURE spAuthor (@Author varchar(100))
AS
SELECT        tblEpisode.Title
FROM            tblAuthor INNER JOIN
                         tblEpisode ON tblAuthor.AuthorId = tblEpisode.AuthorId
WHERE        (tblAuthor.AuthorName = @Author)
ORDER BY tblEpisode.EpisodeDate DESC
GO

EXEC spAuthor 'Russell T. Davies'
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
GO

ALTER PROC spSummariseEpisodes 
AS
SELECT   TOP 5     tblCompanion.CompanionName, COUNT(tblEpisodeCompanion.CompanionId) AS Episodes
FROM            tblCompanion INNER JOIN
                         tblEpisodeCompanion ON tblCompanion.CompanionId = tblEpisodeCompanion.CompanionId
GROUP BY tblEpisodeCompanion.CompanionId, tblCompanion.CompanionName
ORDER BY Episodes ASC

SELECT   TOP 5    tblEnemy.EnemyName, COUNT(tblEpisodeEnemy.EnemyId) AS Episodes
FROM            tblEnemy INNER JOIN
                         tblEpisodeEnemy ON tblEnemy.EnemyId = tblEpisodeEnemy.EnemyId
GROUP BY tblEpisodeEnemy.EnemyId, tblEnemy.EnemyName
ORDER BY Episodes ASC
GO

CREATE PROC spEnemyEpisodes (@Name varchar(50))
AS
SELECT        tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblEpisode.Title
FROM            tblEnemy INNER JOIN
                         tblEpisodeEnemy ON tblEnemy.EnemyId = tblEpisodeEnemy.EnemyId INNER JOIN
                         tblEpisode ON tblEpisodeEnemy.EpisodeId = tblEpisode.EpisodeId
WHERE tblEnemy.EnemyName LIKE '%' + @Name + '%' -- parameters cannot be in ''.
ORDER BY tblEpisode.SeriesNumber
GO

EXEC spEnemyEpisodes 'Silence'



DECLARE @EpisodeId int = 42
DECLARE @EpisodeName varchar(100), @NumberCompanions int, @NumberEnemies int
SELECT       @EpisodeName = tblEpisode.Title, @EpisodeId = tblEpisode.EpisodeId, 
			@NumberCompanions = COUNT(tblEpisodeCompanion.CompanionId), 
			@NumberEnemies = COUNT(tblEpisodeEnemy.EnemyId)
FROM            tblEpisode INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId
WHERE tblEpisode.EpisodeId = @EpisodeId
GROUP BY tblEpisode.Title, tblEpisode.EpisodeId

SELECT @EpisodeName AS Title, @EpisodeId AS EpisodeId, 
		@NumberCompanions AS [Number of Companions], 
		@NumberEnemies AS [Number of enemies]

--Use a default parameter value to list episodes for a given series
GO

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
EXEC spListEpisodes 2

ALTER PROC spCompanionsForDoctor (@Doctor varchar(50) = NULL)
AS
IF @Doctor IS NULL
BEGIN
	SELECT   DISTINCT     tblCompanion.CompanionName
	FROM            tblEpisodeCompanion INNER JOIN
							 tblEpisode ON tblEpisodeCompanion.EpisodeId = tblEpisode.EpisodeId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
							 tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
END
ELSE
BEGIN
	SELECT   DISTINCT     tblCompanion.CompanionName
	FROM            tblEpisodeCompanion INNER JOIN
							 tblEpisode ON tblEpisodeCompanion.EpisodeId = tblEpisode.EpisodeId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
							 tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
	WHERE tblDoctor.DoctorName LIKE '%' + @Doctor + '%'
END

spCompanionsForDoctor 'matt'



