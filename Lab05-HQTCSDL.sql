/*
CREATE VIEW uvw_DetailProductInOrder
AS
	SELECT I.OrderId, O.OrderNumber, O.OrderDate, I.ProductId,
			ProductInfo = P.ProductName + ' ' + P.Package,
			I.UnitPrice, I.Quantity
	FROM [Order] O join OrderItem I ON O.Id = I.OrderId join Product P ON I.ProductId = P.Id
GO

CREATE VIEW uvw_AllProductInOrder
AS
	SELECT OrderId, OrderNumber, OrderDate,
			ProductList = STUFF((
								SELECT ',' + CAST(I.ProductId AS NVARCHAR(25))
								FROM [Order] O join OrderItem I ON O.Id = I.OrderId
								WHERE I.OrderId = uvw_DetailProductInOrder.OrderId
								FOR XML PATH ('')
								), 1, 1, ''),
			TotalAmount = SUM(UnitPrice * Quantity)
	FROM uvw_DetailProductInOrder
	GROUP BY OrderId, OrderNumber, OrderDate
GO
*/

SET STATISTICS IO, TIME ON
GO

SELECT * FROM uvw_DetailProductInOrder
GO
SELECT * FROM uvw_AllProductInOrder
GO

SET STATISTICS IO, TIME OFF
GO