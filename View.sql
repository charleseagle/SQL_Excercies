CREATE VIEW vwSingleYear
AS
SELECT EventName, EventDate
FROM tblEvent
WHERE EventDate <= '20001231' AND EventDate >='20000101'
GO


ALTER VIEW [dbo].[vwEventsByCountry]
AS
SELECT        dbo.tblCountry.CountryName, COUNT(dbo.tblEvent.EventId) AS NumberEvents
FROM            dbo.tblCountry INNER JOIN
                         dbo.tblEvent ON dbo.tblCountry.CountryId = dbo.tblEvent.CountryId
WHERE        (dbo.tblEvent.EventDate >= '19900101')
GROUP BY dbo.tblCountry.CountryName
HAVING        (COUNT(dbo.tblEvent.EventId) >= 5)

