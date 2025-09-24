USE [04_BikeStores]
GO

-- PROCEDURE
--35. Thống kê doanh số bán hàng của từng cửa hàng theo năm
CREATE OR ALTER PROCEDURE [sales].[uspAnnualSalesByStore]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		ST.store_id
		, ST.store_name
		, YEAR(O.order_date) AS YEAR_ZF
		, SUM(OI.quantity) AS SUM_QUANTITY
		, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
	FROM 
		[sales].[orders] AS O
		JOIN [sales].[stores] AS ST ON ST.store_id = O.store_id
		JOIN [sales].[order_items] AS OI ON OI.order_id = O.order_id
	GROUP BY
		ST.store_id, ST.store_name, YEAR(O.order_date)
	ORDER BY 
		TOTAL_REVENUE
END;
GO

EXEC [sales].[uspAnnualSalesByStore];
GO


USE [00_AdventureWorks2022]
GO
--Bài 1: Stored Procedure cơ bản
--Đề: Tạo procedure usp_GetCustomerOrders nhận CustomerID 
--trả về tất cả hóa đơn (Sales.SalesOrderHeader) của khách hàng này.
CREATE OR ALTER PROCEDURE [sales].[uspGetCustomerOrders] 
	@CustomerID INT
AS
BEGIN
	SELECT
		soh.[SalesOrderID]
	FROM 
		[Sales].[SalesOrderHeader] AS soh
	WHERE
		soh.[CustomerID] = @CustomerID
END;
GO

EXEC [sales].[uspGetCustomerOrders] @CustomerID = 11000;
GO
--Bài 5: Stored Procedure nâng cao
--Đề: Tạo procedure usp_GetTopProducts nhận @Year INT, @Top INT
--trả về Top sản phẩm bán chạy nhất trong năm đó, bao gồm:
--ProductID
--Name
--TotalQuantity
--TotalRevenue
CREATE OR ALTER PROCEDURE dbo.[uspGetTopProducts] 
	@Year INT, @Top INT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @_FromDate INT = @Year
	DECLARE @_ToDate INT = @Year + 1
	SELECT
		TOP (@Top) sod.[ProductID]
		, p.[Name]
		, SUM(sod.[OrderQty]) AS TotalQuantity
		, SUM([LineTotal]) AS TotalRevenue
	FROM 
		[Sales].[SalesOrderHeader] AS soh
		JOIN [Sales].[SalesOrderDetail] AS sod ON sod.[SalesOrderID] = soh.[SalesOrderID]
		JOIN [Production].[Product] AS p ON p.[ProductID] = sod.[ProductID]
	WHERE
		YEAR(soh.[OrderDate]) >= @_FromDate
		AND YEAR(soh.[OrderDate]) < @_ToDate
	GROUP BY
		sod.[ProductID], p.[Name]
	ORDER BY TotalQuantity DESC, TotalRevenue DESC;
END;
GO

EXEC dbo.uspGetTopProducts @Year = 2011, @Top = 10;
GO

--Viết procedure usp_GetEmployeePerformance nhận @Year INT → trả về hiệu suất nhân viên bán hàng:
--EmployeeID
--FullName
--TotalOrders
--TotalSales
-- Gợi ý: JOIN HumanResources.Employee với Sales.SalesOrderHeader.
CREATE OR ALTER PROCEDURE dbo.[uspGetEmployeePerformance] 
	@Year INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @_FromDate INT = @Year
	DECLARE @_ToDate INT = @Year + 1
	SELECT
		soh.[SalesPersonID]
		, CONCAT_WS(' ', p.[FirstName], p.[MiddleName], p.[LastName]) AS FullName
		, COUNT(soh.[SalesOrderID]) AS TotalOrders
		, SUM(soh.[TotalDue]) AS TotalSales
	FROM
		[HumanResources].[Employee]  AS e
		JOIN [Sales].[SalesPerson] AS sp ON sp.[BusinessEntityID] = e.[BusinessEntityID]
		JOIN [Sales].[SalesOrderHeader] AS soh ON soh.[SalesPersonID] = sp.[BusinessEntityID]
		JOIN [Person].[Person] AS p ON p.[BusinessEntityID] = e.[BusinessEntityID]
	WHERE
		YEAR(soh.[OrderDate]) >= @_FromDate
		AND YEAR(soh.[OrderDate]) < @_ToDate
	GROUP BY
		soh.[SalesPersonID], p.[FirstName], p.[MiddleName], p.[LastName]
	ORDER BY TotalOrders DESC, TotalSales DESC;
END;
GO

EXEC dbo.[uspGetEmployeePerformance] @Year = 2011;
GO

-- FUNCTION
-- Scalar Function
--Bài 1: Scalar Function

--Đề: Viết một function nhận ProductID 
--trả về số năm sản phẩm đó đã tồn tại trên hệ thống (dựa vào SellStartDate trong bảng Production.Product).

USE [00_AdventureWorks2022]
GO

CREATE OR ALTER FUNCTION dbo.udf_ProductYearsInSystem (@ProductID INT)
RETURNS INT
AS
BEGIN
	DECLARE @ProductYearsInSystem  INT;
	SET @ProductYearsInSystem = (SELECT DATEDIFF(YEAR, P.SellStartDate, GETDATE()) 
								 FROM [Production].[Product] AS P 
								 WHERE P.ProductID = @ProductID);
	RETURN @ProductYearsInSystem
END;
GO

SELECT dbo.udf_ProductYearsInSystem(1) AS SellStartDate;
SELECT dbo.udf_ProductYearsInSystem(2) AS SellStartDate;
SELECT dbo.udf_ProductYearsInSystem(4) AS SellStartDate;
GO

--Bài 2: Inline Table-Valued Function

--Đề: Viết function nhận BusinessEntityID của nhân viên (HumanResources.Employee) 
--trả về danh sách các đơn hàng mà nhân viên này phụ trách (trong Sales.SalesOrderHeader).
CREATE OR ALTER FUNCTION dbo.ufn_GetSalesOrderList(@BusinessEntityID INT)
RETURNS TABLE
AS
RETURN
(
	SELECT
        E.BusinessEntityID,
        SOH.SalesOrderID,
        SOH.OrderDate,
        SOH.CustomerID,
        SOH.TotalDue
	FROM 
		[HumanResources].[Employee] AS E
		JOIN [Sales].[SalesPerson] AS SP ON SP.[BusinessEntityID] = E.[BusinessEntityID]
		JOIN [Sales].[SalesOrderHeader] AS SOH ON SOH.[SalesPersonID] = SP.[BusinessEntityID]
	WHERE
		E.BusinessEntityID = @BusinessEntityID
)
GO

SELECT * FROM dbo.ufn_GetSalesOrderList(279)
SELECT * FROM dbo.ufn_GetSalesOrderList(280)
GO

--Bài 3: Multi-Statement Table-Valued Function
--Đề: Viết function nhận ProductCategoryID → trả về bảng gồm:
--ProductID
--Name
--TotalSales (tổng doanh thu từ bảng Sales.SalesOrderDetail × OrderQty * UnitPrice)
CREATE OR ALTER FUNCTION dbo.ufn_GetTotalSalesByProductCategoryID(@ProductCategoryID INT)
RETURNS @retTotalSalesByProductCategoryID TABLE
(
	-- Columns returned by the function
	[ProductID] INT NOT NULL,
	[Name] NVARCHAR(100) NULL,
	[TotalSales] MONEY
)
AS
BEGIN
-- Returns the [ProductID], [Name] and [TotalSales] for the specified ProductCategoryID.
	INSERT INTO @retTotalSalesByProductCategoryID
	SELECT
        p.[ProductID]
		, p.[Name]
		, SUM((sod.[OrderQty] * sod.[UnitPrice])) AS [TotalSales]
	FROM
		[Production].[Product] AS p
		JOIN [Sales].[SalesOrderDetail] AS sod ON sod.[ProductID] = p.[ProductID]
		JOIN [Production].[ProductSubcategory] AS ps ON ps.[ProductSubcategoryID] = p.[ProductSubcategoryID]
		JOIN [Production].[ProductCategory] AS pc ON pc.[ProductCategoryID] = ps.[ProductCategoryID]
	WHERE
		pc.[ProductCategoryID] = @ProductCategoryID
	GROUP BY
		p.[ProductID]
		, p.[Name]
	RETURN;
END;
GO

SELECT * FROM dbo.ufn_GetTotalSalesByProductCategoryID(1);
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
--# 🔧 Function (UDF)

--## 1) fn_AgeAtHire (Scalar UDF)

--**Yêu cầu:** Nhập `@BusinessEntityID` → trả về **tuổi tại thời điểm được tuyển**.
--**Bảng:** `HumanResources.Employee` (BirthDate, HireDate).
--**Hint:** `DATEDIFF(YEAR, BirthDate, HireDate)` trừ đi 1 nếu chưa qua sinh nhật.
--**Test:** `SELECT dbo.fn_AgeAtHire(EMP_ID);`
CREATE OR ALTER FUNCTION dbo.udfAgeAtHire(@BusinessEntityID INT)
RETURNS INT
AS
BEGIN
    DECLARE @AgeAtHire INT = NULL;
	IF @BusinessEntityID IS NOT NULL AND
		EXISTS (SELECT 1 FROM HumanResources.Employee AS e WHERE e.BusinessEntityID = @BusinessEntityID)
	BEGIN
		-- Lấy BirthDate và HireDate
		SELECT 
			@AgeAtHire = 
				CASE 
					WHEN e.BirthDate IS NULL OR e.HireDate IS NULL THEN NULL
					WHEN YEAR(e.HireDate) <= YEAR(e.BirthDate) THEN NULL
					ELSE
						DATEDIFF(YEAR, BirthDate, HireDate)
						- CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, BirthDate, HireDate), BirthDate) > HireDate THEN 1	ELSE 0 END
				END
		FROM HumanResources.Employee AS e
		WHERE e.BusinessEntityID = @BusinessEntityID;
	END
    RETURN @AgeAtHire;
END;
GO

DECLARE @i INT = 1;

WHILE @i <= 3
BEGIN
    SELECT dbo.udfAgeAtHire(@i) AS AgeAtHire
    SET @i = @i + 1;  -- tăng biến đếm
END;
GO
---

--## 2) fn\_ProductGrossMargin (Scalar UDF)

--**Yêu cầu:** Nhập `@ProductID, @Year` → trả về **GrossMargin% = (Revenue - StandardCost\*Qty)/Revenue**.
--**Bảng:** `Sales.SalesOrderDetail (LineTotal, OrderQty)`, `Production.Product (StandardCost)`, `Sales.SalesOrderHeader (OrderDate)`.
--**Hint:** Dùng `SUM(LineTotal)` và `SUM(OrderQty * StandardCost)` trong khoảng ngày năm.
--**Test:** `SELECT dbo.fn_ProductGrossMargin(707, 2013);`
CREATE OR ALTER FUNCTION dbo.ufnProductGrossMargin
(
	@ProductID INT,
	@Year INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
	DECLARE @GrossMarginPercentage  DECIMAL(5,2) = NULL;
	DECLARE @Revenue   DECIMAL(18,2) = NULL;
	DECLARE @Cost   DECIMAL(18,2) = NULL;

	IF @ProductID IS NOT NULL 
	AND @Year IS NOT NULL 
	BEGIN
		SELECT
			@Revenue = SUM(sod.LineTotal)
			, @Cost = SUM(sod.OrderQty * p.StandardCost)
		FROM 
			 [Sales].[SalesOrderDetail] sod
			 JOIN [Production].[Product] p ON p.ProductID = sod.ProductID
			 JOIN [Sales].[SalesOrderHeader] soh ON soh.SalesOrderID = sod.SalesOrderID
		WHERE
			p.ProductID = @ProductID
			--AND YEAR(soh.OrderDate) = @Year
			AND soh.OrderDate >= DATEFROMPARTS(@Year, 1, 1)
			AND soh.OrderDate <  DATEFROMPARTS(@Year + 1, 1, 1);
	END

	IF @Revenue IS NOT NULL AND @Revenue > 0
		SET @GrossMarginPercentage = ROUND(((@Revenue - @Cost) / @Revenue) * 100.0, 2);

	RETURN @GrossMarginPercentage;
END;
GO

SELECT dbo.ufnProductGrossMargin(744, 2012) AS GrossMarginPercent;
GO
---

--## 3) fn\_CustomersByRegion (Inline TVF)

--**Yêu cầu:** Nhập `@TerritoryID` → trả về danh sách **khách hàng** thuộc territory đó 
-- (CustomerID, AccountNumber, PersonName/NULL nếu Store).
--**Bảng:** `Sales.Customer`, `Sales.SalesTerritory`, `Person.Person`, `Sales.Store`.
--**Hint:** Customer có thể là cá nhân (PersonID) hoặc cửa hàng (StoreID).
--**Test:** `SELECT * FROM dbo.fn_CustomersByRegion(5);`
CREATE OR ALTER FUNCTION [dbo].[ufnCustomersByRegion](@TerritoryID INT)
RETURNS TABLE
AS
RETURN
(
	SELECT
		c.CustomerID
		, c.AccountNumber
		-- Nếu là cá nhân thì lấy tên từ Person, nếu là cửa hàng thì NULL
		, CASE
			WHEN p.BusinessEntityID IS NOT NULL THEN CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName)
			ELSE NULL
		  END AS PersonName
	FROM 
		[Sales].[Customer] c
		JOIN [Person].[Person] p ON p.BusinessEntityID = c.PersonID
		JOIN [Sales].[Store] s ON s.BusinessEntityID = c.StoreID
	WHERE
		c.TerritoryID = @TerritoryID
)
GO

SELECT * FROM [dbo].[ufnCustomersByRegion](1)
GO
---

--## 4) fn\_ReorderCandidates (Multi-Statement TVF)

--**Yêu cầu:** Nhập `@SafetyStockRatio DECIMAL(5,2)` → trả về **sản phẩm cần đặt hàng**: ProductID, 
-- Name, CurrentStock, SafetyStockLevel, `NeedReorder=1/0`.
--**Bảng:** `Production.Product (SafetyStockLevel)`, `Production.ProductInventory (Quantity)`.
--**Hint:** Tổng tồn kho theo `ProductID`; Reorder nếu `Quantity < SafetyStockLevel * @SafetyStockRatio`.
--**Test:** `SELECT * FROM dbo.fn_ReorderCandidates(1.00);`
CREATE OR ALTER FUNCTION dbo.ufnReorderCandidates(@SafetyStockRatio DECIMAL(5,2))
RETURNS @retReorderCandidates TABLE
(
	-- Columns returned by the function
	[ProductID] INT NOT NULL,
	[Name] NVARCHAR(100) NULL,
	[CurrentStock] INT NOT NULL,
	[SafetyStockLevel] SMALLINT NOT NULL,
	[NeedReorder] SMALLINT NOT NULL
)
AS
BEGIN
	IF @SafetyStockRatio IS NOT NULL
	BEGIN
		INSERT INTO @retReorderCandidates
		SELECT
			p.[ProductID]
			, p.[Name]
			, SUM(pit.Quantity) AS CurrentStock
			, p.SafetyStockLevel -- là một giá trị duy nhất cho mỗi sản phẩm, không cần SUM().
			, CASE
				WHEN SUM(pit.Quantity) < (p.SafetyStockLevel * @SafetyStockRatio) THEN 1
				ELSE 0
			  END AS NeedReorder
		FROM
			[Production].[Product] AS p
			JOIN [Production].[ProductInventory] pit ON pit.ProductID = p.ProductID
		GROUP BY
			p.[ProductID]
			, p.[Name]
			, p.SafetyStockLevel
	END
	RETURN;
END;
GO

SELECT * FROM dbo.ufnReorderCandidates(1.00);  -- Kiểm tra bình thường
SELECT * FROM dbo.ufnReorderCandidates(2.00);  -- Giả định cao hơn → dễ phát hiện thiếu hàng
GO
---

--# 🚀 Stored Procedure

--## 5) usp\_GetMonthlySalesTrend

--**Yêu cầu:** `@Year INT, @ProductID INT = NULL` → trả về **doanh số theo tháng**: Month, Orders, Revenue.
--**Bảng:** `Sales.SalesOrderHeader`, `Sales.SalesOrderDetail`.
--**Hint:** Dùng `EOMONTH` hoặc `DATEFROMPARTS`; GROUP BY `YEAR, MONTH`. Nếu `@ProductID` NULL thì lấy tất cả.
--**Test:** `EXEC dbo.usp_GetMonthlySalesTrend 2013;`
CREATE OR ALTER PROC [dbo].[uspGetMonthlySalesTrend]
	@Year INT,
	@ProductID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	SELECT
		MONTH(soh.OrderDate) AS [MONTH]
		, YEAR(soh.OrderDate) AS [YEAR]
		, COUNT(DISTINCT soh.SalesOrderID) AS [TOTAL ORDER]
		, SUM(sod.LineTotal) AS [Revenue]
	FROM 
		[Sales].[SalesOrderHeader] soh
		JOIN [Sales].[SalesOrderDetail] sod ON sod.SalesOrderID = soh.SalesOrderID
	WHERE 
		soh.OrderDate >= @FromDate AND soh.OrderDate < @ToDate
		AND (@ProductID IS NULL OR sod.ProductID = @ProductID)
	GROUP BY
		MONTH(soh.OrderDate), YEAR(soh.OrderDate)
	ORDER BY 
		[Revenue] DESC

END;
GO

EXEC dbo.[uspGetMonthlySalesTrend] @Year = 2011;
GO
---

--## 6) usp\_GetTopCustomers

--**Yêu cầu:** `@Year INT, @Top INT = 20, @TerritoryID INT = NULL` → Top khách hàng theo **TotalRevenue**.
--**Bảng:** `Sales.SalesOrderHeader (CustomerID)`, `Sales.Customer`, `Person.Person|Sales.Store`.
--**Hint:** Lọc theo ngày; nếu `@TerritoryID` có giá trị, join `Sales.SalesTerritory` qua `TerritoryID`.
--**Sắp xếp:** `ORDER BY TotalRevenue DESC`.
--**Test:** `EXEC dbo.usp_GetTopCustomers 2013, 10;`
CREATE OR ALTER PROC [dbo].[uspGetTopCustomers]
	@Year INT,
	@Top INT = 20,
	@TerritoryID INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	SELECT
		TOP (@Top) c.CustomerID
		, CASE
			WHEN s.BusinessEntityID IS NOT NULL THEN s.Name
			WHEN p.BusinessEntityID IS NOT NULL THEN CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName)
			ELSE 'Unknown'
		  END AS CustomerName
		, SUM(sod.LineTotal)  AS TotalRevenue
	FROM 
		[Sales].[SalesOrderHeader] soh
		JOIN [Sales].[Customer] c ON c.CustomerID = soh.CustomerID
		LEFT JOIN [Sales].[Store] s ON s.BusinessEntityID = c.StoreID
		LEFT JOIN [Person].[Person] p ON p.BusinessEntityID = c.PersonID
		JOIN [Sales].[SalesOrderDetail] sod ON sod.SalesOrderID = soh.SalesOrderID
	WHERE 
		soh.OrderDate >= @FromDate AND soh.OrderDate < @ToDate
		AND (@TerritoryID IS NULL OR c.TerritoryID = @TerritoryID)
	GROUP BY
		c.CustomerID,
		CASE
			WHEN s.BusinessEntityID IS NOT NULL THEN s.Name
			WHEN p.BusinessEntityID IS NOT NULL THEN CONCAT_WS(' ', p.FirstName, p.MiddleName, p.LastName)
			ELSE 'Unknown'
		END
	ORDER BY 
		TotalRevenue DESC
END;
GO

EXEC [dbo].[uspGetTopCustomers] 2013, 10, 1;
GO

---

--## 7) usp\_ProductPerformanceBySubcategory

--**Yêu cầu:** `@FromDate DATE, @ToDate DATE, @TopPerSubcategory INT = 3` → với **mỗi Subcategory**, trả Top N sản phẩm theo **TotalRevenue**.
--**Bảng:** `Production.Product`, `Production.ProductSubcategory`, `Sales.SalesOrderDetail`, `Sales.SalesOrderHeader`.
--**Hint:** Dùng **window function** `ROW_NUMBER() OVER (PARTITION BY Subcategory ORDER BY Revenue DESC)`.
--**Test:** `EXEC dbo.usp_ProductPerformanceBySubcategory '2013-01-01','2014-01-01',3;`
CREATE OR ALTER PROC [dbo].[uspProductPerformanceBySubcategory]
	@FromDate DATE,
	@ToDate DATE,
	@TopPerSubcategory INT = 3
AS
BEGIN
	SET NOCOUNT ON;
	;WITH cte_ProductRevenueBySubcategory AS (
		SELECT
			p.ProductID
			, p.Name AS [Product Name]
			, p.ProductSubcategoryID
			, SUM(sod.LineTotal) AS TotalRevenue
			, ROW_NUMBER() OVER (PARTITION BY p.ProductSubcategoryID ORDER BY SUM(sod.LineTotal) DESC) AS RANKING
		FROM 
			[Production].[Product] p
			LEFT JOIN [Production].[ProductSubcategory] AS ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID
			JOIN [Sales].[SalesOrderDetail] sod ON sod.ProductID = p.ProductID
			JOIN [Sales].[SalesOrderHeader] soh ON soh.SalesOrderID = sod.SalesOrderID
		WHERE
			soh.OrderDate >= @FromDate AND soh.OrderDate < @ToDate
		GROUP BY
			p.ProductID
			, p.Name
			, p.ProductSubcategoryID
	 )
	 SELECT
		TEMP.ProductID
		, TEMP.[Product Name]
		, TEMP.TotalRevenue
		, TEMP.RANKING
	 FROM cte_ProductRevenueBySubcategory AS TEMP
	 WHERE
		TEMP.RANKING <= @TopPerSubcategory
END;
GO

EXEC [dbo].[uspProductPerformanceBySubcategory] '2013-01-01','2014-01-01', 10;
GO
---

--## 8) usp\_SalespersonLeaderboard

--**Yêu cầu:** `@Year INT, @Metric NVARCHAR(20) = 'Revenue'` → trả về bảng xếp hạng nhân viên bán hàng theo **Revenue** hoặc **Orders**.
--**Bảng:** `Sales.SalesOrderHeader (SalesPersonID, TotalDue)` + `Person.Person`.
--**Hint:** CASE khi `@Metric='Orders'` thì `COUNT(*)`, còn lại `SUM(TotalDue)`.
--**Test:** `EXEC dbo.usp_SalespersonLeaderboard 2013, 'Orders';`
CREATE OR ALTER PROC [dbo].[uspSalespersonLeaderboard]
	@Year INT,
	@Metric NVARCHAR(20) = 'Revenue'
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	IF @Year IS NULL OR @Metric IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	IF @Metric NOT IN ('Revenue', 'Orders')
		THROW 50002, 'Invalid @Metric. Accepted values are: ''Revenue'' or ''Orders''.', 1;

	SELECT
		P.BusinessEntityID
		, CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName) AS [FULL NAME]
		, CASE
			WHEN @Metric = 'Orders' THEN COUNT(DISTINCT SOH.[SalesOrderID])
			ELSE SUM(SOH.TotalDue)
		  END AS MetricValue
		, ROW_NUMBER() OVER (ORDER BY
			CASE 
                WHEN @Metric = 'Orders' THEN COUNT(*) 
                ELSE SUM(SOH.TotalDue)
            END DESC) AS RANKING
	FROM
		[Sales].[SalesOrderHeader] AS SOH
		JOIN [Sales].[SalesPerson] AS SP ON SP.BusinessEntityID = SOH.SalesPersonID
		JOIN [Person].[Person] AS P ON P.BusinessEntityID = SP.BusinessEntityID
	WHERE 
		SOH.OrderDate >= @FromDate AND SOH.OrderDate < @ToDate
	GROUP BY
		P.BusinessEntityID
		, SOH.SalesPersonID
		, CONCAT_WS(' ', P.FirstName, P.MiddleName, P.LastName)
	ORDER BY
		MetricValue DESC		
END;
GO

EXEC [dbo].[uspSalespersonLeaderboard] 2013, 'Orders';
EXEC [dbo].[uspSalespersonLeaderboard] 2013, 'Revenue';
EXEC [dbo].[uspSalespersonLeaderboard] 2012, 'WhateverElse';
GO
---

--## 9) usp\_BackorderFillRate

--**Yêu cầu:** `@Year INT` → trả về theo **Product**: `OrderedQty, ShippedQty, FillRate=Shipped/Ordered`.
--**Bảng:** `Sales.SalesOrderDetail (OrderQty)` và `Sales.SalesOrderHeader (ShipDate)`.
--**Hint:** Tính Ordered theo `OrderDate`, Shipped theo `ShipDate` trong cùng năm; chú ý NULL ShipDate.
--**Test:** `EXEC dbo.usp_BackorderFillRate 2013;`
CREATE OR ALTER PROC [dbo].[uspBackorderFillRate]
	@Year INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	;WITH cte_CalculateOrderedQtyShippedQty AS (
		SELECT
			SOD.ProductID
			-- TÍNH TỔNG SỐ ĐƠN HÀNG TRONG CÙNG NĂM ĐÃ ĐƯỢC ĐẶT THEO SẢN PHẨM SOD.ProductID
			, SUM(CASE WHEN SOH.OrderDate >= @FromDate AND SOH.OrderDate < @ToDate THEN SOD.OrderQty ELSE 0 END) AS OrderedQty
			-- TÍNH TỔNG SỐ ĐƠN HÀNG TRONG CÙNG NĂM ĐÃ ĐƯỢC CHUYỂN GIAO THEO SẢN PHẨM SOD.ProductID TẤT NHIÊN CHÚNG TA CHỈ LẤY NHỮNG ĐƠN HÀNG ĐƯỢC CHUYỂN THÀNH CÔNG (TỨC SOH.ShipDate IS NOT NULL)
			, SUM(CASE WHEN SOH.ShipDate IS NOT NULL AND SOH.ShipDate >= @FromDate AND SOH.ShipDate < @ToDate THEN SOD.OrderQty ELSE 0 END) AS ShippedQty
		FROM 
			[Sales].[SalesOrderDetail] AS SOD
			JOIN [Sales].[SalesOrderHeader] AS SOH ON SOH.SalesOrderID = SOD.SalesOrderID
		--WHERE
		--	SOH.OrderDate >= @FromDate
		--	AND SOH.OrderDate < @ToDate
		--	AND SOH.ShipDate >= @FromDate
		--	AND SOH.ShipDate < @ToDate
			--AND SOH.ShipDate IS NOT NULL
		-- ĐIỀU KIỆN WHERE RẤT GẮT VÌ NÓ SẼ LỌC ĐI NHỮNG ĐƠN HÀNG ĐẶT VÀ CHUYỂN TRONG CÙNG 1 NĂM
		-- VÀ NÓ SẼ BỎ LUÔN NHỮNG ĐƠN HÀNG CHƯA ĐƯỢC CHUYỂN. CHỖ NÀY KHÔNG ĐÚNG.
		-- VÌ CÓ NHỮNG ĐƠN HÀNG ĐẶT TRONG NĂM ĐÓ VÀ CHƯA ĐƯỢC GIAO CÓ THỂ SANG NĂM GIAO NÊN SOH.ShipDate CÓ THỂ NULL HOẶC SỐ NĂM LỚN HƠN THÌ CŨNG SẼ BỊ LỌC.
		-- CÁCH TỐT NHẤT LÀ BỎ ĐK TRONG WHERE.
		GROUP BY
			SOD.ProductID
	)
	SELECT
		TEMP.ProductID
		, TEMP.OrderedQty
		, TEMP.ShippedQty
		, CASE
			WHEN TEMP.OrderedQty = 0 THEN 0
			WHEN TEMP.ShippedQty = 0 THEN NULL
			ELSE CAST((1.0 * TEMP.ShippedQty / TEMP.OrderedQty) AS DECIMAL(5, 3))
		  END AS FillRate
	FROM
		cte_CalculateOrderedQtyShippedQty AS TEMP
END;
GO

EXEC  [dbo].[uspBackorderFillRate] 2013;
GO
---

--# 🧠 Tổng hợp & Nâng cao

--## 10) fn\_ProductPriceHistory (Inline TVF)

--**Yêu cầu:** `@ProductID INT` → trả về **lịch sử giá** (StartDate, EndDate, ListPrice, IsCurrent).
--**Bảng:** `Production.ProductListPriceHistory`.
--**Hint:** `LEAD(StartDate) OVER (ORDER BY StartDate)` để suy ra `EndDate`. `IsCurrent` khi `EndDate IS NULL`.
--**Test:** `SELECT * FROM dbo.fn_ProductPriceHistory(707);`
CREATE OR ALTER FUNCTION dbo.ufnProductPriceHistory(@ProductID INT)
RETURNS TABLE
AS
RETURN
(
	SELECT
		PLP.StartDate
		, LEAD(StartDate) OVER (ORDER BY StartDate) AS EndDate
		, PLP.ListPrice
		, CASE
			WHEN LEAD(StartDate) OVER (ORDER BY StartDate) IS NULL THEN 1
			ELSE 0
		  END AS IsCurrent
	FROM
		[Production].[ProductListPriceHistory] AS PLP
	WHERE
		PLP.ProductID = @ProductID
)
GO

SELECT * FROM dbo.ufnProductPriceHistory(707);
GO
--## 11) usp\_TopVendorsByOnTimeRate

--**Yêu cầu:** `@Year INT, @Top INT=5` → Top nhà cung cấp theo **On-Time Delivery Rate**.
--**Bảng:** `Purchasing.PurchaseOrderHeader (OrderDate, ShipDate, VendorID, Status)`, `Purchasing.Vendor`.
--**Hint:** On-time: `DATEDIFF(DAY, OrderDate, ShipDate) <= LeadTime` (giả sử LeadTime từ `Vendor` hoặc cố định tham số).
--**Test:** `EXEC dbo.usp_TopVendorsByOnTimeRate 2013, 5;`
CREATE OR ALTER PROC [dbo].[uspTopVendorsByOnTimeRate]
	@Year INT,
	@Top INT=5,
	@LeadTime INT=5
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	;WITH CTE_TopVendorsByOnTimeRate AS(
		SELECT
			V.BusinessEntityID AS VendorID
			, V.Name AS VendorName
			, SUM(
					CASE
						WHEN POH.ShipDate IS NOT NULL AND DATEDIFF(DAY, POH.OrderDate, POH.ShipDate) <= @LeadTime THEN 1
						ELSE 0
					END	
				) AS OnTimeOrders
			, COUNT(DISTINCT POH.PurchaseOrderID) AS TotalOrders
		FROM
			[Purchasing].[PurchaseOrderHeader] AS POH
			JOIN [Purchasing].[Vendor] AS V ON V.BusinessEntityID = POH.VendorID
		WHERE
			POH.OrderDate >= @FromDate AND POH.OrderDate < @ToDate
			AND POH.Status = 4
		GROUP BY
			V.BusinessEntityID
			, V.Name
	)
	SELECT TOP (@Top)
		TEMP.VendorID
		, TEMP.VendorName
		, TEMP.TotalOrders
		, TEMP.OnTimeOrders
		, CASE
			WHEN TEMP.OnTimeOrders = 0 THEN 0
			WHEN TEMP.TotalOrders = 0 THEN NULL
			ELSE CAST((100.00 * TEMP.OnTimeOrders / TEMP.TotalOrders) AS DECIMAL(5, 3))
		  END AS OnTimeRate 
	FROM
		CTE_TopVendorsByOnTimeRate AS TEMP
END;
GO

EXEC [dbo].[uspTopVendorsByOnTimeRate] 2013, 5;
EXEC [dbo].[uspTopVendorsByOnTimeRate] 2011, 5;
GO

--## 12) fn\_OrderRiskScore (Scalar UDF)

--**Yêu cầu:** Nhập `@SalesOrderID` → trả về **RiskScore (0–100)** dựa trên rule đơn giản:

--* +30 nếu `OnlineOrderFlag=1`
--* +40 nếu `TotalDue > 5000`
--* +20 nếu `ShipDate - OrderDate > 5 ngày`
--* Cắt max 100.
--  **Bảng:** `Sales.SalesOrderHeader`.
--  **Hint:** `CASE WHEN ... THEN`.
--  **Test:** `SELECT dbo.fn_OrderRiskScore(43659);`
CREATE OR ALTER FUNCTION dbo.ufnOrderRiskScore(@SalesOrderID INT)
RETURNS INT
AS
BEGIN
	DECLARE @RiskScore  INT = 0;
	SELECT
		@RiskScore =
					(CASE WHEN SOH.OnlineOrderFlag = 1 THEN 30 ELSE 0 END) +
					(CASE WHEN SOH.TotalDue > 5000 THEN 40 ELSE 0 END) +
					(CASE WHEN SOH.ShipDate IS NOT NULL AND DATEDIFF(DAY, SOH.ShipDate, SOH.OrderDate) > 5 THEN 20 ELSE 0 END)
	FROM
		[Sales].[SalesOrderHeader] AS SOH
	WHERE
		SOH.SalesOrderID = @SalesOrderID

	RETURN CASE WHEN @RiskScore = 100 THEN 100 ELSE @RiskScore END;
END;
GO

SELECT dbo.ufnOrderRiskScore(43659) AS RiskScore
GO
---

--## 13) usp\_CustomerRFM (Phân khúc RFM)

--**Yêu cầu:** `@AsOfDate DATE, @Buckets INT = 5` → phân nhóm khách hàng theo **RFM**:

--* **R**ecency: số ngày từ lần mua gần nhất
--* **F**requency: số đơn trong 12 tháng gần nhất
--* **M**onetary: tổng chi trong 12 tháng gần nhất
--  **Bảng:** `Sales.SalesOrderHeader`.
--  **Hint:** dùng window `NTILE(@Buckets)` trên từng trục; join lại để có `Segment = CONCAT(R,F,M)`.
--  **Test:** `EXEC dbo.usp_CustomerRFM '2014-01-01', 5;`
CREATE OR ALTER PROCEDURE [dbo].[uspCustomerRFM]
    @AsOfDate DATE,
	@Buckets INT = 5
AS
BEGIN
	;WITH CTE_RFM AS (
		SELECT
			soh.CustomerID
			, DATEDIFF(DAY, MAX(soh.OrderDate), @AsOfDate) AS R_VALUE
			-- Frequency: số đơn trong 12 tháng gần nhất
			, COUNT(DISTINCT CASE WHEN soh.OrderDate >= DATEADD(YEAR, -1, @AsOfDate) THEN soh.OrderDate ELSE 0 END) AS F_VALUE
			--* **M**onetary: tổng chi trong 12 tháng gần nhất
			, SUM(CASE WHEN soh.OrderDate >= DATEADD(YEAR, -1, @AsOfDate) THEN soh.TotalDue ELSE 0 END) AS M_VALUE
		FROM
			[Sales].[SalesOrderHeader] AS soh
		WHERE
			soh.OrderDate <= @AsOfDate
		GROUP BY
			soh.CustomerID	
	),
	-- Áp dụng NTILE cho từng trục
	CTE_SCORED AS (
		SELECT
			TEMP.CustomerID
			, temp.R_VALUE
			, temp.F_VALUE
			, temp.M_VALUE
			, (@Buckets + 1) - NTILE(@Buckets) OVER (ORDER BY R_VALUE ASC) AS R_Score
			, NTILE(@Buckets) OVER (ORDER BY F_VALUE ASC) AS F_Score
			, NTILE(@Buckets) OVER (ORDER BY M_VALUE ASC) AS M_Score
		FROM CTE_RFM AS temp
	)
	SELECT
		sc.CustomerID
		, sc.R_VALUE
		, sc.F_VALUE
		, sc.M_VALUE
		, sc.R_Score
		, sc.F_Score
		, sc.M_Score
		, CONCAT(sc.R_Score, sc.F_Score, sc.M_Score) AS [RFM Segment]
		, CASE
			WHEN sc.R_Score = @Buckets AND sc.F_Score = @Buckets AND sc.M_Score = @Buckets THEN 'Best Customer'
			WHEN sc.R_Score = @Buckets AND sc.M_Score = @Buckets THEN 'Loyal Customer'
			WHEN sc.F_Score = @Buckets AND sc.M_Score = @Buckets THEN 'Big Spenders'
			WHEN sc.R_Score = @Buckets AND sc.F_Score = @Buckets THEN 'Frequent Buyers'
			WHEN sc.R_Score = @Buckets THEN 'Recent Customers'
			WHEN sc.F_Score = @Buckets THEN 'Potential Loyalists'
			WHEN sc.R_Score = 1 THEN 'Lost Customers'
			WHEN sc.F_Score = 1 THEN 'At Risk'
			WHEN sc.M_Score = 1 THEN 'Low Spenders'
			ELSE 'Others'
		  END AS CustomerSegment
	FROM
		CTE_SCORED AS sc
	ORDER BY
		sc.CustomerID
END;
GO

EXEC [dbo].[uspCustomerRFM] '2014-01-01', 5;
GO
--## Ghi chú chung khi làm bài

--* **SARGable**: lọc ngày bằng khoảng `@FromDate <= OrderDate < @ToDate`.
--* **Đặt tên**: `dbo.usp_*` cho proc, `dbo.fn_*`/`dbo.ufn_*` cho function.
--* **Kiểm thử**: luôn có `ORDER BY` rõ ràng với Top.
--* **Hiệu năng**: chỉ chọn cột cần, ưu tiên **iTVF** khi có thể; cân nhắc index trên cột join/lọc (`OrderDate`, `SalesPersonID`, `ProductID`, `CustomerID`).
--* **Tương thích phiên bản**: nếu dưới SQL 2017, thay `CONCAT_WS` bằng `CONCAT`/`ISNULL`.



