SELECT M.releaseDate, COUNT(*)
FROM Movie M
GROUP BY M.releaseDate
