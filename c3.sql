SELECT YEAR(M.releaseDate), COUNT(*)
FROM Movie M
GROUP BY YEAR(M.releaseDate);
