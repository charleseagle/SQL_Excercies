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
