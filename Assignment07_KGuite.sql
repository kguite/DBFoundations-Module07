--*************************************************************************--
-- Title: Assignment07
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KGuite')
	 Begin 
	  Alter Database [Assignment07DB_KGuite] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KGuite;
	 End
	Create Database Assignment07DB_KGuite;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KGuite;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

-- formatting my response as step-by-step pieces

-- Step1: list of product names and prices from vProducts
SELECT ProductName, UnitPrice
FROM vProducts
GO

-- Step2: function to format price as USD
SELECT ProductName, FORMAT(UnitPrice, 'C') UnitPrice
FROM vProducts
GO

-- Step3: order result by ProductName
SELECT ProductName, FORMAT(UnitPrice, 'C') UnitPrice
FROM vProducts
ORDER BY 1, 2
GO


-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

-- Step1: List of CategoryNames, Product Names, and Price
SELECT CategoryName, ProductName, UnitPrice
FROM vCategories
INNER JOIN vProducts
ON vCategories.CategoryID = vProducts.CategoryID
GO

-- Step2: add function to format price as USD
SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C') UnitPrice
FROM vCategories
INNER JOIN vProducts
ON vCategories.CategoryID = vProducts.CategoryID
GO

-- Step3: add order by Category, Product
SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C') UnitPrice
FROM vCategories
INNER JOIN vProducts
ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY 1, 2, 3
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Step 1: Select ProductName, InventoryDate, Inventory Count
-- by joining vProducts and vInventories
SELECT	ProductName,
		[InventoryDate],
		[InventoryCount] = [Count]
FROM vProducts
INNER JOIN vInventories
ON vProducts.ProductID = vInventories.ProductID
GO

-- Step 2: Add date format function, should look like "January, 2017"
SELECT	ProductName,
		[InventoryDate] = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
		[InventoryCount] = [Count]
FROM vProducts
INNER JOIN vInventories
ON vProducts.ProductID = vInventories.ProductID
GO

-- Step 3: Order by Products and Date
-- ordering by column name orders the months alphabetically
-- need to cast the named month as the integer month to order by 1, 2, 3 etc
SELECT	ProductName,
		[InventoryDate] = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
		[InventoryCount] = [Count]
FROM vProducts
INNER JOIN vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY 1, CAST([InventoryDate] as DATE), 3
GO


-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Step1: Create VIEW vProductInventories
-- can copy SELECT from above selecting ProductNames, Dates, Counts, Date format, join

-- CREATE VIEW vProductInventories
-- AS
-- SELECT
-- 	ProductName,
-- 	[InventoryDate] = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
-- 	[InventoryCount] = [Count]
-- FROM vProducts
-- INNER JOIN vInventories
-- ON vProducts.ProductID = vInventories.ProductID
-- GO

-- Step2:
-- order by Product, Date
-- can't use ORDER BY without a SELECT TOP statement
-- SELECT TOP must be a number, not a percent, to use ORDER BY
-- Combined steps into one view below:

CREATE VIEW vProductInventories
AS
SELECT TOP 1000000 -- random large number
	ProductName,
	[InventoryDate] = DateName(MM, InventoryDate) + ', ' + DateName(YY, InventoryDate),
	[InventoryCount] = [Count]
FROM vProducts
INNER JOIN vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY 1, MONTH([InventoryDate]), 3
GO

-- Check that it works: 
SELECT * FROM vProductInventories;
GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

-- Step1: SELECT CategoryName, InventoryDate, InventoryCount
	-- InventoryDate: format as above
	-- InventoryCount: needs to be a SUM TOTAL by Category
	-- Join Categories to Products, Products to Inventories

-- Step2: Wrap into a view called vCategoryInventories
-- Step 4: add group by - group category name, date
-- Step 5: add order by (Product, Date)


CREATE VIEW vCategoryInventories
AS
SELECT TOP 100000 -- random large number
	C.CategoryName,
	[InventoryDate] = DateName(MM, I.InventoryDate) + ', ' + DateName(YY, I.InventoryDate),
	InventoryCountByCategory = Sum([count])
FROM
	vCategories as C
INNER JOIN vProducts as P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories as I
ON P.ProductID = I.ProductID
GROUP BY C.CategoryName, InventoryDate
ORDER BY CategoryName, MONTH(InventoryDate), InventoryCountByCategory -- month works like cast here, sorting by numeric month not alphabetical
GO


-- Check that it works: 
SELECT * FROM vCategoryInventories;
GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

-- Step1: Select ProductName, InventoryDate, InventoryCount, and previous month count FROM previous view vProductInventories
-- Step 2: use function to set any January counts to zero (lag, over, 0)
-- Step 3: order By Products, date
-- Step 4: Wrap in new view vProductInventoriesWithPreviouMonthCounts

CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
SELECT TOP 10000
	ProductName,
	InventoryDate,
	InventoryCount,
	[PreviousMonthCount] = IIF(InventoryDate Like ('January%'), 0, IsNull(Lag(InventoryCount) OVER (Order By ProductName, Year(InventoryDate)), 0))
	FROM vProductInventories
	ORDER BY 1, MONTH(InventoryDate), 3
GO

-- Check that it works: 
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Verify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- Step1: SELECT ProductName, InventoryDate, InventoryCount PreviousMonthCount(as above), FROM vProductInventoriesWithPreviousMonthCounts
-- Step2: Previous Month Count function: if count > previous = 1, count = 0, count < -1
-- Step3:

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!


CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT TOP 10000
	ProductName,
	InventoryDate,
	InventoryCount,
	[PreviousMonthCount],
	[CountVsPreviousCountKPI] = isNull(CASE
		WHEN InventoryCount > [PreviousMonthCount] THEN 1
		WHEN InventoryCount = [PreviousMonthCount] THEN 0
		WHEN InventoryCount < [PreviousMonthCount] THEN -1
		END, 0)
	FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY 1, MONTH(InventoryDate), 3
GO

-- Check that it works: 
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

-- Step 1: Create function fProductInventoriesWithPreviousMonthCountsWithKPIs
-- Step 2: which selects ProductNames, InventoryDate, InventoryCount, PreviousMonthCount (as above) (returns table)
-- Step 3: FROM ProductInventoriesWithPreviousMonthCountsWithKPIs
-- Step 4: compare countVsPreviousCountKPI to KPIValue


CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPIValue int)
RETURNS TABLE 
AS
	RETURN SELECT
		ProductName,
		InventoryDate,
		InventoryCount,
		[PreviousMonthCount],
		[CountVsPreviousCountKPI]
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	WHERE [CountVsPreviousCountKPI] = @KPIValue
GO

-- Check that it works:
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM  fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO

/***************************************************************************************/