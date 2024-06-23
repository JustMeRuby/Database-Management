/*
CREATE TRIGGER [dbo].[Trigger_OrderIdDelete]
ON [dbo].[Order]
FOR DELETE
AS

DECLARE @DeletedOrderID INT
SELECT @DeletedOrderID = Id FROM deleted

DELETE FROM [OrderItem] WHERE OrderId = @DeletedOrderID

PRINT 'Cac xoa cac item cua hoa don OrderId = ' + LTRIM(STR(@DeletedOrderID))

SELECT * FROM [OrderItem] WHERE OrderId = 1

ALTER TABLE [OrderItem] DROP CONSTRAINT FK_ORDERITE_REFERENCE_ORDER
DELETE FROM [Order] WHERE Id = 1
*/

/*
CREATE TRIGGER [dbo].[Trigger_CustomerIdDelete]
ON [dbo].[Order]
FOR DELETE
AS

	DECLARE @DeletedCustomerID INT
	SELECT @DeletedCustomerID = CustomerId FROM deleted

	IF (@DeletedCustomerID = 1)
	BEGIN
		RAISERROR ('CustomerID = 1 khong the xoa duoc', 16, 1)
		ROLLBACK TRANSACTION
	END

EXEC sp_settriggerorder	@triggername = 'Trigger_CustomerIdDelete', @order = 'First', @stmttype = 'Delete'

DELETE FROM [Order] WHERE CustomerId = 1
*/

/*
CREATE TRIGGER [dbo].[Trigger_PhoneUpdate]
ON [dbo].[Supplier]
FOR UPDATE
AS
DECLARE @UpdatePhone NVARCHAR(30)
IF UPDATE(Phone)
BEGIN
	SELECT @UpdatePhone = Phone FROM inserted
	IF @UpdatePhone = NULL OR @UpdatePhone LIKE '%[A-Za-z]%'
	BEGIN
		RAISERROR ('Phone is NULL or contrains letters', 16, 1)
		ROLLBACK TRANSACTION
	END
END

UPDATE Supplier SET Phone = 'ALUHA 123' WHERE Id = 1
*/

/*
CREATE FUNCTION dbo.ufn_ListCompanyByCountry (@CountryDescription NVARCHAR(MAX))
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @CompanyList NVARCHAR(MAX) = 'Companies in ' + @CountryDescription + ' are: '
	DECLARE @Id INT
	DECLARE @CompanyName NVARCHAR(MAX)

	DECLARE CompanyCursor CURSOR READ_ONLY
	FOR
	SELECT Id, CompanyName
	FROM Supplier
	WHERE LOWER(Country) LIKE '%' + LTRIM(RTRIM(LOWER(@CountryDescription))) + '%'

	OPEN CompanyCursor

	FETCH NEXT FROM CompanyCursor INTO @Id, @CompanyName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @CompanyList = @CompanyList + @CompanyName + '(ID:' + LTRIM(STR(@Id)) + ') ; '
		FETCH NEXT FROM CompanyCursor INTO @Id, @CompanyName
	END

	CLOSE CompanyCursor
	DEALLOCATE CompanyCursor

	RETURN @CompanyList
END

SELECT dbo.ufn_ListCompanyByCountry('USA')
*/

/*
BEGIN TRY
	BEGIN TRANSACTION UpdateQuantityTrans

		SET NOCOUNT ON

		DECLARE @NumOfUpdatedRecords INT = 0
		DECLARE @DFactor INT
		SET @DFactor = 0

		UPDATE OrderItem SET Quantity = Quantity / @DFactor
		FROM OrderItem I JOIN [Order] O ON I.OrderId = O.Id JOIN Customer C ON O.CustomerId = C.Id
		WHERE C.Country LIKE '%USA%'

		SET @NumOfUpdatedRecords = @@ROWCOUNT
		PRINT 'Cap nhat thanh cong ' + LTRIM(STR(@NumOfUpdatedRecords)) + ' dong trong bang OrderItem'

	COMMIT TRANSACTION UpdateQuantityTrans
END TRY
BEGIN CATCH
	ROLLBACK TRAN UpdateQuantityTrans
	PRINT 'Cap nhat that bai. Chi tiet:'
	PRINT ERROR_MESSAGE()
END CATCH
*/

BEGIN TRY
BEGIN TRANSACTION CompareTwoCountriesTrans

	SET NOCOUNT ON
	DECLARE @Country1 NVARCHAR(MAX)
	DECLARE @Country2 NVARCHAR(MAX)

	SET @Country1 = 'USA'
	SET @Country2 = 'UK'

	CREATE TABLE #ProductInfo1
	(
		Country NVARCHAR(30),
		SupplierId INT,
		Product NVARCHAR(MAX)
	)
	DECLARE @ProductInfo2 TABLE
	(
		Country NVARCHAR(30),
		SupplierId INT,
		Product NVARCHAR(MAX)
	)

	INSERT INTO #ProductInfo1
	SELECT S.Country, S.Id, P.ProductName
	FROM Supplier S JOIN Product P ON S.Id = P.SupplierId
	WHERE LTRIM(RTRIM(LOWER(Country))) LIKE '%' + LTRIM(RTRIM(LOWER(@Country1))) + '%'
	
	INSERT INTO @ProductInfo2
	SELECT S.Country, S.Id, P.ProductName
	FROM Supplier S JOIN Product P ON S.Id = P.SupplierId
	WHERE LTRIM(RTRIM(LOWER(Country))) LIKE '%' + LTRIM(RTRIM(LOWER(@Country2))) + '%'

	DECLARE @NumProduct1 INT
	SET @NumProduct1 = (SELECT COUNT(DISTINCT Product) FROM #ProductInfo1)
	DECLARE @NumProduct2 INT
	SET @NumProduct2 = (SELECT COUNT(DISTINCT Product) FROM @ProductInfo2)

	PRINT @Country1 + ' cung cap ' + LTRIM(STR(@NumProduct1)) + ' san pham'
	PRINT @Country2 + ' cung cap ' + LTRIM(STR(@NumProduct2)) + ' san pham'

	
	PRINT
	CASE
		WHEN @NumProduct1 > @NumProduct2
			THEN @Country1 + ' cung cap nhieu san pham hon ' + @Country2
		WHEN @NumProduct1 < @NumProduct2
			THEN @Country2 + ' cung cap nhieu san pham hon ' + @Country1
		ELSE @Country1 + ' cung cap so san pham bang ' + @Country2
	END

	DROP TABLE #ProductInfo1

COMMIT TRANSACTION CompareTwoCountriesTrans
END TRY
BEGIN CATCH
	ROLLBACK TRAN CompareTwoCountriesTrans
	PRINT 'Co loi xay ra. Chi tiet:'
	PRINT ERROR_MESSAGE()
END CATCH