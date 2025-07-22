create database sql_projects;

drop table  if exists retail_sales;

create table retail_sales
(
transactions_id int primary key,
sale_date date,
sale_time time,
customer_id int,
gender varchar(15), 
age	int,
category varchar(15), 
quantity int,
price_per_unit float, 
cogs float, 
total_sale float
);

select * from retail_sales;

USE sql_projects;
load data local infile 'C:\\Users\\user\\Desktop\\my project\\SQL\\Retail Sales Analysis_utf.csv'
into table retail_sales
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

-- CHECKING TABLE WITH THE FILE
select count(*) from retail_sales;
select * from retail_sales where transactions_id = 679;

-- Correcting columns with 0 to NULL 

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

-- CLEARING DATA 
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

-- deleting rows with null since it doesnt affect sales, except age since there are sales
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

-- DATA EXPLORATION -- 

-- total quantity of sales
select count(*) as total_sales from retail_sales;

-- GENERAL SALES ANALYSIS--

-- total amount of sales
select sum(total_sale) as total_sales from retail_sales; -- 911720 

-- average sale for transaction
select round(avg(total_sale), 2) as average_sale_per_trasaction from retail_sales; -- 456.54

-- total cost of good sold 
select round(sum(cogs),2) as total_cog from retail_sales; -- 189762.7

-- gross profit 
select round(sum(total_sale) - sum(cogs), 2) as gross_profit from retail_sales; -- 721957.3

-- ANALYSIS BY PRODUCT CATEGORIES 

-- which category brings more gross profit
select sum(total_sale) as total_sales, round(sum(cogs),2) as total_cogs, category, round((sum(total_sale)- sum(cogs)), 2) as gross_profit
from retail_sales
group by category
order by gross_profit desc; -- Clothing 

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
order by avg_price desc; -- 184.57	Beauty; 181.9	Electronics; 174.49	Clothing

-- sold quantitis by category
select sum(quantity) as total_quantity_sold, category
from retail_sales 
group by category
order by total_quantity_sold desc; -- 1785	Clothing; 1698	Electronics; 1535	Beauty
 
-- DEMOGRAPHIC ANALYSIS

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

-- SALES ANALYSIS BY TIME

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

-- CLIENT ANALYSIS 
-- amount of customers
select count(distinct customer_id) as total_customers from retail_sales; -- 155

-- top customer by spent amount
select customer_id, sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc
limit 1; -- 3	38440

-- ADDITIONAL QUESTIONS

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

-- ERRORS OF THE FILE: checking age is null, we can fill in ages if we compare customer_id's and extract that info. But if we check customer_id, 
-- the same customer_id has different info about age and gender, which means customer_id is working wrong and needed to be fixed and gives wrong info about unique customers and 
-- total amount of customers and top customer
select * from retail_sales where age is null;

select * from retail_sales where customer_id = 16;
select * from retail_sales where customer_id = 3;

-- END OF THE PROJECT

