--10. Viết procedure thực hiện chức năng phân bổ voucher

--"Phân bổ voucher" (allocate voucher) nghĩa là gán một hoặc nhiều **Voucher** cho một **Employee** nào đó để họ sử dụng.
--Để làm được việc này, mình thường cần thêm một bảng quan hệ trung gian.

---

--Thiết kế bảng phân bổ
USE [02_Evoucher]
GO

DROP TABLE IF EXISTS Biz.VoucherAllocation;
CREATE TABLE Biz.VoucherAllocation
(
    VoucherAllocation_Id NVARCHAR(50) PRIMARY KEY,
    Voucher_Id NVARCHAR(50) NOT NULL,
    Employee_Id NVARCHAR(50) NOT NULL,
    AllocateDate DATETIME NOT NULL DEFAULT GETDATE(),
    AllocatedBy NVARCHAR(50) NOT NULL, -- người cấp voucher
    Status NVARCHAR(50) NOT NULL DEFAULT 'Allocated', -- Allocated, Used, Returned
    CONSTRAINT FK_VoucherAllocation_Voucher FOREIGN KEY (Voucher_Id) 
        REFERENCES Biz.Voucher(Voucher_Id) ON DELETE CASCADE,
    CONSTRAINT FK_VoucherAllocation_Employee FOREIGN KEY (Employee_Id) 
        REFERENCES Biz.Employee(Employee_Id) ON DELETE CASCADE,
    CONSTRAINT CK_VoucherAllocation_Status CHECK(Status IN ('Allocated','Used','Returned'))
);
GO

--Bảng này lưu: **voucher nào, gán cho ai, ngày nào, ai cấp, trạng thái**.

--Procedure phân bổ voucher

CREATE OR ALTER PROC Biz.sp_Voucher_Allocate
    @VoucherAllocation_Id NVARCHAR(50),
    @Voucher_Id NVARCHAR(50),
    @Employee_Id NVARCHAR(50),
    @AllocatedBy NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherAllocation_Id IS NULL
        THROW 64001, '@VoucherAllocation_Id cannot be NULL', 1;
    IF @Voucher_Id IS NULL
        THROW 64002, '@Voucher_Id cannot be NULL', 1;
    IF @Employee_Id IS NULL
        THROW 64003, '@Employee_Id cannot be NULL', 1;
    IF @AllocatedBy IS NULL
        THROW 64004, '@AllocatedBy cannot be NULL', 1;

    -- Kiểm tra voucher có tồn tại & còn trạng thái 'New'
    IF NOT EXISTS (SELECT 1 FROM Biz.Voucher WHERE Voucher_Id = @Voucher_Id AND Status = 'New' AND IsActive = 1)
        THROW 64005, 'Voucher is not available for allocation', 1;

    -- Insert vào bảng phân bổ
    INSERT INTO Biz.VoucherAllocation (
        VoucherAllocation_Id, Voucher_Id, Employee_Id, AllocateDate, AllocatedBy, Status
    )
    VALUES (
        @VoucherAllocation_Id, @Voucher_Id, @Employee_Id, GETDATE(), @AllocatedBy, 'Allocated'
    );

    -- Cập nhật trạng thái voucher sang 'Allocated'
    UPDATE Biz.Voucher
    SET Status = 'Allocated',
        UpdateUser = @AllocatedBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

---

--## 3️⃣ Cách hoạt động
--* Khi gọi `sp_Voucher_Allocate`, hệ thống sẽ:
--  1. Kiểm tra **voucher còn trạng thái New** chưa dùng.
--  2. Thêm bản ghi vào `Biz.VoucherAllocation` (ai cấp, cho ai, ngày nào).
--  3. Cập nhật `Biz.Voucher.Status` từ **New → Allocated**.

--👉 Với thiết kế này, có thể quản lý:

--* Ai đang giữ voucher nào.
--* Khi dùng → update `Status = 'Used'`.
--* Khi thu hồi → update `Status = 'Returned'`.

---------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_Use
    @VoucherAllocation_Id NVARCHAR(50),
    @UsedBy NVARCHAR(50) -- người xác nhận sử dụng (có thể là nhân viên hoặc hệ thống)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherAllocation_Id IS NULL
        THROW 65001, '@VoucherAllocation_Id cannot be NULL', 1;
    IF @UsedBy IS NULL
        THROW 65002, '@UsedBy cannot be NULL', 1;

    -- Kiểm tra phân bổ có tồn tại & đang ở trạng thái Allocated
    IF NOT EXISTS (SELECT 1 FROM Biz.VoucherAllocation WHERE VoucherAllocation_Id = @VoucherAllocation_Id AND Status = 'Allocated')
        THROW 65003, 'Voucher is not available for use', 1;

    DECLARE @Voucher_Id NVARCHAR(50);

    -- Lấy Voucher_Id từ Allocation
    SELECT @Voucher_Id = Voucher_Id
    FROM Biz.VoucherAllocation
    WHERE VoucherAllocation_Id = @VoucherAllocation_Id;

    -- Update trạng thái Allocation sang Used
    UPDATE Biz.VoucherAllocation
    SET Status = 'Used'
    WHERE VoucherAllocation_Id = @VoucherAllocation_Id;

    -- Update trạng thái Voucher sang Used
    UPDATE Biz.Voucher
    SET Status = 'Used',
        UpdateUser = @UsedBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

/*
## 🔑 Giải thích

* **Input**:

  * `@VoucherAllocation_Id`: Id của record phân bổ.
  * `@UsedBy`: người xác nhận voucher đã được sử dụng.
* **Logic**:

  1. Kiểm tra allocation tồn tại và đang `Allocated`.
  2. Lấy `Voucher_Id` từ allocation.
  3. Update `Biz.VoucherAllocation.Status = 'Used'`.
  4. Update `Biz.Voucher.Status = 'Used'`, đồng thời lưu `UpdateUser` và `UpdateDate`.

---

👉 Với 2 SP **`sp_Voucher_Allocate`** và **`sp_Voucher_Use`**, anh đã có full luồng:

* Tạo voucher (Insert).
* Phân bổ cho nhân viên (`Allocate`).
* Khi nhân viên dùng → `Use`.
*/

---------------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_Return
    @VoucherAllocation_Id NVARCHAR(50),
    @ReturnBy NVARCHAR(50) -- người xác nhận trả về (có thể là nhân viên hoặc hệ thống)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate input
    IF @VoucherAllocation_Id IS NULL
        THROW 65001, '@VoucherAllocation_Id cannot be NULL', 1;
    IF @ReturnBy IS NULL
        THROW 65002, '@ReturnBy cannot be NULL', 1;

    -- Kiểm tra phân bổ có tồn tại & đang ở trạng thái Allocated
    IF NOT EXISTS (SELECT 1 FROM Biz.VoucherAllocation WHERE VoucherAllocation_Id = @VoucherAllocation_Id AND Status = 'Allocated')
        THROW 65003, 'Voucher is not available for return', 1;

    DECLARE @Voucher_Id NVARCHAR(50);

    -- Lấy Voucher_Id từ Allocation
    SELECT @Voucher_Id = Voucher_Id
    FROM Biz.VoucherAllocation
    WHERE VoucherAllocation_Id = @VoucherAllocation_Id;

    -- Update trạng thái Allocation sang Returned
    UPDATE Biz.VoucherAllocation
    SET Status = 'Returned'
    WHERE VoucherAllocation_Id = @VoucherAllocation_Id;

    -- Update trạng thái Voucher sang Returned
    UPDATE Biz.Voucher
    SET Status = 'Returned',
        UpdateUser = @ReturnBy,
        UpdateDate = GETDATE()
    WHERE Voucher_Id = @Voucher_Id;
END
GO

---------------------------------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC Biz.sp_Voucher_GetAllocationHistory
    @Voucher_Id NVARCHAR(50) = NULL,
    @Employee_Id NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        va.VoucherAllocation_Id,
        va.AllocateDate,
        va.AllocatedBy,
        va.Status AS AllocationStatus,
        v.Voucher_Id,
        v.VoucherCode,
        v.Title AS VoucherTitle,
        v.Status AS VoucherStatus,
        e.Employee_Id,
        e.FullName AS EmployeeName,
        e.Email AS EmployeeEmail,
        e.PhoneNumber AS EmployeePhone
    FROM Biz.VoucherAllocation va
        INNER JOIN Biz.Voucher v ON va.Voucher_Id = v.Voucher_Id
        INNER JOIN Biz.Employee e ON va.Employee_Id = e.Employee_Id
    WHERE (@Voucher_Id IS NULL OR va.Voucher_Id = @Voucher_Id)
      AND (@Employee_Id IS NULL OR va.Employee_Id = @Employee_Id)
    ORDER BY va.AllocateDate DESC;
END
GO
