SELECT FilmName FROM tblFilm AS a INNER JOIN
tblDirector AS b ON a.FilmDirectorID = b.DirectorID
WHERE b.DirectorDOB < (SELECT MIN(ActorDOB) FROM tblActor)

SELECT DISTINCT FilmName FROM tblFilm AS a INNER JOIN
tblCast AS b ON a.FilmID = b.CastFilmID INNER JOIN
tblActor AS c ON b.CastActorID = c.ActorID
WHERE c.ActorID IN (
SELECT TOP 3 ActorID FROM tblActor
ORDER BY ActorDOB DESC)

SELECT DISTINCT A.FilmName FROM tblFilm AS A LEFT OUTER JOIN
tblCast AS B ON A.FilmID = B.CastFilmID LEFT OUTER JOIN
tblActor AS C ON B.CastActorID = C.ActorID
WHERE A.FilmID NOT IN (SELECT DISTINCT CastFilmID FROM tblCast AS B INNER JOIN
tblActor AS C ON B.CastActorID = C.ActorID)

SELECT DISTINCT A.ActorName FROM tblActor AS A 
LEFT OUTER JOIN tblCast AS B ON A.ActorID =  B.CastActorID
LEFT OUTER JOIN tblFilm AS C ON B.CastFilmID = C.FilmID
WHERE A.ActorID NOT IN (SELECT DISTINCT B.CastActorID FROM tblCast AS B
INNER JOIN tblFilm AS C ON B.CastFilmID = C.FilmID)

CREATE TABLE #Actors
(FlowChildName nvarchar(100),
Professsion varchar(50),
DOB datetime)


INSERT INTO #Actors 
SELECT ActorName, 'Actor',  ActorDOB
FROM            tblActor
WHERE ActorDOB >= '19690101' AND ActorDOB <= '19691231'

INSERT INTO #Actors 
SELECT DirectorName, 'Director', DirectorDOB
FROM tblDirector
WHERE DirectorDOB >= '19690101' AND DirectorDOB <= '19691231'

TRUNCATE TABLE #Actors

INSERT INTO #Actors 
SELECT ActorName, 'Actor',  ActorDOB
FROM            tblActor
WHERE ActorDOB >= '19690101' AND ActorDOB <= '19691231'
UNION ALL
SELECT DirectorName, 'Director', DirectorDOB
FROM tblDirector
WHERE DirectorDOB >= '19690101' AND DirectorDOB <= '19691231'

SELECT * FROM #Actors
order by DOB
GO

CREATE FUNCTION dbo.fnCharacters (@Name varchar(100))
RETURNS TABLE
AS
RETURN
SELECT        tblDirector.DirectorID, tblActor.ActorName, tblCast.CastCharacterName, tblFilm.FilmName
FROM            tblDirector INNER JOIN
                         tblFilm ON tblDirector.DirectorID = tblFilm.FilmDirectorID INNER JOIN
                         tblCast ON tblFilm.FilmID = tblCast.CastFilmID INNER JOIN
                         tblActor ON tblCast.CastActorID = tblActor.ActorID
WHERE tblCast.CastCharacterName LIKE '%' + @Name + '%'
GO

SELECT * FROM dbo.fnCharacters('Ben')

SELECT A.ActorName, A.FilmName, A.CastCharacterName, B.DirectorName
FROM dbo.fnCharacters('Ben') AS A 
INNER JOIN tblDirector AS B ON A.DirectorID = B.DirectorID


SELECT        tblActor.ActorName, tblFilm.FilmName, tblCast.CastCharacterName
FROM            tblDirector INNER JOIN
                         tblFilm ON tblDirector.DirectorID = tblFilm.FilmDirectorID INNER JOIN
                         tblCast ON tblFilm.FilmID = tblCast.CastFilmID INNER JOIN
                         tblActor ON tblCast.CastActorID = tblActor.ActorID
WHERE tblDirector.DirectorName LIKE '%Spielberg%'
ORDER BY tblActor.ActorName

WITH cte_Actors (FilmName, FilmId)
AS
(SELECT        tblFilm.FilmName, tblFilm.FilmID
FROM            tblFilm INNER JOIN
                         tblDirector ON tblFilm.FilmDirectorID = tblDirector.DirectorID
WHERE tblDirector.DirectorName LIKE '%Spielberg%'
)
SELECT        tblActor.ActorName, a.FilmName, tblCast.CastCharacterName
FROM            tblActor INNER JOIN
                         tblCast ON tblActor.ActorID = tblCast.CastActorID
						 INNER JOIN cte_Actors AS a ON a.FilmId = tblCast.CastFilmID
ORDER BY tblActor.ActorName









