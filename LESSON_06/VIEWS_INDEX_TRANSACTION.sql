USE [04_BikeStores]
GO

--Lấy thông tin đầy đủ của một order
--Ngày tạo order, ngày chốt đơn, ngày ship hàng
--Tên khách (full name), số ĐT khách, email khách, địa chỉ khách (street, city, state, zip code)
--Tên cửa hàng, số ĐT cửa hàng, email cửa hàng, địa chỉ cửa hàng (street, city, state, zip code)
--Tên nhân viên bán hàng (full name), email nhân viên, số ĐT nhân viên
ALTER VIEW [dbo].[vInformationOrder] AS
SELECT
	-- ORDER
	O.order_date
	, O.required_date
	, O.shipped_date
	-- CUSTOMER
	, (CU.first_name + ' ' + CU.last_name) AS CUSTOMER_FULL_NAME
	, CU.phone AS CUSTOMER_PHONE
	, CU.email as CUSTOMER_EMAIL
	, (CU.street + ' - ' + CU.city + ' - ' + CU.state + ' - ' + CU.zip_code) AS CUSTOMER_ADDRESS -- street, city, state, zip code
	-- STORE
	, ST.store_name AS STORE_NAME
	, ST.phone AS STORE_PHONE
	, ST.email AS STORE_EMAIL
	, (ST.street + ' - ' + ST.city + ' - ' + ST.state + ' - ' + ST.zip_code) AS STORE_ADDRESS -- street, city, state, zip code
	-- STAFF
	, (STA.first_name + ' ' + STA.last_name) AS STAFF_FULL_NAME
	, STA.email AS STAFF_EMAIL
	, STA.phone AS STA_PHONE
FROM 
	[sales].[orders] AS O
	JOIN [sales].[customers] AS CU ON CU.customer_id = O.customer_id
	JOIN [sales].[stores] AS ST ON ST.store_id = O.store_id
	JOIN [sales].[staffs] AS STA ON STA.staff_id = O.staff_id
GO

SELECT	* FROM [dbo].[vInformationOrder];
GO
-- Lấy danh sách customer có first_name bắt đầu bằng chữ cái A
ALTER VIEW [dbo].[vGetInformationSpcificCustomerName] AS
SELECT 
	CU.*
FROM 
	[sales].[customers] AS CU
WHERE
	CU.first_name LIKE 'A%';
GO

SELECT * FROM [dbo].[vGetInformationSpcificCustomerName]

 
BEGIN TRANSACTION

UPDATE [sales].[customers] SET first_name = 'TEST' WHERE customer_id = 1
UPDATE [sales].[customers] SET first_name = 'TEST2' WHERE customer_id = 2

SELECT * FROM [sales].[customers]

COMMIT
ROLLBACK

GO
-----------------------------------------------------------------------------------------------------------------------------------------
--# 📘 Bài tập SQL với AdventureWorks2022

--## 1. Function (User-defined Function)

--### Bài 1: Tính tuổi nhân viên

--* **Yêu cầu:** Tạo function `ufn_GetEmployeeAge(@BusinessEntityID INT)` trả về số tuổi của nhân viên.
--* **Gợi ý bảng:** `HumanResources.Employee` (có `BirthDate`).
--* **Dùng thử:** Lấy danh sách `BusinessEntityID, JobTitle, Age`.
USE [00_AdventureWorks2022]
GO

CREATE OR ALTER FUNCTION [dbo].[ufnCountOrderItems](@BusinessEntityID INT)
RETURNS INT
AS
BEGIN
	DECLARE @Age INT = 0;
	DECLARE @Now DATE = CAST(GETDATE() AS DATE);
	IF @BusinessEntityID IS NOT NULL
	BEGIN
		SELECT
			@Age =	DATEDIFF(YEAR, e.[BirthDate], @Now) -
					CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.[BirthDate], @Now), e.[BirthDate]) > @Now THEN 1 ELSE 0 END
		FROM
			[HumanResources].[Employee] e
		WHERE
			e.BusinessEntityID = @BusinessEntityID
	END;
	RETURN @Age;
END;
GO

SELECT [dbo].[ufnCountOrderItems](1) AS AGE;
GO

---

--### Bài 2: Tính tổng chi tiêu của khách hàng
--* **Yêu cầu:** Tạo function `ufn_TotalCustomerSpent(@CustomerID INT)` trả về tổng số tiền khách đã chi.
--* **Gợi ý bảng:**
--  * `Sales.SalesOrderHeader` (có `CustomerID`, `TotalDue`).
--* **Dùng thử:** SELECT CustomerID, gọi function để xem tổng chi tiêu.
CREATE OR ALTER FUNCTION [dbo].[ufnTotalCustomerSpent](@CustomerID INT)
RETURNS DECIMAL(10, 3)
AS
BEGIN
	DECLARE @TotalAmount DECIMAL(10, 3) = 0;
	IF @CustomerID IS NOT NULL
	BEGIN
		SELECT
			@TotalAmount = SUM(soh.TotalDue)
		FROM
			[Sales].[SalesOrderHeader] soh
		WHERE 
			soh.CustomerID = @CustomerID
	END;
	RETURN @TotalAmount;
END;
GO

SELECT [dbo].[ufnTotalCustomerSpent](29825);
GO
---

--### Bài 3: Phân loại khách hàng theo tổng chi tiêu

--* **Yêu cầu:** Tạo **inline table-valued function** `ufn_ClassifyCustomer(@CustomerID INT)` trả về:

--  * `Low Spender` nếu tổng chi < 5000
--  * `Medium Spender` nếu 5000–20000
--  * `High Spender` nếu > 20000
--* **Dùng thử:** Lọc danh sách khách hàng trong `Sales.Customer`.
CREATE OR ALTER FUNCTION [dbo].[ufnClassifyCustomer](@CustomerID INT)
RETURNS TABLE
AS
RETURN (
	SELECT
		c.CustomerID
		, CASE
			WHEN SUM(soh.TotalDue) < 5000 THEN 'Low Spender'
			WHEN SUM(soh.TotalDue) BETWEEN 5000 AND 20000 THEN 'Medium Spender'
			WHEN SUM(soh.TotalDue) > 20000 THEN 'High Spender'
			ELSE 'Others'
		 END AS ClassifyCustomer
	FROM
		[Sales].[Customer] c
		JOIN [Sales].[SalesOrderHeader] soh ON soh.CustomerID = c.CustomerID
	WHERE 
		c.CustomerID = @CustomerID
	GROUP BY
		c.CustomerID
);
GO

SELECT 
    c.CustomerID,
    cf.ClassifyCustomer
FROM Sales.Customer c
CROSS APPLY [dbo].[ufnClassifyCustomer](c.CustomerID) cf;
GO
---

--## 2. Stored Procedure

--### Bài 4: Lấy danh sách đơn hàng của khách hàng

--* **Yêu cầu:** Tạo procedure `usp_GetOrdersByCustomer @CustomerID INT`.
--* **Kết quả:** Truy xuất từ `Sales.SalesOrderHeader` và `Sales.SalesOrderDetail` → hiển thị `OrderID, OrderDate, ProductID, Quantity, LineTotal`.
CREATE OR ALTER PROC [dbo].[uspGetOrdersByCustomer]
	@CustomerID INT
AS
BEGIN
	IF @CustomerID IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;
	SELECT
		soh.SalesOrderID
		, soh.OrderDate
		, sod.ProductID
		, sod.OrderQty
		, sod.LineTotal
	FROM
		[Sales].[SalesOrderHeader] soh
		JOIN [Sales].[SalesOrderDetail] sod ON sod.SalesOrderID = soh.SalesOrderID
	WHERE
		soh.CustomerID = @CustomerID
END;
GO

EXEC [dbo].[uspGetOrdersByCustomer] 11012;
EXEC [dbo].[uspGetOrdersByCustomer] NULL;
GO
---

--### Bài 5: Thêm sản phẩm mới

--* **Yêu cầu:** Tạo procedure `usp_AddProduct` với tham số:

--  * `@Name, @ProductNumber, @StandardCost, @ListPrice, @SellStartDate`.
--* **Chèn vào:** `Production.Product`.
--* **Ràng buộc:** `ListPrice > 0`, `StandardCost >= 0`.
CREATE OR ALTER PROC [dbo].[uspAddProduct]
		@Name NVARCHAR(100)
		, @ProductNumber NVARCHAR(100)
		, @SafetyStockLevel SMALLINT
		, @ReorderPoint SMALLINT
		, @StandardCost MONEY
		, @ListPrice MONEY
		, @DaysToManufacture INT
		, @SellStartDate DATE		
		, @rowguid uniqueidentifier
		, @ModifiedDate DATE
AS
BEGIN
	SET NOCOUNT ON;
	IF @Name IS NULL
	   OR @ProductNumber IS NULL
	   OR @StandardCost IS NULL
	   OR @ReorderPoint IS NULL
	   OR @ListPrice IS NULL
	   OR @DaysToManufacture IS NULL
	   OR @SellStartDate IS NULL
	   OR @SafetyStockLevel IS NULL
	   OR @rowguid IS NULL
	   OR @ModifiedDate IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	IF @ListPrice <= 0
		THROW 50002, 'The @ListPrice must be grater than 0.', 1;

	IF @StandardCost < 0
		THROW 50003, 'The @StandardCost must be grater than or equal to 0.', 1;

	INSERT INTO [Production].[Product]([Name], [ProductNumber], [SafetyStockLevel], [ReorderPoint], [StandardCost], [ListPrice],
				[DaysToManufacture], [SellStartDate], [rowguid], [ModifiedDate])
	VALUES (@Name, @ProductNumber, @SafetyStockLevel, @ReorderPoint, @StandardCost, @ListPrice,
			@DaysToManufacture, @SellStartDate, @rowguid, @ModifiedDate)

	PRINT 'Product inserted successfully.';
END;
GO

DECLARE @newid uniqueidentifier = NEWID();
DECLARE @DateModified DATE = CAST(GETDATE() AS DATE);

EXEC [dbo].[uspAddProduct]
     @Name = N'Laptop Gaming Z2025',
     @ProductNumber = N'LT-Z2025',
     @SafetyStockLevel = 100,
	 @ReorderPoint = 50,
     @StandardCost = 1200,
     @ListPrice = 2000,
	 @DaysToManufacture = 5,
     @SellStartDate = '2025-09-19',
     @rowguid = @newid,
     @ModifiedDate = @DateModified;
GO

---

--### Bài 6: Cập nhật giá bán hàng loạt

--* **Yêu cầu:** Viết procedure `usp_UpdateProductPrice @Percentage DECIMAL(5,2)`
--* **Nội dung:** Tăng hoặc giảm giá bán (`ListPrice`) của tất cả sản phẩm theo % nhập vào.
--* **Gợi ý bảng:** `Production.Product`.
CREATE OR ALTER PROC [dbo].[uspUpdateProductPrice]
	@Percentage DECIMAL(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	IF @Percentage IS NULL
		THROW 50001, 'The input cannot be NULL.', 1;

	UPDATE [Production].[Product]
	SET [ListPrice] = [ListPrice] + [ListPrice] * @Percentage;

	PRINT 'Product updated successfully.';
END;
GO

EXEC [dbo].[uspUpdateProductPrice] 0.32;
EXEC [dbo].[uspUpdateProductPrice] -0.32;
GO
---

--## 3. Transaction

--### Bài 7: Tạo đơn hàng mới

--* **Yêu cầu:** Viết procedure `usp_CreateOrder @ProductID INT, @Quantity INT`.
--* **Transaction logic:**

--  1. Kiểm tra tồn kho trong `Production.ProductInventory`.
--  2. Giảm số lượng tồn kho.
--  3. Nếu lỗi ở bất kỳ bước nào → **ROLLBACK**; thành công → **COMMIT**.
CREATE OR ALTER PROC [dbo].[uspCreateOrder]
	 @ProductID INT
	 , @Quantity INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
		--  1. Kiểm tra tồn kho trong `Production.ProductInventory`.
		DECLARE @Stock INT
		SELECT @Stock = p.Quantity
		FROM [Production].[ProductInventory] p
		WHERE p.ProductID = @ProductID

		IF @Stock IS NULL
			THROW 50001, 'The product not found in inventory.', 1;

		IF @Stock < @Quantity
			THROW 50002, 'Not enough stock.', 1;

		--  2. Giảm số lượng tồn kho.
		UPDATE [Production].[ProductInventory]
		SET [Quantity] = [Quantity] - @Quantity
			, [ModifiedDate] = GETDATE()
		WHERE
			[ProductID] = @ProductID
			AND [Quantity] >= @Quantity;

	    -- Commit transaction
        COMMIT TRANSACTION;
        PRINT 'Order created successfully.';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrState INT = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
	END CATCH
END;
GO

EXEC [dbo].[uspCreateOrder]
    @ProductID = 707,     -- ID sản phẩm có tồn kho
    @Quantity = 5;
GO
---

--### Bài 8: Chuyển kho sản phẩm

--* **Giả sử:** Cùng một sản phẩm có thể ở nhiều `LocationID` khác nhau trong `Production.ProductInventory`.
--* **Yêu cầu:** Viết procedure `usp_TransferInventory @ProductID INT, @FromLocation INT, @ToLocation INT, @Quantity INT`.
--* **Transaction logic:**

--  * Kiểm tra `FromLocation` còn đủ số lượng.
--  * Giảm số lượng ở `FromLocation`.
--  * Tăng số lượng ở `ToLocation`.
--  * Rollback nếu bất kỳ bước nào thất bại.
CREATE OR ALTER PROC [dbo].[uspTransferInventory]
	 @ProductID INT
	 , @FromLocation INT
	 , @ToLocation INT
	 , @Quantity INT
AS
BEGIN
	SET NOCOUNT ON;
	-- Validate Input
	IF @ProductID IS NULL
		THROW 50001, '@ProductID cannot be NULL', 1;
	IF @FromLocation IS NULL
		THROW 50002, '@FromLocation cannot be NULL', 1;
	IF @ToLocation IS NULL
		THROW 50003, '@ToLocation cannot be NULL', 1;
	IF @Quantity IS NULL
		THROW 50004, '@Quantity cannot be NULL', 1;
	IF @FromLocation = @ToLocation
		THROW 50005, '@FromLocation and @ToLocation cannot be the same.', 1;
	IF @Quantity <= 0
		THROW 50006, '@Quantity must be greater than zero.', 1;

	BEGIN TRY
		BEGIN TRANSACTION;
		--  * Kiểm tra `FromLocation` còn đủ số lượng.
		DECLARE @Stock INT
		SELECT @Stock = SUM(p.Quantity)
		FROM [Production].[ProductInventory] p
		WHERE p.LocationID = @FromLocation AND p.ProductID = @ProductID

		IF @Stock IS NULL
			THROW 50007, 'The product not found in the specified FromLocation.', 1;

		IF @Stock < @Quantity
			THROW 50008, 'Not enough stock.', 1;

		--  * Giảm số lượng ở `FromLocation`.
		UPDATE [Production].[ProductInventory]
		SET [Quantity] = [Quantity] - @Quantity
		WHERE
			[LocationID] = @FromLocation
			AND ProductID = @ProductID
			AND [Quantity] >= @Quantity;

		--  * Tăng số lượng ở `ToLocation`.
		IF EXISTS (
			SELECT 1 FROM [Production].[ProductInventory] p
			WHERE p.ProductID = @ProductID AND p.LocationID = @ToLocation
		)
		BEGIN
			UPDATE [Production].[ProductInventory]
			SET [Quantity] = [Quantity] + @Quantity
			WHERE
				[LocationID] = @ToLocation
				AND ProductID = @ProductID;
		END
		ELSE
		BEGIN
			DECLARE @newid UNIQUEIDENTIFIER = NEWID();
			DECLARE @DateModified DATETIME = GETDATE();
			INSERT INTO [Production].[ProductInventory](ProductID, LocationID, Shelf, Bin, Quantity, rowguid, ModifiedDate)
			VALUES(@ProductID, @ToLocation, 'N/A', 0, @Quantity, @newid, @DateModified)
		END
		-- Commit transaction
        COMMIT TRANSACTION;
		PRINT 'Transfer Inventory successfully.';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrState INT = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
	END CATCH
END;
GO

EXEC [dbo].[uspTransferInventory] 
     @ProductID = NULL,       -- sản phẩm HL Road Frame
     @FromLocation = 1,      -- chuyển từ kho 1
     @ToLocation = 6,        -- sang kho 6
     @Quantity = 10;         -- số lượng 10
GO
---

--### Bài 9: Hủy đơn hàng

--* **Yêu cầu:** Viết procedure `usp_CancelOrder @SalesOrderID INT`.
--* **Transaction logic:**

--  * Xóa chi tiết đơn hàng trong `Sales.SalesOrderDetail`.
--  * Xóa header trong `Sales.SalesOrderHeader`.
--  * Cập nhật lại tồn kho trong `Production.ProductInventory`.
--  * Rollback nếu có lỗi.
CREATE OR ALTER PROC [dbo].[uspCancelOrder]
	 @SalesOrderID INT
AS
BEGIN
	SET NOCOUNT ON;
	IF @SalesOrderID IS NULL
		THROW 50001, '@SalesOrderID cannot be NULL', 1;


	BEGIN TRY
		BEGIN TRANSACTION;

		-- 1. Lấy lại sản phẩm + số lượng từ SalesOrderDetail
		IF NOT EXISTS (
			SELECT 1 FROM [Sales].[SalesOrderDetail] sod
			WHERE sod.SalesOrderID = @SalesOrderID
		)
			THROW 50002, '@SalesOrderID does not exist in SalesOrderDetail', 1;

		DECLARE @Restock TABLE
		(
			ProductID INT,
			Quantity INT
		);

		INSERT INTO @Restock (ProductID, Quantity)
		SELECT
			sod.ProductID
			, sod.OrderQty
		FROM [Sales].[SalesOrderDetail] sod
		WHERE sod.SalesOrderID = @SalesOrderID

		-- 2. Cập nhật tồn kho (giả sử LocationID = 1 là kho chính)
		UPDATE pri
		SET
			pri.Quantity = pri.Quantity + r.Quantity,
			pri.ModifiedDate = GETDATE()
		FROM 
			[Production].[ProductInventory] pri
			JOIN @Restock r ON r.ProductID = pri.ProductID
		WHERE
			pri.[LocationID] = 1;

		-- 3. Xóa chi tiết đơn hàng
		DELETE [Sales].[SalesOrderDetail]
		WHERE [SalesOrderID] = @SalesOrderID

		-- 4. Xóa header đơn hàng
		IF NOT EXISTS (
			SELECT 1 FROM [Sales].[SalesOrderHeader] soh
			WHERE soh.SalesOrderID = @SalesOrderID
		)
			THROW 50003, '@SalesOrderID does not exist in SalesOrderHeader', 1;
		ELSE
			DELETE [Sales].[SalesOrderHeader]
			WHERE [SalesOrderID] = @SalesOrderID

		--  * Cập nhật lại tồn kho trong `Production.ProductInventory`.

		-- Commit transaction
        COMMIT TRANSACTION;
		PRINT 'Cancel Order successfully.';
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION

		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrState INT = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
	END CATCH
END;
---




