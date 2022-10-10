SELECT C.id, C.name
FROM Customer C
JOIN Streams S ON (S.customer = C.id)
WHERE S.duration >= 3600 AND C.id IN (
    SELECT S2.customer 
    FROM Streams S2
    GROUP BY S2.customer
    HAVING COUNT(S2.customer) = 5
    )
GROUP BY S.customer
