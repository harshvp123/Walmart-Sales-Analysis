SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;  

SELECT payment_method,COUNT(*)
FROM walmart
GROUP BY payment_method


SELECT MAX(quantity)
FROM walmart;

--Business Problems
--Q1.Find different Payment Methods,Number of Transactions and Number of Quantity Sold.
SELECT payment_method,COUNT(*) as Total_Transactions,SUM(quantity) as Total_Quantity
FROM walmart
GROUP BY payment_method;

--Q2.Identify highest-rated category in each branch,display branch,category rating,AVG RATING
SELECT * FROM
(SELECT branch,category,
       AVG(rating) as average_rating,
	   RANK() OVER(PARTITION BY branch ORDER BY AVG(rating)DESC) as rank
FROM walmart
GROUP BY 1,2)
WHERE rank = 1;

--Q3.Identify the busiest day for each branch based on the number of transactions.
SELECT * FROM
(SELECT branch,
      TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') as day_name,
	  COUNT(*) as Total_Transaction,
	  RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC ) as rank
FROM walmart
GROUP BY 1,2)
WHERE rank=1;

--Q4.Calculate the total quantity of items sold per payment method.
SELECT payment_method,SUM(quantity) as quantity_sold
FROM walmart
GROUP BY payment_method;

--Q5.Determine the average,minimum and maximum rating of products for each city.
SELECT city,
       category,
	   AVG(rating) as average_rating,
	   MIN(rating) as minimum_rating,
	   MAX(rating) as maximum_rating
FROM walmart	
GROUP BY 1,2;

--Q6.Calculate the total profit for each category by considering total profit as (unit_price * quantity * profit_margin)
SELECT category,
       SUM(unit_price * profit_margin * quantity) as profit
FROM walmart 
GROUP BY 1;

--Q7.Determine the most common payment method for each branch.
WITH cte
AS
(SELECT branch,
        payment_method,
		COUNT(*) as total_transaction,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2)
SELECT *
FROM cte
WHERE rank=1;

--Q8.Categorize sales into three groups:Morning,Afternoon,Evening
-----Find out which of the shift and number of invoices.
SELECT branch,
CASE
     WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
	 WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	 ELSE 'Evening'
 END day_time,
 COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

--Q9.Identify 5 branch with highest decrease ratio in revenue
-----compare to last year.
SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;