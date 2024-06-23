SELECT S.Id, S.CompanyName, S.ContactName, S.City, S.Country, S.Phone, MIN(P.UnitPrice) AS 'Min Price', MAX(P.UnitPrice) AS 'Max Price'
FROM Supplier S JOIN Product P ON S.Id = P.SupplierId
GROUP BY S.Id, S.CompanyName, S.ContactName, S.City, S.Country, S.Phone
ORDER BY S.Id

SELECT S.Id, S.CompanyName, S.ContactName, S.City, S.Country, S.Phone, MIN(P.UnitPrice) AS 'Min Price', MAX(P.UnitPrice) AS 'Max Price'
FROM Supplier S JOIN Product P ON S.Id = P.SupplierId
GROUP BY S.Id, S.CompanyName, S.ContactName, S.City, S.Country, S.Phone
HAVING (MAX(P.UnitPrice) - MIN(P.UnitPrice)) <= 30
ORDER BY S.Id

SELECT Id, OrderNumber, OrderDate, TotalAmount, 'VIP' AS [Description]
FROM [Order]
WHERE TotalAmount >= 1500
UNION
SELECT Id, OrderNumber, OrderDate, TotalAmount, 'Normal' AS [Description]
FROM [Order]
WHERE TotalAmount < 1500
ORDER BY Id

SELECT Id, OrderNumber, OrderDate
FROM [Order]
WHERE MONTH(OrderDate) = 7
EXCEPT
SELECT O.Id, OrderNumber, OrderDate
FROM [Order] O JOIN Customer C ON O.CustomerId = C.Id
WHERE C.Country LIKE '%France%'

SELECT Id, OrderNumber, OrderDate, TotalAmount
FROM [Order]
WHERE TotalAmount IN (SELECT TOP 5 TotalAmount
						FROM [Order]
						ORDER BY TotalAmount DESC)