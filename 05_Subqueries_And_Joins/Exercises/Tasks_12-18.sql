-- 12. Highest Peaks in Bulgaria
SELECT c.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Peaks AS p
INNER JOIN Mountains AS m ON P.MountainId = m.Id
INNER JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
INNER JOIN Countries AS c ON mc.CountryCode = c.CountryCode
WHERE c.CountryName = 'Bulgaria' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

-- 13. Count Mountain Ranges
SELECT c.CountryCode, COUNT(mc.MountainId) AS MountainRanges FROM Countries AS c
INNER JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
WHERE c.CountryCode IN ('US', 'RU', 'BG')
GROUP BY c.CountryCode

-- Solution with a subquery
SELECT CountryCode, COUNT(MountainId) AS MountainRanges FROM MountainsCountries
WHERE CountryCode IN (
                       SELECT CountryCode FROM Countries
					   WHERE CountryName IN ('United States', 'Russia', 'Bulgaria')
                     )
GROUP BY CountryCode

-- 14. Countries With or Without Rivers
SELECT TOP 5 c.CountryName, r.RiverName FROM Rivers AS r
INNER JOIN CountriesRivers AS cr ON r.Id = cr.RiverId
RIGHT JOIN Countries AS c ON cr.CountryCode = c.CountryCode
INNER JOIN Continents AS co ON c.ContinentCode = co.ContinentCode
WHERE co.ContinentName = 'Africa'
ORDER BY c.CountryName ASC

-- 15. Continents and Currencies
SELECT ContinentCode, CurrencyCode, CurrencyUsage FROM
(
   SELECT *,
     DENSE_RANK() OVER 
     (PARTITION BY ContinentCode ORDER BY CurrencyUsage DESC) 
     AS CurrencyRank
   FROM
   (
      SELECT 
        ContinentCode, 
        CurrencyCode, 
        COUNT(*) AS CurrencyUsage 
      FROM Countries
      GROUP BY ContinentCode, CurrencyCode
      HAVING COUNT(*) > 1
   ) AS CurrencyUsageSubquery
) AS CurrencyRankingSubquery
WHERE CurrencyRank = 1

-- 16. Countries Without any Mountains
SELECT COUNT(*) AS [Count] FROM Countries
WHERE CountryCode NOT IN (
                           SELECT CountryCode FROM MountainsCountries
                         )

-- 17. Highest Peak and Longest River by Country
SELECT TOP 5 c.CountryName, 
       MAX(p.Elevation) AS HighestPeakElevation,
	   MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC,
LongestRiverLength DESC,
c.CountryName ASC

-- 18. Highest Peak Name and Elevation by Country
SELECT TOP 5
   CountryName AS Country,
   ISNULL(PeakName, '(no highest peak)') AS [Highest Peak Name],
   ISNULL(Elevation, 0) AS [Highest Peak Elevation],
   ISNULL(MountainRange, '(no mountain)') AS Mountain
FROM
(
   SELECT
      c.CountryName,
      p.PeakName,
      p.Elevation,
      m.MountainRange,
      DENSE_RANK() OVER
      (PARTITION BY c.CountryName ORDER BY p.Elevation DESC)
      AS PeakRank
   FROM Countries AS c
   LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
   LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
   LEFT JOIN Peaks AS p ON m.Id = p.MountainId
) AS  PeakRankingSubquery
WHERE PeakRank = 1
ORDER BY CountryName ASC,
[Highest Peak Elevation] ASC