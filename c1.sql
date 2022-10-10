SELECT C.id, C.name 
FROM Customer C 
WHERE C.subscriptionLevel = "Basic"
ORDER BY TIMESTAMPDIFF(YEAR , C.dob, NOW()) ASC;
