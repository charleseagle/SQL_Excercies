WITH Decade_CTE (Decade, EventId) AS
(SELECT 
	CASE
		WHEN '19500101' > EventDate AND EventDate > '19301231' THEN 'Decade 1 - forties'
		WHEN '19600101' > EventDate AND EventDate > '19401231' THEN 'Decade 2 - fifties'
		WHEN '19700101' > EventDate AND EventDate > '19501231' THEN 'Decade 3 - sixties'
		WHEN '19800101' > EventDate AND EventDate > '19601231' THEN 'Decade 4 - seventies'
		WHEN '19900101' > EventDate AND EventDate > '19701231' THEN 'Decade 5 - eighties'
		WHEN '20000101' > EventDate AND EventDate > '19801231' THEN 'Decade 6 - ninties'
		ELSE 'Decade 7 - noughties'
	END,
	EventId
FROM tblEvent
)
SELECT Decade, COUNT(EventId) AS [Number of events]
FROM Decade_CTE
GROUP BY Decade

