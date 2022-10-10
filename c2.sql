SELECT S.moviePrefix, S.movieSuffix, M.name
FROM Streams S, Movie M
WHERE DATEDIFF(CURRENT_DATE, DATE(S.timestamp)) < 7 AND (M.prefix = S.moviePrefix AND M.suffix = S.movieSuffix)
