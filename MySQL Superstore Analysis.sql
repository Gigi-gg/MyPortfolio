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

| region  | qty_sold | avg_sale | total_sales | total_profit |
|---------|----------|----------|-------------|--------------|
| Central | 754      | 193.57   | 145949.54   | 8118.23      |
| East    | 887      | 238.06   | 211156.41   | 32989.42     |
| South   | 503      | 242.1    | 121774.58   | 8595.35      |
| West    | 1057     | 232.84   | 246114.03   | 43071.99     |


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

| region  | year | num_orders | avg_sale | total_sales | total_profit |
|---------|------|------------|----------|-------------|--------------|
| Central | 2016 | 583        | 251.77   | 146783.14   | 19734.33     |
| Central | 2017 | 754        | 193.57   | 145949.54   | 8118.23      |
| East    | 2016 | 744        | 238.52   | 177459.35   | 19647.58     |
| East    | 2017 | 887        | 238.06   | 211156.41   | 32989.42     |
| South   | 2016 | 404        | 230.71   | 93207.01    | 17712.84     |
| South   | 2017 | 503        | 242.1    | 121774.58   | 8595.35      |
| West    | 2016 | 773        | 237.8    | 183815.76   | 23035.9      |
| West    | 2017 | 1057       | 232.84   | 246114.03   | 43071.99     |



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

| region  | order_year | year_sales | prev_sales | change     |
|---------|------------|------------|------------|------------|
| Central | 2016       | 146783.14  |            |            |
| Central | 2017       | 145949.54  | 146783.14  | -833.61    |
| East    | 2016       | 177459.35  | 145949.54  | 31509.81   |
| East    | 2017       | 211156.41  | 177459.35  | 33697.06   |
| South   | 2016       | 93207.01   | 211156.41  | -117949.41 |
| South   | 2017       | 121774.58  | 93207.01   | 28567.57   |
| West    | 2016       | 183815.76  | 121774.58  | 62041.18   |
| West    | 2017       | 246114.03  | 183815.76  | 62298.27   |


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

| order_month | month_sales | prev_sales | change    |
|-------------|-------------|------------|-----------|
| 1           | 43860.29    |            |           |
| 2           | 20262.32    | 43860.29   | -23597.96 |
| 3           | 58739.22    | 20262.32   | 38476.9   |
| 4           | 36020.17    | 58739.22   | -22719.05 |
| 5           | 44095.35    | 36020.17   | 8075.18   |
| 6           | 52242.56    | 44095.35   | 8147.21   |
| 7           | 44490.45    | 52242.56   | -7752.11  |
| 8           | 62643.41    | 44490.45   | 18152.96  |
| 9           | 86487.31    | 62643.41   | 23843.9   |
| 10          | 77542.48    | 86487.31   | -8944.82  |
| 11          | 117383.38   | 77542.48   | 39840.9   |
| 12          | 81227.62    | 117383.38  | -36155.77 |



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

| category        | sub_categories | num_orders | total_sales | MIN(profit) | AVG(profit) | MAX(profit) | total_profit |
|-----------------|----------------|------------|-------------|-------------|-------------|-------------|--------------|
| Technology      | 4              | 2348       | 271604.937  | -3839.9904  | 81.67387597 | 6719.9808   | 50637.8      |
| Office Supplies | 9              | 7345       | 241483.265  | -2929.4845  | 20.5371902  | 2504.2216   | 39390.33     |
| Furniture       | 4              | 2358       | 211906.3592 | -1002.7836  | 4.143064706 | 609.7157    | 2746.85      |



/* Find lead time stats by region */
SELECT 
    region,
    min(datediff(ship_date, order_date)) AS min_lead_time,
    avg(datediff(ship_date, order_date)) AS avg_lead_time,
    max(datediff(ship_date, order_date)) AS max_lead_time
FROM superstore
GROUP BY region
ORDER BY region;

| region  | min_lead_time | avg_lead_time | max_lead_time |
|---------|---------------|---------------|---------------|
| Central | 0             | 4.0527        | 7             |
| East    | 0             | 3.897         | 7             |
| South   | 0             | 3.9601        | 7             |
| West    | 0             | 3.9297        | 7             |


/* Shipping mode lead times */

SELECT
    ship_mode,
    min(datediff(ship_date, order_date)) AS min_lead_time,
    AVG(datediff(ship_date, order_date)) as avg_lead_time,
    MAX(datediff(ship_date, order_date)) AS max_lead_time
FROM superstore
GROUP BY ship_mode;

| ship_mode      | min_lead_time | avg_lead_time | max_lead_time |
|----------------|---------------|---------------|---------------|
| Second Class   | 1             | 3.2365        | 5             |
| Standard Class | 3             | 5.0048        | 7             |
| First Class    | 1             | 2.1812        | 4             |
| Same Day       | 0             | 0.0455        | 1             |



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

| region  | segment     | cust_count | sate_count | total_sales |
|---------|-------------|------------|------------|-------------|
| Central | Consumer    | 171        | 13         | 67883.7734  |
| Central | Corporate   | 91         | 11         | 47878.9394  |
| Central | Home Office | 60         | 11         | 30186.8254  |
| East    | Consumer    | 174        | 12         | 94065.954   |
| East    | Corporate   | 107        | 11         | 64555.994   |
| East    | Home Office | 69         | 12         | 52534.464   |
| South   | Consumer    | 119        | 11         | 60405.461   |
| South   | Corporate   | 61         | 10         | 41821.98    |
| South   | Home Office | 40         | 10         | 19547.1385  |
| West    | Consumer    | 197        | 9          | 105314.2685 |
| West    | Corporate   | 118        | 10         | 84539.675   |
| West    | Home Office | 79         | 9          | 56260.088   |

	
