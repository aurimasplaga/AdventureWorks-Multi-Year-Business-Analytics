# 📊 Adventureworks: Multi Year Business Analysis

### 🎯 Project Goal
This project analyzes sales performance and revenue distribution within AdventureWorks, identifying key trends, top contributors, and overall business impact. By leveraging SQL and Power BI, the analysis provides insights into sales channels, salesperson effectiveness, and product category performance. The goal is to support executive decision-making by uncovering opportunities for growth, optimizing sales strategies, and improving resource allocation.

### 📄 Project Overview
The project is divided into several key phases:
1. Data Collection & Preparation
2. SQL Query Writing to Pull Information From the Database
3. Visualization with Power BI
4. Insights & Findings
5. Recommendations
6. Conclusion & Future Work

### 🛠 Technologies Used
- **Google BigQuery**: For data querying, aggregation, and analysis across various datasets (Employee, Product, Sales, etc.).
- **Power BI**: For data visualization, creating dashboards, and presenting key insights.
- **GitHub**: For version control and project management.
---

## 1. Data Collection & Preparation

### Data Sources

- **Original Data Source**: The dataset was sourced from the Google BigQuery AdventureWorks database hosted by Turing College.

### Data Cleaning & Transformation

- **Data Cleaning**: The data was pre-cleaned and optimized for analysis.
- **SQL Queries**: SQL queries were employed to extract relevant data for Power BI reporting.
---

## 2. Exploratory Data Analysis (EDA) Using SQL  

### 🔍 Initial Analysis  
- **Data Querying and Aggregation:** SQL queries were employed to extract, aggregate, and summarize key data from multiple tables, such as employee, product, and sales information. This analysis provided valuable insights into sales performance, employee roles, and product categories.  
- **Trend Analysis:** Through the use of grouping and filtering techniques, SQL was utilized to identify trends and patterns in sales performance by different variables like employee role, product category, and geographical region.  

### 📌 Example Query #1  
```sql
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
```
### Sample Query Results (Limit of 10)
| Row | SalesPersonID | SumSales       | Ranking | CumulativeTotal  | TotalSales        | CumulativePercent |
|-----|--------------|---------------|---------|------------------|------------------|------------------|
| 1   | Online Sales | 32441339.12  | 1       | 32441339.12    | 140707584.8246   | 0.231          |
| 2   | 276          | 13975741.46   | 2       | 46417080.58    | 140707584.8246   | 0.33           |
| 3   | 277          | 13434509.55  | 3       | 59851590.13    | 140707584.8246   | 0.425           |
| 4   | 275          | 12433502.84  | 4       | 72285092.97    | 140707584.8246   | 0.514           |
| 5   | 285          | 11384512.99  | 5       | 83669605.96    | 140707584.8246   | 0.595           |
| 6   | 279          | 9629926.9   | 6       | 93299532.85     | 140707584.8246   | 0.663           |
| 7   | 281          | 8761727.29   | 7       | 102061260.14   | 140707584.8246   | 0.725           |
| 8   | 282          | 7967768.8   | 8       | 110029028.94   | 140707584.8246   | 0.782            |
| 9   | 286          | 6083690.96   | 9       | 116112719.90   | 140707584.8246   | 0.825           |
| 10  | 283          | 5029846.91   | 10      | 121142566.81   | 140707584.8246   | 0.861           |

### 📌 Example Query #2
```sql
-- Query to retrieve individual product details
SELECT 
    prod.ProductID,  
    prod.name AS ProductName,  
    prod.MakeFlag,  
    prod.StandardCost,  
    prod.ListPrice,
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
```
### Sample Query Results (Limit of 10)
| Row | ProductID | ProductName         | MakeFlag | StandardCost | ListPrice | CategoryName | SubcategoryName |
|-----|----------|---------------------|----------|--------------|-----------|--------------|----------------|
| 1   | 865      | Classic Vest, M     | 0        | 23.749       | 63.5      | Clothing     | Vests          |
| 2   | 864      | Classic Vest, S     | 0        | 23.749       | 63.5      | Clothing     | Vests          |
| 3   | 866      | Classic Vest, L     | 0        | 23.749       | 63.5      | Clothing     | Vests          |
| 4   | 712      | AWC Logo Cap        | 0        | 6.9223       | 8.99      | Clothing     | Caps           |
| 5   | 861      | Full-Finger Gloves, S | 0      | 15.6709      | 37.99     | Clothing     | Gloves         |
| 6   | 863      | Full-Finger Gloves, L | 0      | 15.6709      | 37.99     | Clothing     | Gloves         |
| 7   | 862      | Full-Finger Gloves, M | 0      | 15.6709      | 37.99     | Clothing     | Gloves         |
| 8   | 858      | Half-Finger Gloves, S | 0      | 9.1593       | 24.49     | Clothing     | Gloves         |
| 9   | 859      | Half-Finger Gloves, M | 0      | 9.1593       | 24.49     | Clothing     | Gloves         |
| 10  | 860      | Half-Finger Gloves, L | 0      | 9.1593       | 24.49     | Clothing     | Gloves         |

### 📌 Example Query #3 
```sql
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
```
### Sample Query Results (Limit of 10)
| Row | EmployeeId | FirstName | LastName   | FullName          | Title                   |
|-----|------------|-----------|------------|-------------------|-------------------------|
| 1   | 270        | Sharon    | Salavaria  | Sharon Salavaria  | Design Engineer         |
| 2   | 269        | Wanida    | Benshoof   | Wanida Benshoof   | Marketing Assistant     |
| 3   | 278        | Garrett   | Vargas     | Garrett Vargas    | Sales Representative    |
| 4   | 276        | Linda     | Mitchell   | Linda Mitchell    | Sales Representative    |
| 5   | 279        | Tsvi      | Reiter     | Tsvi Reiter       | Sales Representative    |
| 6   | 282        | José      | Saraiva    | José Saraiva      | Sales Representative    |
| 7   | 287        | Tete      | Mensa-Annan| Tete Mensa-Annan  | Sales Representative    |
| 8   | 281        | Shu       | Ito        | Shu Ito           | Sales Representative    |
| 9   | 284        | Amy       | Alberts    | Amy Alberts       | European Sales Manager  |
| 10  | 268        | Stephen   | Jiang      | Stephen Jiang     | North American Sales Manager |

[All SQL queries used for aggregating data can be found here.](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/SQL%20Queries/SQL%20Queries.sql)

---

## 3. Visualization with Power BI

The project includes four key dashboards designed to provide valuable insights:

- **[Quarterly Performance Overview](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Performance%20KPIs.png)**: Displays performance metrics across different quarters, such as revenue, profit margins, and growth trends. This dashboard provides an at-a-glance view of the company's overall performance.
  
- **[Sales Insights](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Sales%20Insights.png)**: Focuses on sales efficiency, analyzing top-performing salespersons, product categories, and overall sales trends to identify opportunities for improvement and growth.

- **[Product Analytics](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Product%20Overview.png)**: Offers insights into the performance of individual products, analyzing factors like sales volume, average order value, and profitability. This helps in making data-driven decisions on product portfolio management.

- **[Regional Sales Analysis](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Geographical%20Dashboard.png)**: Breaks down sales data by region, providing a clear view of geographical performance. This dashboard highlights market opportunities and challenges by region, allowing for targeted strategies.

Each dashboard leverages interactive features like filters, drill-downs, and visualizations (charts, tables, and KPIs) to give a comprehensive understanding of the business dynamics.

*Example visuals:*
- **Pareto Analysis of Sales Performance: Revenue Contribution by Salesperson**: 
 ![Pareto Chart](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Pareto%20Chart.png)

- **Monthly Sales Trends: Revenue Performance Over Time**:
![Monthly Chart](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Monthly%20Sales%20Chart.png)

[Interactive Dashboard template can be downloaded here](https://github.com/aurimasplaga/AdventureWorks-Multi-Year-Business-Analytics/blob/main/Dashboards/Template/Multi%20Year%20Business%20Analytics.pbit)

---
## 4. Insights & Findings

- **Sales Trends:**
	- Overall revenue has grown steadily, with notable quarterly and monthly variations. For instance, Year 2 Q1 recorded high revenue despite a dip in profit, suggesting rising costs.
- **Profitability:**
	- Year 1 Q2 had the highest profit, while other quarters showed significant profit declines, indicating potential cost pressures.
- **Sales Channels & Performance:**
	- Offline transactions (87.9% of orders) dominate, and sales are highly concentrated among top performers—the top 5 salespeople contribute over 66% of total revenue.
- **Product & Category Performance:**
	- High-revenue subcategories include Mountain and Road Frames, with Road Bikes leading overall. While top items like the "Water Bottle - 30 oz." and "Fender Set - Mountain" perform well, some apparel items register losses.
- **Geographical Insights:**
	- Key US states such as California and Texas drive sales, and international markets show promising performance, though the US market remains dominant.

---

## 5. Recommendations

- **Cost Optimization:** Investigate cost drivers in high-revenue quarters to improve profit margins.
- **Sales Strategy:** Leverage the strength of offline channels while exploring opportunities to boost online sales.
- **Product Focus:** Prioritize high-margin products and reassess product lines with recurring losses.
- **Targeted Marketing:** Concentrate efforts on high-performing regions and support underperforming sales teams with targeted training and resources.

---

## 6. Conclusion & Future Work

### Project Summary
This analysis provided a clear view of sales and profitability trends, highlighting steady revenue growth but also identifying profit pressure due to rising costs. Key strengths include a dominant offline sales channel, concentrated top performer contributions, and robust performance in select product categories and regions.

### Future Directions
- **Predictive Analytics:** Develop models to forecast trends and manage costs proactively.
- **Real-Time Reporting:** Integrate live data feeds into Power BI for dynamic decision-making.
- **Enhanced Data Integration:** Expand analysis by incorporating more granular customer and cost data.
- **Strategic Adjustments:** Tailor marketing and sales strategies based on regional performance and product profitability insights.
