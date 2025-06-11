-- Data from Kaggle: https://www.kaggle.com/datasets/mohammadtalib786/retail-sales-dataset

-- 1. Take a look and understand this dataset
SELECT * 
FROM retail_sales_dataset;

DESCRIBE retail_sales_dataset;
-- Date is stored as Text, we should convert it to Date

-- Check if there are NULL or Missing Values (row by row)
SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Transaction ID` IS NULL OR `Transaction ID` = '' THEN 1 ELSE 0 END) AS missing_transaction_id
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Date` IS NULL OR `Date` = '' THEN 1 ELSE 0 END) AS missing_date
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Customer ID` IS NULL OR `Customer ID` = '' THEN 1 ELSE 0 END) AS missing_customer_id
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Gender` IS NULL OR `Gender` = '' THEN 1 ELSE 0 END) AS missing_gender
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Age` IS NULL OR `Age` = '' THEN 1 ELSE 0 END) AS missing_age
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Product Category` IS NULL OR `Product Category` = '' THEN 1 ELSE 0 END) AS missing_product_category
FROM retail_sales_dataset;
-- 4 missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Product Code` IS NULL OR `Product Code` = '' THEN 1 ELSE 0 END) AS missing_product_code
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Quantity` IS NULL OR `Quantity` = '' THEN 1 ELSE 0 END) AS missing_quantity
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Price per Unit` IS NULL OR `Price per Unit` = '' THEN 1 ELSE 0 END) AS missing_price_per_unit
FROM retail_sales_dataset;
-- no missing values

SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Total Amount` IS NULL OR `Total Amount` = '' THEN 1 ELSE 0 END) AS missing_total_amount
FROM retail_sales_dataset;
-- no missing values

-- Check for Duplicates (using unique identifier)
SELECT `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Code`,
       `Product Category`, `Quantity`, `Price per Unit`, `Total Amount`,
       COUNT(*) AS count
FROM retail_sales_dataset
GROUP BY `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Code`,
       `Product Category`, `Quantity`, `Price per Unit`, `Total Amount`
HAVING COUNT(*) > 1;

-- Check for Duplicates (assigning row number, good for when there is no unique identifier)
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Code`,`Product Category`, `Quantity`, `Price per Unit`, `Total Amount`) AS row_num
FROM retail_sales_dataset;

# Create subquery or cte to take a look at duplicates:
WITH duplicate_cte AS 
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Code`,`Product Category`, `Quantity`, `Price per Unit`, `Total Amount`) AS row_num
FROM retail_sales_dataset
)
SELECT *
FROM duplicate_cte
WHERE row_num >1;
-- Two duplicates, Transaction ID 129 and 992
-- We need to remove duplicates

-- Let's look at the product categories
SELECT DISTINCT `Product Category` 
FROM retail_sales_dataset;
-- It shows 5 distinct categories, but there should only be 3 product categories: Beauty, Clothing, and Electronics
-- We need to clean the extra spaces and standardize it

-- And Gender
SELECT DISTINCT `Gender` 
FROM retail_sales_dataset;

-- Now let's look at Age
SELECT 
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age
FROM 
    retail_sales_dataset;

-- 2. Data Cleaning
-- Data cleaning tasks:
-- a. Change Date field type to Date
-- b. Remove duplicates
-- c. Standardize product categories
-- d. Handle missing values in product category

-- We first create a new table
CREATE TABLE `retail_sales_dataset2` (
 `Transaction ID` int, 
 `Date` text, 
 `Customer ID` text, 
 `Gender` text, 
 `Age` int, 
 `Product Category` text,
 `Product Code` int,
 `Quantity` int, 
 `Price per Unit` int, 
 `Total Amount` int,
 `row_num` int
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
 
SELECT * 
FROM retail_sales_dataset2;
 
INSERT INTO retail_sales_dataset2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY `Transaction ID`, `Date`, `Customer ID`, `Gender`, `Age`, `Product Category`, `Product Code`, `Quantity`, `Price per Unit`, `Total Amount`) AS row_num
FROM retail_sales_dataset;

-- a. Change Date field type to Date and ensure it is formatted correctly
ALTER TABLE retail_sales_dataset2
ADD COLUMN `formatted_date` VARCHAR(10);

UPDATE retail_sales_dataset2
SET `formatted_date` = STR_TO_DATE(`Date`, '%d-%m-%Y');

SELECT *
FROM retail_sales_dataset2;

-- The formatted date is now correct, we will replace the Date column
ALTER TABLE retail_sales_dataset2
CHANGE COLUMN `Date` `old_date` VARCHAR(10);

ALTER TABLE retail_sales_dataset2
CHANGE COLUMN `formatted_date` `Date` VARCHAR(10);

-- b. Remove duplicates
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM retail_sales_dataset2
WHERE row_num > 1
;

SELECT *
FROM retail_sales_dataset2
WHERE row_num > 1
;
-- Duplicates removed

-- c. Standardize product categories
SELECT `Product Category`,TRIM(`Product Category`)
FROM retail_sales_dataset2;

UPDATE retail_sales_dataset2
SET `Product Category`= TRIM(`Product Category`);

SELECT DISTINCT `Product Category` 
FROM retail_sales_dataset2;

SELECT *
FROM retail_sales_dataset2;

-- d. Handle missing values in product category
SELECT rs.`Product Code`, pc.`Product Code`
FROM retail_sales_dataset2 AS rs
JOIN retail_sales_dataset_product_code AS pc
	ON rs.`Product Code`= pc.`Product Code`
WHERE (rs.`Product Category` IS NULL OR rs.`Product Category` = '');

UPDATE retail_sales_dataset2 AS rs
JOIN retail_sales_dataset_product_code AS pc
  ON rs.`Product Code` = pc.`Product Code`
SET rs.`Product Category` = pc.`Product Category`
WHERE rs.`Product Category` IS NULL OR rs.`Product Category` = '';

-- Check
SELECT 
  COUNT(*) AS total_rows,
  SUM(CASE WHEN `Product Category` IS NULL OR `Product Category` = '' THEN 1 ELSE 0 END) AS missing_product_category
FROM retail_sales_dataset2;

SELECT *
FROM retail_sales_dataset2;

-- Let's remove row_num and save the cleaned data
ALTER TABLE retail_sales_dataset2
DROP COLUMN `row_num`;