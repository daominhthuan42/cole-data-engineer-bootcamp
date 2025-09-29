--13. Viết procedure báo cáo số lượng và giá trị voucher đã phân bổ theo tháng
USE [02_Evoucher]
GO

CREATE OR ALTER PROC Biz.sp_VoucherCode_ReportMonthly
	@Year INT
AS
BEGIN
    SET NOCOUNT ON;
	-- Validate Input
	IF @Year IS NULL
		THROW 65001, '@Year cannot be NULL', 1;
	
	SELECT
		COUNT(VC.VoucherCodeAllocation_Id) AS TotalAllocated
		, SUM(V.Value) AS TotalValue
		, YEAR(VC.AllocateDate) AS [Year]
		, MONTH(VC.AllocateDate) AS [Month]
	FROM [Biz].[VoucherCodeAllocation] VC
	JOIN [Biz].[Voucher] V ON V.[Voucher_Id] = VC.[Voucher_Id]
	WHERE
		VC.Status = 'Allocated'
		AND YEAR(VC.AllocateDate) = @Year
	GROUP BY
		YEAR(VC.AllocateDate), MONTH(VC.AllocateDate)
	ORDER BY
		[Month]
END
GO