SELECT *
FROM Customer

SELECT Id, FirstName + ' ' + LastName AS FullName, City, Country
FROM Customer

SELECT Country, COUNT(Id)
FROM Customer
WHERE Country LIKE '%Germany%' OR Country LIKE '%UK%'
GROUP BY Country

SELECT *
FROM Customer
WHERE Country LIKE '%Germany%' OR Country LIKE '%UK%'

SELECT *
FROM Customer
ORDER BY FirstName, Country DESC

SELECT *
FROM Customer
WHERE Id = 5 OR Id = 10

SELECT TOP 10 *
FROM Customer
ORDER BY Id

SELECT *
FROM Customer
ORDER BY Id
OFFSET 4 ROWS
FETCH NEXT 6 ROWS ONLY

SELECT Customer.*, [Order].Id AS OrderId, Product.ProductName, Product.SupplierId, Product.UnitPrice, Product.Package
FROM Customer JOIN [Order] ON Customer.Id = [Order].CustomerId
	JOIN OrderItem ON [Order].Id = OrderItem.OrderId
	JOIN Product ON OrderItem.ProductId = Product.Id
WHERE Product.Package LIKE '%bottles%' AND (Product.UnitPrice BETWEEN 15 AND 20) AND Product.SupplierId != 16

SELECT DISTINCT Customer.*
FROM Customer JOIN [Order] ON Customer.Id = [Order].CustomerId
	JOIN OrderItem ON [Order].Id = OrderItem.OrderId
	JOIN Product ON OrderItem.ProductId = Product.Id
WHERE Product.Package LIKE '%bottles%' AND (Product.UnitPrice BETWEEN 15 AND 20) AND Product.SupplierId != 16