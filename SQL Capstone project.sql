create database amazonsalesdata;

select * from amazon

#Feature Engineering - Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.

alter table amazon
add column timeofday varchar(20);

#Updating the timeofday based on the time column

UPDATE amazon
SET timeofday =
    CASE
        WHEN HOUR(time) >= 5 AND HOUR(time) < 12 THEN 'Morning'
        WHEN HOUR(time) >= 12 AND HOUR(time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END
WHERE time IS NOT NULL;

#Feature Engineering - Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 

ALTER TABLE amazon
add COLUMN dayweek varchar(10);

#Updating the dayweek based on the date column

update amazon
set dayweek = dayname (date) ;

#Feature Engineering - Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar)

ALTER TABLE amazon
ADD COLUMN monthname VARCHAR(10);

#Updating the monthname

update amazon
set monthname = monthname(date);

#Exploratory Data Analysis (EDA) is done to answer the business questions and aims of this project.

#Question :- 1.) What is the count of distinct cities in the dataset?

Select count(distinct city) from amazon

#Question :- 2.) For each branch, what is the corresponding city? 

select distinct(branch) , city from amazon

#Question :- 3.) What is the count of distinct product lines in the dataset?

select count(distinct product_line)from amazon

#Question :- 4.) Which payment method occurs most frequently?

select payment_method, count(*) AS payment_method_count from amazon
group by payment_method
order by payment_method_count desc
limit 1;

#Question :- 5.) Which product line has the highest sales?

SELECT product_line, count(invoice_id) AS sales_count
FROM amazon
GROUP BY product_line
ORDER BY sales_count DESC
LIMIT 1;

#Question :- 6.) How much revenue is generated each month? 

select monthname,sum(total) as revenue_amount from amazon
group by monthname;

#Question :- 7.) In which month did the cost of goods sold reach its peak?

select monthname, sum(cogs) as cogs_sum from amazon
group by monthname
order by cogs_sum
desc limit 1;

#Question :- 8.) Which product line generated the highest revenue?

select product_line, sum(total) as total_sales from amazon
group by product_line order by total_sales desc limit 1;

#Question :- 9.) In which city was the highest revenue recorded?

select city, max(total) as revenue from amazon group by city order by revenue desc;

#Question :- 10.) Which product line incurred the highest Value Added Tax?

select product_line , max(VAT) as max_tax from amazon
group by product_line order by max_tax desc limit 1;

#Question :- 11.) For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

select a1.product_line, a1.cogs,
 case when a1.cogs > a2.avg_sales then "Good" else "Bad"
 end as sales_status
 from amazon as a1
join (select product_line, avg(cogs) as avg_sales from amazon group by product_line) as a2
on a1.product_line=a2.product_line;     

#Question :- 12.) Identify the branch that exceeded the average number of products sold.

select branch, sum(quantity) as products_sold from amazon
group by branch
having sum(quantity) > (select avg(products_sold)
from (select sum(quantity) as products_sold from amazon group by branch) as avg_table);

select branch, sum(quantity) as products_sold
from amazon group by branch;

#Question :- 13.) Which product line is most frequently associated with each gender?

SELECT gender, product_line, frequency
FROM (SELECT gender, product_line, COUNT(*) AS frequency, ROW_NUMBER() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rn FROM amazon
GROUP BY gender, product_line) AS ranked
WHERE rn = 1;

#Question :- 14.) Calculate the average rating for each product line.

SELECT product_line, round(avg(rating),2) AS average_rating
FROM amazon
GROUP BY product_line
order by average_rating desc;

#Question :- 15.) Count the sales occurrences for each time of day on every weekday.

SELECT dayweek, timeofday, COUNT(*) AS sales_occurrences FROM amazon
GROUP BY dayweek, timeofday
ORDER BY dayweek, timeofday;

#Question :- 16.) Identify the customer type contributing the highest revenue.

select customer_type,sum(total) as revenue from amazon
group by customer_type
order by revenue desc limit 1;

#Question :- 17.) Determine the city with the highest VAT percentage.

select city, round(sum(VAT),3) as highest_tax from amazon
group by city order by highest_tax desc;

#Question :- 18.) Identify the customer type with the highest VAT payments.

select customer_type, round(sum(VAT),2) as total_vat_payments from amazon
group by customer_type order by total_vat_payments desc limit 1;

#Question :- 19.) What is the count of distinct customer types in the dataset?

select count(distinct customer_type) as customer_type from amazon;
select distinct customer_type from amazon;

#Question :- 20.) What is the count of distinct payment methods in the dataset?

select count(distinct payment_method) as payment_method from amazon;
select distinct payment_method from amazon;

#Question :- 21.) Which customer type occurs most frequently?

select customer_type, count(*) as count from amazon
group by customer_type
order by count desc;

#Question :- 22.) Identify the customer type with the highest purchase frequency.

select customer_type, count(distinct invoice_id) as purchase_frequency from amazon
group by customer_type 
order by purchase_frequency desc limit 1;

#Question :- 23.) Determine the predominant gender among customers.

select gender, count(*) as gender_count from amazon
group by gender;

#Question :- 24.) Examine the distribution of genders within each branch.

select branch, gender, count(gender) as gender_distribution from amazon
group by branch, gender
order by branch, gender_distribution desc;

#Question :- 25.) Identify the time of day when customers provide the most ratings.

select timeofday, count(rating) as rating_count from amazon
group by timeofday
order by rating_count desc;

#Question :- 26.) Determine the time of day with the highest customer ratings for each branch.

select branch, timeofday, count(rating) as rating_count from amazon
group by branch, timeofday
order by branch;

#Question :- 27.) Identify the day of the week with the highest average ratings.

select dayweek, avg(rating) as avg_rating from amazon
group by dayweek
order by avg_rating desc limit 1; 

#Question :- 28.) Determine the day of the week with the highest average ratings for each branch.

WITH avg_rating_per_day AS (
    SELECT 
        branch, 
        dayweek, 
        AVG(rating) AS average_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS row_num 
    FROM 
        amazon
    GROUP BY 
        branch, dayweek
)
SELECT 
    branch, 
    dayweek, 
    average_rating 
FROM 
    avg_rating_per_day
WHERE 
    row_num = 1;

