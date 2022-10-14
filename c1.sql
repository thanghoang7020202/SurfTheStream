SELECT C.id, C.name 
FROM Customer C
WHERE C.subscriptionLevel LIKE 'basic'
ORDER BY YEAR(C.dob) DESC, MONTH(C.dob) DESC, DAY(C.dob) DESC;
