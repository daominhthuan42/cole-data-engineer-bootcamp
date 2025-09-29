USE [02_Evoucher]
GO

--5. Thiết kế bảng dữ liệu nghiệp vụ EVoucher
--    Nhân viên
--    Danh mục loại voucher
--    Danh sách voucher
--    Quản lý ngân sách voucher

-- CREATE SCHEMAS
CREATE SCHEMA Biz;
GO

--    Nhân viên
DROP TABLE IF EXISTS Biz.Employee
CREATE TABLE Biz.Employee
(
    Employee_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL, -- thuộc về tổ chức nào
    EmployeeCode NVARCHAR(50) NOT NULL,
    FullName NVARCHAR(250) NOT NULL,
    Email NVARCHAR(250) CONSTRAINT CK_Employee_Email CHECK(
															Email LIKE '%_@__%.__%'
															AND Email NOT LIKE '% %'
															AND LEN(Email) - LEN(REPLACE(Email,'@','')) = 1
														),
    PhoneNumber NVARCHAR(10)CONSTRAINT CK_Employee_PhoneNumber CHECK(
																		LEN(PhoneNumber) = 10
																		AND PhoneNumber NOT LIKE '%[^0-9]%'
																	  ),
    Department NVARCHAR(250),

	CONSTRAINT UQ_Employee_EmployeeCode UNIQUE (EmployeeCode),
    CONSTRAINT FK_Employee_Org FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION
);
GO

--    Danh mục loại voucher
DROP TABLE IF EXISTS Biz.VoucherCategory
CREATE TABLE Biz.VoucherCategory
(
    VoucherCategory_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    CategoryCode NVARCHAR(50) NOT NULL,
    CategoryName NVARCHAR(250) NOT NULL,
    Description NVARCHAR(1000),

	CONSTRAINT UQ_VoucherCategory_CategoryCode UNIQUE (CategoryCode),
    CONSTRAINT FK_VoucherCategory_Org FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
);

--    Danh sách voucher
DROP TABLE IF EXISTS Biz.Voucher
CREATE TABLE Biz.Voucher
(
    Voucher_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    VoucherCode NVARCHAR(50) NOT NULL,
    VoucherCategory_Id NVARCHAR(50) NOT NULL,
    Title NVARCHAR(250) NOT NULL,
    Description NVARCHAR(1000),
    Value DECIMAL(18,2) NOT NULL CONSTRAINT CK_Voucher_Value CHECK(Value > 0), -- giá trị voucher
    ExpiredDate DATETIME NOT NULL,     -- ngày hết hạn
    Status NVARCHAR(50) NOT NULL,      -- trạng thái: New, Used, Expired

	CONSTRAINT CK_Voucher_Status CHECK(Status IN ('New', 'Used', 'Expired')),
	CONSTRAINT UQ_Voucher_VoucherCode UNIQUE (VoucherCode),
    CONSTRAINT FK_Voucher_Org FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION,
    CONSTRAINT FK_Voucher_Category FOREIGN KEY(VoucherCategory_Id) REFERENCES Biz.VoucherCategory(VoucherCategory_Id) ON DELETE NO ACTION
);
GO

--    Quản lý ngân sách voucher
DROP TABLE IF EXISTS Biz.VoucherBudget
CREATE TABLE Biz.VoucherBudget
(
    VoucherBudget_Id NVARCHAR(50) PRIMARY KEY,
    CreateUser NVARCHAR(50) NOT NULL,
    CreateDate DATETIME NOT NULL,
    UpdateUser NVARCHAR(50),
    UpdateDate DATETIME,
    IsActive BIT,
    App_Org_Id NVARCHAR(50) NOT NULL,
    BudgetYear INT NOT NULL CONSTRAINT CK_VoucherBudget_BudgetYear CHECK(BudgetYear >= 0),
    BudgetMonth INT NOT NULL CONSTRAINT CK_VoucherBudget_BudgetMonth CHECK(BudgetMonth >= 0),
    TotalBudget DECIMAL(18,2) NOT NULL CONSTRAINT CK_VoucherBudget_TotalBudget CHECK(TotalBudget >= 0),
    UsedAmount DECIMAL(18,2) DEFAULT 0,
    RemainingAmount AS (TotalBudget - UsedAmount) PERSISTED, -- computed column

    CONSTRAINT FK_VoucherBudget_Org FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION
);
GO

-----------------------------------------------------------------Biz.Employee-----------------------------------------------------
-- Insert
CREATE OR ALTER PROC Biz.sp_Employee_Insert
    @Employee_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @EmployeeCode NVARCHAR(50),
    @FullName NVARCHAR(250),
    @Email NVARCHAR(250) = NULL,
    @PhoneNumber NVARCHAR(10) = NULL,
    @Department NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @Employee_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @EmployeeCode IS NULL THEN 5005
					WHEN @FullName IS NULL THEN 5006
				END,

		@ErrMsg = CASE
					WHEN @Employee_Id IS NULL THEN '@Employee_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @EmployeeCode IS NULL THEN '@EmployeeCode cannot be NULL'
					WHEN @FullName IS NULL THEN '@FullName cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Biz.Employee (Employee_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive, App_Org_Id, EmployeeCode, FullName,
							  Email, PhoneNumber, Department)
    VALUES (@Employee_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive, @App_Org_Id, @EmployeeCode,
        @FullName, @Email, @PhoneNumber, @Department);
END
GO

-- Update
CREATE OR ALTER PROC Biz.sp_Employee_Update
    @Employee_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50) = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @EmployeeCode NVARCHAR(50) = NULL,
    @FullName NVARCHAR(250) = NULL,
    @Email NVARCHAR(250) = NULL,
    @PhoneNumber NVARCHAR(10) = NULL,
    @Department NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @Employee_Id IS NULL
		THROW 50001, '@Employee_Id cannot be NULL', 1;

    UPDATE Biz.Employee
    SET 
		CreateUser = ISNULL(@CreateUser, CreateUser),
		UpdateUser = ISNULL(@UpdateUser, UpdateUser),
		UpdateDate = ISNULL(@UpdateDate, GETDATE()),
		IsActive = ISNULL(@IsActive, IsActive),
		App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
		EmployeeCode = ISNULL(@EmployeeCode, EmployeeCode),
		@FullName = ISNULL(@FullName, FullName),
        Email = ISNULL(@Email, Email),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        Department = ISNULL(@Department, Department)
    WHERE Employee_Id = @Employee_Id;
END
GO

-- Delete (soft delete)
CREATE OR ALTER PROC Biz.sp_Employee_Delete
    @Employee_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @Employee_Id IS NULL
		THROW 50001, '@Employee_Id cannot be NULL', 1;

    UPDATE Biz.Employee
    SET IsActive = 0
    WHERE Employee_Id = @Employee_Id;
END
GO

-- GetById
CREATE OR ALTER PROC Biz.sp_Employee_GetById
    @Employee_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @Employee_Id IS NULL
		THROW 50001, '@Employee_Id cannot be NULL', 1;

    SELECT *
    FROM Biz.Employee
    WHERE Employee_Id = @Employee_Id;
END
GO

-- GetPaging
CREATE OR ALTER PROC Biz.sp_Employee_GetPaging
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

	;WITH Employee_CTE AS (
		SELECT 
			e.*,
			ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum
		FROM Biz.Employee e
	)
	SELECT *
	FROM Employee_CTE
	WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1)
					AND (@PageNumber * @PageSize);
END
GO

-----------------------------------------------------------------Biz.VoucherCategory-----------------------------------------------------
-------------------------------------------------
-- INSERT
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCategory_Insert
    @VoucherCategory_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @CategoryCode NVARCHAR(50),
    @CategoryName NVARCHAR(250),
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @VoucherCategory_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @CategoryCode IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @VoucherCategory_Id IS NULL THEN '@VoucherCategory_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @CategoryCode IS NULL THEN '@CategoryCode cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Biz.VoucherCategory(
        VoucherCategory_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, CategoryCode, CategoryName, Description
    )
    VALUES(
        @VoucherCategory_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @CategoryCode, @CategoryName, @Description
    );
END
GO

-------------------------------------------------
-- UPDATE
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCategory_Update
    @VoucherCategory_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50) = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @CategoryCode NVARCHAR(50) = NULL,
    @CategoryName NVARCHAR(250) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @VoucherCategory_Id IS NULL
        THROW 50001, '@VoucherCategory_Id cannot be NULL', 1;

    UPDATE Biz.VoucherCategory
    SET
        CreateUser   = ISNULL(@CreateUser, CreateUser),
        UpdateUser   = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate   = ISNULL(@UpdateDate, GETDATE()),
        IsActive     = ISNULL(@IsActive, IsActive),
        App_Org_Id   = ISNULL(@App_Org_Id, App_Org_Id),
        CategoryCode = ISNULL(@CategoryCode, CategoryCode),
        CategoryName = ISNULL(@CategoryName, CategoryName),
        Description  = ISNULL(@Description, Description)
    WHERE VoucherCategory_Id = @VoucherCategory_Id;
END
GO

-------------------------------------------------
-- DELETE (Soft Delete: set IsActive = 0)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCategory_Delete
    @VoucherCategory_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VoucherCategory_Id IS NULL
        THROW 50001, '@VoucherCategory_Id cannot be NULL', 1;

    UPDATE Biz.VoucherCategory
    SET IsActive = 0
    WHERE VoucherCategory_Id = @VoucherCategory_Id;
END
GO

-------------------------------------------------
-- GET BY ID
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCategory_GetById
    @VoucherCategory_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF @VoucherCategory_Id IS NULL
        THROW 50001, '@VoucherCategory_Id cannot be NULL', 1;

    SELECT *
    FROM Biz.VoucherCategory
    WHERE VoucherCategory_Id = @VoucherCategory_Id;
END
GO

-------------------------------------------------
-- GET PAGING (dùng ROW_NUMBER)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCategory_GetPaging
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH CTE AS (
        SELECT 
            vc.*,
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum
        FROM Biz.VoucherCategory vc
    )
    SELECT *
    FROM CTE
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                     AND (@PageNumber * @PageSize);
END
GO

-----------------------------------------------------------------Biz.voucher-----------------------------------------------------
-------------------------------------------------
-- INSERT
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_Insert
    @Voucher_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @VoucherCode NVARCHAR(50),
    @VoucherCategory_Id NVARCHAR(50),
    @Title NVARCHAR(250),
    @Description NVARCHAR(1000) = NULL,
    @Value DECIMAL(18,2),
    @ExpiredDate DATETIME,
    @Status NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @Voucher_Id IS NULL
        THROW 62001, '@Voucher_Id cannot be NULL', 1;
    IF @CreateUser IS NULL
        THROW 62002, '@CreateUser cannot be NULL', 1;
    IF @CreateDate IS NULL
        THROW 62003, '@CreateDate cannot be NULL', 1;
    IF @App_Org_Id IS NULL
        THROW 62004, '@App_Org_Id cannot be NULL', 1;
    IF @VoucherCode IS NULL
        THROW 62005, '@VoucherCode cannot be NULL', 1;
    IF @VoucherCategory_Id IS NULL
        THROW 62006, '@VoucherCategory_Id cannot be NULL', 1;
    IF @Title IS NULL
        THROW 62007, '@Title cannot be NULL', 1;
    IF @Value IS NULL OR @Value <= 0
        THROW 62008, '@Value must be greater than 0', 1;
    IF @ExpiredDate IS NULL
        THROW 62009, '@ExpiredDate cannot be NULL', 1;
    IF @Status IS NULL
        THROW 62010, '@Status cannot be NULL', 1;

    INSERT INTO Biz.Voucher(
        Voucher_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, VoucherCode, VoucherCategory_Id, Title, Description,
        Value, ExpiredDate, Status
    )
    VALUES(
        @Voucher_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @VoucherCode, @VoucherCategory_Id, @Title, @Description,
        @Value, @ExpiredDate, @Status
    );
END
GO

-------------------------------------------------
-- UPDATE (theo style ISNULL)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_Update
    @Voucher_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50) = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @CreateDate DATETIME = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @VoucherCode NVARCHAR(50) = NULL,
    @VoucherCategory_Id NVARCHAR(50) = NULL,
    @Title NVARCHAR(250) = NULL,
    @Description NVARCHAR(1000) = NULL,
    @Value DECIMAL(18,2) = NULL,
    @ExpiredDate DATETIME = NULL,
    @Status NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @Voucher_Id IS NULL
        THROW 62011, '@Voucher_Id cannot be NULL', 1;

    UPDATE Biz.Voucher
    SET
        CreateUser         = ISNULL(@CreateUser, CreateUser),
        UpdateUser         = ISNULL(@UpdateUser, UpdateUser),
        CreateDate         = ISNULL(@CreateDate, CreateDate),
        UpdateDate         = ISNULL(@UpdateDate, GETDATE()),
        IsActive           = ISNULL(@IsActive, IsActive),
        App_Org_Id         = ISNULL(@App_Org_Id, App_Org_Id),
        VoucherCode        = ISNULL(@VoucherCode, VoucherCode),
        VoucherCategory_Id = ISNULL(@VoucherCategory_Id, VoucherCategory_Id),
        Title              = ISNULL(@Title, Title),
        Description        = ISNULL(@Description, Description),
        Value              = ISNULL(@Value, Value),
        ExpiredDate        = ISNULL(@ExpiredDate, ExpiredDate),
        Status             = ISNULL(@Status, Status)
    WHERE Voucher_Id = @Voucher_Id;
END
GO

-------------------------------------------------
-- DELETE (Soft Delete: set IsActive = 0)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_Delete
    @Voucher_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @Voucher_Id IS NULL
        THROW 62021, '@Voucher_Id cannot be NULL', 1;

    UPDATE Biz.Voucher
    SET IsActive = 0,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

-------------------------------------------------
-- GET BY ID
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_GetById
    @Voucher_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Biz.Voucher
    WHERE Voucher_Id = @Voucher_Id;
END
GO

-------------------------------------------------
-- GET PAGING (dùng ROW_NUMBER)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_GetPaging
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH CTE AS (
        SELECT 
            v.*,
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum
        FROM Biz.Voucher v
    )
    SELECT *
    FROM CTE
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                     AND (@PageNumber * @PageSize);
END
GO

-----------------------------------------------------------------Biz.VoucherBudget-----------------------------------------------------
-------------------------------------------------
-- INSERT
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherBudget_Insert
    @VoucherBudget_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = 1,
    @App_Org_Id NVARCHAR(50),
    @BudgetYear INT,
    @BudgetMonth INT,
    @TotalBudget DECIMAL(18,2),
    @UsedAmount DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherBudget_Id IS NULL
        THROW 63001, '@VoucherBudget_Id cannot be NULL', 1;
    IF @CreateUser IS NULL
        THROW 63002, '@CreateUser cannot be NULL', 1;
    IF @CreateDate IS NULL
        THROW 63003, '@CreateDate cannot be NULL', 1;
    IF @App_Org_Id IS NULL
        THROW 63004, '@App_Org_Id cannot be NULL', 1;
    IF @BudgetYear IS NULL OR @BudgetYear < 2000
        THROW 63005, '@BudgetYear must be >= 2000', 1;
    IF @BudgetMonth IS NULL OR @BudgetMonth < 0
        THROW 63006, '@BudgetMonth must be >= 0', 1;
    IF @TotalBudget IS NULL OR @TotalBudget < 0
        THROW 63007, '@TotalBudget must be >= 0', 1;

    INSERT INTO Biz.VoucherBudget (
        VoucherBudget_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, BudgetYear, BudgetMonth, TotalBudget, UsedAmount
    )
    VALUES (
        @VoucherBudget_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @BudgetYear, @BudgetMonth, @TotalBudget, @UsedAmount
    );
END
GO

-------------------------------------------------
-- UPDATE (theo style ISNULL)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherBudget_Update
    @VoucherBudget_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50) = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @CreateDate DATETIME = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @BudgetYear INT = NULL,
    @BudgetMonth INT = NULL,
    @TotalBudget DECIMAL(18,2) = NULL,
    @UsedAmount DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @VoucherBudget_Id IS NULL
        THROW 63011, '@VoucherBudget_Id cannot be NULL', 1;

    UPDATE Biz.VoucherBudget
    SET
        CreateUser  = ISNULL(@CreateUser, CreateUser),
        UpdateUser  = ISNULL(@UpdateUser, UpdateUser),
        CreateDate  = ISNULL(@CreateDate, CreateDate),
        UpdateDate  = ISNULL(@UpdateDate, GETDATE()),
        IsActive    = ISNULL(@IsActive, IsActive),
        App_Org_Id  = ISNULL(@App_Org_Id, App_Org_Id),
        BudgetYear  = ISNULL(@BudgetYear, BudgetYear),
        BudgetMonth = ISNULL(@BudgetMonth, BudgetMonth),
        TotalBudget = ISNULL(@TotalBudget, TotalBudget),
        UsedAmount  = ISNULL(@UsedAmount, UsedAmount)
    WHERE VoucherBudget_Id = @VoucherBudget_Id;
END
GO

-------------------------------------------------
-- DELETE (Soft Delete)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherBudget_Delete
    @VoucherBudget_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @VoucherBudget_Id IS NULL
        THROW 63021, '@VoucherBudget_Id cannot be NULL', 1;

    UPDATE Biz.VoucherBudget
    SET IsActive = 0,
        UpdateDate = GETDATE()
    WHERE VoucherBudget_Id = @VoucherBudget_Id;
END
GO

-------------------------------------------------
-- GET BY ID
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherBudget_GetById
    @VoucherBudget_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Biz.VoucherBudget
    WHERE VoucherBudget_Id = @VoucherBudget_Id;
END
GO

-------------------------------------------------
-- GET PAGING (ROW_NUMBER)
-------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherBudget_GetPaging
    @PageNumber INT,
    @PageSize INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH CTE AS (
        SELECT 
            vb.*,
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum
        FROM Biz.VoucherBudget vb
    )
    SELECT *
    FROM CTE
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1)
                     AND (@PageNumber * @PageSize);
END
GO
