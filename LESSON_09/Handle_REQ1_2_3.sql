--**Yêu cầu chi tiết Project**

--1. Tạo database cho project
--2. Thiết kế, tạo các bảng chức năng chung

--* **App_User**

--  * App_User_Id – nvarchar(50) – primary key
--  * CreateUser – nvarchar(50) – not null
--  * CreateDate – datetime – not null
--  * UpdateUser – nvarchar(50)
--  * UpdateDate – datetime
--  * IsActive – bit
--  * App_Org_Id – nvarchar(50) – not null – FK: App_Org
--  * UserName – nvarchar(50) – not null – unique
--  * FullName – nvarchar(250) – not null
--  * Email – nvarchar(250)
--  * EmailConfirmed – bit
--  * PhoneNumber – nvarchar(50)
--  * PhoneNumberConfirmed – bit
--  * AccessFailedCount – int
--  * IsAdmin – bit
--  * PasswordHash – nvarchar(250)
--  * LastLogin – datetime

--**App_Menu**

--* App_Menu_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* Name – nvarchar(250) – not null
--* TranslateKey – nvarchar(250)
--* Uri – nvarchar(250)
--* Icon – nvarchar(50)
--* DisplayOrder – int
--* ParentId – nvarchar(50)

--**App_Role**

--* App_Role_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* Code – nvarchar(50) – not null
--* Name – nvarchar(250) – not null
--* Description – nvarchar(1000)

--**App_Org**

--* App_Org_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* Code – nvarchar(50) – not null – unique
--* Name – nvarchar(250)
--* NameEn – nvarchar(250)
--* Type – nvarchar(50) – FK: App_Dic_Domain.App_Org.Type
--* Address – nvarchar(1000)
--* Description – nvarchar(1000)
--* ParentId – nvarchar(50)
--* DisplayOrder – int

--**App_Setting**

--* App_Setting_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* Code – nvarchar(50) – not null
--* Value – nvarchar(50) – not null
--* Description – nvarchar(1000)

--**App_File**

--* App_File_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* FilePath – nvarchar(550)
--* FileExt – nvarchar(50) – not null
--* FileName – nvarchar(250) – not null
--* FileSize – int – not null
--* FileContent – varbinary(max)
--* IsContentOnly – bit
--* IsTemp – bit

--**App_Dic_Domain**

--* App_Dic_Domain_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* DomainCode – nvarchar(50) – not null
--* ItemCode – nvarchar(50) – not null
--* ItemValue – nvarchar(50) – not null
--* DisplayOrder – int
--* Description – nvarchar(1000)

--**App_Sequence**

--* App_Sequence_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* UpdateUser – nvarchar(50)
--* UpdateDate – datetime
--* IsActive – bit
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* Code – nvarchar(50) – not null
--* Type – nvarchar(50)
--* Prefix – nvarchar(50)
--* Length – int
--* SeqValue – int
--* Description – nvarchar(1000)

--**App_Log**

--* App_Log_Id – nvarchar(50) – primary key
--* CreateUser – nvarchar(50) – not null
--* CreateDate – datetime – not null
--* App_Org_Id – nvarchar(50) – not null – FK: App_Org
--* TableName – nvarchar(50)
--* RowId – nvarchar(50)
--* Action – nvarchar(50)
--* OldValue – nvarchar(1000)
--* NewValue – nvarchar(1000)

--**App_Role_Menu_Ref**

--* App_Role_Menu_Ref_Id – nvarchar(50) – primary key
--* CreatedDate – datetime – not null
--* CreatedUser – nvarchar(50) – not null
--* App_Role_Id – nvarchar(250) – not null
--* App_Menu_Id – nvarchar(250) – not null

--**App_User_Org_Ref**

--* App_User_Org_Ref_Id – nvarchar(50) – primary key
--* CreatedDate – datetime – not null
--* CreatedUser – nvarchar(50) – not null
--* App_User_Id – nvarchar(250) – not null
--* App_Org_Id – nvarchar(250) – not null

--**App_User_Role_Ref**

--* App_User_Role_Ref_Id – nvarchar(50) – primary key
--* CreatedDate – datetime – not null
--* CreatedUser – nvarchar(50) – not null
--* App_User_Id – nvarchar(250) – not null
--* App_Role_Id – nvarchar(250) – not null

--3. Với mỗi bảng chức năng chung tạo các store nghiệp vụ thêm sửa xóa, get by id, get paging
--4. Viết một số store nghiệp vụ riêng
--   * Lấy dữ liệu menu tương ứng với App_User
--5. Thiết kế bảng dữ liệu nghiệp vụ EVoucher
--   * Nhân viên
--   * Danh mục loại voucher
--   * Danh sách voucher
--   * Quản lý ngân sách voucher
--6. Với mỗi bảng chức năng nghiệp vụ EVoucher tạo các store nghiệp vụ thêm sửa xóa, get by id, get paging
--7. Import dữ liệu nhân viên
--8. Import dữ liệu ngân sách
--9. Import dữ liệu voucher
--10. Viết procedure thực hiện chức năng phân bổ voucher
--11. Viết procedure thực hiện chức năng phân bổ mã voucher
--12. Viết procedure thực hiện nghiệp vụ sử dụng voucher
--13. Viết procedure báo cáo số lượng và giá trị voucher đã phân bổ theo tháng

DROP DATABASE IF EXISTS [02_Evoucher]
CREATE DATABASE [02_Evoucher]
ON
(
	NAME = 'Evoucher_DB',
	FILENAME = 'C:\00_DATA\04_DE_CODE\cole-data-engineer-bootcamp\LESSON_09\Evoucher_DB.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB)
LOG ON
(
	NAME = 'Evoucher_DB_LOG',
	FILENAME = 'C:\00_DATA\04_DE_CODE\cole-data-engineer-bootcamp\LESSON_09\Evoucher_DB.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE [02_Evoucher]
GO

-- CREATE SCHEMAS
CREATE SCHEMA Core;
GO

CREATE SCHEMA Ref;
GO

DROP TABLE IF EXISTS Core.App_Org
CREATE TABLE Core.App_Org
(
	App_Org_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	Code NVARCHAR(50) NOT NULL,
	Name NVARCHAR(250) NOT NULL,
	NameEn NVARCHAR(250) NOT NULL,
	Type NVARCHAR(50),
	Address NVARCHAR(1000),
	Description NVARCHAR(1000),
	ParentId NVARCHAR(50),
	DisplayOrder INT,
	CONSTRAINT UQ_App_Org_Code UNIQUE (Code)
)
GO

DROP TABLE IF EXISTS Core.App_User
CREATE TABLE Core.App_User
(
	App_User_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	UserName NVARCHAR(50) NOT NULL,
	FullName NVARCHAR(250) NOT NULL,
	Email NVARCHAR(250) CONSTRAINT CK_App_User_Email CHECK(
															Email LIKE '%_@__%.__%'
															AND Email NOT LIKE '% %'
															AND LEN(Email) - LEN(REPLACE(Email,'@','')) = 1
														),
	EmailConfirmed BIT,
	PhoneNumber VARCHAR(10) CONSTRAINT CK_App_User_PhoneNumber CHECK(
																		LEN(PhoneNumber) = 10
																		AND PhoneNumber NOT LIKE '%[^0-9]%'
																	  ),
	PhoneNumberConfirmed BIT,
	AccessFailedCount INT,
	IsAdmin BIT,
	PasswordHash nvarchar(250),
	LastLogin DATETIME
	CONSTRAINT UQ_App_User_UserName UNIQUE (UserName),
	CONSTRAINT FK_App_User_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Menu
CREATE TABLE Core.App_Menu
(
	App_Menu_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	Name NVARCHAR(250) NOT NULL,
	TranslateKey NVARCHAR(50),
	Uri NVARCHAR(50),
	Icon NVARCHAR(50),
	DisplayOrder INT,
	ParentId NVARCHAR(50),
	CONSTRAINT FK_App_Menu_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Role
CREATE TABLE Core.App_Role
(
	App_Role_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	Code NVARCHAR(50) NOT NULL,
	Name NVARCHAR(250) NOT NULL,
	Description NVARCHAR(1000),
	CONSTRAINT FK_App_Role_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Setting
CREATE TABLE Core.App_Setting
(
	App_Setting_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	Code NVARCHAR(50) NOT NULL,
	Value NVARCHAR(50) NOT NULL,
	Description NVARCHAR(1000),
	CONSTRAINT UQ_App_Setting_Code UNIQUE (Code),
	CONSTRAINT FK_App_Setting_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_File
CREATE TABLE Core.App_File
(
	App_File_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	FilePath NVARCHAR(250),
	FileExt NVARCHAR(50) NOT NULL,
	FileName NVARCHAR(250) NOT NULL,
	FileSize INT NOT NULL,
	FileContent VARBINARY(MAX),
	IsContentOnly BIT,
	IsTemp BIT,
	CONSTRAINT FK_App_File_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Dic_Domain
CREATE TABLE Core.App_Dic_Domain
(
	App_Dic_Domain_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	DomainCode NVARCHAR(50) NOT NULL,
	ItemCode NVARCHAR(50) NOT NULL,
	ItemValue NVARCHAR(50) NOT NULL,
	DisplayOrder INT,
	Description NVARCHAR(1000),
	CONSTRAINT FK_App_Dic_Domain_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Sequence
CREATE TABLE Core.App_Sequence
(
	App_Sequence_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	UpdateUser NVARCHAR(50),
	UpdateDate DATETIME,
	IsActive BIT,
	App_Org_Id NVARCHAR(50) NOT NULL,
	Code NVARCHAR(50) NOT NULL,
	Type NVARCHAR(50),
	Prefix NVARCHAR(50),
	Length INT,
	SeqValue INT,
	Description NVARCHAR(1000),
	CONSTRAINT FK_App_Sequence_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Core.App_Log
CREATE TABLE Core.App_Log
(
	App_Log_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	App_Org_Id NVARCHAR(50) NOT NULL,
	TableName NVARCHAR(50),
	RowId NVARCHAR(50),
	Action NVARCHAR(50),
	OldValue NVARCHAR(1000),
	NewValue NVARCHAR(1000),
	CONSTRAINT FK_App_Log_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION ON UPDATE CASCADE
)
GO

DROP TABLE IF EXISTS Ref.App_Role_Menu_Ref
CREATE TABLE Ref.App_Role_Menu_Ref
(
	App_Role_Menu_Ref_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	App_Role_Id NVARCHAR(50) NOT NULL,
	App_Menu_Id NVARCHAR(50) NOT NULL,
	CONSTRAINT FK_App_Role_Menu_Ref_App_Role_Id FOREIGN KEY(App_Role_Id) REFERENCES Core.App_Role(App_Role_Id) ON DELETE NO ACTION,
	CONSTRAINT FK_App_Role_Menu_Ref_App_Menu_Id FOREIGN KEY(App_Menu_Id) REFERENCES Core.App_Menu(App_Menu_Id) ON DELETE NO ACTION
)
GO

DROP TABLE IF EXISTS Ref.App_User_Org_Ref
CREATE TABLE Ref.App_User_Org_Ref
(
	App_User_Org_Ref_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	App_User_Id NVARCHAR(50) NOT NULL,
	App_Org_Id NVARCHAR(50) NOT NULL,
	CONSTRAINT FK_App_User_Org_Ref_App_User_Id FOREIGN KEY(App_User_Id) REFERENCES Core.App_User(App_User_Id) ON DELETE NO ACTION,
	CONSTRAINT FK_App_User_Org_Ref_App_Org_Id FOREIGN KEY(App_Org_Id) REFERENCES Core.App_Org(App_Org_Id) ON DELETE NO ACTION
)
GO

DROP TABLE IF EXISTS Ref.App_User_Role_Ref
CREATE TABLE Ref.App_User_Role_Ref
(
	App_User_Role_Ref_Id NVARCHAR(50) PRIMARY KEY,
	CreateUser NVARCHAR(50) NOT NULL,
	CreateDate DATETIME NOT NULL,
	App_User_Id NVARCHAR(50) NOT NULL,
	App_Role_Id NVARCHAR(50) NOT NULL,
	CONSTRAINT FK_App_User_Role_Ref_App_User_Id FOREIGN KEY(App_User_Id) REFERENCES Core.App_User(App_User_Id) ON DELETE NO ACTION,
	CONSTRAINT FK_App_User_Role_Ref_App_Role_Id FOREIGN KEY(App_Role_Id) REFERENCES Core.App_Role(App_Role_Id) ON DELETE NO ACTION
)
GO
--3. Với mỗi bảng chức năng chung tạo các store nghiệp vụ thêm sửa xóa, get by id, get paging
-------------------------------App_Org-----------------------------------------------------------
-- Insert
CREATE OR ALTER PROC [Core].[usp_App_Org_Insert]
	@App_Org_Id NVARCHAR(50),
	@CreateUser NVARCHAR(50),
	@CreateDate DATETIME,
	@UpdateUser NVARCHAR(50) = NULL,
	@UpdateDate DATETIME = NULL,
	@IsActive BIT = NULL,
	@Code NVARCHAR(50),
	@Name NVARCHAR(250),
	@NameEn NVARCHAR(250),
	@Type NVARCHAR(50) = NULL,
	@Address NVARCHAR(1000) = NULL,
	@Description NVARCHAR(1000) = NULL,
	@ParentId NVARCHAR(50) = NULL,
	@DisplayOrder INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Org_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @Code IS NULL THEN 5004
					WHEN @Name IS NULL THEN 5005
					WHEN @NameEn IS NULL THEN 5006
				END,

		@ErrMsg = CASE
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @Code IS NULL THEN '@Code cannot be NULL'
					WHEN @Name IS NULL THEN '@Name cannot be NULL'
					WHEN @NameEn IS NULL THEN '@NameEn cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

	INSERT INTO [Core].[App_Org](App_Org_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive, Code, Name, NameEn, Type, Address, Description, ParentId, DisplayOrder)
	VALUES(@App_Org_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive, @Code, @Name, @NameEn, @Type, @Address, @Description, @ParentId, @DisplayOrder);
END;
GO

-- Update
CREATE OR ALTER PROC [Core].[usp_App_Org_Update]
	@App_Org_Id NVARCHAR(50),
	@CreateUser NVARCHAR(50) = NULL,
	@UpdateUser NVARCHAR(50) = NULL,
	@UpdateDate DATETIME = NULL,
	@IsActive BIT = NULL,
	@Code NVARCHAR(50) = NULL,
	@Name NVARCHAR(250) = NULL,
	@NameEn NVARCHAR(250) = NULL,
	@Type NVARCHAR(50) = NULL,
	@Address NVARCHAR(1000) = NULL,
	@Description NVARCHAR(1000) = NULL,
	@ParentId NVARCHAR(50) = NULL,
	@DisplayOrder INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	IF @App_Org_Id IS NULL
		THROW 50001, '@App_Org_Id cannot be NULL', 1;

	UPDATE [Core].[App_Org]
	SET
		[CreateUser] = ISNULL(@CreateUser, [CreateUser]),
		[UpdateUser] = ISNULL(@UpdateUser, [UpdateUser]),
		[UpdateDate] = ISNULL(@UpdateDate, GETDATE()),
		[IsActive] = ISNULL(@IsActive, [IsActive]),
		[Code] = ISNULL(@Code, [Code]),
		[Name] = ISNULL(@Name, [Name]),
		[NameEn] = ISNULL(@NameEn, [NameEn]),
		[Type] = ISNULL(@Type, [Type]),
		[Address] = ISNULL(@Address, [Address]),
		[Description] = ISNULL(@Description, [Description]),
		[ParentId] = ISNULL(@ParentId, [ParentId]),
		[DisplayOrder] = ISNULL(@ParentId, [DisplayOrder])
	WHERE
		[App_Org_Id] = @App_Org_Id
END;
GO

-- DELETE
CREATE OR ALTER PROC [Core].[usp_App_Org_Delete]
	@App_Org_Id NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	-- Validate Input
	IF @App_Org_Id IS NULL
		THROW 50001, '@App_Org_Id cannot be NULL', 1;

	DELETE FROM [Core].[App_Org]
	WHERE [App_Org_Id] = @App_Org_Id
END;
GO

-- Get By Id
CREATE OR ALTER PROC [Core].[usp_App_Org_GetById]
	@App_Org_Id NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	-- Validate Input
	IF @App_Org_Id IS NULL
		THROW 50001, '@App_Org_Id cannot be NULL', 1;

	SELECT
		 *
	FROM [Core].[App_Org]
	WHERE [App_Org_Id] = @App_Org_Id
END;
GO

-- Get Paging
CREATE OR ALTER PROC [Core].[usp_App_Org_GetPaging]
	@PageNumber INT,
	@PageSize INT,
	@SearchByCode NVARCHAR(250) = NULL,
	@SearchByName NVARCHAR(250) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    SET NOCOUNT ON;
	-- Lấy dữ liệu có phân trang
	WITH cteGetPagging AS
	(
		SELECT
			ROW_NUMBER() OVER (ORDER BY [CreateDate] DESC) AS RowNum
			, *
		FROM [Core].[App_Org]
		WHERE 
			@SearchByCode IS NULL
			OR @SearchByName IS NULL
			OR [Name] LIKE '%' + @SearchByName + '%'
			OR [Code] LIKE '%' + @SearchByCode + '%'
	)
	SELECT
		o.*
	FROM cteGetPagging o
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_User-----------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.usp_App_User_Insert
    @App_User_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @UserName NVARCHAR(50),
    @FullName NVARCHAR(250),
    @Email NVARCHAR(250) = NULL,
    @EmailConfirmed BIT = NULL,
    @PhoneNumber NVARCHAR(50) = NULL,
    @PhoneNumberConfirmed BIT = NULL,
    @AccessFailedCount INT = NULL,
    @IsAdmin BIT = NULL,
    @PasswordHash NVARCHAR(250) = NULL,
    @LastLogin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_User_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @UserName IS NULL THEN 5005
					WHEN @FullName IS NULL THEN 5006
				END,

		@ErrMsg = CASE
					WHEN @App_User_Id IS NULL THEN '@App_User_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @UserName IS NULL THEN '@UserName cannot be NULL'
					WHEN @FullName IS NULL THEN '@FullName cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_User (
        App_User_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, UserName, FullName, Email, EmailConfirmed, PhoneNumber,
        PhoneNumberConfirmed, AccessFailedCount, IsAdmin, PasswordHash, LastLogin
    )
    VALUES (
        @App_User_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @UserName, @FullName, @Email, @EmailConfirmed, @PhoneNumber,
        @PhoneNumberConfirmed, @AccessFailedCount, @IsAdmin, @PasswordHash, @LastLogin
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.usp_App_User_Update
    @App_User_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @UserName NVARCHAR(50) = NULL,
    @FullName NVARCHAR(250) = NULL,
    @Email NVARCHAR(250) = NULL,
    @EmailConfirmed BIT = NULL,
    @PhoneNumber NVARCHAR(50) = NULL,
    @PhoneNumberConfirmed BIT = NULL,
    @AccessFailedCount INT = NULL,
    @IsAdmin BIT = NULL,
    @PasswordHash NVARCHAR(250) = NULL,
    @LastLogin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
	IF @App_User_Id IS NULL
		THROW 50001, '@App_User_Id cannot be NULL', 1;

    UPDATE Core.App_User
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        UserName = ISNULL(@UserName, UserName),
        FullName = ISNULL(@FullName, FullName),
        Email = ISNULL(@Email, Email),
        EmailConfirmed = ISNULL(@EmailConfirmed, EmailConfirmed),
        PhoneNumber = ISNULL(@PhoneNumber, PhoneNumber),
        PhoneNumberConfirmed = ISNULL(@PhoneNumberConfirmed, PhoneNumberConfirmed),
        AccessFailedCount = ISNULL(@AccessFailedCount, AccessFailedCount),
        IsAdmin = ISNULL(@IsAdmin, IsAdmin),
        PasswordHash = ISNULL(@PasswordHash, PasswordHash),
        LastLogin = ISNULL(@LastLogin, LastLogin)
    WHERE
		App_User_Id = @App_User_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.usp_App_User_Delete
    @App_User_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Core.App_User
    WHERE App_User_Id = @App_User_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.usp_App_User_GetById
    @App_User_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Core.App_User
    WHERE App_User_Id = @App_User_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.usp_App_User_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH User_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_User
        WHERE (@Search IS NULL
               OR UserName LIKE '%' + @Search + '%'
               OR FullName LIKE '%' + @Search + '%'
               OR Email LIKE '%' + @Search + '%')
    )
    SELECT 
        u.*
    FROM User_CTE u
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

---------------------------------------------App_Menu--------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.usp_App_Menu_Insert
    @App_Menu_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @Name NVARCHAR(250),
    @TranslateKey NVARCHAR(250) = NULL,
    @Uri NVARCHAR(250) = NULL,
    @Icon NVARCHAR(50) = NULL,
    @DisplayOrder INT = NULL,
    @ParentId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Menu_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @Name IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @App_Menu_Id IS NULL THEN '@App_Menu_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @Name IS NULL THEN '@Name cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Menu (
        App_Menu_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, Name, TranslateKey, Uri, Icon, DisplayOrder, ParentId
    )
    VALUES (
        @App_Menu_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @Name, @TranslateKey, @Uri, @Icon, @DisplayOrder, @ParentId
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.usp_App_Menu_Update
    @App_Menu_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @Name NVARCHAR(250) = NULL,
    @TranslateKey NVARCHAR(250) = NULL,
    @Uri NVARCHAR(250) = NULL,
    @Icon NVARCHAR(50) = NULL,
    @DisplayOrder INT = NULL,
    @ParentId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Menu_Id IS NULL
		THROW 50001, '@App_Menu_Id cannot be NULL', 1;

    UPDATE Core.App_Menu
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        Name = ISNULL(@Name, Name),
        TranslateKey = ISNULL(@TranslateKey, TranslateKey),
        Uri = ISNULL(@Uri, Uri),
        Icon = ISNULL(@Icon, Icon),
        DisplayOrder = ISNULL(@DisplayOrder, DisplayOrder),
        ParentId = ISNULL(@ParentId, ParentId)
    WHERE App_Menu_Id = @App_Menu_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.usp_App_Menu_Delete
    @App_Menu_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	IF @App_Menu_Id IS NULL
		THROW 50001, '@App_Menu_Id cannot be NULL', 1;

    DELETE FROM Core.App_Menu
    WHERE App_Menu_Id = @App_Menu_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.usp_App_Menu_GetById
    @App_Menu_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM Core.App_Menu
    WHERE App_Menu_Id = @App_Menu_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.usp_App_Menu_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Menu_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Menu
        WHERE (@Search IS NULL
               OR Name LIKE '%' + @Search + '%'
               OR TranslateKey LIKE '%' + @Search + '%'
               OR Uri LIKE '%' + @Search + '%')
    )
    SELECT 
        m.*
    FROM Menu_CTE m
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Role--------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_Role_Insert
    @App_Role_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @Code NVARCHAR(50),
    @Name NVARCHAR(250),
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Role_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @Code IS NULL THEN 5005
					WHEN @Name IS NULL THEN 5006
				END,
		@ErrMsg = CASE
					WHEN @App_Role_Id IS NULL THEN '@App_Menu_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @Code IS NULL THEN '@Code cannot be NULL'
					WHEN @Name IS NULL THEN '@Name cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Role (
        App_Role_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, Code, Name, Description
    )
    VALUES (
        @App_Role_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @Code, @Name, @Description
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_Role_Update
    @App_Role_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @Code NVARCHAR(50) = NULL,
    @Name NVARCHAR(250) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Role_Id IS NULL
		THROW 50001, '@App_Role_Id cannot be NULL', 1;

    UPDATE Core.App_Role
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        Code = ISNULL(@Code, Code),
        Name = ISNULL(@Name, Name),
        Description = ISNULL(@Description, Description)
    WHERE App_Role_Id = @App_Role_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_Role_Delete
    @App_Role_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Role_Id IS NULL
		THROW 50001, '@App_Role_Id cannot be NULL', 1;

    DELETE FROM Core.App_Role
    WHERE App_Role_Id = @App_Role_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_Role_GetById
    @App_Role_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Role_Id IS NULL
		THROW 50001, '@App_Role_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_Role
    WHERE App_Role_Id = @App_Role_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_Role_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;

	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Role_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Role
        WHERE (@Search IS NULL
               OR Code LIKE '%' + @Search + '%'
               OR Name LIKE '%' + @Search + '%'
               OR Description LIKE '%' + @Search + '%')
    )
    SELECT 
        r.*
    FROM Role_CTE r
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Setting--------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_Setting_Insert
    @App_Setting_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @Code NVARCHAR(50),
    @Value NVARCHAR(50),
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Setting_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @Code IS NULL THEN 5005
					WHEN @Value IS NULL THEN 5006
				END,
		@ErrMsg = CASE
					WHEN @App_Setting_Id IS NULL THEN '@App_Setting_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @Code IS NULL THEN '@Code cannot be NULL'
					WHEN @Value IS NULL THEN '@Value cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Setting (
        App_Setting_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, Code, Value, Description
    )
    VALUES (
        @App_Setting_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @Code, @Value, @Description
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_Setting_Update
    @App_Setting_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @Code NVARCHAR(50) = NULL,
    @Value NVARCHAR(50) = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Setting_Id IS NULL
		THROW 50001, '@App_Setting_Id cannot be NULL', 1;

    UPDATE Core.App_Setting
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        Code = ISNULL(@Code, Code),
        Value = ISNULL(@Value, Value),
        Description = ISNULL(@Description, Description)
    WHERE App_Setting_Id = @App_Setting_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_Setting_Delete
    @App_Setting_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Setting_Id IS NULL
		THROW 50001, '@App_Setting_Id cannot be NULL', 1;

    DELETE FROM Core.App_Setting
    WHERE App_Setting_Id = @App_Setting_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_Setting_GetById
    @App_Setting_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Setting_Id IS NULL
		THROW 50001, '@App_Setting_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_Setting
    WHERE App_Setting_Id = @App_Setting_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_Setting_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Setting_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Setting
        WHERE (@Search IS NULL
               OR Code LIKE '%' + @Search + '%'
               OR Value LIKE '%' + @Search + '%'
               OR Description LIKE '%' + @Search + '%')
    )
    SELECT 
        s.*
    FROM Setting_CTE s
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_File--------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_File_Insert
    @App_File_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @FilePath NVARCHAR(250) = NULL,
    @FileExt NVARCHAR(50),
    @FileName NVARCHAR(250),
    @FileSize INT,
    @FileContent VARBINARY(MAX) = NULL,
    @IsContentOnly BIT = NULL,
    @IsTemp BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_File_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @FileExt IS NULL THEN 5005
					WHEN @FileName IS NULL THEN 5006
					WHEN @FileSize IS NULL THEN 5007
				END,
		@ErrMsg = CASE
					WHEN @App_File_Id IS NULL THEN '@App_File_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @FileExt IS NULL THEN '@FileExt cannot be NULL'
					WHEN @FileName IS NULL THEN '@FileName cannot be NULL'
					WHEN @FileSize IS NULL THEN '@FileSize cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_File (
        App_File_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, FilePath, FileExt, FileName, FileSize, FileContent,
        IsContentOnly, IsTemp
    )
    VALUES (
        @App_File_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @FilePath, @FileExt, @FileName, @FileSize, @FileContent,
        @IsContentOnly, @IsTemp
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_File_Update
    @App_File_Id NVARCHAR(50),
	@CreateUser NVARCHAR(50) = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @FilePath NVARCHAR(250) = NULL,
    @FileExt NVARCHAR(50) = NULL,
    @FileName NVARCHAR(250) = NULL,
    @FileSize INT = NULL,
    @FileContent VARBINARY(MAX) = NULL,
    @IsContentOnly BIT = NULL,
    @IsTemp BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_File_Id IS NULL
		THROW 50001, '@App_File_Id cannot be NULL', 1;

    UPDATE Core.App_File
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        FilePath = ISNULL(@FilePath, FilePath),
        FileExt = ISNULL(@FileExt, FileExt),
        FileName = ISNULL(@FileName, FileName),
        FileSize = ISNULL(@FileSize, FileSize),
        FileContent = ISNULL(@FileContent, FileContent),
        IsContentOnly = ISNULL(@IsContentOnly, IsContentOnly),
        IsTemp = ISNULL(@IsTemp, IsTemp)
    WHERE App_File_Id = @App_File_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_File_Delete
    @App_File_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_File_Id IS NULL
		THROW 50001, '@App_File_Id cannot be NULL', 1;

    DELETE FROM Core.App_File
    WHERE App_File_Id = @App_File_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_File_GetById
    @App_File_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_File_Id IS NULL
		THROW 50001, '@App_File_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_File
    WHERE App_File_Id = @App_File_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_File_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH File_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_File
        WHERE (@Search IS NULL
               OR FileName LIKE '%' + @Search + '%'
               OR FileExt LIKE '%' + @Search + '%'
               OR FilePath LIKE '%' + @Search + '%')
    )
    SELECT 
        f.*
    FROM File_CTE f
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Dic_Domain--------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_Dic_Domain_Insert
    @App_Dic_Domain_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50),
    @DomainCode NVARCHAR(50),
    @ItemCode NVARCHAR(50),
    @ItemValue NVARCHAR(50),
    @DisplayOrder INT = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Dic_Domain_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @DomainCode IS NULL THEN 5005
					WHEN @ItemCode IS NULL THEN 5006
					WHEN @ItemValue IS NULL THEN 5007
				END,
		@ErrMsg = CASE
					WHEN @App_Dic_Domain_Id IS NULL THEN '@App_Dic_Domain_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @DomainCode IS NULL THEN '@DomainCode cannot be NULL'
					WHEN @ItemCode IS NULL THEN '@ItemCode cannot be NULL'
					WHEN @ItemValue IS NULL THEN '@ItemValue cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Dic_Domain (
        App_Dic_Domain_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, DomainCode, ItemCode, ItemValue, DisplayOrder, Description
    )
    VALUES (
        @App_Dic_Domain_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @DomainCode, @ItemCode, @ItemValue, @DisplayOrder, @Description
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_Dic_Domain_Update
    @App_Dic_Domain_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @DomainCode NVARCHAR(50) = NULL,
    @ItemCode NVARCHAR(50) = NULL,
    @ItemValue NVARCHAR(50) = NULL,
    @DisplayOrder INT = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Dic_Domain_Id IS NULL
		THROW 50001, '@App_Dic_Domain_Id cannot be NULL', 1;

    UPDATE Core.App_Dic_Domain
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        DomainCode = ISNULL(@DomainCode, DomainCode),
        ItemCode = ISNULL(@ItemCode, ItemCode),
        ItemValue = ISNULL(@ItemValue, ItemValue),
        DisplayOrder = ISNULL(@DisplayOrder, DisplayOrder),
        Description = ISNULL(@Description, Description)
    WHERE App_Dic_Domain_Id = @App_Dic_Domain_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_Dic_Domain_Delete
    @App_Dic_Domain_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Dic_Domain_Id IS NULL
		THROW 50001, '@App_Dic_Domain_Id cannot be NULL', 1;

    DELETE FROM Core.App_Dic_Domain
    WHERE App_Dic_Domain_Id = @App_Dic_Domain_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_Dic_Domain_GetById
    @App_Dic_Domain_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Dic_Domain_Id IS NULL
		THROW 50001, '@App_Dic_Domain_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_Dic_Domain
    WHERE App_Dic_Domain_Id = @App_Dic_Domain_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_Dic_Domain_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL,
    @Domain NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Dic_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY DisplayOrder ASC, CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Dic_Domain
        WHERE (@Search IS NULL
               OR ItemCode LIKE '%' + @Search + '%'
               OR ItemValue LIKE '%' + @Search + '%'
               OR Description LIKE '%' + @Search + '%')
          AND (@Domain IS NULL OR DomainCode = @Domain)
    )
    SELECT 
        d.*
    FROM Dic_CTE d
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Sequence----------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_Sequence_Insert
    @App_Sequence_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME = NULL,
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = 1,
    @App_Org_Id NVARCHAR(50) = NULL,
    @Code NVARCHAR(50),
    @Type NVARCHAR(50) = NULL,
    @Prefix NVARCHAR(50) = NULL,
    @Length INT = NULL,
    @SeqValue INT = 0,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Sequence_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
					WHEN @Code IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @App_Sequence_Id IS NULL THEN '@App_Sequence_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
					WHEN @Code IS NULL THEN '@Code cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Sequence (
        App_Sequence_Id, CreateUser, CreateDate, UpdateUser, UpdateDate, IsActive,
        App_Org_Id, Code, Type, Prefix, Length, SeqValue, Description
    )
    VALUES (
        @App_Sequence_Id, @CreateUser, @CreateDate, @UpdateUser, @UpdateDate, @IsActive,
        @App_Org_Id, @Code, @Type, @Prefix, @Length, @SeqValue, @Description
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_Sequence_Update
    @App_Sequence_Id NVARCHAR(50),
    @UpdateUser NVARCHAR(50) = NULL,
    @UpdateDate DATETIME = NULL,
    @IsActive BIT = NULL,
    @App_Org_Id NVARCHAR(50) = NULL,
    @Code NVARCHAR(50) = NULL,
    @Type NVARCHAR(50) = NULL,
    @Prefix NVARCHAR(50) = NULL,
    @Length INT = NULL,
    @SeqValue INT = NULL,
    @Description NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Sequence_Id IS NULL
		THROW 50001, '@App_Sequence_Id cannot be NULL', 1;

    UPDATE Core.App_Sequence
    SET
        UpdateUser = ISNULL(@UpdateUser, UpdateUser),
        UpdateDate = ISNULL(@UpdateDate, GETDATE()),
        IsActive = ISNULL(@IsActive, IsActive),
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        Code = ISNULL(@Code, Code),
        Type = ISNULL(@Type, Type),
        Prefix = ISNULL(@Prefix, Prefix),
        Length = ISNULL(@Length, Length),
        SeqValue = ISNULL(@SeqValue, SeqValue),
        Description = ISNULL(@Description, Description)
    WHERE App_Sequence_Id = @App_Sequence_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_Sequence_Delete
    @App_Sequence_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Sequence_Id IS NULL
		THROW 50001, '@App_Sequence_Id cannot be NULL', 1;

    DELETE FROM Core.App_Sequence
    WHERE App_Sequence_Id = @App_Sequence_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_Sequence_GetById
    @App_Sequence_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Sequence_Id IS NULL
		THROW 50001, '@App_Sequence_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_Sequence
    WHERE App_Sequence_Id = @App_Sequence_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_Sequence_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Seq_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Sequence
        WHERE (@Search IS NULL
               OR Code LIKE '%' + @Search + '%'
               OR Prefix LIKE '%' + @Search + '%'
               OR Description LIKE '%' + @Search + '%')
    )
    SELECT 
        s.*
    FROM Seq_CTE s
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Log------------------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Core.sp_App_Log_Insert
    @App_Log_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @App_Org_Id NVARCHAR(50),
    @TableName NVARCHAR(50) = NULL,
    @RowId NVARCHAR(50) = NULL,
    @Action NVARCHAR(50) = NULL,
    @OldValue NVARCHAR(1000) = NULL,
    @NewValue NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Log_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Org_Id IS NULL THEN 5004
				END,
		@ErrMsg = CASE
					WHEN @App_Log_Id IS NULL THEN '@App_Log_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Core.App_Log (
        App_Log_Id, CreateUser, CreateDate, App_Org_Id,
        TableName, RowId, Action, OldValue, NewValue
    )
    VALUES (
        @App_Log_Id, @CreateUser, @CreateDate, @App_Org_Id,
        @TableName, @RowId, @Action, @OldValue, @NewValue
    );
END;
GO

-- Update
CREATE OR ALTER PROCEDURE Core.sp_App_Log_Update
    @App_Log_Id NVARCHAR(50),
    @App_Org_Id NVARCHAR(50) = NULL,
    @TableName NVARCHAR(50) = NULL,
    @RowId NVARCHAR(50) = NULL,
    @Action NVARCHAR(50) = NULL,
    @OldValue NVARCHAR(1000) = NULL,
    @NewValue NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Log_Id IS NULL
		THROW 50001, '@App_Log_Id cannot be NULL', 1;

    UPDATE Core.App_Log
    SET
        App_Org_Id = ISNULL(@App_Org_Id, App_Org_Id),
        TableName = ISNULL(@TableName, TableName),
        RowId = ISNULL(@RowId, RowId),
        Action = ISNULL(@Action, Action),
        OldValue = ISNULL(@OldValue, OldValue),
        NewValue = ISNULL(@NewValue, NewValue)
    WHERE App_Log_Id = @App_Log_Id;
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Core.sp_App_Log_Delete
    @App_Log_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Log_Id IS NULL
		THROW 50001, '@App_Log_Id cannot be NULL', 1;

    DELETE FROM Core.App_Log
    WHERE App_Log_Id = @App_Log_Id;
END;
GO

-- Get By Id
CREATE OR ALTER PROCEDURE Core.sp_App_Log_GetById
    @App_Log_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Log_Id IS NULL
		THROW 50001, '@App_Log_Id cannot be NULL', 1;

    SELECT *
    FROM Core.App_Log
    WHERE App_Log_Id = @App_Log_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Core.sp_App_Log_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @Search NVARCHAR(250) = NULL,
    @Table NVARCHAR(50) = NULL,
    @Action NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH Log_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Core.App_Log
        WHERE (@Search IS NULL
               OR OldValue LIKE '%' + @Search + '%'
               OR NewValue LIKE '%' + @Search + '%')
          AND (@Table IS NULL OR TableName = @Table)
          AND (@Action IS NULL OR Action = @Action)
    )
    SELECT 
        l.*
    FROM Log_CTE l
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_Role_Menu_Ref------------------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Ref.sp_App_Role_Menu_Ref_Insert
    @App_Role_Menu_Ref_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME,
    @App_Role_Id NVARCHAR(50),
    @App_Menu_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_Role_Menu_Ref_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_Role_Id IS NULL THEN 5004
					WHEN @App_Menu_Id IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @App_Role_Menu_Ref_Id IS NULL THEN '@App_Role_Menu_Ref_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_Role_Id IS NULL THEN '@App_Role_Id cannot be NULL'
					WHEN @App_Menu_Id IS NULL THEN '@App_Menu_Id cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Ref.App_Role_Menu_Ref (
        App_Role_Menu_Ref_Id, CreateUser, CreateDate, App_Role_Id, App_Menu_Id
    )
    VALUES (
        @App_Role_Menu_Ref_Id, @CreateUser, @CreateDate, @App_Role_Id, @App_Menu_Id
    );
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Ref.sp_App_Role_Menu_Ref_Delete
    @App_Role_Menu_Ref_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Role_Menu_Ref_Id IS NULL
		THROW 50001, '@App_Role_Menu_Ref_Id cannot be NULL', 1;

    DELETE FROM Ref.App_Role_Menu_Ref
    WHERE App_Role_Menu_Ref_Id = @App_Role_Menu_Ref_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Ref.sp_App_Role_Menu_Ref_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @RoleId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH RM_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Ref.App_Role_Menu_Ref
        WHERE (@RoleId IS NULL OR App_Role_Id = @RoleId)
    )
    SELECT 
        rm.*
    FROM RM_CTE rm
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_User_Org_Ref------------------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Org_Ref_Insert
    @App_User_Org_Ref_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME = NULL,
    @App_User_Id NVARCHAR(50),
    @App_Org_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_User_Org_Ref_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_User_Id IS NULL THEN 5004
					WHEN @App_Org_Id IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @App_User_Org_Ref_Id IS NULL THEN '@App_User_Org_Ref_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_User_Id IS NULL THEN '@App_User_Id cannot be NULL'
					WHEN @App_Org_Id IS NULL THEN '@App_Org_Id cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Ref.App_User_Org_Ref (
        App_User_Org_Ref_Id, CreateUser, CreateDate, App_User_Id, App_Org_Id
    )
    VALUES (
        @App_User_Org_Ref_Id, @CreateUser, @CreateDate, @App_User_Id, @App_Org_Id
    );
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Org_Ref_Delete
    @App_User_Org_Ref_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_User_Org_Ref_Id IS NULL
		THROW 50001, '@App_Role_Menu_Ref_Id cannot be NULL', 1;

    DELETE FROM Ref.App_User_Org_Ref
    WHERE App_User_Org_Ref_Id = @App_User_Org_Ref_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Org_Ref_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @UserId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH UO_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Ref.App_User_Org_Ref
        WHERE (@UserId IS NULL OR App_User_Id = @UserId)
    )
    SELECT 
        uo.*
    FROM UO_CTE uo
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO

-------------------------------App_User_Role_Ref------------------------------------------------------------------------------
-- Insert
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Role_Ref_Insert
    @App_User_Role_Ref_Id NVARCHAR(50),
    @CreateUser NVARCHAR(50),
    @CreateDate DATETIME = NULL,
    @App_User_Id NVARCHAR(50),
    @App_Role_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @App_User_Role_Ref_Id IS NULL THEN 5001
					WHEN @CreateUser IS NULL THEN 5002
					WHEN @CreateDate IS NULL THEN 5003
					WHEN @App_User_Id IS NULL THEN 5004
					WHEN @App_Role_Id IS NULL THEN 5005
				END,
		@ErrMsg = CASE
					WHEN @App_User_Role_Ref_Id IS NULL THEN '@App_User_Role_Ref_Id cannot be NULL'
					WHEN @CreateUser IS NULL THEN '@CreateUser cannot be NULL'
					WHEN @CreateDate IS NULL THEN '@CreateDate cannot be NULL'
					WHEN @App_User_Id IS NULL THEN '@App_User_Id cannot be NULL'
					WHEN @App_Role_Id IS NULL THEN '@App_Role_Id cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    INSERT INTO Ref.App_User_Role_Ref (
        App_User_Role_Ref_Id, CreateUser, CreateDate, App_User_Id, App_Role_Id
    )
    VALUES (
        @App_User_Role_Ref_Id, @CreateUser, @CreateDate, @App_User_Id, @App_Role_Id
    );
END;
GO

-- DELETE
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Role_Ref_Delete
    @App_User_Role_Ref_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_User_Role_Ref_Id IS NULL
		THROW 50001, '@App_Role_Menu_Ref_Id cannot be NULL', 1;

    DELETE FROM Ref.App_User_Role_Ref
    WHERE App_User_Role_Ref_Id = @App_User_Role_Ref_Id;
END;
GO

-- Get Paging
CREATE OR ALTER PROCEDURE Ref.sp_App_User_Role_Ref_GetPaging
    @PageNumber INT,
    @PageSize INT,
    @UserId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

	-- Validate Input
	IF @PageNumber IS NULL
		THROW 50001, '@PageNumber cannot be NULL', 1;
	IF @PageSize IS NULL
		THROW 50002, '@PageSize cannot be NULL', 1;

    ;WITH UR_CTE AS (
        SELECT 
            ROW_NUMBER() OVER (ORDER BY CreateDate DESC) AS RowNum,
            *
        FROM Ref.App_User_Role_Ref
        WHERE (@UserId IS NULL OR App_User_Id = @UserId)
    )
    SELECT 
        ur.*
    FROM UR_CTE ur
    WHERE RowNum BETWEEN ((@PageNumber-1)*@PageSize + 1)
                     AND (@PageNumber*@PageSize);
END;
GO


--DROP PROCEDURE IF EXISTS [Core].[uspDeleteAppOrg]
--DROP PROCEDURE IF EXISTS [Core].[uspGetPaggingAppOrg]
--DROP PROCEDURE IF EXISTS [Core].[uspInsertAppOrg]
--DROP PROCEDURE IF EXISTS [Core].[uspUpdateAppOrg]