##Retail Sales Analysis SQL Project		
                
Project Overview
This project presents a comprehensive analysis of retail sales data using SQL. The goal of the project is to extract valuable business insights from transaction data, identify key performance indicators, understand customer behavior, and determine sales trends.

The project covers the following stages:

Database structure creation.

Data import from a CSV file.

Data cleaning and preprocessing.

Data exploration to obtain basic statistics.

In-depth analysis of business questions covering general sales, product categories, customer demographics, and temporal trends.

Identification of data quality issues and their implications.

Dataset
The Retail Sales Analysis_utf.csv dataset contains information about retail sales transactions. It includes the following columns:

transactions_id: Unique transaction identifier.

sale_date: Date of sale.

sale_time: Time of sale.

customer_id: Customer identifier.

gender: Customer's gender.

age: Customer's age.

category: Category of the product sold.

quantity: Quantity of items sold.

price_per_unit: Price per unit of the item.

cogs: Cost of goods sold.

total_sale: Total sale amount.

Database Setup and Data Import (MySQL)
To reproduce this analysis, you will need a MySQL server installed.

1. Database and Table Creation
-- Create database
CREATE DATABASE IF NOT EXISTS sql_projects;

-- Use the created database
USE sql_projects;

-- Drop table if it exists (for a clean start)
DROP TABLE IF EXISTS retail_sales;

-- Create retail_sales table
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(15),
    age INT,
    category VARCHAR(15),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

2. Data Import
To import data from Retail Sales Analysis_utf.csv, use the LOAD DATA LOCAL INFILE command.

Important notes before importing:

local_infile: To use LOAD DATA LOCAL INFILE, this option must be enabled on both the MySQL server side and the client side.

On the server: Add local_infile=1 to the [mysqld] section of your my.ini (or my.cnf) file and restart the MySQL server.

Example path to my.ini on Windows: C:\ProgramData\MySQL\MySQL Server 8.0\my.ini

On the client (MySQL Workbench): In the connection settings (usually under the "Advanced" or "SSL" tab), add OPT_LOCAL_INFILE=1 in the "Others" or "Connection Arguments" field. Then reconnect to the server.

File Path: Ensure that the path to your CSV file C:\Users\user\Desktop\Retail Sales Analysis_utf.csv is absolutely accurate. Use forward slashes (/) or double backslashes (\\) in the path.

USE sql_projects;

LOAD DATA LOCAL INFILE 'C:/Users/user/Desktop/Retail Sales Analysis_utf.csv'
-- Or 'C:\\Users\\user\\Desktop\\Retail Sales Analysis_utf.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES; -- Skip the header row

Verify Import:

SELECT COUNT(*) FROM retail_sales;
SELECT * FROM retail_sales WHERE transactions_id = 679; -- Example to check a specific row

Data Cleaning and Preprocessing
After data import, cleaning steps were performed to ensure the quality of the analysis.

1. Correcting 0 to NULL in Numeric Columns
During import, empty values in the CSV file might have been interpreted as 0 in numeric columns. The following queries convert 0 back to NULL for fields where 0 is not a logically valid value (e.g., for missing data).

UPDATE retail_sales SET age = NULL WHERE age = 0;
UPDATE retail_sales SET quantity = NULL WHERE quantity = 0;
UPDATE retail_sales SET price_per_unit = NULL WHERE price_per_unit = 0;
UPDATE retail_sales SET cogs = NULL WHERE cogs = 0;
UPDATE retail_sales SET total_sale = NULL WHERE total_sale = 0;

-- Note: For sale_date, sale_time, customer_id, if they were imported as 0,
-- this could also indicate issues, but they usually import as NULL
-- or throw an error if they don't match the data type.
-- UPDATE retail_sales SET sale_date = NULL WHERE sale_date = '0000-0000-00'; -- If dates were imported as 0
-- UPDATE retail_sales SET sale_time = NULL WHERE sale_time = '00:00:00'; -- If times were imported as 0
-- UPDATE retail_sales SET customer_id = NULL WHERE customer_id = 0;

2. Deleting Rows with NULL Values
Rows with missing critical transaction data (excluding age, as sales could have occurred) were deleted.

SELECT * FROM retail_sales
WHERE
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    -- OR age IS NULL -- Age is not deleted as sales could have occurred
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

DELETE FROM retail_sales
WHERE
    transactions_id IS NULL
    OR sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;

Data Exploration
Basic queries to understand the overall volume and uniqueness of the data.

-- Total number of sales (transactions)
SELECT COUNT(*) AS total_transactions FROM retail_sales;

-- Total number of unique customers
SELECT COUNT(DISTINCT customer_id) AS total_unique_customers FROM retail_sales;

-- Unique product categories
SELECT DISTINCT category FROM retail_sales;

Data Analysis and Business Insights
General Sales Analysis
-- Total sales amount
SELECT SUM(total_sale) AS total_sales FROM retail_sales;

-- Average sale per transaction
SELECT ROUND(AVG(total_sale), 2) AS average_sale_per_transaction FROM retail_sales;

-- Total cost of goods sold
SELECT ROUND(SUM(cogs), 2) AS total_cogs FROM retail_sales;

-- Gross profit
SELECT ROUND(SUM(total_sale) - SUM(cogs), 2) AS gross_profit FROM retail_sales;

Analysis by Product Categories
-- Categories generating the most gross profit
SELECT
    category,
    SUM(total_sale) AS total_sales,
    ROUND(SUM(cogs), 2) AS total_cogs,
    ROUND((SUM(total_sale) - SUM(cogs)), 2) AS gross_profit
FROM retail_sales
GROUP BY category
ORDER BY gross_profit DESC;

-- Percentage profit margin by category
SELECT
    category,
    ROUND(((SUM(total_sale) - SUM(cogs)) / SUM(total_sale)) * 100, 2) AS margin_profit_percentage
FROM retail_sales
GROUP BY category
ORDER BY margin_profit_percentage DESC;

-- Average price per unit by category
SELECT
    category,
    ROUND(AVG(price_per_unit), 2) AS avg_price_per_unit
FROM retail_sales
GROUP BY category
ORDER BY avg_price_per_unit DESC;

-- Total quantity sold by category
SELECT
    category,
    SUM(quantity) AS total_quantity_sold
FROM retail_sales
GROUP BY category
ORDER BY total_quantity_sold DESC;

Demographic Analysis
-- Sales distribution by gender: total sales, transactions, average purchase amount
SELECT
    gender,
    SUM(total_sale) AS total_sales,
    COUNT(transactions_id) AS number_of_transactions,
    ROUND(AVG(total_sale), 2) AS avg_sum_of_purchase
FROM retail_sales
GROUP BY gender
ORDER BY total_sales DESC;

-- Sales distribution by age group: total sales, transactions, average purchase amount
SELECT
    CASE
        WHEN age IS NULL THEN 'unknown'
        WHEN age BETWEEN 18 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 39 THEN 'Young Adult'
        WHEN age BETWEEN 40 AND 59 THEN 'Middle Age Adult'
        WHEN age >= 60 THEN 'Senior Adult'
        ELSE 'Another'
    END AS age_group,
    SUM(total_sale) AS total_sales,
    COUNT(transactions_id) AS number_of_transactions,
    ROUND(AVG(total_sale), 2) AS avg_sum_of_purchase
FROM retail_sales
GROUP BY age_group
ORDER BY total_sales DESC;

-- Popular categories by gender
SELECT
    gender,
    category,
    COUNT(transactions_id) AS number_of_transactions,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale), 2) AS avg_sum_of_purchase
FROM retail_sales
GROUP BY gender, category
ORDER BY gender, number_of_transactions DESC;

Sales Analysis by Time
-- Sales by year
SELECT
    YEAR(sale_date) AS sale_year,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_year
ORDER BY sale_year DESC;

-- Sales by year and month
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY sale_month
ORDER BY total_sales DESC;

-- Popular time for purchase (by shift)
SELECT
    CASE
        WHEN TIME(sale_time) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
        WHEN TIME(sale_time) BETWEEN '12:00:00' AND '17:59:59' THEN 'Day'
        WHEN TIME(sale_time) BETWEEN '18:00:00' AND '21:59:59' THEN 'Evening'
        WHEN TIME(sale_time) >= '22:00:00' OR TIME(sale_time) < '05:00:00' THEN 'Night'
        ELSE 'Another'
    END AS time_of_day,
    COUNT(transactions_id) AS number_of_transactions,
    SUM(total_sale) AS total_sales_in_shift,
    ROUND(AVG(total_sale), 2) AS average_sale_in_shift
FROM retail_sales
GROUP BY time_of_day
ORDER BY number_of_transactions DESC;

Client Analysis
-- Total number of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales;

-- Top customer by amount spent
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 1;

Additional Questions
-- Retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Retrieve all transactions where the category is 'Clothing' and the quantity sold is
-- greater than 4 in the month of Nov-2022
SELECT * FROM retail_sales
WHERE
    category = 'Clothing'
    AND quantity > 4
    AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';

-- Retrieve all transactions where total_sale is greater than 1000
SELECT * FROM retail_sales
WHERE total_sale > 1000;

Data Quality Insights (Important!)
During the analysis, a critical data quality issue was identified in the customer_id column.

-- Example query that revealed the issue:
SELECT customer_id, gender, age, COUNT(*) AS num_transactions
FROM retail_sales
WHERE customer_id = 16 -- Example customer_id that showed inconsistencies
GROUP BY customer_id, gender, age
HAVING COUNT(*) > 1; -- If the same customer_id has different gender/age

Upon checking customer_id, it was observed that the same customer_id can be associated with different gender and age values. This implies that customer_id in the current dataset is not a reliable unique identifier for an individual customer.

Implications:

Metrics based on COUNT(DISTINCT customer_id) (e.g., "total number of unique customers") and "top customer" analyses might be inaccurate regarding actual unique individuals.

Demographic analysis linked to customer_id may be skewed.

Recommendations:

In a real project, further investigation into the data source would be required to understand the true meaning of customer_id or to find an alternative unique customer identifier.

When presenting results, it is crucial to highlight this data limitation.

Conclusion
This SQL project demonstrates the ability to perform comprehensive retail sales data analysis, identify key trends, segment customers and products, and critically evaluate data quality. The insights gained can be used to make informed business decisions in marketing, inventory management, and strategic planning.
