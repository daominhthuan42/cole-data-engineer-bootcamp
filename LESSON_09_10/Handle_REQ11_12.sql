/*
11. Viết procedure thực hiện chức năng phân bổ mã voucher

* **Voucher** trong hệ thống hiện giờ là **tài nguyên gốc** (có `Voucher_Id`, `VoucherCode`, `Category`, `Value`, `Status` …).
* Khi cần **phân bổ cho user** (hoặc employee) thì mình **không nên ghi trực tiếp vào bảng `Biz.Voucher`**, mà nên có **bảng quan hệ trung gian** để quản lý lịch sử và trạng thái phân bổ.

### 🛠 Cấu trúc đề xuất

1. **Biz.VoucherAllocation**:

   * `VoucherAllocation_Id` (PK)
   * `Voucher_Id` (FK → Biz.Voucher)
   * `User_Id`
   * `Employee_Id`
   * `AllocateDate`
   * `AllocatedBy`
   * `Status` (Allocated, Used, Returned, …)

👉 Bảng này cho phép:

* Một voucher có thể gắn cho nhiều user (theo thời gian, vì sau khi trả về có thể cấp lại).
* Một user có thể có nhiều voucher.
* Mình có lịch sử phân bổ rõ ràng.

### 📌 Procedure "Phân bổ mã voucher"

* Input: `Voucher_Id` hoặc `VoucherCode`, `User_Id`, `AllocatedBy`.
* Kiểm tra voucher còn trạng thái `"New"` (chưa phân bổ).
* Insert vào `Biz.VoucherAllocation`.
* Update `Biz.Voucher.Status = 'Allocated'`.

### 🔑 Kết luận

👌: Để phân bổ voucher code cho user thì **cần thêm bảng quan hệ trung gian (VoucherAllocation)**.
Procedure sẽ thực hiện **insert vào bảng này** + **update trạng thái voucher gốc**.
*/

USE [02_Evoucher]
GO

DROP TABLE IF EXISTS Biz.VoucherCodeAllocation;
CREATE TABLE Biz.VoucherCodeAllocation
(
    VoucherCodeAllocation_Id NVARCHAR(50) PRIMARY KEY,
    Voucher_Id NVARCHAR(50) NOT NULL,
	App_User_Id NVARCHAR(50) NOT NULL,
    Employee_Id NVARCHAR(50) NOT NULL,
    AllocateDate DATETIME NOT NULL DEFAULT GETDATE(),
    AllocatedBy NVARCHAR(50) NOT NULL, -- người cấp voucher
    Status NVARCHAR(50) NOT NULL DEFAULT 'Allocated', -- Allocated, Used, Returned

    CONSTRAINT FK_VoucherCodeAllocation_Voucher FOREIGN KEY (Voucher_Id) 
        REFERENCES Biz.Voucher(Voucher_Id) ON DELETE CASCADE,
    CONSTRAINT FK_VoucherCodeAllocation_Employee FOREIGN KEY (Employee_Id) 
        REFERENCES Biz.Employee(Employee_Id) ON DELETE CASCADE,
    CONSTRAINT FK_VoucherCodeAllocation_User FOREIGN KEY (App_User_Id) 
        REFERENCES Core.App_User(App_User_Id) ON DELETE CASCADE,
    CONSTRAINT CK_VoucherCodeAllocation_Status CHECK(Status IN ('Allocated','Used','Returned'))
);
GO

--Bảng này lưu: **voucher nào, gán cho ai, ngày nào, ai cấp, trạng thái**.
--Procedure phân bổ mã voucher
CREATE OR ALTER PROC Biz.sp_VoucherCode_Allocate
    @VoucherCodeAllocation_Id NVARCHAR(50),
    @Voucher_Id NVARCHAR(50),
	@App_User_Id NVARCHAR(50),
    @Employee_Id NVARCHAR(50),
    @AllocatedBy NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	DECLARE @ErrMsg NVARCHAR(200), @ErrNo INT;
	SELECT
		@ErrNo = CASE
					WHEN @VoucherCodeAllocation_Id IS NULL THEN 64001
					WHEN @Voucher_Id IS NULL THEN 64002
					WHEN @Employee_Id IS NULL THEN 64003
					WHEN @App_User_Id IS NULL THEN 64004
					WHEN @AllocatedBy IS NULL THEN 64005
				END,

		@ErrMsg = CASE
					WHEN @VoucherCodeAllocation_Id IS NULL THEN '@VoucherCodeAllocation_Id cannot be NULL'
					WHEN @Voucher_Id IS NULL THEN '@Voucher_Id cannot be NULL'
					WHEN @Employee_Id IS NULL THEN '@Employee_Id cannot be NULL'
					WHEN @App_User_Id IS NULL THEN '@App_User_Id cannot be NULL'
					WHEN @AllocatedBy IS NULL THEN '@AllocatedBy cannot be NULL'
				END
	IF @ErrNo IS NOT NULL
		THROW @ErrNo, @ErrMsg, 1;

    -- Kiểm tra voucher có tồn tại & còn trạng thái 'New'
    IF NOT EXISTS (SELECT 1 FROM Biz.Voucher WHERE Voucher_Id = @Voucher_Id AND Status = 'New' AND IsActive = 1)
        THROW 64006, 'Voucher is not available for allocation', 1;

    -- Insert vào bảng phân bổ
    INSERT INTO Biz.VoucherCodeAllocation (
        VoucherCodeAllocation_Id, Voucher_Id, App_User_Id, Employee_Id, AllocateDate, AllocatedBy, Status
    )
    VALUES (
        @VoucherCodeAllocation_Id, @Voucher_Id, @App_User_Id, @Employee_Id, GETDATE(), @AllocatedBy, 'Allocated'
    );

    -- Cập nhật trạng thái voucher sang 'Allocated'
    UPDATE Biz.Voucher
    SET Status = 'Allocated',
        UpdateUser = @AllocatedBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

---------------------------------------------------------------------------------------------------------------------------------------
--12. Viết procedure thực hiện nghiệp vụ sử dụng voucher
CREATE OR ALTER PROC Biz.sp_VoucherCode_Use
    @VoucherCodeAllocation_Id NVARCHAR(50),
    @UsedBy NVARCHAR(50) -- người xác nhận sử dụng (có thể là nhân viên hoặc hệ thống)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherCodeAllocation_Id IS NULL
        THROW 65001, '@VoucherCodeAllocation_Id cannot be NULL', 1;
    IF @UsedBy IS NULL
        THROW 65002, '@UsedBy cannot be NULL', 1;

    -- Kiểm tra phân bổ có tồn tại & đang ở trạng thái Allocated
    IF NOT EXISTS (SELECT 1 FROM Biz.VoucherCodeAllocation WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id
																 AND Status = 'Allocated')
        THROW 65003, 'Voucher is not available for use', 1;

    DECLARE @Voucher_Id NVARCHAR(50);

    -- Lấy Voucher_Id từ Allocation
    SELECT @Voucher_Id = Voucher_Id
    FROM Biz.VoucherCodeAllocation
    WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id;

    -- Update trạng thái Allocation sang Used
    UPDATE Biz.VoucherCodeAllocation
    SET Status = 'Used'
    WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id;

    -- Update trạng thái Voucher sang Used
    UPDATE Biz.Voucher
    SET Status = 'Used',
        UpdateUser = @UsedBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

---------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC Biz.sp_VoucherCode_Return
    @VoucherCodeAllocation_Id NVARCHAR(50),
    @ReturnBy NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherCodeAllocation_Id IS NULL
        THROW 65001, '@VoucherCodeAllocation_Id cannot be NULL', 1;
    IF @ReturnBy IS NULL
        THROW 65002, '@ReturnBy cannot be NULL', 1;

    -- Kiểm tra phân bổ có tồn tại & đang ở trạng thái Allocated
    IF NOT EXISTS (SELECT 1 FROM Biz.VoucherCodeAllocation WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id 
															 AND Status = 'Allocated')
        THROW 65003, 'Voucher is not available for return', 1;

    DECLARE @Voucher_Id NVARCHAR(50);

    -- Lấy Voucher_Id từ Allocation
    SELECT @Voucher_Id = Voucher_Id
    FROM Biz.VoucherCodeAllocation
    WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id;

    -- Update trạng thái Allocation sang Returned
    UPDATE Biz.VoucherCodeAllocation
    SET Status = 'Returned'
    WHERE VoucherCodeAllocation_Id = @VoucherCodeAllocation_Id;

    -- Update trạng thái Voucher sang Returned
    UPDATE Biz.Voucher
    SET Status = 'Returned',
        UpdateUser = @ReturnBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO