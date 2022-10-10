SELECT C.id, C.name, F.name, DATEDIFF(C.dob,F.dob)
FROM Customer C
JOIN Customer F ON (C.bestFriend = F.id)
