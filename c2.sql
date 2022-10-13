SELECT DISTINCT S.moviePrefix, S.movieSuffix, M.name
FROM Streams S
JOIN Movie M ON (M.prefix = S.moviePrefix AND M.suffix = S.movieSuffix)
WHERE DATEDIFF(CURRENT_DATE, DATE(S.timestamp)) < 7;
