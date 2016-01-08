USE Books;
GO

CREATE TABLE tblGenre
(GenreId int NOT NULL PRIMARY KEY,
GenreName varchar(20) NOT NULL,
Rating int NULL)

CREATE CLUSTERED INDEX IX_tblGenre_GenreId
	ON dbo.tblGenre(GenreId) --cannot create another clustered index becaseu primary key constraint refers to it.


INSERT INTO tblGenre
VALUES(1, 'Romance', 3),
	(2, 'Science fiction', 7),
	(3, 'Thriller', 5),
	(4, 'Humour', 3)


SELECT * FROM tblGenre

IF EXISTS(
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tblAuthor' AND
			COLUMN_NAME = 'GenreId'
)
ALTER TABLE tblAuthor
DROP COLUMN GenreId

ALTER TABLE tblAuthor
ADD GenreId int NULL

ALTER TABLE tblAuthor
ADD CONSTRAINT FK_tblAuthor_GenreId FOREIGN KEY (GenreId) 
REFERENCES tblGenre (GenreId)

UPDATE tblAuthor
SET GenreId = (SELECT A.GenreId
FROM tblGenre AS A
WHERE A.GenreName = 'Thriller')
WHERE FirstName = 'Stieg'


UPDATE tblAuthor
SET GenreId = (SELECT GenreId
FROM tblGenre
WHERE GenreName = 'Science fiction')
WHERE FirstName = 'John'


UPDATE tblAuthor
SET GenreId = (SELECT GenreId
FROM tblGenre
WHERE GenreName = 'Romance')
WHERE FirstName = 'Lynne Reid'

SELECT A.FirstName + ' ' + A.LastName AS Author, B.GenreName AS Genre
FROM tblAuthor AS A INNER JOIN 
	tblGenre AS B ON A.GenreId = B.GenreId