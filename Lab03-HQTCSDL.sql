SELECT *
FROM (
	SELECT RowNum, Id, ProductName, UnitPrice, MAX(RowNum) OVER (ORDER BY (SELECT 1)) AS RowLast
	FROM (
		SELECT ROW_NUMBER() OVER (ORDER BY UnitPrice) AS RowNum, Id, ProductName, UnitPrice
		FROM Product
	) AS DerivedTable
) Report
WHERE Report.RowNum >= 0.2 * RowLast

SELECT Id, OrderId, ProductId, Quantity, ProductName, STR([Percent]*100, 5, 2) + '%' AS [Percent]
FROM (
	SELECT I.Id, I.OrderId, I.ProductId, I.Quantity, P.ProductName,
		CAST(I.Quantity AS decimal) / (SUM(I.Quantity) OVER (PARTITION BY I.OrderId)) AS [Percent]
	FROM OrderItem I JOIN Product P ON I.ProductId = P.Id
) Report
ORDER BY Id

/*
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES
			WHERE TABLE_NAME = N'WantedCountries')
BEGIN
	DROP TABLE WantedCountries
END

SELECT Id, Country,	1 AS [Type] INTO WantedCountries
FROM Supplier
WHERE Country LIKE '%USA%' OR Country LIKE '%UK%' OR Country LIKE '%France%' OR Country LIKE '%Germany%' OR Country LIKE '%Others%'
UNION
SELECT Id, 'Others' AS Country,	1 AS [Type]
FROM Supplier
WHERE Country NOT LIKE '%USA%' AND Country NOT LIKE '%UK%' AND Country NOT LIKE '%France%' AND
	Country NOT LIKE '%Germany%' AND Country NOT LIKE '%Others%'
ORDER BY Id

SELECT SupplierByCountry.Id, S.CompanyName,
		ISNULL(SupplierByCountry.[USA], 0) AS [USA],
		ISNULL(SupplierByCountry.[UK], 0) AS [UK],
		ISNULL(SupplierByCountry.[France], 0) AS [France],
		ISNULL(SupplierByCountry.[Germany], 0) AS [Germany],
		ISNULL(SupplierByCountry.[Others], 0) AS [Others]
FROM (
	SELECT * FROM WantedCountries
	PIVOT (SUM([Type]) FOR Country IN ([USA], [UK], [France], [Germany], [Others])) AS PivotedSupplier
) SupplierByCountry
INNER JOIN Supplier S ON SupplierByCountry.Id = S.Id
*/

SELECT OrderNumber, OrderDate = REPLACE(CONVERT(VARCHAR(10), OrderDate, 103), '/', ' '),
		CustomerName = C.FirstName + ' ' + C.LastName,
		Address = 'Phone: ' + C.Phone + '. City: ' + C.City + ' and Country: ' + C.Country,
		TotalAmount = LTRIM(STR(CAST(TotalAmount AS decimal)) + ' Euro')
FROM [Order] O JOIN Customer C ON O.CustomerId = C.Id

SELECT Id, ProductName, SupplierId, UnitPrice, Package = REPLACE(Package, 'bags', N'túi')
FROM Product
WHERE Package LIKE '%bags%'

SELECT C.Id, CustomerName = C.FirstName + ' ' + C.LastName,
		OrderAmount = COUNT(O.Id),
		TotalAmount = SUM(ISNULL(O.TotalAmount, 0)),
		[Rank] = DENSE_RANK() OVER (ORDER BY COUNT(O.Id) DESC),
		[Group] = NTILE(3) OVER (ORDER BY COUNT(O.Id) DESC)
FROM Customer C LEFT JOIN [Order] O ON C.Id = O.CustomerId
GROUP BY C.Id, C.FirstName, C.LastName

