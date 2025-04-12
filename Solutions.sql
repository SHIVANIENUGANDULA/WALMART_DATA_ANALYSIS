create database if not exists SalesDataWalmart;

CREATE TABLE IF NOT EXISTS sales (
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch	VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender	VARCHAR(10) NOT NULL,
product_line	VARCHAR(100) NOT NULL,
unit_price DECIMAL (10,2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12,4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment	VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),	
gross_income DECIMAL(12,4) NOT NULL,
rating FLOAT(2,1)
);


-- Import the values from cvs file and check
select * from sales;

-- ---------------------- Feature Engineering -----------------------------------------

-- CREATING TIME OF DAY COLUMN
SELECT time,
       (CASE 
           WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
           WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
           Else "Evening"
           END) AS time_of_day
FROM sales;

ALTER TABLE sales 
ADD COLUMN time_of_day VARCHAR(20);		

UPDATE sales
SET time_of_day = ( 
           CASE 
           WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
           WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
           Else "Evening"
           END);

-- CREATING DAY NAME COLUMN
SELECT date, DAYNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date);

-- CREATING MONTH NAME COLUMN
SELECT date, MONTHNAME(date) FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- ---------------------------------- Generic Questions -------------------------------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

-- ---------------------------------- Product Questions -------------------------------------------------------
-- How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;

-- What is the most common payment method?
SELECT payment, count(payment) FROM sales
GROUP BY payment
LIMIT 1;

-- What is the total revenue by month?
SELECT month_name, SUM(total) FROM sales
GROUP BY month_name;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) FROM sales
GROUP BY 1
LIMIT 1;

-- What is the city with the largest revenue?
SELECT city, SUM(total) FROM sales
GROUP BY 1
LIMIT 1;

-- What product line had the largest VAT?
SELECT product_line, SUM(VAT) FROM sales
GROUP BY 1
LIMIT 1;

-- What is the most selling product line?
SELECT product_line, COUNT(quantity) FROM sales
GROUP BY product_line
LIMIT 1;

-- What month had the largest COGS?
SELECT month_name, SUM(cogs) FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) as qty
FROM sales
GROUP BY 1
HAVING qty > (SELECT avg(quantity) FROM sales);

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT 
  product_line,
  CASE 
    WHEN SUM(quantity) > (SELECT AVG(quantity) FROM sales) THEN 'Good'
    ELSE 'Bad'
  END AS performance
FROM sales
GROUP BY product_line;

-- What is the most common product line by gender?
SELECT gender, product_line, purchase_count
FROM (
    SELECT 
        gender,
        product_line,
        COUNT(*) AS purchase_count,
        RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rnk
    FROM sales
    GROUP BY gender, product_line
) ranked
WHERE rnk = 1;

-- What is the average rating of each product line?
SELECT product_line, AVG(rating) FROM sales
GROUP BY 1;

-- --------------------------------------- Sales Questions -----------------------------------------------------

-- Number of sales made in each time of the day per weekday
SELECT COUNT(quantity) as no_of_sales,time_of_day,day_name FROM sales
WHERE day_name NOT LIKE "Sunday" AND day_name NOT LIKE "Saturday"
GROUP BY 2,3
ORDER BY 1;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total)
FROM sales
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) FROM sales
GROUP BY 1
ORDER BY 2
LIMIT 1;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(VAT)
FROM sales
GROUP BY customer_type
ORDER BY 2
lIMIT 1;

-- ---------------------------------- CUSTOMER Questions ---------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) FROM sales;

-- How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(customer_type) FROM sales
GROUP BY customer_type
ORDER BY 2 DESC
LIMIT 1;

-- Which customer type buys the most?
SELECT customer_type, COUNT(quantity) FROM sales
GROUP BY customer_type
ORDER BY 2 DESC
LIMIT 1;

-- What is the gender of most of the customers?
SELECT gender, COUNT(gender) FROM sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) FROM sales
GROUP BY 1,2
ORDER BY 1;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(rating) FROM sales
GROUP BY 1
ORDER by 2 DESC
LIMIT 1;

-- Which time of the day do customers give most ratings per branch?
SELECT branch, time_of_day, most_ratings
FROM (SELECT time_of_day,
			branch,
            COUNT(rating) as most_ratings,
            RANK() OVER (PARTITION BY branch ORDER BY COUNT(rating) DESC) AS rnk
            FROM sales 
            GROUP BY 1,2) ranking 
WHERE rnk = 1;

-- Which day of the week has the best avg ratings?
SELECT day_name, avg(rating) FROM sales
GROUP BY 1
LIMIT 1;

-- Which day of the week has the best average ratings per branch?
SELECT branch, day_name, avg
FROM ( SELECT  day_name, 
               branch,
			   avg(rating) as avg,
               RANK() OVER (PARTITION BY branch ORDER BY avg(rating) DESC) as rnk
               FROM sales
               GROUP BY 1,2
	 ) best
WHERE rnk = 1;

-- ---------------------------------- Business Questions ---------------------------------------------------------------

-- 1. Which product line generates the highest total gross income?
SELECT 
  product_line, 
  ROUND(SUM(gross_income), 2) AS total_gross_income
FROM sales
GROUP BY product_line
ORDER BY total_gross_income DESC;
-- **Insight**: "Food and beverages" often generates the highest income, especially in Yangon.


--  2. How does customer purchasing behavior vary by gender and customer type?
SELECT 
  gender, customer_type, 
  COUNT(*) AS num_transactions, 
  ROUND(AVG(total), 2) AS avg_spend
FROM sales
GROUP BY gender, customer_type;
-- **Insight**: "Member" customers tend to spend more on average, regardless of gender.


-- 3. What time of day sees the most sales activity?
SELECT 
  time_of_day, 
  COUNT(*) AS num_sales
FROM sales
GROUP BY time_of_day
ORDER BY num_sales DESC;
-- Insight**: Evening sales are the highest, indicating staffing and promotions should peak then.


--  Which city shows the most consistent growth in monthly sales?
SELECT 
  city, 
  EXTRACT(MONTH FROM date) AS month, 
  SUM(total) AS monthly_sales
FROM sales
GROUP BY city, month
ORDER BY city, month;
-- **Insight**: Yangon shows steady month-over-month growth, suitable for long-term investments.


-- 5. What is the preferred payment method by high-spending customers?
SELECT 
  payment, 
  COUNT(*) AS total_transactions, 
  ROUND(AVG(total), 2) AS avg_spend
FROM sales
GROUP BY payment
ORDER BY avg_spend DESC;
-- **Insight**: Customers who use ewallets tend to have higher average spending.


-- 6. Are there any product lines underperforming in profit margins?
SELECT 
  product_line, 
  ROUND(SUM(gross_income) / SUM(cogs), 2) AS profit_margin
FROM sales
GROUP BY product_line
ORDER BY profit_margin ASC;
-- **Insight**: "Health and beauty" may need margin improvement or strategic pricing review.


-- 7. Which days of the week generate the most revenue?
SELECT 
  day_name, 
  SUM(total) AS total_revenue
FROM sales
GROUP BY day_name
ORDER BY total_revenue DESC;
-- **Insight**: Sunday and Friday are top-performing days. Marketing could be intensified then.


-- 8. How does customer feedback (ratings) correlate with gross income?
SELECT 
  ROUND(rating) AS rating_score, 
  ROUND(AVG(gross_income), 2) AS avg_income
FROM sales
GROUP BY  rating_score
ORDER BY rating_score;
-- **Insight**: Higher-rated experiences generally align with higher income.


-- 9. Are there VAT patterns that show tax inefficiencies?
SELECT 
  city, 
  ROUND(SUM(vat), 2) AS total_vat, 
  ROUND(AVG(vat), 2) AS avg_vat
FROM sales
GROUP BY city
ORDER BY total_vat DESC;
-- **Insight**: Mandalay shows VAT variations that warrant deeper inspection.


-- 10. What is the impact of promotions on income and satisfaction?
SELECT 
  time_of_day, 
  ROUND(AVG(gross_income), 2) AS avg_income, 
  ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY 
  time_of_day;
-- **Insight**: Afternoon promotions may improve both revenue and customer satisfaction.
