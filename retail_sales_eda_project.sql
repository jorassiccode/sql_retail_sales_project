-- Exploratory Data Analysis (EDA)
-- Data from Kaggle: https://www.kaggle.com/datasets/mohammadtalib786/retail-sales-dataset
-- Continuing on from data cleaning project

SELECT *
FROM retail_sales_dataset2;

-- Let's look at the gender distribution of this dataset
SELECT Gender,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM retail_sales_dataset2) AS gender_distribution
FROM retail_sales_dataset2
GROUP BY Gender;
-- Our customers include 49% male and 51% female

-- Now let's look at age group
SELECT 
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM 
    retail_sales_dataset2;
-- Min age is 18 and Max age is 64

-- Now we look at how many customers are in each age group
SELECT 
    CASE 
        WHEN Age < 20 THEN '<20'
        WHEN Age BETWEEN 20 AND 30 THEN '21–30'
        WHEN Age BETWEEN 31 AND 40 THEN '31–40'
        WHEN Age BETWEEN 41 AND 50 THEN '41–50'
        WHEN Age BETWEEN 51 AND 60 THEN '51–60'
        ELSE '60+'
    END AS Age_Group,
    COUNT(*) AS Count
FROM 
    retail_sales_dataset2
GROUP BY 
    Age_Group
ORDER BY 
    Age_Group;
-- Most customers are aged 21-30

-- Now let's look at the product category with highest total sales
SELECT 
    `Product Category`,
    SUM(`Total Amount`) AS Total_Sales
FROM 
    retail_sales_dataset2
GROUP BY 
    `Product Category`
ORDER BY 
    Total_Sales DESC;
-- The product category with the highest sales is Electronics, followed by Clothing, then beauty

-- Now we look at Product Category Popularity by Age Group and Gender
SELECT 
    `Gender`,
    `Product Category`,
    SUM(`Quantity`) AS `Items_Purchased`,
    SUM(`Total Amount`) AS `Total_Spent`
FROM 
    retail_sales_dataset2
GROUP BY 
    `Gender`, `Product Category`
ORDER BY 
    `Gender`, `Items_Purchased` DESC;
-- The popular product category amongst female is Clothing, with the highest spending
-- The popular product category amongst male is Electronics, with the highest spending

-- Now let's do time-based analysis
SELECT YEAR(Date) AS Year, SUM(`Total Amount`) AS yearly_sales
FROM retail_sales_dataset2
GROUP BY YEAR(Date)
ORDER BY yearly_sales DESC;
-- We only have 2023 and 2024 data hence let's look at it monthly instead

SELECT 
  MONTH(`Date`) AS `Month`,
  SUM(CASE WHEN YEAR(`Date`) = 2023 THEN `Total Amount` ELSE 0 END) AS `Sales_2023`,
  SUM(CASE WHEN YEAR(`Date`) = 2024 THEN `Total Amount` ELSE 0 END) AS `Sales_2024`
FROM 
  retail_sales_dataset2
WHERE 
  YEAR(`Date`) IN (2023, 2024)
GROUP BY 
  MONTH(`Date`)
ORDER BY 
  `Sales_2023` DESC
LIMIT 3;
-- We do not have enough data for 2024 so we will look at 2023. 
-- Months with highest sales: May, Oct, Dec
  
-- Highest Sales Month per Product Category
WITH monthly_sales AS (
  SELECT 
    `Product Category`,
    DATE_FORMAT(`Date`, '%Y-%m') AS `Month`,
    SUM(`Total Amount`) AS `Total_Sales`
  FROM 
    retail_sales_dataset2
  GROUP BY 
    `Product Category`, `Month`
),
ranked_sales AS (
  SELECT *,
    RANK() OVER (PARTITION BY `Product Category` ORDER BY `Total_Sales` DESC) AS `rank`
  FROM monthly_sales
)
SELECT 
  `Product Category`,
  `Month`,
  `Total_Sales`
FROM 
  ranked_sales
WHERE 
  `rank` = 1;
-- Sales for Beauty were the highest in Jul 2023, sales for clothing as well as electronics were the highest in May 2023.



