
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

spListDelegates 'Lloyds', 'ASP.NET'

spListDelegates 'bp'

spListDelegates @CourseName = 'WORD'