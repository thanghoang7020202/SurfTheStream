CREATE OR REPLACE VIEW `CustomerRating` AS
SELECT S.customer, M.rating, COUNT(M.rating) AS content 
FROM Streams S
JOIN Movie M ON (M.prefix = S.moviePrefix AND M.suffix = S.movieSuffix)
GROUP BY M.rating,S.customer
ORDER BY S.customer;

CREATE OR REPLACE VIEW `result` AS
SELECT CR.customer, CR.rating
FROM CustomerRating CR
WHERE CR.content IN (
    SELECT MAX(CR2.content)
    FROM CustomerRating CR2
    WHERE CR2.customer = CR.customer
    GROUP BY CR2.customer
    HAVING MAX(CR.content)
	);

SELECT R1.customer, R1.rating
FROM result R1
LEFT JOIN result R2 ON (R1.customer = R2.customer AND R1.rating < R2.rating)
WHERE R2.customer IS NULL;