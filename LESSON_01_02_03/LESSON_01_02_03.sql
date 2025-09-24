USE [04_BikeStores]
GO

SELECT
	*
FROM [sales].[customers] AS CU
WHERE CU.phone IS NOT NULL;

SELECT 
	CU.state
	, CU.city
	, STRING_AGG(CU.first_name + ' ' + CU.last_name, ', ') AS FULL_NAME
	, SUBSTRING(CU.zip_code, 1, 3) AS SHORT_ZIP_CODE
	, COUNT(*) AS NUM_CUSTOMERS
FROM 
	[sales].[customers] AS CU
WHERE
	CU.phone IS NOT NULL
GROUP BY
	CU.state, CU.city, SUBSTRING(CU.zip_code, 1, 3)
HAVING
	COUNT(*) > 5
ORDER BY 
	CU.state, CU.city

--17. Lấy thông tin đầy đủ của một order
--Ngày tạo order, ngày chốt đơn, ngày ship hàng
--Tên khách (full name), số ĐT khách, email khách, địa chỉ khách (street, city, state, zip code)
--Tên cửa hàng, số ĐT cửa hàng, email cửa hàng, địa chỉ cửa hàng (street, city, state, zip code)
--Tên nhân viên bán hàng (full name), email nhân viên, số ĐT nhân viên
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

-- 18. Lấy danh sách customer có số điện thoại
SELECT 
	CU.*
FROM 
	[sales].[customers] AS CU
WHERE
	CU.phone IS NOT NULL;

-- 19. Lấy danh sách customer có first_name bắt đầu bằng chữ cái A
SELECT 
	CU.*
FROM 
	[sales].[customers] AS CU
WHERE
	CU.first_name LIKE 'A%';

-- 20. Lấy danh sách Tên sản phẩm, Tên nhãn hàng, Tên loại sản phẩm
SELECT
	PR.product_name
	, BR.brand_name
	, CAT.category_name
FROM 
	[production].[products] AS PR
	JOIN [production].[brands] AS BR ON BR.brand_id = PR.brand_id
	JOIN [production].[categories] AS CAT ON CAT.category_id = PR.category_id
ORDER BY
	CAT.category_name;

-- 21. Lấy danh sách Tên nhân viên và tên quản lý của nhân viên đó
SELECT
	-- STAFF
	ST.staff_id AS STAFF_ID
	, (ST.first_name + ' ' + ST.last_name) AS STAFF_NAME
	-- MANAGER
	, MA.manager_id AS MANAGER_ID
	, (MA.first_name + ' ' + MA.last_name) AS MANAGER_NAME
FROM 
	[sales].[staffs] AS ST
	JOIN [sales].[staffs] AS MA ON MA.manager_id = ST.manager_id
ORDER BY
	ST.staff_id;

-- 22. Lấy danh sách Tên nhân viên và tên quản lý của nhân viên đó bao gồm cả nhân viên không có quản lý
SELECT
	-- STAFF
	ST.staff_id AS STAFF_ID
	, (ST.first_name + ' ' + ST.last_name) AS STAFF_NAME
	-- MANAGER
	, MA.manager_id AS MANAGER_ID
	, (MA.first_name + ' ' + MA.last_name) AS MANAGER_NAME
FROM 
	[sales].[staffs] AS ST
	LEFT JOIN [sales].[staffs] AS MA ON MA.manager_id = ST.manager_id
--WHERE
--	MA.manager_id IS NOT NULL
ORDER BY
	ST.staff_id;

SELECT
	-- STAFF
	ST.staff_id AS STAFF_ID
	, (ST.first_name + ' ' + ST.last_name) AS STAFF_NAME
	-- MANAGER
	, MA.manager_id AS MANAGER_ID
	, (MA.first_name + ' ' + MA.last_name) AS MANAGER_NAME
FROM 
	[sales].[staffs] AS ST
	RIGHT JOIN [sales].[staffs] AS MA ON MA.manager_id = ST.manager_id
ORDER BY
	ST.staff_id;

-- 23. Viết câu truy vấn:
--Lấy thông tin đầy đủ của một order
SELECT
	*
FROM 
	[sales].[orders] AS O
WHERE 
	O.order_id = 1;

-- 24. Lấy thông tin chi tiết của từng dòng bán hàng order_items
SELECT
	*
FROM [sales].[order_items] AS OI;

-- 25. Thống kê Doanh số bán hàng theo từng sản phẩm
SELECT
	PR.product_id
	, PR.product_name
	, SUM(OI.quantity) AS SUM_QUANTITY
	, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
FROM 
	[production].[products] AS PR
	JOIN [sales].[order_items] AS OI ON OI.product_id = PR.product_id
GROUP BY
	PR.product_id, PR.product_name
ORDER BY 
	TOTAL_REVENUE;

-- 26. Thống kê số lượng đơn hàng của từng cửa hàng
SELECT
	ST.store_id
	, ST.store_name
	, COUNT(O.order_id) AS TOTAL_ORDER
FROM 
	[sales].[orders] AS O
	JOIN [sales].[stores] AS ST ON ST.store_id = O.store_id
GROUP BY
	ST.store_id, ST.store_name
ORDER BY 
	TOTAL_ORDER;

-- 27. Thống kê doanh số bán hàng của từng cửa hàng
SELECT
	ST.store_id
	, ST.store_name
	, SUM(OI.quantity) AS SUM_QUANTITY
	, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
FROM 
	[sales].[orders] AS O
	JOIN [sales].[stores] AS ST ON ST.store_id = O.store_id
	JOIN [sales].[order_items] AS OI ON OI.order_id = O.order_id
GROUP BY
	ST.store_id, ST.store_name
ORDER BY 
	TOTAL_REVENUE;

-- 28. Thống kê doanh số bán hàng theo từng nhân viên
SELECT
	STA.staff_id
	, (STA.first_name + ' ' + STA.last_name) AS STAFF_NAME
	, SUM(OI.quantity) AS SUM_QUANTITY
	, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
FROM 
	[sales].[staffs] AS STA
	JOIN [sales].[orders] AS O ON O.staff_id = STA.staff_id
	JOIN [sales].[order_items] AS OI ON OI.order_id = O.order_id
GROUP BY
	STA.staff_id, (STA.first_name + ' ' + STA.last_name)
ORDER BY 
	TOTAL_REVENUE DESC;

-- 29. Thống kê số lượng tồn kho theo từng sản phẩm
SELECT
	PR.product_id
	, PR.product_name
	, STO.quantity
FROM 
	[production].[stocks] AS STO
	JOIN [production].[products] AS PR ON PR.product_id = STO.product_id;

-- 30. Thống kê doanh số bán hàng theo từng thương hiệu sản phẩm
SELECT
	CAT.category_id
	, CAT.category_name
	, SUM(OI.quantity) AS SUM_QUANTITY
	, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
FROM 
	[production].[categories] AS CAT
	JOIN [production].[products] AS PR ON PR.category_id = CAT.category_id
	JOIN [sales].[order_items] AS OI ON OI.product_id = PR.product_id
GROUP BY
	CAT.category_id, CAT.category_name
ORDER BY 
	TOTAL_REVENUE DESC;

-- 31. Liệt kê danh sách sản phẩm chưa bán được cái nào
-- CACH 1
SELECT
	PR.product_id
	, PR.product_name
	, OI.product_id
FROM 
	[production].[products] AS PR
	LEFT JOIN [sales].[order_items] AS OI ON OI.product_id = PR.product_id
WHERE
	OI.product_id IS NULL
ORDER BY
	PR.product_id;

-- CACH 2
SELECT
	PR.product_id
	, PR.product_name
FROM 
	[production].[products] AS PR
WHERE
	NOT EXISTS (
		SELECT 1
		FROM
			[sales].[order_items] AS OI
		WHERE
			OI.product_id = PR.product_id
	)
ORDER BY
	PR.product_id;

--32. Liệt kê danh sách khách hàng chưa mua hàng lần nào
-- CACH 1
SELECT
	DISTINCT CU.customer_id
	, (CU.first_name + ' ' + CU.last_name) AS CUSTOMER_NAME
	, SO.customer_id
FROM
	[sales].[customers] AS CU
	LEFT JOIN [sales].[orders] AS SO ON SO.customer_id = CU.customer_id
WHERE
	SO.customer_id IS NULL
ORDER BY
	CU.customer_id;

-- CACH 2
SELECT
	DISTINCT CU.customer_id
	, (CU.first_name + ' ' + CU.last_name) AS CUSTOMER_NAME
FROM
	[sales].[customers] AS CU
WHERE
	NOT EXISTS (
		SELECT 1
		FROM 
			[sales].[orders] AS SO
		WHERE 
			SO.customer_id = CU.customer_id
	)
ORDER BY
	CU.customer_id;

--33. Liệt kê danh sách khách hàng đã mua 10 đơn hàng trở lên
SELECT
	CU.customer_id
	, (CU.first_name + ' ' + CU.last_name) AS CUSTOMER_NAME
	, COUNT(SO.order_id) AS TOTAL_ORDER
FROM
	[sales].[customers] AS CU
	JOIN [sales].[orders] AS SO ON SO.customer_id = CU.customer_id
GROUP BY
	CU.customer_id, (CU.first_name + ' ' + CU.last_name)
HAVING 
	COUNT(SO.order_id) >= 10
ORDER BY
	CU.customer_id;

--34. Liệt kê khách hàng ở thành phố New York, bang NY
SELECT
	*
FROM [sales].[customers] AS CU
WHERE CU.state = 'NY' AND CU.city = 'New York';

--35. Thống kê doanh số bán hàng của từng cửa hàng theo năm
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
	TOTAL_REVENUE;

--31. Thống kê sản phẩm có tồn kho lớn hơn 100 tại mỗi kho
SELECT
	ST.product_id
	, ST.store_id
	, SUM(ST.quantity) AS TOTAL_QUANTITY
FROM 
	[production].[stocks] AS ST
GROUP BY
	ST.product_id, ST.store_id
HAVING
	SUM(ST.quantity) > 100

--32. Thống kê số khách hàng đã từng mua hàng tại cửa hàng Santa Cruz Bikes
SELECT
	STO.store_name
	, COUNT(DISTINCT CU.customer_id) AS TOTAL_CUSTOMER -- Một khách hàng có thể mua nhiều đơn hàng
	-- nên dùng DISTINCT
FROM 
	[sales].[stores] AS STO
	JOIN [sales].[orders] AS O ON O.store_id = STO.store_id
	JOIN [sales].[customers] AS CU ON CU.customer_id = O.customer_id
WHERE 
	STO.store_name = 'Santa Cruz Bikes'
GROUP BY
	STO.store_name

--33. Thống kê số khách hàng đã từng mua hàng tại cửa hàng Santa Cruz Bikes và địa chỉ ở thành phố Longview
SELECT
	STO.store_name
	, COUNT(DISTINCT CU.customer_id) AS TOTAL_CUSTOMER -- Một khách hàng có thể mua nhiều đơn hàng
	-- nên dùng DISTINCT
FROM 
	[sales].[stores] AS STO
	JOIN [sales].[orders] AS O ON O.store_id = STO.store_id
	JOIN [sales].[customers] AS CU ON CU.customer_id = O.customer_id
WHERE 
	STO.store_name = 'Santa Cruz Bikes'
	AND CU.city = 'Longview'
GROUP BY
	STO.store_name

--34. Liệt kê sản phẩm có giá từ \$500 đến \$1000
SELECT
	PR.product_id
	, PR.product_name
FROM 
	[production].[products] AS PR
WHERE
	PR.list_price BETWEEN 500 AND 1000

--35. Tính tổng doanh số bán hàng từng năm theo từng cửa hàng
SELECT
	ST.store_id
	, YEAR(O.order_date) AS YEAR_ZF
	, ST.store_name
	, SUM(OI.quantity) AS SUM_QUANTITY
	, SUM(OI.list_price * OI.quantity * (1 - OI.discount)) AS TOTAL_REVENUE
FROM 
	[sales].[orders] AS O
	JOIN [sales].[stores] AS ST ON ST.store_id = O.store_id
	JOIN [sales].[order_items] AS OI ON OI.order_id = O.order_id
GROUP BY
	ST.store_id, ST.store_name, YEAR(O.order_date)
ORDER BY 
	YEAR_ZF;

--36. Liệt kê danh sách khách hàng có `first_name` kết thúc bằng chữ cái “u”
SELECT
	CU.customer_id
	, CU.first_name
	, CU.last_name
	, ISNULL(CU.first_name + ' ','') + ISNULL(CU.last_name, '') AS FULL_NAME
FROM 
	[sales].customers AS CU
WHERE  
	CU.first_name LIKE '%u';

--37. Liệt kê danh sách khách hàng có email của gmail
SELECT
	CU.customer_id
	, ISNULL(CU.first_name + ' ','') + ISNULL(CU.last_name, '') AS FULL_NAME
	, CU.email
FROM 
	[sales].customers AS CU
WHERE
	SUBSTRING(CU.email, CHARINDEX('@', CU.email) + 1, LEN(CU.email) - (CHARINDEX('@', CU.email) + 1)) LIKE 'gmail%'

--38. Trích xuất dữ liệu email domain khác nhau từ dữ liệu khách hàng 
-- (gợi ý: sử dụng các hàm `substring`, `charindex` và `len`)
SELECT
	CU.customer_id
	, ISNULL(CU.first_name + ' ','') + ISNULL(CU.last_name, '') AS FULL_NAME
	, SUBSTRING(CU.email, CHARINDEX('@', CU.email) + 1, LEN(CU.email) - (CHARINDEX('@', CU.email) + 1)) AS DOMAIN_EMAIL
FROM 
	[sales].customers AS CU
WHERE
	CU.email IS NOT NULL;

--39. Trích xuất đầu số điện thoại khác nhau từ dữ liệu khách hàng
SELECT
	CU.customer_id
	, CU.phone
	, SUBSTRING(CU.phone, CHARINDEX('(', CU.phone) + 1, 3) AS FIRST_NUMBER_PHONE
FROM 
	[sales].customers AS CU
WHERE
	CU.phone IS NOT NULL;

--40. Liệt kê danh sách thông tin nhân viên kèm thông tin người quản lý
SELECT
	STA.staff_id
	, ISNULL(STA.first_name + ' ','') + ISNULL(STA.last_name, '') AS FULL_NAME_STAFF
	, MA.manager_id
	, ISNULL(MA.first_name + ' ','') + ISNULL(MA.last_name, '') AS FULL_NAME_MANAGER
FROM 
	[sales].[staffs] AS STA
	JOIN [sales].[staffs] AS MA ON MA.manager_id = STA.manager_id

-- TỔNG KẾT TRUY VẤN
-- DÒNG CHẢY DỮ LIỆU.
-- DỮ LIỆU VÀ TRƯỚC SAU CỦA MỖI PHARE, DỮ LIỆU TẠI 1 VỊ TRÍ TRONG CÂU TRUY VẤN.
-- ĐỂ Ý ĐẾN GIÁ TRỊ NULL.
-- JOIN.
-- SUB QUERRY.