INSERT INTO Previews (customer, moviePrefix, movieSuffix, timestamp)
	SELECT C.id, M.prefix, M.suffix, NOW()
	FROM Movie M, Customer C
	WHERE M.name LIKE '%Harry Potter%' AND NOT EXISTS (
 		SELECT *
 		FROM Previews P
 		WHERE P.customer = C.id
		AND P.moviePrefix = M.prefix 
		AND P.movieSuffix = M.suffix
 	)
