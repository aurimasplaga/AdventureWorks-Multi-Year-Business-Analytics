-- Query used to retrieve geographical/territory data
SELECT
      salesorderheader.*,  -- Selects all columns from the sales order header table
      province.stateprovincecode AS ship_province, 
      province.CountryRegionCode AS country_code,  
      province.name AS country_state_name  
FROM `tc-da-1.adwentureworks_db.salesorderheader` AS salesorderheader
-- Join to get the shipping address details
INNER JOIN `tc-da-1.adwentureworks_db.address` AS address
    ON salesorderheader.ShipToAddressID = address.AddressID
-- Join to get province/state information
INNER JOIN `tc-da-1.adwentureworks_db.stateprovince` AS province
    ON address.stateprovinceid = province.stateprovinceid;

-- Query used to calculate sales person performance and cumulative sales percentage
WITH TotalSales AS (
    -- Aggregates total sales per salesperson
    SELECT
        salesorder.SalesPersonID,
        SUM(salesorder.TotalDue) AS SumSales  -- Sum of total sales per salesperson
    FROM tc-da-1.adwentureworks_db.salesorderheader salesorder
    LEFT JOIN tc-da-1.adwentureworks_db.salesperson salesperson
        ON salesorder.SalesPersonID = salesperson.SalesPersonID
    GROUP BY salesorder.SalesPersonID
),
RankedSales AS (
    -- Assigns ranking and calculates cumulative totals
    SELECT
        SalesPersonID,
        SumSales,
        RANK() OVER (ORDER BY SumSales DESC) AS Ranking,  -- Rank based on total sales
        SUM(SumSales) OVER (ORDER BY SumSales DESC) AS CumulativeTotal,  -- Running total of sales
        SUM(SumSales) OVER () AS TotalSales  -- Total sales across all salespersons
    FROM TotalSales
),
FinalResult AS (
    -- Rounds values and calculates cumulative percentage
    SELECT
        SalesPersonID,
        ROUND(SumSales, 4) AS SumSales,
        Ranking,
        ROUND(CumulativeTotal, 4) AS CumulativeTotal,
        ROUND(TotalSales, 4) AS TotalSales,
        ROUND((CumulativeTotal * 1.0 / TotalSales), 4) AS CumulativePercent  -- Computes cumulative percentage
    FROM RankedSales
)
-- Retrieves final results ordered by sales amount
SELECT 
  CASE
    WHEN SalesPersonID IS NULL THEN 'Online Sales'
    ELSE CAST(SalesPersonID AS STRING)
  END AS SalesPersonID,
  ROUND(SumSales,2) AS SumSales,
  Ranking,
  ROUND(CumulativeTotal,2) AS CumulativeTotal,
  ROUND(TotalSales, 2) AS TotalSales,
  ROUND(CumulativePercent,3) AS CumulativePercent
FROM FinalResult
ORDER BY 
	SumSales DESC;
-- Query to retrieve individual product details
SELECT 
    prod.ProductID,  
    prod.name AS ProductName,  
    prod.MakeFlag,  
    prod.StandardCost,  
    prod.ListPrice,  -
    -- Categorizes products, assigning 'Uncategorized' if no category is found
    CASE
        WHEN cat.Name IS NULL THEN 'Uncategorized'
        ELSE cat.Name
    END AS CategoryName,
    -- Categorizes subcategories, assigning 'Uncategorized' if no subcategory is found
    CASE
        WHEN subcat.Name IS NULL THEN 'Uncategorized'
        ELSE subcat.Name
    END AS SubcategoryName
FROM tc-da-1.adwentureworks_db.product AS prod
-- Joins product subcategory table
LEFT JOIN tc-da-1.adwentureworks_db.productsubcategory AS subcat 
    ON prod.ProductSubcategoryID = subcat.ProductSubcategoryID
-- Joins product category table
LEFT JOIN tc-da-1.adwentureworks_db.productcategory AS cat 
    ON subcat.ProductCategoryID = cat.ProductCategoryID;

-- Query to retrieve sales reason information
WITH sales_per_reason AS (
    -- Aggregates sales data per sales reason
    SELECT
        sales.SalesOrderID,
        DATE_TRUNC(OrderDate, MONTH) AS year_month,  -- Groups data by month
        sales_reason.SalesReasonID,
        SUM(sales.TotalDue) AS sales_amount  -- Calculates total sales amount per reason
    FROM `tc-da-1.adwentureworks_db.salesorderheader` AS sales
    -- Joins sales reason mapping table
    INNER JOIN `tc-da-1.adwentureworks_db.salesorderheadersalesreason` AS sales_reason
        ON sales.SalesOrderID = sales_reason.SalesOrderID
    GROUP BY 
        SalesOrderID,
        OrderDate,
        SalesReasonID
)
-- Joins with sales reason names
SELECT
    sales_per_reason.SalesOrderID,
    sales_per_reason.SalesReasonID,
    sales_per_reason.year_month,
    reason.Name AS sales_reason,  -- Retrieves reason name
    sales_per_reason.sales_amount
FROM sales_per_reason
LEFT JOIN `tc-da-1.adwentureworks_db.salesreason` AS reason
    ON sales_per_reason.SalesReasonID = reason.SalesReasonID
GROUP BY 
    ALL;

-- Query to retrieve sales order details
SELECT 
    SalesOrderID,  
    SalesOrderDetailID, 
    OrderQty, 
    ProductID,  
    SpecialOfferID,  
    UnitPrice,  
    UnitPriceDiscount,  
    LineTotal  
FROM `tc-da-1.adwentureworks_db.salesorderdetail`;

-- Query to retrieve product cost history
SELECT
    ProductID,  
    StartDate,  
    EndDate,  
    StandardCost  
FROM `tc-da-1.adwentureworks_db.productcosthistory`;

-- Query to retrieve salespersons' names and titles
SELECT
    emp.EmployeeId,  
    cont.FirstName,  
    cont.LastName,  
    cont.FirstName || ' ' || cont.LastName AS FullName,  -- Concatenates first and last name
    emp.Title  -- Employee title
FROM `tc-da-1.adwentureworks_db.employee` AS emp
-- Joins contact table to get personal details
INNER JOIN `tc-da-1.adwentureworks_db.contact` AS cont
    ON emp.ContactID = cont.ContactId
-- Filters to include only salespersons within a specific employee ID range
WHERE emp.EmployeeId BETWEEN 268 AND 290;
