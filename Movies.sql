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

