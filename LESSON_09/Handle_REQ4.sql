USE [02_Evoucher]
GO

--4. Viết một số store nghiệp vụ riêng
--    Lấy dữ liệu menu tương ứng với App_User

--* **JOIN qua Role/Ref (Role-Based Access Control - RBAC):**

--  * Linh hoạt hơn, user trong cùng một Org có thể có quyền khác nhau.
--  * Dùng trong hầu hết hệ thống phân quyền hiện đại.

--* **JOIN trực tiếp qua Org:**

--  * Đơn giản, nhanh.
--  * Nhưng tất cả user trong cùng một Org sẽ có chung menu.
--  * Không hỗ trợ granular permission (ví dụ cùng Org nhưng khác Role).

CREATE OR ALTER PROC Core.sp_GetMenuByUser
	@App_User_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_User_Id IS NULL
		THROW 50001, '@App_User_Id cannot be NULL', 1;

	SELECT
		m.App_Menu_Id
		, m.CreateUser
		, m.Name
		, m.Uri
		, m.Icon
		, m.DisplayOrder
		, m.ParentId
	FROM
		[Core].[App_User] u
		JOIN [Ref].[App_User_Role_Ref] ur ON u.App_User_Id = ur.App_User_Id
		JOIN [Ref].[App_Role_Menu_Ref] rm ON ur.App_Role_Id = rm.App_Role_Id
		JOIN [Core].[App_Menu] m ON rm.App_Menu_Id = m.App_Menu_Id
	WHERE
		u.App_User_Id = @App_User_Id
		AND m.IsActive = 1
		AND u.IsActive = 1
END
GO

-- GetUsersByRole
CREATE OR ALTER PROC Core.sp_GetUsersByRole
	@App_Role_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_Role_Id IS NULL
		THROW 50001, '@App_Role_Id cannot be NULL', 1;

	SELECT
		u.App_User_Id
		, u.CreateUser
		, u.UserName
		, u.FullName
		, u.Email
		, u.PhoneNumber
		, u.IsAdmin
	FROM
		[Core].[App_Role] r
		JOIN [Ref].[App_User_Role_Ref] ur ON r.App_Role_Id = ur.App_Role_Id
		JOIN [Core].[App_User] u ON u.App_User_Id = ur.App_User_Id
	WHERE
		r.App_Role_Id = @App_Role_Id
		AND r.IsActive = 1
		AND u.IsActive = 1
END
GO

-- GetRolesByUser
CREATE OR ALTER PROC Core.sp_GetRolesByUser
	@App_User_Id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @App_User_Id IS NULL
		THROW 50001, '@App_User_Id cannot be NULL', 1;

	SELECT
		r.App_Role_Id
		, r.Name
		, r.CreateDate
		, r.CreateUser
		, r.Code
	FROM
		[Core].[App_Role] r
		JOIN [Ref].[App_User_Role_Ref] ur ON ur.App_Role_Id = r.App_Role_Id
		JOIN [Core].[App_User] u ON u.App_User_Id = ur.App_User_Id		
	WHERE
		u.App_User_Id = @App_User_Id
		AND u.IsActive = 1
		AND r.IsActive = 1
END
GO