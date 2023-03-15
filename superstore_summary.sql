/*Get total sales for 2017 by region*/

SELECT
	region,
    COUNT(Quantity) AS num_orders,
    ROUND(AVG(sales),2) AS avg_sale,
    ROUND(sum(sales),2) AS total_sales,
    ROUND(sum(profit),2) as total_profit
FROM superstore
WHERE order_year = '2017'
GROUP BY region
ORDER BY region;

/* Get previous year (2016) sales by region */
SELECT
	region,
    order_year AS year,
    COUNT(Quantity) AS num_orders,
    ROUND(AVG(sales),2) AS avg_sale,
    ROUND(sum(sales),2) AS total_sales,
    ROUND(sum(profit),2) as total_profit
FROM superstore
WHERE order_year IN( '2016', '2017')
GROUP BY region, year
ORDER BY region;


/* Find 2017 year sales, previous year sales and change each region*/

WITH year_sales AS
			(SELECT 
            region,
			order_year,
            sum(sales) as total_sales
		FROM superstore
        GROUP BY region, order_year
        ORDER BY region,order_year)
SELECT
	region,
	order_year,
    ROUND(total_sales,2) as year_sales,
    ROUND(lag(total_sales,1) OVER (ORDER BY region, order_year),2) AS prev_sales,
    ROUND(((total_sales) -lag(total_sales,1) OVER (ORDER BY region,order_year)),2) as `change`
FROM year_sales
WHERE order_year IN ('2016','2017')
ORDER BY region;

/* Find 2017 monthly sales, previous month sales and change for all regions*/

WITH month_sales AS
			(SELECT 
			order_month,
            sum(sales) as total_sales
		FROM superstore
        WHERE order_year ='2017'
        GROUP BY order_month
        ORDER BY order_month)
SELECT
	order_month,
    ROUND(total_sales,2) as month_sales,
    ROUND(lag(total_sales,1) OVER (ORDER BY order_month),2) AS prev_sales,
    ROUND(((total_sales) -lag(total_sales,1) OVER (ORDER BY order_month)),2) as `change`
FROM month_sales;


/*Get summary stats by category*/
SELECT 
	category,
	MIN(profit),
    AVG(profit),
    MAX(profit)
FROM superstore
WHERE order_year ='2017'
GROUP BY category
ORDER BY MAX(profit) DESC;


/* Find 2017 monthly sales, previous month sales and change for all regions*/

WITH month_sales AS
			(SELECT 
			order_month,
            sum(sales) as total_sales
		FROM superstore
        WHERE order_year ='2017'
        GROUP BY order_month
        ORDER BY order_month)
SELECT
	order_month,
    ROUND(total_sales,2) as month_sales,
    ROUND(lag(total_sales,1) OVER (ORDER BY order_month),2) AS prev_sales,
    ROUND(((total_sales) -lag(total_sales,1) OVER (ORDER BY order_month)),2) as `change`
FROM month_sales;