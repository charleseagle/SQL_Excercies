SELECT * FROM tblContinent;

SELECT * FROM tblCountry;

SELECT * FROM tblEvent;

SELECT EventName, EventDate, CountryID
FROM tblEvent
WHERE (CountryID <> 17 AND EventDate > '20001231' AND EventDate < '20011231') 
OR (CountryID IN(3, 5, 7) AND EventName NOT LIKE '%U%' AND EventName NOT LIKE '%u%')
ORDER BY EventDate ASC;


