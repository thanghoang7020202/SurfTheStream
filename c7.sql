SELECT C.id, C.name 
FROM Customer C
JOIN Previews P ON P.customer = C.id
JOIN Movie M ON M.prefix = P.moviePrefix AND M.suffix = P.movieSuffix
WHERE M.name LIKE "%Harry Potter%"
GROUP BY P.customer
HAVING COUNT(*) = (SELECT COUNT(*)
		    FROM Movie M2
		    WHERE M2.name LIKE "%Harry Potter%")
