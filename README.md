
# Retail Sales Analysis SQL Project

## Project Overview

This project presents a comprehensive analysis of retail sales data using SQL. The goal of the project is to extract valuable business insights from transaction data, identify key performance indicators, understand customer behavior, and determine sales trends.

The project covers the following stages:

-   Database structure creation.
    
-   Data import from a CSV file.
    
-   Data cleaning and preprocessing.
    
-   Data exploration to obtain basic statistics.
    
-   In-depth analysis of business questions covering general sales, product categories, customer demographics, and temporal trends.
    
-   Identification of data quality issues and their implications.
    

## Dataset

The `Retail Sales Analysis_utf.csv` dataset contains information about retail sales transactions. It includes the following columns:

-   `transactions_id`: Unique transaction identifier.
    
-   `sale_date`: Date of sale.
    
-   `sale_time`: Time of sale.
    
-   `customer_id`: Customer identifier.
    
-   `gender`: Customer's gender.
    
-   `age`: Customer's age.
    
-   `category`: Category of the product sold.
    
-   `quantity`: Quantity of items sold.
    
-   `price_per_unit`: Price per unit of the item.
    
-   `cogs`: Cost of goods sold.
    
-   `total_sale`: Total sale amount.
    

## Database Setup and Data Import (MySQL)

To reproduce this analysis, you will need a MySQL server installed.

### 1. Database and Table Creation

```
create database sql_projects;

drop table  if exists retail_sales;

create table retail_sales
(
transactions_id int primary key,
sale_date date,
sale_time time,
customer_id int,
gender varchar(15), 
age int,
category varchar(15), 
quantity int,
price_per_unit float, 
cogs float, 
total_sale float
);

```

### 2. Data Import

To import data from `Retail Sales Analysis_utf.csv`, use the `LOAD DATA LOCAL INFILE` command.

**Important notes before importing:**

-   **`local_infile`:** To use `LOAD DATA LOCAL INFILE`, this option must be enabled on both the MySQL server side and the client side.
    
    -   **On the server:** Add `local_infile=1` to the `[mysqld]` section of your `my.ini` (or `my.cnf`) file and restart the MySQL server.
        
        -   Example path to `my.ini` on Windows: `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini`
            
    -   **On the client (MySQL Workbench):** In the connection settings (usually under the "Advanced" or "SSL" tab), add `OPT_LOCAL_INFILE=1` in the "Others" or "Connection Arguments" field. Then reconnect to the server.
        
-   **File Path:** Ensure that the path to your CSV file `C:\Users\user\Desktop\Retail Sales Analysis_utf.csv` is absolutely accurate. Use forward slashes (`/`) or double backslashes (`\\`) in the path.
    

```
USE sql_projects;
load data local infile 'C:\\Users\\user\\Desktop\\my project\\SQL\\Retail Sales Analysis_utf.csv'
into table retail_sales
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

```

**Verify Import:**

```
select count(*) from retail_sales;
select * from retail_sales where transactions_id = 679;

```

## Data Cleaning and Preprocessing

After data import, cleaning steps were performed to ensure the quality of the analysis.

### 1. Correcting `0` to `NULL` in Numeric Columns

During import, empty values in the CSV file might have been interpreted as `0` in numeric columns. The following queries convert `0` back to `NULL` for fields where `0` is not a logically valid value (e.g., for missing data).

```
UPDATE retail_sales
SET sale_date = NULL
WHERE sale_date = 0;

UPDATE retail_sales
SET sale_time = NULL
WHERE sale_time = 0;

UPDATE retail_sales
SET customer_id = NULL
WHERE customer_id = 0;

UPDATE retail_sales
SET age = NULL
WHERE age = 0;

UPDATE retail_sales
SET quantity = NULL
WHERE quantity = 0;

UPDATE retail_sales
SET  price_per_unit= NULL
WHERE price_per_unit = 0;

UPDATE retail_sales
SET  cogs= NULL
WHERE cogs = 0;

UPDATE retail_sales
SET  total_sale= NULL
WHERE total_sale = 0;

```

### 2. Deleting Rows with `NULL` Values

Rows with missing critical transaction data (excluding age, as sales could have occurred) were deleted.

```
Select * from retail_sales
where 
transactions_id is null
or  
sale_date is null
or
sale_time is null
or  
customer_id is null
or 
gender is null
or 
age is null
or  
category is null
or 
quantity is null
or 
price_per_unit is null
or  
cogs is null
or 
total_sale is null;

delete from retail_sales
where 
transactions_id is null
or  
sale_date is null
or
sale_time is null
or  
customer_id is null
or 
gender is null
or  
category is null
or 
quantity is null
or 
price_per_unit is null
or  
cogs is null
or 
total_sale is null;

```

## Data Exploration

Basic queries to understand the overall volume and uniqueness of the data.

```
-- total quantity of sales
select count(*) as total_sales from retail_sales;

-- amount of unique customers
select count(distinct customer_id) as total_customers from retail_sales;

-- Unique product categories
select distinct category FROM retail_sales;

```

## Data Analysis and Business Insights

### General Sales Analysis

```
-- total amount of sales
select sum(total_sale) as total_sales from retail_sales; 

-- average sale for transaction
select round(avg(total_sale), 2) as average_sale_per_trasaction from retail_sales; 

-- total cost of good sold 
select round(sum(cogs),2) as total_cog from retail_sales; 

-- gross profit 
select round(sum(total_sale) - sum(cogs), 2) as gross_profit from retail_sales; 

```

### Analysis by Product Categories

```
-- which category brings more gross profit
select sum(total_sale) as total_sales, round(sum(cogs),2) as total_cogs, category, round((sum(total_sale)- sum(cogs)), 2) as gross_profit
from retail_sales
group by category
order by gross_profit desc; 

-- percentage margin profit by category 
select category, 
round(((sum(total_sale)-sum(cogs))/sum(total_sale))*100,2) as margin_profit
from retail_sales
group by category
order by margin_profit desc;

-- average price per unit by category 
select round(avg(price_per_unit), 2) as avg_price, category
from retail_sales 
group by category
order by avg_price desc; 

-- sold quantitis by category
select sum(quantity) as total_quantity_sold, category
from retail_sales 
group by category
order by total_quantity_sold desc; 

```

### Demographic Analysis

```
-- sales distribution by gender: total_sales, transactions, average sum for transaction
select gender, sum(total_sale) as total_sales, count(transactions_id) as number_of_transactions, 
round(avg(total_sale),2) as avg_sum_of_purchase
from retail_sales
group by gender
order by total_sales desc;

-- sales distribution by age group: total_sales, transactions, average sum for transaction
select 
case 
	when age is null then 'unknown'
    when age between 18 and 19 then 'Teen'
    when age between 20 and 39 then 'Young Adult'
    when age between 40 and 59 then 'Middle Age Adult'
    when age >=60 then 'Senior Adult'
    else 'Another'
end as age_group, 
sum(total_sale) as total_sales, count(transactions_id) as number_of_transactions, 
round(avg(total_sale),2) as avg_sum_of_purchase
from retail_sales
group by age_group
order by total_sales desc;

-- popular category by gender
select gender, category,
count(transactions_id) as number_of_transactions, 
sum(total_sale) as total_sales,  
round(avg(total_sale), 2) as avg_sum_of_purchase   
from retail_sales
group by gender, category
order by number_of_transactions desc;

```

### Sales Analysis by Time

```
-- sales by year
select year(sale_date) as sale_year, sum(total_sale) as total_sales
from retail_sales
group by sale_year
order by sale_year desc;

-- sales by year and month
select date_format(sale_date, '%Y-%m') sale_month, sum(total_sale) as total_sales
from retail_sales
group by sale_month
order by total_sales desc;

-- popular time for purchase
select 
case 
	when sale_time between '05:00:00' and '11:59:59' then 'Morning'
	when sale_time between '12:00:00' and '17:59:59' then 'Day'
    when sale_time between '18:00:00' and '21:59:59' then 'Evening'
	when sale_time>= '22:00:00' or sale_time <'05:00:00' then 'Night'
    else 'Another'
    end as time_of_day, 
      count(transactions_id) as number_of_transactions
from retail_sales
group by time_of_day
order by number_of_transactions desc;

```

### Client Analysis

```
-- amount of customers
select count(distinct customer_id) as total_customers from retail_sales; 

-- top customer by spent amount
select customer_id, sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc
limit 1; 

```

### Additional Questions

```
-- retrieve all columns for sales made on '2022-11-05
select * from retail_sales
where sale_date = '2022-11-05';

-- retrieve all transactions where the category is 'Clothing' and the quantity sold is qual or more than 4 in the month of Nov-2022
select * from retail_sales
where 
	category = 'Clothing'
	and 
    quantity>=4 
    and 
    date_format(sale_date, '%Y-%m') = '2022-11';
    
-- retrieve all transactions where the total_sale is greater than 1000
select * from retail_sales
where total_sale > 1000;

```

## Data Quality Insights (Important!)

During the analysis, a **critical data quality issue** was identified in the `customer_id` column.

```
-- Example query that revealed the issue:
select * from retail_sales where age is null;

select * from retail_sales where customer_id = 16;

```

Upon checking `customer_id`, it was observed that the same `customer_id` can be associated with different `gender` and `age` values. This implies that `customer_id` in the current dataset **is not a reliable unique identifier for an individual customer**.

**Implications:**

-   Metrics based on `COUNT(DISTINCT customer_id)` (e.g., "total number of unique customers") and "top customer" analyses might be **inaccurate** regarding actual unique individuals.
    
-   Demographic analysis linked to `customer_id` may be skewed.
    

**Recommendations:**

-   In a real project, further investigation into the data source would be required to understand the true meaning of `customer_id` or to find an alternative unique customer identifier.
    
-   When presenting results, it is crucial to highlight this data limitation.
    

## Conclusion

This SQL project demonstrates the ability to perform comprehensive retail sales data analysis, identify key trends, segment customers and products, and critically evaluate data quality. The insights gained can be used to make informed business decisions in marketing, inventory management, and strategic planning.

