USE [01_BikeStores]
GO

exec sp_helpindex '[sales].[customers1]'

SELECT customer_id, first_name, last_name, phone, email, street, city, state, zip_code
INTO sales.customers1   -- bảng mới sẽ được tạo
FROM sales.customers;

SELECT customer_id, first_name, last_name, phone, email, street, city, state, zip_code
INTO sales.customers2   -- bảng mới sẽ được tạo
FROM sales.customers;

CREATE INDEX IDX_CUSTOMER1_FIRST_NAME ON [sales].[customers1](first_name)
CREATE INDEX IDX_CUSTOMER1_LAST_NAME ON [sales].[customers1](last_name)

CREATE INDEX IDX_CUSTOMER1_FIRST_NAME_LAST_NAME ON [sales].[customers1](first_name, last_name)

SELECT
	first_name, last_name
FROM
	[sales].[customers1] WITH(INDEX(IDX_CUSTOMER1_FIRST_NAME))
WHERE first_name = 'Kasha'

SELECT
	first_name, last_name
FROM
	[sales].[customers2]
WHERE first_name = 'Kasha'

-----------------------------------------
CREATE CLUSTERED INDEX PK_CUSTOMER1_CUSTOMER_ID ON [sales].[customers1]([customer_id])

SELECT
	*
FROM
	[sales].[customers1]
WHERE [customer_id] = 5

SELECT
	*
FROM
	[sales].[customers2]
WHERE [customer_id] = 5

-------------------------------------------------------------
SELECT *
INTO [sales].[orders1]
FROM [sales].[orders]

SELECT *
INTO [sales].[orders2]
FROM [sales].[orders]

-- TẠO INDEX
CREATE INDEX SALES_ORDER1_CUSTOMER_ID ON [sales].[orders1](customer_id)

SELECT *
FROM [sales].[orders1] O1
JOIN [sales].[customers1] C1 ON C1.customer_id = O1.customer_id
WHERE C1.first_name = 'Kasha'

SELECT *
FROM [sales].[orders1] O2
JOIN [sales].[customers2] C2 ON C2.customer_id = O2.customer_id
WHERE C2.first_name = 'Kasha'

