/*
CREATE FUNCTION ufn_TotalAmountByCustID(@CustomerID INT = 0)
RETURNS int
AS
BEGIN
	DECLARE @SumAmount INT
	
	SELECT @SumAmount = SUM(TotalAmount)
	FROM [Order]
	WHERE CustomerID = @CustomerID

	RETURN @SumAmount
END

SELECT *, dbo.ufn_TotalAmountByCustID(Id) AS 'Sum Of Total Amount'
FROM Customer
*/

/*
CREATE FUNCTION ufn_ProductListByPrice(@Low INT, @High INT)
RETURNS TABLE
AS
RETURN (
	SELECT *
	FROM Product
	WHERE UnitPrice > @Low AND UnitPrice < @High
)

SELECT * FROM dbo.ufn_ProductListByPrice(20, 50)
*/

/*
CREATE FUNCTION ufn_OrderListByMonthFilter(@MonthFilter NVARCHAR(MAX))
RETURNS @ResultTable TABLE (Id INT, OrderDate DateTime, OrderNumber NVARCHAR(MAX),
							CustomerId INT, TotalAmount DECIMAL(12, 2))
AS
BEGIN
	SET @MonthFilter = LOWER(@MonthFilter)

	INSERT INTO @ResultTable
	SELECT Id, OrderDate, OrderNumber, CustomerId, TotalAmount
	FROM [Order]
	WHERE CHARINDEX(LTRIM(RTRIM(LOWER(DATENAME(month, OrderDate)))), @MonthFilter) > 0

	RETURN
END

SELECT * FROM ufn_OrderListByMonthFilter('July')

CREATE FUNCTION ufn_OrderListByMonthFilter2(@MonthFilter NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN (
	SELECT *
	FROM [Order]
	WHERE CHARINDEX(LTRIM(RTRIM(LOWER(DATENAME(month, OrderDate)))), LOWER(@MonthFilter)) > 0
)

SET STATISTICS TIME ON
SELECT * FROM ufn_OrderListByMonthFilter('March, April, July, December')
SELECT * FROM ufn_OrderListByMonthFilter2('March, April, July, December')
SET STATISTICS TIME OFF
*/

/*
CREATE FUNCTION ufn_CheckItemAmount(@OrderId INT)
RETURNS BIT
AS
	BEGIN
		DECLARE @Amount BIT
		IF (EXISTS(SELECT COUNT(Id) FROM OrderItem WHERE OrderId = @OrderId GROUP BY OrderId HAVING COUNT(Id) < 5))
			SET @Amount = 1
		ELSE
			SET @Amount = 0

		RETURN @Amount
	END
GO

ALTER TABLE OrderItem WITH NOCHECK
ADD CONSTRAINT CheckItemAmount
	CHECK (dbo.ufn_CheckItemAmount(OrderId) = 1)

INSERT INTO OrderItem VALUES(26, 14, 20, 10)
/*