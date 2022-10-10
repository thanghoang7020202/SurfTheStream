SELECT C.id, C.bestFriend, COUNT(P.customer)
FROM Customer C
JOIN Previews P ON (C.id = P.customer)
GROUP BY C.id
HAVING COUNT(P.customer) = (
    SELECT COUNT(P2.customer)
    FROM Previews P2
    WHERE(P2.customer = C.bestFriend)
    )
