USE sales_db;

/*Cleaning the data*/

SELECT * FROM `e-commerce data analysis project` LIMIT 10;
RENAME TABLE `e-commerce data analysis project` TO e_commerce_data;
select * from e_commerce_data limit 5;

/*Change column names for easy use*/

ALTER TABLE e_commerce_data
CHANGE `Order ID` order_id VARCHAR(50),
CHANGE `Product Category` product_category VARCHAR(100),
CHANGE `Quantity Ordered` quantity_ordered INT,
CHANGE `Price Each` price_each DECIMAL(10,2),
CHANGE `Order Date` order_date VARCHAR(50);
ALTER TABLE e_commerce_data
CHANGE `Purchase Address` purchase_address VARCHAR(1000);
ALTER TABLE e_commerce_data
CHANGE `Time of Day` time_of_day VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;
UPDATE e_commerce_data
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y %H:%i')
WHERE order_date IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;
select * from e_commerce_data limit 5;

/*Revenue & Sales Trend Analysis*/

select month,year(order_date) as 'year',
sum(sales) as totalsales from e_commerce_data
 group by month,year(order_date)
 order by totalsales desc;
 /*Q4 has the maximum sales*/
 
 select round(sum(sales),2) as total_sales, time_of_day
from e_commerce_data group by Time_of_day order by sum(sales) desc;
/*The sales are generally more in Afternoon*/

/*Top-Selling Products & Product Categories*/

select product, sum(sales) from e_commerce_data 
group by product order by sum(sales) desc limit 1;
/*macbook pro is the most selling product by revenue*/

select product, sum(quantity_ordered) from e_commerce_data 
group by product order by sum(quantity_ordered) desc limit 1;
/*AAA batteries are the most ordered product*/

/*City-Level Sales Performance*/
select city, round(avg(sales),2)
from e_commerce_data group by city;
/*Atlanta has the highest average sales*/

select city, 
(sum(sales)/(select sum(sales) from e_commerce_data))*100 as percent
from e_commerce_data group by city;
/*San Francisco has the highest contribution*/

/*Hourly sales analysis*/
select hour, count(*) as total_orders, 
round(sum(sales),2) as total_sales
from e_commerce_data group by hour order by total_orders desc;
/*Sale is high during evening*/

/*Average Order Value (AOV) Analysis*/
SELECT ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value FROM e_commerce_data;
/* average order by month*/
SELECT YEAR(order_date) AS year, month, ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM e_commerce_data GROUP BY YEAR(order_date), MONTH
ORDER BY year, month;

/*average order value by category*/
SELECT product_category, 
ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM e_commerce_data GROUP BY product_category ORDER BY avg_order_value DESC;

/* High volume product and high price product*/
SELECT product, SUM(quantity_ordered) AS total_quantity_sold, ROUND(AVG(price_each), 2) AS avg_price, 
ROUND(SUM(sales), 2) AS total_revenue FROM e_commerce_data GROUP BY product order by total_quantity_sold desc;

/*Check the most contributing products - Pareto analysis*/
WITH product_revenue AS (
    SELECT
        product,
        SUM(sales) AS total_revenue
    FROM e_commerce_data
    GROUP BY product
),
ranked_products AS (
    SELECT product, total_revenue, SUM(total_revenue) OVER () AS overall_revenue, SUM(total_revenue) OVER ( 
ORDER BY total_revenue DESC
        ) AS cumulative_revenue FROM product_revenue
)
SELECT product,
    total_revenue,
    ROUND(100 * cumulative_revenue / overall_revenue, 2) AS cumulative_revenue_pct
FROM ranked_products ORDER BY total_revenue DESC;
/*Top 3 SKUs are contributing to 50% of the companany's revenue*/

/*Monthly growth rate analysis using lag()*/
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS year,month,
        SUM(sales) AS total_sales
    FROM e_commerce_data
    GROUP BY YEAR(order_date), MONTH
)
SELECT
    year,
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
    ROUND(
        100 * (total_sales - LAG(total_sales) OVER (ORDER BY year, month))
        / LAG(total_sales) OVER (ORDER BY year, month),
        2
    ) AS mom_growth_pct
FROM monthly_sales
ORDER BY year, month;

/* Best and worst performing city*/
select product_category, City, round(sum(sales),2) as total_sales,
rank() over (partition by product_category order by sum(sales) DESC) as rnk 
from e_commerce_data group by product_category, city
/*San Francisco is the best performing city and Austin the least*/












