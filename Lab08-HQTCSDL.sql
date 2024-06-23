/*
CREATE PROCEDURE usp_GetOrderID_CustomerID_MinMaxTotalAmount
	@CustomerId INT,
	@MinOrderId INT OUTPUT,
	@MinTotalAmount DECIMAL(12, 2) OUTPUT,
	@MaxOrderId INT OUTPUT,
	@MaxTotalAmount DECIMAL(12, 2) OUTPUT
AS
BEGIN
	WITH CustomerInfo(MinId, MinTotalAmount, MaxId, MaxTotalAmount)
	AS
	(
		SELECT o1.Id, o1.TotalAmount, o2.Id, o2.TotalAmount

		FROM
		(
			SELECT Id, TotalAmount, ROW_NUMBER() OVER (ORDER BY TotalAmount) AS RowNum
			FROM [Order]
			WHERE CustomerId = @CustomerId
		) o1
		JOIN
		(
			SELECT Id, TotalAmount, ROW_NUMBER() OVER (ORDER BY TotalAmount DESC) AS RowNum
			FROM [Order]
			WHERE CustomerId = @CustomerId
		) o2
		ON o1.RowNum = o2.RowNum
	)
	SELECT @MinOrderId = MinId, @MinTotalAmount = MinTotalAmount, @MaxOrderId = MaxId, @MaxTotalAmount = MaxTotalAmount
	FROM CustomerInfo
END

DECLARE @CustomerId INT
DECLARE @MinOrderId INT
DECLARE @MinTotalAmount DECIMAL(12, 2)
DECLARE @MaxOrderId INT
DECLARE @MaxTotalAmount DECIMAL(12, 2)
SET @CustomerId = 5
EXEC usp_GetOrderID_CustomerID_MinMaxTotalAmount @CustomerId, @MaxOrderId OUTPUT, @MaxTotalAmount OUTPUT,
																@MinOrderId OUTPUT, @MinTotalAmount OUTPUT
																
SELECT @CustomerId AS CustomerId, @MinOrderId AS MinOrderId, @MinTotalAmount AS MinTotalAmount,
									@MaxOrderId AS MaxOrderId, @MaxTotalAmount AS MaxTotalAmount

Select * from [Order] where CustomerId = 5 order by TotalAmount
*/

/*
CREATE PROCEDURE usp_InsertNewCustomer
	@FirstName NVARCHAR(40),
	@LastName NVARCHAR(40),
	@City NVARCHAR(40),
	@Country NVARCHAR(40),
	@Phone NVARCHAR(20)
AS
BEGIN
	IF(EXISTS(
			SELECT * FROM Customer
			WHERE FirstName LIKE @FirstName AND LastName LIKE @LastName AND City LIKE @City AND
				Country LIKE @Country AND Phone LIKE @Phone
			))
	BEGIN
		PRINT N'Khach hang ' + @FirstName + ' ' + @LastName + ' da ton tai'
		RETURN -1
	END

	IF(LEN(@FirstName) = 0 OR LEN(@LastName) = 0 OR LEN(@City) = 0 OR LEN(@Country) = 0 OR LEN(@Phone) = 0)
	BEGIN
		PRINT N'khach hang moi khong du thong tin'
		RETURN -1
	END

	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO Customer(FirstName, LastName, City, Country, Phone)
			VALUES (@FirstName, @LastName, @City, @Country, @Phone)
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		DECLARE @ERR NVARCHAR(MAX)
		SET @ERR = ERROR_MESSAGE()
		PRINT N'Co loi trong qua trinh them Customer moi'
		RAISERROR(@ERR, 16, 1)
		RETURN -1
	END CATCH
END

DECLARE @StateInsert INT
EXEC @StateInsert = usp_InsertNewCustomer 'Alice', 'Lily', 'Wonderland', 'Fairy Tale', ''
PRINT @StateInsert
*/

/*
CREATE PROCEDURE usp_UpdateUnitPriceAndTotalAmount
	@OrderId INT,
	@ProductId INT,
	@UnitPrice DECIMAL(12, 2)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM OrderItem WHERE OrderId = @OrderId AND ProductId = @ProductId))			
	BEGIN
		PRINT 'Khong ton tai trong bang OrderItem record co OrderId = ' + LTRIM(STR(@OrderId)) + ' va ProductId = ' + LTRIM(STR(@ProductId))
		RETURN -1
	END

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE OrderItem
			SET UnitPrice = @UnitPrice
			WHERE OrderId = @OrderId AND ProductId = @ProductId

			UPDATE [Order]
			SET TotalAmount = (SELECT SUM(UnitPrice * Quantity) FROM OrderItem
								WHERE OrderId = @OrderId
								GROUP BY OrderId)
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		DECLARE @ERR NVARCHAR(MAX)
		SET @ERR = ERROR_MESSAGE()
		PRINT 'Co loi trong qua trinh them update UnitPrice va TotalAmount'
		RAISERROR(@ERR, 16, 1)
		RETURN -1
	END CATCH
END

SELECT * FROM OrderItem WHERE OrderId = 261
SELECT * FROM [Order] WHERE Id = 261

DECLARE @StateInsert INT
EXEC @StateInsert = usp_UpdateUnitPriceAndTotalAmount 261, 13, 6.0
PRINT @StateInsert

SELECT * FROM OrderItem WHERE OrderId = 261
SELECT * FROM [Order] WHERE Id = 261
*/