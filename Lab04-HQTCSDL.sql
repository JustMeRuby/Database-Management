SELECT I.OrderId, I.ProductId, I.Quantity,
		SUM(Quantity) OVER (PARTITION BY I.OrderId),
		QuantityPercent = CAST((CAST(Quantity AS decimal) / (SUM(Quantity) OVER (PARTITION BY I.OrderId)) * 100) AS decimal(6, 2))
FROM [Order] O JOIN OrderItem I ON O.Id = I.OrderId

SELECT *, [Day in Week] = CASE DATENAME(dw, OrderDate) WHEN 'Monday' THEN N'Thứ 2'
														WHEN 'Tuesday' THEN N'Thứ 3'
														WHEN 'Wednesday' THEN N'Thứ 4'
														WHEN 'Thursday' THEN N'Thứ 5'
														WHEN 'Friday' THEN N'Thứ 6'
														WHEN 'Saturday' THEN N'Thứ 7'
														ELSE N'Chủ Nhật' END
FROM [Order]

SELECT I.OrderId, I.ProductId, P.ProductName, I.UnitPrice, I.Quantity, COALESCE(S.Fax, S.Phone) AS ContactInfo,
		CASE COALESCE(S.Fax, S.Phone) WHEN Fax THEN 'Fax' ELSE 'Phone' END AS ContactType
FROM OrderItem I JOIN Product P ON I.ProductId = P.Id JOIN Supplier S ON P.SupplierId = S.Id

SELECT DB_ID('Northwind') AS [Northwind Database ID],
		OBJECT_ID('Northwind.dbo.Supplier') AS [Supplier Table ID],
		SUSER_ID() AS [Current User ID],
		SUSER_NAME() AS [Current User Name]

SELECT user_updates, user_seeks, user_scans, user_lookups
FROM sys.dm_db_index_usage_stats us
WHERE us.object_id = OBJECT_ID('Northwind.dbo.Order')


WITH SupplierCategory(Country, City, OrderID, alevel)
AS (
	SELECT DISTINCT Country, City = CAST('' AS NVARCHAR(255)), OrderID = CAST('' AS NVARCHAR(255)), alevel = 0
	FROM Supplier

	UNION ALL

	SELECT S.Country, City = CAST(S.City AS NVARCHAR(255)), OrderID = CAST('' AS NVARCHAR(255)), alevel = SC.alevel + 1
	FROM SupplierCategory SC JOIN Supplier S ON SC.Country = S.Country
	WHERE SC.alevel = 0

	UNION ALL

	SELECT S.Country, City = CAST(S.City AS NVARCHAR(255)), OrderID = CAST(O.Id AS NVARCHAR(255)), alevel = SC.alevel + 1
	FROM SupplierCategory SC JOIN Supplier S ON SC.Country = S.Country AND SC.City = S.City
							JOIN [Customer] C ON S.Country = C.Country AND S.City = C.City
							JOIN [Order] O ON C.Id = O.CustomerId
	WHERE SC.alevel = 1
)
SELECT [Country_] = CASE WHEN alevel = 0 THEN Country ELSE '' END,
		[City_] = CASE WHEN alevel = 1 THEN City ELSE '' END,
		[OrderID_] = OrderID,
		[Level_] = alevel
FROM SupplierCategory
ORDER BY Country, City, OrderID, alevel

SELECT O.Id, O.CustomerId, O.OrderDate, O.TotalAmount, SUM(I.Quantity) AS TotalQuantity
FROM [Order] O JOIN OrderItem I ON O.Id = I.OrderId JOIN Customer C ON O.CustomerId = C.Id
WHERE C.Country LIKE '%France%'
GROUP BY O.Id, O.CustomerId, O.OrderDate, O.TotalAmount
HAVING SUM(I.Quantity) > 50
ORDER BY O.Id