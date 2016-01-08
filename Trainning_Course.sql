
DECLARE @CurseName varchar(50)
DECLARE @People varchar(MAX) 
SET @CurseName = (SELECT DISTINCT CourseName
FROM tblPerson AS A INNER JOIN 
tblDelegate AS B ON A.Personid = B.PersonId
INNER JOIN tblSchedule AS C ON B.ScheduleId = C.ScheduleId
INNER JOIN tblCourse AS D ON C.CourseId = D.CourseId
WHERE C.ScheduleId = 1)
PRINT @CurseName + ' Delegates'
PRINT ''

DECLARE @People_cursor CURSOR
SET @People_cursor = CURSOR FOR
SELECT A.FirstName + ' ' + A.LastName AS FullName
FROM tblPerson AS A INNER JOIN 
tblDelegate AS B ON A.Personid = B.PersonId
INNER JOIN tblSchedule AS C ON B.ScheduleId = C.ScheduleId
WHERE C.ScheduleId = 1

OPEN @People_cursor
FETCH NEXT FROM @People_cursor 
INTO @People
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @People
	FETCH NEXT FROM @People_cursor
	INTO @People
END
CLOSE @People_cursor
DEALLOCATE @People_cursor

SELECT C.FirstName, C.LastName
FROM tblSchedule AS A INNER JOIN
tblDelegate AS B ON A.ScheduleId = B.ScheduleId
INNER JOIN tblPerson AS C 
ON B.PersonId = C.Personid
WHERE B.ScheduleId = 1

SELECT A.FirstName, A.LastName 
FROM tblPerson AS A INNER JOIN 
tblDelegate AS B ON A.Personid = B.PersonId
INNER JOIN tblSchedule AS C ON B.ScheduleId = C.ScheduleId
WHERE C.ScheduleId = 1

SELECT A.ScheduleId
FROM tblSchedule AS A INNER JOIN
tblDelegate AS B ON A.ScheduleId = B.ScheduleId
INNER JOIN tblPerson AS C 
ON B.PersonId = C.Personid
WHERE C.FirstName = 'Darryl' AND C.LastName = 'Hazelden' --The practice answer is wrong.
GO

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
GO

spListDelegates 'Lloyds', 'ASP.NET'

spListDelegates 'bp'

spListDelegates @CourseName = 'WORD'
GO


ALTER PROC spResourceCourseCount 
			@Resource varchar(100),
			@NumberFound int OUTPUT
AS
SET @NumberFound =
(SELECT       
	CASE 
	WHEN COUNT(tblSchedule.CourseId) = 0 THEN -1
	ELSE COUNT(tblSchedule.CourseId)
	END
FROM            tblResource INNER JOIN
                         tblSchedule ON tblSchedule.ResourceIds LIKE '%'+ CONVERT(VARCHAR(50), tblResource.ResourceId) +'%' 
WHERE 	tblResource.ResourceName = 	@Resource)
GO

DECLARE @NumberFound int 
EXEC spResourceCourseCount 'Flip chart', @NumberFound OUTPUT

IF @NumberFound = -1
	PRINT 'This resource doesn''t exist'
ELSE
	PRINT CAST(@NumberFound AS VARCHAR(50)) + ' course(s) using this resource'

ALTER TABLE tblPerson 
ADD Importance int
GO



ALTER FUNCTION fnNumber (@PersonId int)
RETURNS int
AS
BEGIN 
	DECLARE @Number int
	SET @Number =
	(SELECT COUNT(*) 
	FROM tblPerson INNER JOIN
    tblDelegate ON tblPerson.Personid = tblDelegate.PersonId
	WHERE tblPerson.Personid = @PersonId)
	RETURN @Number
END
GO


SET NOCOUNT ON
BEGIN TRANSACTION; --table common expression must use ';' before it
WITH cte_AttendCourse (PersonId, Attended)  --table common expression is a good way to update the whole column
AS
(SELECT PersonId,
	CASE 
		WHEN dbo.fnNumber(Personid) <=1 THEN 10
		WHEN dbo.fnNumber(Personid) >=2 AND dbo.fnNumber(Personid) <= 4 THEN 20
		ELSE 30
	END
FROM  tblPerson)

UPDATE tblPerson 
SET Importance = Attended
FROM  cte_AttendCourse AS A
WHERE A.PersonId = tblPerson.PersonId  --Must use where clause to specify the row.
	
DECLARE @Row int
DELETE FROM tblPerson
WHERE Importance = 10
SET @Row = @@ROWCOUNT
PRINT CONVERT(VARCHAR(5), @Row) + ' unimportant people deleted.'
	
DECLARE @RowLeft int
SET  @RowLeft = (SELECT COUNT(*) FROM tblPerson)
IF @RowLeft >= 500
COMMIT TRANSACTION
ELSE
ROLLBACK TRANSACTION

CREATE TABLE #Person
(PersonId int,
FirstName varchar(100),
LastName varchar(100),
NumberPlaces int,
NumberSql int,
NumberVisio int)

INSERT INTO #Person (PersonId, FirstName, LastName)
SELECT PersonId, FirstName, LastName
FROM tblPerson

WITH cte_Course (Personid, NumberPlaces)
AS
(SELECT      tblPerson.Personid,  COUNT( DISTINCT tblCourse.CourseId)
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId INNER JOIN
                         tblPerson ON tblDelegate.PersonId = tblPerson.Personid
GROUP BY tblPerson.Personid)
UPDATE #Person
SET NumberPlaces = A.NumberPlaces
FROM cte_Course AS A
WHERE A.Personid = #Person.PersonId
UPDATE #Person
SET NumberPlaces = 0
WHERE NumberPlaces IS NULL

WITH cte_Course (Personid, NumberSql)
AS
(SELECT      tblPerson.Personid,  COUNT( DISTINCT tblCourse.CourseId)
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId INNER JOIN
                         tblPerson ON tblDelegate.PersonId = tblPerson.Personid
WHERE tblCourse.CourseName LIKE '%SQL%'
GROUP BY tblPerson.Personid)
UPDATE #Person
SET NumberSql = A.NumberSql
FROM cte_Course AS A
WHERE A.Personid = #Person.PersonId
UPDATE #Person
SET NumberSql = 0
WHERE NumberSql IS NULL

WITH cte_Course (Personid, NumberVisio)
AS
(SELECT      tblPerson.Personid,  COUNT( DISTINCT tblCourse.CourseId)
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId INNER JOIN
                         tblPerson ON tblDelegate.PersonId = tblPerson.Personid
WHERE tblCourse.CourseName LIKE '%Visio%'
GROUP BY tblPerson.Personid)
UPDATE #Person
SET NumberVisio = A.NumberVisio
FROM cte_Course AS A
WHERE A.Personid = #Person.PersonId
UPDATE #Person
SET NumberVisio = 0
WHERE NumberVisio IS NULL

SELECT * FROM #Person
ORDER BY FirstName

select PersonId FROM tblPerson



-- Get the comma plit values
DECLARE @S varchar(max),
        @Split char(1),
        @X xml

SELECT @S = '21, 93, 3993, 4085',
       @Split = ','

SELECT @X = CONVERT(xml,' <root> <s>' + REPLACE(@S,@Split,'</s> <s>') + '</s>   </root> ')

SELECT [Value] = T.c.value('.','varchar(20)')
FROM @X.nodes('/root/s') T(c)
GO

CREATE PROCEDURE spTrainer @TrainerId varchar(100)
AS
SELECT

DECLARE @X xml, @Ids VARCHAR(100) = '21, 93, 3993, 4085'
SET @X = CONVERT(xml,' <root> <s>' + REPLACE(@Ids, ',','</s> <s>') + '</s>   </root> ')
;WITH cte_Id (ID)
AS(
SELECT [Value] = T.c.value('.','varchar(20)')
FROM @X.nodes('/root/s') T(c)
)
SELECT TrainerName
FROM tblTrainer AS B INNER JOIN cte_Id AS A
ON A.ID = B.TrainerId
GO

DROP TABLE #Org
CREATE TABLE #Org
(OrgId int,
OrgName varchar(100)
)

INSERT INTO #Org(OrgId, OrgName)
SELECT      tblOrg.OrgId,  tblOrg.OrgName
FROM            tblSector INNER JOIN
                         tblOrg ON tblSector.SectorId = tblOrg.SectorId
WHERE tblSector.SectorName = 'Retail'
 
INSERT INTO #Org (OrgId, OrgName)
SELECT   B.OrgId, B.Orgname
FROM tblOrg AS B
WHERE (SELECT COUNT(*) FROM tblPerson AS A
		WHERE A.OrgId = B.OrgId) > 12

SELECT * FROM #Org

DECLARE @TechieCourses TABLE
(ScheduleId int)
INSERT INTO @TechieCourses
SELECT        tblSchedule.ScheduleId
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblTrainer ON CONVERT(VARCHAR(10), tblTrainer.TrainerId) LIKE tblSchedule.TrainerIds
WHERE tblCourse.CourseName LIKE '%C#%' OR tblTrainer.TrainerName = 'Gabriella Montez'

INSERT INTO @TechieCourses
SELECT        ScheduleId
FROM            tblSchedule
WHERE ',' + TrainerIds  + ',' LIKE '%,2936,%'

SELECT A.ScheduleId, B.StartDate, C.CourseName, B.TrainerIds 
FROM @TechieCourses AS A INNER JOIN 
tblSchedule AS B ON A.ScheduleId = B.ScheduleId INNER JOIN
tblCourse AS C ON B.CourseId = C.CourseId 
ORDER BY B.StartDate	
GO


ALTER FUNCTION fnCoursesForResources (@Name varchar(50))
RETURNS TABLE
AS RETURN
SELECT    DISTINCT    tblSchedule.ScheduleId, tblCourse.CourseName, tblSchedule.StartDate, tblSchedule.ResourceIds
FROM            tblSchedule INNER JOIN
                         tblCourse ON tblSchedule.CourseId = tblCourse.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId INNER JOIN
                         tblResource ON tblSchedule.ResourceIds LIKE '%' + CAST(tblResource.ResourceId AS VARCHAR(10)) + '%'
WHERE tblResource.ResourceName = @Name

SELECT * FROM fnCoursesForResources('Projector')


PRINT 'TRAINERS'
PRINT '----------'
DECLARE @Name varchar(50)
DECLARE @Trainer_Cursor CURSOR
SET @Trainer_Cursor = CURSOR FOR
SELECT TrainerName + '(id '+CONVERT(VARCHAR(10), TrainerId)+')'
FROM tblTrainer

OPEN @Trainer_Cursor
FETCH NEXT FROM @Trainer_Cursor
INTO @Name

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @Name
	FETCH NEXT FROM @Trainer_Cursor
	INTO @Name
END
CLOSE @Trainer_Cursor
DEALLOCATE @Trainer_Cursor
GO

WITH PersonCte AS
(SELECT        tblPerson.Personid
FROM            tblPerson INNER JOIN
                         tblDelegate ON tblPerson.Personid = tblDelegate.PersonId
GROUP BY tblPerson.Personid
HAVING COUNT(tblDelegate.DelegateId) >= 6)
SELECT    DISTINCT    tblCourse.CourseName, tblDelegate.DelegateId, tblDelegate.PersonId
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId
						 INNER JOIN PersonCte ON PersonCte.Personid = tblDelegate.PersonId
ORDER BY tblCourse.CourseName
GO

CREATE PROCEDURE spNames @ScheduleId int,
						@Text1 varchar(255) OUTPUT
AS
BEGIN
	DECLARE @Text varchar(255)
	DECLARE @People_Cursor CURSOR
	SET @People_Cursor = CURSOR FOR
	SELECT        tblPerson.FirstName + ' ' + tblPerson.LastName
	FROM            tblSchedule INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId INNER JOIN
                         tblPerson ON tblDelegate.PersonId = tblPerson.Personid 
	WHERE tblSchedule.ScheduleId = @ScheduleId

	OPEN @People_Cursor
	FETCH NEXT FROM @People_Cursor
	INTO @Text

	SET @Text1 = @Text 
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		FETCH NEXT FROM @People_Cursor
		INTO @Text
		SET @Text1 = @Text1 + ', ' + @Text
	END
	CLOSE @People_Cursor
	DEALLOCATE @People_Cursor
END
GO

DECLARE @Text varchar(255)
EXEC spNames 31, @Text OUTPUT
PRINT @Text


CREATE TABLE #Schedules 
(ScheduleId int,
StartDate datetime,
CourseName varchar(100),
People varchar(255)
)

DECLARE @Course varchar(100)
DECLARE @Date datetime
DECLARE @Id int

DECLARE @Course_Cursor CURSOR
SET @Course_Cursor = CURSOR FOR
SELECT CourseName
FROM tblCourse
WHERE CourseName LIKE '%SQL%'

DECLARE @Date_Cursor CURSOR
SET @Date_Cursor = CURSOR FOR
SELECT    DISTINCT    tblSchedule.StartDate
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId
WHERE CourseName LIKE '%SQL%'

DECLARE @Id_Cursor CURSOR
SET @Id_Cursor = CURSOR FOR
SELECT     DISTINCT   tblSchedule.ScheduleId
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId
WHERE CourseName LIKE '%SQL%'

OPEN @Course_Cursor
OPEN @Date_Cursor
OPEN @Id_Cursor

FETCH NEXT FROM @Course_Cursor
INTO @Course
FETCH NEXT FROM @Date_Cursor
INTO @Date
FETCH NEXT FROM @Id_Cursor
INTO @Id

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @People varchar(255)
	EXEC spNames @Id, @People OUTPUT
	INSERT INTO #Schedules (ScheduleId, StartDate, CourseName, People)
	VALUES (@Id, @Date, @Course, @People)
	FETCH NEXT FROM @Course_Cursor
	INTO @Course
	FETCH NEXT FROM @Date_Cursor
	INTO @Date
	FETCH NEXT FROM @Id_Cursor
	INTO @Id
END

SELECT * FROM #Schedules
ORDER BY ScheduleId


SELECT        tblPerson.Personid, COUNT(tblDelegate.DelegateId) AS [Number of Courses Attended]
FROM            tblPerson INNER JOIN
                         tblDelegate ON tblPerson.Personid = tblDelegate.PersonId
GROUP BY tblPerson.Personid
HAVING COUNT(tblDelegate.DelegateId) >= 6



WITH cte_ImportantPeopleCourse (PersonId)
AS
(SELECT        tblPerson.Personid AS [Number of Courses Attended]
FROM            tblPerson INNER JOIN
                         tblDelegate ON tblPerson.Personid = tblDelegate.PersonId
GROUP BY tblPerson.Personid
HAVING COUNT(tblDelegate.DelegateId) >= 6
)
SELECT   distinct     tblCourse.CourseName, tblDelegate.DelegateId, a.PersonId
FROM            tblCourse INNER JOIN
                         tblSchedule ON tblCourse.CourseId = tblSchedule.CourseId INNER JOIN
                         tblDelegate ON tblSchedule.ScheduleId = tblDelegate.ScheduleId
						 INNER JOIN cte_ImportantPeopleCourse AS a
						 ON a.PersonId = tblDelegate.PersonId

CREATE TABLE #BigPeople 
(PersonId int IDENTITY(1,1) PRIMARY KEY,
FirstName varchar(100),
LastName varchar(100)
)

INSERT INTO #BigPeople (FirstName, LastName)
SELECT FirstName, LastName
FROM tblPerson 
WHERE LEN(FirstName) + LEN(LastName) > 20

SELECT * FROM #BigPeople

--IF EXISTS(SELECT name FROM tempdb.sys.tables WHERE [name] like '#BigPeople%')

SET NOCOUNT ON
IF EXISTS(SELECT FirstName FROM #BigPeople)
BEGIN
DELETE FROM #BigPeople
PRINT 'The data in #BigPeople were deleted.'
END
ELSE 
BEGIN
PRINT 'Nothing was deleted.'
END

DROP TABLE #BigPeople
GO

CREATE TABLE Log_PersonMoves
(LogId int IDENTITY(1,1) PRIMARY KEY,
LogName varchar(50))
GO

ALTER PROC sp_MovePerson @PersonId int, @OrgId int
AS
BEGIN
	UPDATE tblPerson
	SET [OrgId] = @OrgId
	WHERE [Personid] = @PersonId
	DECLARE @Row int = @@ROWCOUNT
	IF @Row = 0
	BEGIN
	INSERT INTO Log_PersonMoves (LogName)
	VALUES ('No such person or company')
	END
	ELSE
	BEGIN
	INSERT INTO Log_PersonMoves (LogName)
	VALUES ('Moved person ' + CONVERT(varchar(10), @PersonId) + 
	' to organization' + CAST(@OrgId AS varchar(10)))
	END
END
GO

EXEC sp_MovePerson 22, 39
EXEC sp_MovePerson 2200, 39
EXEC sp_MovePerson 22, 3900
SELECT * FROM Log_PersonMoves
GO

ALTER PROC sp_Select @Columns varchar(100),
						@TableName varchar(50),
						@NumberRows int,
						@OrderColumn varchar(50)
AS
BEGIN
	DECLARE @Sql varchar(250)
	SELECT @Sql= 'SELECT TOP ' + CONVERT(VARCHAR(10), @NumberRows) +' ' + @Columns +
	' FROM ' + @TableName +
	' ORDER BY ' + @OrderColumn
	EXEC (@Sql)
END
GO


EXEC sp_Select 'FirstName, LastName', 'tblPerson', 5, 'LastName'

EXEC sp_Select
	@Columns = 'OrgId,OrgName,SectorId',
	@TableName = 'tblOrg',
	@NumberRows = 3,
	@OrderColumn = 'OrgName'
--SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @TableName


