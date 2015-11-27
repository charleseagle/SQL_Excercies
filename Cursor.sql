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


