CREATE VIEW `CustomerRating` AS
SELECT S.customer, M.rating, COUNT(M.rating) AS content 
FROM Streams S
JOIN Movie M ON (M.prefix = S.moviePrefix AND M.suffix = S.movieSuffix)
GROUP BY M.rating,S.customer
ORDER BY S.customer;

CREATE VIEW `MaxRating` AS 
SELECT CR.customer, MAX(CR.content) AS RR
FROM CustomerRating CR
GROUP BY CR.customer
HAVING MAX(CR.content);

SELECT CR.customer, CR.rating
FROM CustomerRating CR
JOIN MaxRating MR ON (CR.customer = MR.customer)
WHERE CR.content = MR.RR;