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
GO

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
GO

CREATE FUNCTION fnEpisodeDescription (@Title varchar(255))
RETURNS varchar(255)
AS
BEGIN
	DECLARE @Type varchar(50)
	SET @Type =
	(SELECT 
		CASE
			WHEN Title LIKE '%Part 1%' THEN 'First part'
			WHEN Title LIKE '%Part 2%' THEN 'Second part'
			ELSE 'Single episode'
		END
	FROM tblEpisode
	WHERE Title = @Title)
	RETURN @Type
END
GO

SELECT dbo.fnEpisodeDescription(Title) AS 'Episode type',
		COUNT(*) AS 'Number of episodes'
FROM tblEpisode
GROUP BY dbo.fnEpisodeDescription(Title)
GO

CREATE FUNCTION dbo.fnFindWords (@Title varchar(100))
RETURNS int
AS
BEGIN
	DECLARE @Index int
	SET @Index =
	(SELECT 
		CASE
			WHEN Title LIKE '%Part 1%' THEN CHARINDEX('Part 1', Title)
			WHEN Title LIKE '%Part 2%' THEN CHARINDEX('Part 2', Title)
			ELSE CHARINDEX('Part 1', Title)
		END
	FROM tblEpisode
	WHERE Title = @Title)
	RETURN @Index
END
GO

SELECT EpisodeId, Title, dbo.fnFindWords(Title) AS [Index]
FROM tblEpisode
GO

CREATE FUNCTION fnNumberComparisons (@ID int)
RETURNS int
AS
BEGIN
	DECLARE @Number int
	SET @Number = 
	(SELECT        COUNT(tblCompanion.CompanionId)
	FROM            tblEpisode INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
	WHERE tblEpisode.EpisodeId = @ID)
	RETURN @Number
END
GO

CREATE FUNCTION fnNumberEnemies (@ID int)
RETURNS int
AS
BEGIN
	DECLARE @Number int
	SET @Number = 
	(SELECT        COUNT(tblEnemy.EnemyId)
	FROM            tblEpisode INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId INNER JOIN
                         tblEnemy ON tblEpisodeEnemy.EnemyId = tblEnemy.EnemyId
		WHERE tblEpisode.EpisodeId = @ID)
	RETURN @Number
END
GO

ALTER FUNCTION fnWords (@Title nvarchar(255))
RETURNS int
AS
BEGIN
	DECLARE @Number int
	SET @Number =
	(SELECT LEN(LTRIM(RTRIM(Title))) - LEN(REPLACE(LTRIM(RTRIM(Title)), ' ', '')) + 1
	FROM tblEpisode
	WHERE Title = @Title)
	RETURN @Number
END 
GO

SELECT EpisodeId, Title, 
		dbo.fnNumberComparisons(EpisodeId) AS Compasions,
		dbo.fnNumberEnemies(EpisodeId) AS Enemies,
		dbo.fnWords(Title) AS Words
FROM tblEpisode
ORDER BY Words DESC
GO

CREATE PROC spGoodAndBad 
			@Series int,
			@NumEnemies int OUTPUT,
			@NumCompanions int OUTPUT
AS
SELECT       @NumEnemies = COUNT(DISTINCT tblEpisodeEnemy.EnemyId), @NumCompanions = COUNT(DISTINCT tblEpisodeCompanion.CompanionId)
FROM            tblEpisode INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId
WHERE tblEpisode.SeriesNumber = @Series
GO

DECLARE @SeriesNumber int = 1
-- variables to hold answers
DECLARE @NumEnemies int
DECLARE @NumCompanions int
EXEC spGoodAndBad @SeriesNumber, @NumEnemies output, @NumCompanions output
-- show the results
SELECT
@SeriesNumber AS 'Series number',
@NumEnemies AS 'Number of enemies',
@NumCompanions AS 'Number of companions'
GO

BEGIN TRANSACTION
	INSERT INTO tblDoctor (DoctorName, DoctorNumber)
	VALUES ('Shaun the Sheep', 13)
IF 2 + 2 = 5
ROLLBACK TRANSACTION
ELSE
COMMIT TRANSACTION

DELETE FROM tblDoctor 
WHERE DoctorNumber = 13
GO

ALTER TABLE tblEpisode
ADD NumberEnemies int

SET NOCOUNT ON
BEGIN TRAN
	UPDATE tblEpisode
	SET NumberEnemies = 
		(SELECT COUNT(*)
		FROM tblEpisodeEnemy AS A
		WHERE A.EnemyId = B.EpisodeId
		)
	FROM tblEpisode AS B
	DECLARE @Row int = @@ROWCOUNT
IF @Row > 120
	BEGIN
		ROLLBACK TRAN
		PRINT CAST(@Row AS VARCHAR(5)) + 'rows updated, but change rolled back'
	END
ELSE
	BEGIN
		COMMIT TRAN
		SELECT EpisodeId, Title, NumberEnemies
		FROM tblEpisode
	END


CREATE TABLE tblProductionCompany
(ProductionCompanyId int IDENTITY(1,1) PRIMARY KEY,
ProductionCompanyName varchar(255),
Abbreviation varchar(100))

INSERT INTO tblProductionCompany (ProductionCompanyName, Abbreviation)
VALUES ('British Broadcasting Corporation', 'BBC'),
		('Canadian Broadcasting Corporation', 'CBC')

SELECT * FROM tblProductionCompany
GO


SELECT * FROM sys.objects
--Temporary tables and table variables
DECLARE @Procedures TABLE
(ObjectType varchar(100),
ObjectName varchar(255),
DateCreated date)

INSERT INTO @Procedures (ObjectType, ObjectName, DateCreated)
SELECT IIF(type = 'P', 'Stored Procedure', 'Scalar Function'), 
		name, CONVERT(date, create_date)
FROM sys.objects
WHERE (type = 'P' OR type = 'FN') AND type_desc NOT LIKE '%SYSTEM_%'

SELECT * FROM @Procedures
GO


CREATE FUNCTION fnDoctor (@Name varchar(50))
RETURNS TABLE
AS 
RETURN
SELECT        tblEpisode.EpisodeId, tblEpisode.Title, tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblAuthor.AuthorId
FROM            tblEpisode INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
                         tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId
WHERE tblDoctor.DoctorName LIKE '%' + @Name + '%'


SELECT * FROM dbo.fnDoctor('Chris')


SELECT A.SeriesNumber, A.EpisodeNumber, A.Title, B.AuthorName
FROM dbo.fnDoctor('Chris') AS A INNER JOIN
		tblAuthor AS B ON A.AuthorId = B.AuthorId


IF object_id('tempdb.dbo.#Characters', 'U') IS NOT NULL
	DROP TABLE #Characters

SELECT DoctorId AS CharacterId, DoctorName AS CharacterName, 'Doctor' AS CharacterType
INTO #Characters
FROM tblDoctor

ALTER TABLE #Characters
ALTER COLUMN CharacterType varchar(20)

SET IDENTITY_INSERT #Characters ON
INSERT INTO #Characters (CharacterId, CharacterName, CharacterType)
SELECT CompanionId, CompanionName, 'Companion'
FROM tblCompanion

SET IDENTITY_INSERT #Characters ON
INSERT INTO #Characters (CharacterId, CharacterName, CharacterType)
SELECT EnemyId, EnemyName, 'Enemy'
FROM tblEnemy

SELECT * FROM #Characters
ORDER BY CharacterName DESC
GO

--If you cannot alter function, drop it first because you change the return type.
DROP FUNCTION fnChosenEpisodes; 
GO

ALTER FUNCTION fnChosenEpisodes 
				(@SeriesNumber int,
				@AuthorName varchar(50))
RETURNS @Information TABLE
(Title NVARCHAR(255),
Author NVARCHAR(50),
Doctor NVARCHAR(50)
)
AS 
BEGIN
IF @SeriesNumber IS NULL
BEGIN
	INSERT INTO @Information (Title, Author, Doctor)
	SELECT    DISTINCT    tblEpisode.Title, tblAuthor.AuthorName, tblDoctor.DoctorName
	FROM            tblEpisode INNER JOIN
							 tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId
	WHERE tblAuthor.AuthorName LIKE '%' + @AuthorName + '%'
END
ELSE IF @AuthorName IS NULL
BEGIN
	INSERT INTO @Information (Title, Author, Doctor)
	SELECT    DISTINCT    tblEpisode.Title, tblAuthor.AuthorName, tblDoctor.DoctorName
	FROM            tblEpisode INNER JOIN
							 tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId
	WHERE tblEpisode.SeriesNumber = @SeriesNumber 
END

ELSE IF (@SeriesNumber IS NULL AND @AuthorName IS NULL)
BEGIN
	INSERT INTO @Information (Title, Author, Doctor)
	SELECT    DISTINCT    tblEpisode.Title, tblAuthor.AuthorName, tblDoctor.DoctorName
	FROM            tblEpisode INNER JOIN
							 tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId
END
BEGIN
	INSERT INTO @Information (Title, Author, Doctor)
	SELECT    DISTINCT    tblEpisode.Title, tblAuthor.AuthorName, tblDoctor.DoctorName
	FROM            tblEpisode INNER JOIN
							 tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
							 tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId
	WHERE tblEpisode.SeriesNumber = @SeriesNumber AND tblAuthor.AuthorName LIKE '%' + @AuthorName + '%'
END
RETURN
END
GO

SELECT * FROM fnChosenEpisodes(2, 'moffat')
SELECT * FROM fnChosenEpisodes(2, NULL)
SELECT * FROM fnChosenEpisodes(NULL, 'moffat')
SELECT * FROM fnChosenEpisodes(NULL, NULL)


CREATE TABLE #BestDoctor
(EpisodeId int,
Title varchar(100),
SeriersNumber int,
EpisodeNumber int,
Why varchar(100)
)

INSERT INTO #BestDoctor (EpisodeId, Title, SeriersNumber, EpisodeNumber, Why)
SELECT        tblEpisode.EpisodeId, tblEpisode.Title, tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblAuthor.AuthorName
FROM            tblEpisode INNER JOIN
                         tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId
WHERE        (tblAuthor.AuthorName = 'Steven Moffat')

INSERT INTO #BestDoctor (EpisodeId, Title, SeriersNumber, EpisodeNumber, Why)
SELECT        tblEpisode.EpisodeId, tblEpisode.Title, tblEpisode.SeriesNumber, tblEpisode.EpisodeNumber, tblCompanion.CompanionName
FROM            tblEpisode INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
WHERE        (tblCompanion.CompanionName = 'Amy Pond')


SELECT Title, COUNT(EpisodeId) AS [Number of metions] FROM #BestDoctor
GROUP BY Title
HAVING COUNT(EpisodeId) > 1
GO

ALTER FUNCTION fnSilly (@CompanionName varchar(100), @EnemyName varchar(100))
RETURNS TABLE
AS
RETURN
SELECT        tblEpisode.SeriesNumber, tblEpisode.EpisodeId, tblEpisode.Title, tblDoctor.DoctorName, tblAuthor.AuthorName, tblCompanion.CompanionName AS Appearing
FROM            tblEpisode INNER JOIN
                         tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
WHERE tblCompanion.CompanionName LIKE '%' + @CompanionName + '%'
UNION
SELECT        tblEpisode.SeriesNumber, tblEpisode.EpisodeId, tblEpisode.Title, tblDoctor.DoctorName, tblAuthor.AuthorName, tblEnemy.EnemyName + ', ' + tblCompanion.CompanionName
FROM            tblEpisode INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
                         tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId INNER JOIN
                         tblEnemy ON tblEpisodeEnemy.EnemyId = tblEnemy.EnemyId INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
WHERE tblEnemy.EnemyName LIKE '%' + @EnemyName + '%' AND tblCompanion.CompanionName NOT LIKE '%' + @CompanionName + '%'
GO


SELECT * FROM fnSilly('wilf','ood')
GO

WITH NameForYourCte AS
(SELECT        tblEpisode.EpisodeId
FROM            tblEpisode INNER JOIN
                         tblAuthor ON tblEpisode.AuthorId = tblAuthor.AuthorId
WHERE tblAuthor.AuthorName LIKE '%MP%')
SELECT     DISTINCT   tblCompanion.CompanionName
FROM            tblEpisodeCompanion INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId
						 INNER JOIN NameForYourCte ON NameForYourCte.EpisodeId = tblEpisodeCompanion.EpisodeId

WITH cte_Enemy (Enemy)
AS
(
SELECT        tblEnemy.EnemyName
FROM            tblEpisode INNER JOIN
                         tblEpisodeCompanion ON tblEpisode.EpisodeId = tblEpisodeCompanion.EpisodeId INNER JOIN
                         tblCompanion ON tblEpisodeCompanion.CompanionId = tblCompanion.CompanionId INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId INNER JOIN
                         tblEnemy ON tblEpisodeEnemy.EnemyId = tblEnemy.EnemyId
WHERE tblCompanion.CompanionName = 'Rose Tyler' AND tblDoctor.DoctorName <> 'David Tennant')
SELECT DISTINCT Enemy FROM cte_Enemy


SELECT DISTINCT       tblEpisode.EpisodeId, tblEpisode.Title
FROM            tblEpisodeEnemy INNER JOIN
                         tblEnemy ON tblEpisodeEnemy.EnemyId = tblEnemy.EnemyId INNER JOIN
                         tblEpisode INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId ON tblEpisodeEnemy.EpisodeId = tblEpisode.EpisodeId
WHERE tblDoctor.DoctorName = 'David Tennant' AND 
		tblEnemy.EnemyId NOT IN 
		(SELECT    DISTINCT    tblEnemy.EnemyId
		FROM            tblEpisode INNER JOIN
                         tblEpisodeEnemy ON tblEpisode.EpisodeId = tblEpisodeEnemy.EpisodeId INNER JOIN
                         tblEnemy ON tblEpisodeEnemy.EnemyId = tblEnemy.EnemyId INNER JOIN
                         tblDoctor ON tblEpisode.DoctorId = tblDoctor.DoctorId
		WHERE tblDoctor.DoctorName <> 'David Tennant')
ORDER BY tblEpisode.Title
GO


CREATE PROC spEpisodesSorted @SortColumn varchar(15) = 'EpisodeId', 
								@SortOrder varchar(5) = 'ASC'
AS
BEGIN
	DECLARE @Sql varchar(1000)
	SELECT @Sql = 'SELECT ' + @SortColumn + '
	FROM tblEpisode
	ORDER BY ' + @SortColumn +' '+ @SortOrder

	EXEC (@Sql)
END

EXEC spEpisodesSorted 

EXEC spEpisodesSorted 'Title', 'DESC'














