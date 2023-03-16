/*Sales KPI's for 2017 by region*/

SELECT
	region,
    COUNT(Quantity) AS qty_sold,
    ROUND(AVG(sales),2) AS avg_sale,
    ROUND(sum(sales),2) AS total_sales,
    ROUND(sum(profit),2) as total_profit
FROM superstore
WHERE order_year = '2017'
GROUP BY region
ORDER BY region;

/* Sales KPI's for previous year (2016) sales by region */
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


/*Comparing 2017 and 2016 sales*/

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

/* Company wide sales by month and change from previous month*/

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


/* OPERATIONS QUERIES */

/*Review category stats for 2017*/
SELECT 
	category,
    COUNT( DISTINCT category_2) AS sub_categories,
    sum(Quantity) AS num_orders,
    sum(sales) as total_sales,
	MIN(profit),
    AVG(profit),
    MAX(profit),
    ROUND(SUM(profit),2) AS total_profit
FROM superstore
WHERE order_year ='2017'
GROUP BY category
ORDER BY MAX(profit) DESC;


/* Find lead time stats by region */
SELECT 
	region,
    min(datediff(ship_date, order_date)) AS min_lead_time,
	avg(datediff(ship_date, order_date)) AS avg_lead_time,
    max(datediff(ship_date, order_date)) AS max_lead_time
FROM superstore
GROUP BY region
ORDER BY region;

/* Shipping mode lead times */

SELECT
	ship_mode,
    min(datediff(ship_date, order_date)) AS min_lead_time,
    AVG(datediff(ship_date, order_date)) as avg_lead_time,
    MAX(datediff(ship_date, order_date)) AS max_lead_time
FROM superstore
GROUP BY ship_mode;


/* Customer kpi's for 2017FY */

SELECT
	region,
    segment,
    count(DISTINCT cust_id) as cust_count,
    count(DISTINCT State) AS sate_count,
    sum(sales) AS total_sales
FROM superstore
WHERE order_year = '2017'
GROUP BY region, segment
ORDER BY region;
	
