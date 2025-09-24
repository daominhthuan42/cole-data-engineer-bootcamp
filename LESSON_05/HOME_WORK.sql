USE [00_AdventureWorks2022]
GO

--1. usp_CustomerTotalSpend
--Yêu cầu:
--Viết stored procedure nhận tham số @CustomerID → trả về tổng số tiền đã chi (TotalDue) và số đơn hàng của khách này trong toàn bộ lịch sử.
--Bảng: Sales.SalesOrderHeader.
--Thử test với EXEC usp_CustomerTotalSpend 11025;

CREATE OR ALTER PROCEDURE [dbo].[uspCustomerTotalSpend]
    @CustomerID INT
AS
BEGIN
	IF @CustomerID IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	SELECT
		soh.CustomerID
		, SUM(soh.TotalDue) AS TotalAmount
		, COUNT(DISTINCT soh.SalesOrderID) AS TotalOrder
	FROM
		[Sales].[SalesOrderHeader] AS soh
	WHERE
		soh.CustomerID = @CustomerID
	GROUP BY
		soh.CustomerID
END;
GO

EXEC [dbo].[uspCustomerTotalSpend] 11025;
EXEC [dbo].[uspCustomerTotalSpend] NULL;
GO

--2. usp_TopSellingProducts
--Yêu cầu:
--Procedure nhận tham số @Year và @TopN → trả về Top N sản phẩm bán chạy nhất trong năm đó (theo doanh thu).
--Bảng: Sales.SalesOrderDetail, Production.Product.
CREATE OR ALTER PROCEDURE [dbo].[uspTopSellingProducts]
    @Year INT,
	@TopN INT
AS
BEGIN
	IF @Year IS NULL OR @TopN IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)

	SELECT
		TOP (@TopN) sod.ProductID
		, p.Name AS ProductName
		, SUM(sod.LineTotal) AS TotalRevenue
	FROM
		[Sales].[SalesOrderDetail] sod
		JOIN [Production].[Product] p ON p.ProductID = sod.ProductID
		JOIN [Sales].[SalesOrderHeader] soh ON soh.SalesOrderID = sod.SalesOrderID
	WHERE 
		soh.OrderDate >= @FromDate AND soh.OrderDate < @ToDate
	GROUP BY
		sod.ProductID, p.Name
	ORDER BY
		TotalRevenue DESC
END;
GO

EXEC [dbo].[uspTopSellingProducts] 2013, 10;
GO

--4. usp_MonthlySalesByTerritory
--Yêu cầu:
--Procedure trả về doanh số hàng tháng cho mỗi Territory trong một năm bất kỳ (@Year).
--Bảng: Sales.SalesOrderHeader, Sales.SalesTerritory.
--Output: YearMonth, TerritoryName, TotalSales.
CREATE OR ALTER PROCEDURE [dbo].[uspMonthlySalesByTerritory]
    @Year INT
AS
BEGIN
	IF @Year IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	SET NOCOUNT ON;
	DECLARE @FromDate DATE = DATEFROMPARTS(@Year, 1, 1)
	DECLARE @ToDate DATE = DATEFROMPARTS(@Year + 1, 1, 1)
	;WITH MonthlySales AS(
		SELECT
    		st.TerritoryID AS TerritoryID
			, st.Name AS TerritoryName
			, MONTH(soh.OrderDate) AS [MONTH]
			, SUM(sod.LineTotal) AS TotalRevenue
			--, ROW_NUMBER() OVER (PARTITION BY st.TerritoryID ORDER BY SUM(sod.LineTotal) DESC) AS RANKING
		FROM
			[Sales].[SalesOrderHeader] AS soh
			JOIN [Sales].[SalesTerritory] st ON st.TerritoryID = soh.TerritoryID
			JOIN [Sales].[SalesOrderDetail] sod ON sod.SalesOrderID = soh.SalesOrderID
		WHERE 
			soh.OrderDate >= @FromDate AND soh.OrderDate < @ToDate
		GROUP BY
			MONTH(soh.OrderDate), st.TerritoryID, st.Name
		--ORDER BY
		--	st.TerritoryID, MONTH(soh.OrderDate)
	)
    SELECT *
    FROM MonthlySales
    PIVOT
    (
        SUM(TotalRevenue)
        FOR [MONTH] IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
    ) AS p
    ORDER BY TerritoryID;
END;
GO

EXEC [dbo].[uspMonthlySalesByTerritory] 2013;
GO

-- viết procedure tạo đơn hàng:
-- sales.orders: 
-- order_id: tự tăng
-- customer_id: lấy ngẫu nhiên trong bảng sales.customers
-- order_status: mặc định 4
-- order_date: cộng ngẫy nhiên 0 đến 30 ngày vào ngày hiện tại 
-- required_date: ngẫu nhiên trong khoảng order_date + 20 ngày 
-- shipped_date: ngẫu nhiên trong khoảng required_date + 15 ngày 
-- store_id: ngẫu nhiên trong bảng sales.stores
-- staff_id: ngẫu nhiên trong bảng sales.staffs
USE [04_BikeStores]
GO

	
CREATE OR ALTER PROCEDURE [dbo].[uspCreateRandomOrder]
	@OrderID INT OUTPUT -- Xuất ra orderID làm input cho bài 2
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
		@CustomerID INT,
        @StoreID INT,
        @StaffID INT,
        @OrderDate DATE,
        @RequiredDate DATE,
        @ShippedDate DATE;

	-- lấy ngẫu nhiên trong bảng sales.customers
	SELECT TOP 1 @CustomerID = c.customer_id
	FROM
		[sales].[customers] c
	ORDER BY NEWID();

	-- ngẫu nhiên trong bảng sales.stores
	SELECT TOP 1 @StoreID = s.store_id
	FROM
		[sales].[stores] s
	ORDER BY NEWID();

	-- staff_id: ngẫu nhiên trong bảng sales.staffs
	SELECT TOP 1 @StaffID = st.staff_id
	FROM
		[sales].[staffs] st
	ORDER BY NEWID();

	-- order_date: cộng ngẫy nhiên 0 đến 30 ngày vào ngày hiện tại 
	SET @OrderDate = DATEADD(DAY, FLOOR(RAND() * 31), CAST(GETDATE() AS DATE))

	-- required_date: ngẫu nhiên trong khoảng order_date + 20 ngày 
	SET @RequiredDate = DATEADD(DAY, FLOOR(RAND() * 20), @OrderDate)

	-- shipped_date: ngẫu nhiên trong khoảng required_date + 15 ngày 
	SET @ShippedDate = DATEADD(DAY, FLOOR(RAND() * 15), @RequiredDate)

	-- Insert vào bảng sales.orders
	INSERT INTO [sales].[orders]([customer_id], [order_status], [order_date], [required_date], [shipped_date], [store_id], [staff_id])
	VALUES (@CustomerID, 4, @OrderDate, @RequiredDate, @ShippedDate, @StoreID, @StaffID);

	SET @OrderID = SCOPE_IDENTITY();

	PRINT 'Random order created successfully.';
END
GO

-- sales.order_items: số line random từ 3 đến 15
-- order_id: order_id đã tạo ở trên
-- item_id: tăng dần theo số lượng item trong order này
-- product_id: ngẫu nhiên trong bảng production.products 
-- quantity: ngẫu nhiên trong khoảng 1 đến 12
-- list_price: giá của sản phẩm đã chọn
-- discount: ngẫu nhiên trong các giá trị: 0, 5%, 10%, 15%, 20%
CREATE OR ALTER PROCEDURE [dbo].[uspCreateRandomOrderItems]
	@OrderID INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE
        @LineCount INT,     
        @i INT = 1,
        @ProductID INT,
        @Quantity INT,
        @ListPrice DECIMAL(10,2),
        @Discount DECIMAL(4,2);

	-- Random số dòng từ 3 đến 15
	SET @LineCount = 3 + FLOOR(RAND() * 13)
	WHILE @i < @LineCount
	BEGIN
		-- product_id: ngẫu nhiên trong bảng production.products
		-- list_price: giá của sản phẩm đã chọn
		SELECT TOP 1 
			@ProductID = p.product_id
			, @ListPrice = p.list_price
		FROM
			[production].[products] p
		ORDER BY NEWID();

		-- quantity: ngẫu nhiên trong khoảng 1 đến 12
		SET @Quantity = 1 + FLOOR(RAND() * 12)

		-- discount: ngẫu nhiên trong các giá trị: 0, 5%, 10%, 15%, 20%
		DECLARE @RandDiscount INT = FLOOR(RAND() * 5);
		SET @Discount = CASE
							WHEN @RandDiscount = 0 THEN 0.00
							WHEN @RandDiscount = 1 THEN 0.05
							WHEN @RandDiscount = 2 THEN 0.10
							WHEN @RandDiscount = 3 THEN 0.15
							WHEN @RandDiscount = 4 THEN 0.20
						END;

		-- Insert order_items
		INSERT INTO [sales].[order_items](order_id, item_id, product_id, quantity, list_price, discount)
		VALUES(@OrderID, @i, @ProductID, @Quantity, @ListPrice, @Discount);

		SET @i += 1;
	END;
END
GO

DECLARE @NewOrderID INT;
-- Tạo order
EXEC [dbo].[uspCreateRandomOrder] @OrderID = @NewOrderID OUTPUT;

-- Tạo order_items cho order vừa tạo
EXEC [dbo].[uspCreateRandomOrderItems] @OrderID = @NewOrderID;
PRINT CONCAT('Order và Order_Items đã được tạo cho OrderID = ', @NewOrderID);
GO

--59. Viết thủ tục và hàm tìm giá trị max
--    ○ Input: hai số a, b
--    ○ Output: số lớn hơn trong a và b
CREATE OR ALTER PROCEDURE [dbo].[uspMax]
	@a INT, 
	@b INT
AS
BEGIN
	IF @a IS NULL OR @b IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	DECLARE @Max INT = @b

	IF @a > @b
		SET @Max = @a
	PRINT CONCAT('Max in a and b: ', @Max);
END;
GO

EXEC [dbo].[uspMax] 3, 4;
EXEC [dbo].[uspMax] 3, null;
GO
--60. Viết thủ tục và hàm trích xuất domain của 1 email
--    ○ Input: email
--    ○ Output: domain
--    ○ Ví dụ input: abc123@hotmail.com → output hotmail.com
CREATE OR ALTER PROCEDURE [dbo].[uspDomainEmail]
	@Email NVARCHAR(100)
AS
BEGIN
	IF @Email IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	IF @Email NOT LIKE '%_@__%.__%' 
		THROW 50002, 'The input does not comply format email.', 1;

	DECLARE @domain NVARCHAR(100)
	SET @domain = SUBSTRING(@Email, CHARINDEX('@', @Email) + 1, LEN(@Email))
	PRINT CONCAT('Domain Email: ', @domain);
END;
GO

EXEC [dbo].[uspDomainEmail] 'abc123@hotmail.com';
-- Output: Domain Email: hotmail.com

EXEC [dbo].[uspDomainEmail] NULL;
-- Error: 50001 The input cannot be NULL.

EXEC [dbo].[uspDomainEmail] 'abc123hotmail.com';
-- Error: 50002 The input does not comply with email format.
GO


--61. Viết thủ tục và hàm viết hoa chữ cái đầu của tên
--    ○ Input: name
--    ○ Output: tên viết hoa chữ cái đầu
--    ○ Ví dụ: nguyễn văn abc → Nguyễn Văn Abc
CREATE OR ALTER FUNCTION [dbo].[ufnCapitalizeName](@Name NVARCHAR(200))
RETURNS NVARCHAR(200)
AS
BEGIN
	DECLARE @Result NVARCHAR(200) = LTRIM(RTRIM(@Name));
	DECLARE @Word NVARCHAR(100);
	DECLARE @SpacePos INT;

	SET @Result = LOWER(@Result) -- CHUYỂN VỀ CHỮ THƯỜNG
	DECLARE @Output NVARCHAR(200) = ''; -- KHÔNG NÊN ĐỂ TRỐNG HOẶC NULL

	WHILE LEN(@Result) > 0
	BEGIN
		SET @SpacePos = CHARINDEX(' ', @Result)
		IF @SpacePos = 0
		BEGIN
			-- Lấy từ cuối cùng
			SET @Word = @Result;
			SET @Result = '';
		END
		ELSE
		BEGIN
			-- Lấy 1 từ trước khoảng trắng
			SET @Word = LEFT(@Result, @SpacePos - 1);
			SET @Result = LTRIM(RIGHT(@Result, LEN(@Result) - @SpacePos));
		END
		
		-- Viết hoa chữ cái đầu
		SET @Word = CONCAT(Upper(LEFT(@Word, 1)), SUBSTRING(@Word, 2, LEN(@Word)))
		-- Ghép vào Output
		SET @Output = LTRIM(RTRIM(@Output + ' ' + @Word));
	END
	RETURN @Output;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[uspCapitalizeName]
    @Name NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Name IS NULL
        THROW 50001, 'The input cannot be NULL.', 1;

    DECLARE @Result NVARCHAR(200);
    SET @Result = [dbo].[ufnCapitalizeName](@Name);

    PRINT CONCAT('Capitalized Name: ', @Result);
END
GO

EXEC dbo.uspCapitalizeName N'nguyễn văn abc';
GO
-- Output: Capitalized Name: Nguyễn Văn Abc


--62. Viết hàm tính tuổi
--    ○ Input: ngày sinh
--    ○ Output: tuổi
CREATE OR ALTER FUNCTION [dbo].[ufnBirthDay](@DateOfBirth DATE)
RETURNS INT
AS
BEGIN
	DECLARE @Age INT = 0;
	DECLARE @Now DATE = CAST(GETDATE() AS DATE)
	IF @DateOfBirth IS NOT NULL
	BEGIN
		SET @Age = DATEDIFF(YEAR, @DateOfBirth, @Now) - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @DateOfBirth, @Now), @DateOfBirth) > @Now THEN 1	ELSE 0 END
	END
	RETURN @Age;
END;
GO

SELECT [dbo].[ufnBirthDay]('1996-09-09') AS AGE
SELECT [dbo].[ufnBirthDay](NULL) AS AGE
GO
--63. Viết hàm tính số order_items của một order
--    ○ Input: order_id
CREATE OR ALTER FUNCTION [dbo].[ufnCountOrderItems](@order_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @TotalOrder INT = 0;

	SELECT @TotalOrder = COUNT(*)
						 FROM [sales].[order_items] oi
						 WHERE oi.[order_id] = @order_id
	RETURN @TotalOrder;
END;
GO

CREATE OR ALTER PROCEDURE [dbo].[uspCountOrderItem]
    @order_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @order_id IS NULL
        THROW 50001, 'The input cannot be NULL.', 1;

    DECLARE @TotalOrder INT = 0;
    SET @TotalOrder = [dbo].[ufnCountOrderItems](@order_id);

    PRINT CONCAT('Total Order: ', @TotalOrder);
END
GO

EXEC [dbo].[uspCountOrderItem] 2;
EXEC [dbo].[uspCountOrderItem] null;
GO
