DROP DATABASE IF EXISTS [01_SalesDW]
CREATE DATABASE [01_SalesDW]
ON
(
	NAME = 'Evoucher_DB',
	FILENAME = 'C:\01_Data\01-cole-data-engineer-bootcamp\LESSON_11_12_13\01_SalesDW.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB)
LOG ON
(
	NAME = 'Evoucher_DB_LOG',
	FILENAME = 'C:\01_Data\01-cole-data-engineer-bootcamp\LESSON_11_12_13\01_SalesDW.ldf',
	SIZE = 5MB,
	MAXSIZE = 50MB,
	FILEGROWTH = 5MB
)

USE [01_SalesDW]
GO

-- CREATE SCHEMAS
CREATE SCHEMA Dim;
GO

CREATE SCHEMA Fact;
GO

DROP TABLE IF EXISTS Dim.Year
CREATE TABLE Dim.Year
(
	YearKey NVARCHAR(4) PRIMARY KEY,
	Year INT NOT NULL CONSTRAINT CK_Year_Valid CHECK(Year >= 1900 AND Year <= 2100)
)
GO

DROP TABLE IF EXISTS Dim.Month
CREATE TABLE Dim.Month
(
	MonthKey NVARCHAR(6) PRIMARY KEY,
	YearKey NVARCHAR(4) NOT NULL,
	Month INT NOT NULL CONSTRAINT CK_Month_Valid CHECK(Month BETWEEN 1 AND 12),
	CONSTRAINT FK_Month_YearKey FOREIGN KEY (YearKey) REFERENCES Dim.Year (YearKey) ON DELETE NO ACTION ON UPDATE NO ACTION
)
GO

DROP TABLE IF EXISTS Dim.Date
CREATE TABLE Dim.Date
(
	DateKey NVARCHAR(8) PRIMARY KEY,
	MonthKey NVARCHAR(6) NOT NULL,
	Date DATE NOT NULL CONSTRAINT DF_Date_Date DEFAULT CAST(GETDATE() AS DATE),
	CONSTRAINT FK_Date_MonthKey FOREIGN KEY (MonthKey) REFERENCES Dim.Month (MonthKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT CK_Date_Valid CHECK (Date >= '1900-01-01' AND Date <= '2100-12-31')
)
GO

DROP TABLE IF EXISTS Dim.SalesPerson
CREATE TABLE Dim.SalesPerson
(
	SalesPersonKey INT IDENTITY (1, 1) PRIMARY KEY,
	SalesPersonId INT NOT NULL,
	FullName NVARCHAR(500),
	NationalIDNumber NVARCHAR(15) NOT NULL,
	Gender NCHAR(1),
	HireDate DATE NOT NULL CONSTRAINT DF_SalesPerson_HireDate DEFAULT CAST(GETDATE() AS DATE),
	CONSTRAINT CK_SalesPerson_HireDate CHECK (HireDate >= '1900-01-01' AND HireDate <= '2100-12-31'),
	CONSTRAINT CK_SalesPerson_Gender CHECK(Gender IN ('M', 'F')),
	CONSTRAINT UQ_SalesPerson_SalesPersonId UNIQUE (SalesPersonId),
	CONSTRAINT UQ_SalesPerson_NationalIDNumber UNIQUE (NationalIDNumber)
)
GO

DROP TABLE IF EXISTS Dim.Territory
CREATE TABLE Dim.Territory
(
	TerritoryKey INT IDENTITY (1, 1) PRIMARY KEY,
	TerritoryId INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CountryRegionCode NVARCHAR(15) NOT NULL,
	CONSTRAINT UQ_STerritory_TerritoryId UNIQUE (TerritoryId),
	CONSTRAINT UQ_STerritory_CountryRegionCode UNIQUE (CountryRegionCode),
)
GO

DROP TABLE IF EXISTS Dim.ProductCategory
CREATE TABLE Dim.ProductCategory
(
	ProductCategoryKey INT IDENTITY (1, 1) PRIMARY KEY,
	ProductCategoryId INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	CONSTRAINT UQ_ProductCategory_ProductCategoryId UNIQUE (ProductCategoryId)
)
GO

DROP TABLE IF EXISTS Dim.ProductSubCategory
CREATE TABLE Dim.ProductSubCategory
(
	ProductSubCategoryKey INT IDENTITY (1, 1) PRIMARY KEY,
	ProductSubCategoryId INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	ProductCategoryKey INT NOT NULL,
	CONSTRAINT UQ_ProductSubCategory_ProductSubCategoryId UNIQUE (ProductSubCategoryId),
	CONSTRAINT FK_ProductSubCategory_ProductCategoryKey FOREIGN KEY (ProductCategoryKey) REFERENCES Dim.ProductCategory (ProductCategoryKey) ON DELETE NO ACTION ON UPDATE NO ACTION
)
GO

DROP TABLE IF EXISTS Dim.Product
CREATE TABLE Dim.Product
(
	ProductKey INT IDENTITY (1, 1) PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ProductNumber NVARCHAR(25) NOT NULL,
	StandardCost MONEY NOT NULL,
	ListPrice MONEY NOT NULL,
	Weight DECIMAL(8, 2),
	ProductSubCategoryKey INT NOT NULL,
	CONSTRAINT FK_Product_ProductSubCategoryKey FOREIGN KEY (ProductSubCategoryKey) REFERENCES Dim.ProductSubCategory (ProductSubCategoryKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT CK_Product_StandardCost CHECK(StandardCost >= 0),
	CONSTRAINT CK_Product_ListPrice CHECK(ListPrice >= 0),
	CONSTRAINT CK_Product_Weight CHECK(Weight > 0 OR Weight IS NULL),
	CONSTRAINT UQ_Product_ProductNumber UNIQUE (ProductNumber)
)
GO

DROP TABLE IF EXISTS Fact.SalesOrder
CREATE TABLE Fact.SalesOrder
(
	Id INT IDENTITY (1, 1) PRIMARY KEY,
	DateKey NVARCHAR(8) NOT NULL,
	TerritoryKey INT,
	SalesPersonKey INT,
	Revenue DECIMAL(18, 2) NOT NULL,
	NumberOrder INT NOT NULL,
	CONSTRAINT CK_SalesOrder_Revenue CHECK(Revenue >= 0),
	CONSTRAINT CK_SalesOrder_NumberOrder CHECK(NumberOrder >= 0),
	CONSTRAINT FK_SalesOrder_DateKey FOREIGN KEY (DateKey) REFERENCES Dim.Date (DateKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT FK_SalesOrder_TerritoryKey FOREIGN KEY (TerritoryKey) REFERENCES Dim.Territory (TerritoryKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT FK_SalesOrder_SalesPersonKey FOREIGN KEY (SalesPersonKey) REFERENCES Dim.SalesPerson (SalesPersonKey) ON DELETE NO ACTION ON UPDATE NO ACTION
)
GO

DROP TABLE IF EXISTS Fact.Product
CREATE TABLE Fact.Product
(
	Id INT IDENTITY (1, 1) PRIMARY KEY,
	DateKey NVARCHAR(8) NOT NULL,
	TerritoryKey INT,
	ProductKey INT NOT NULL,
	Qty INT NOT NULL,
	CONSTRAINT CK_Product_Qty CHECK(Qty >= 0),
	CONSTRAINT FK_Product_DateKey FOREIGN KEY (DateKey) REFERENCES Dim.Date (DateKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT FK_Product_TerritoryKey FOREIGN KEY (TerritoryKey) REFERENCES Dim.Territory (TerritoryKey) ON DELETE NO ACTION ON UPDATE NO ACTION,
	CONSTRAINT FK_Product_ProductKey FOREIGN KEY (ProductKey) REFERENCES Dim.Product (ProductKey) ON DELETE NO ACTION ON UPDATE NO ACTION
)
GO