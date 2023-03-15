/* ALTER TABLE - altering the superstore table to make query more user friendly */

Select * from superstore limit 5;

| Row ID | Order ID       | Order Date | Ship Date  | Ship Mode      | Customer ID | Customer Name   | Segment   | Country       | City            | State      | Postal Code | Region | Product ID      | Category        | Sub-Category | Product Name                                                | Sales    | Quantity | Discount | Profit   |
|--------|----------------|------------|------------|----------------|-------------|-----------------|-----------|---------------|-----------------|------------|-------------|--------|-----------------|-----------------|--------------|-------------------------------------------------------------|----------|----------|----------|----------|
| 1      | CA-2016-152156 | 2016-11-08 | 2016-11-11 | Second Class   | CG-12520    | Claire Gute     | Consumer  | United States | Henderson       | Kentucky   | 42420       | South  | FUR-BO-10001798 | Furniture       | Bookcases    | Bush Somerset Collection Bookcase                           | 261.96   | 2        | 0        | 41.9136  |
| 2      | CA-2016-152156 | 2016-11-08 | 2016-11-11 | Second Class   | CG-12520    | Claire Gute     | Consumer  | United States | Henderson       | Kentucky   | 42420       | South  | FUR-CH-10000454 | Furniture       | Chairs       | Hon Deluxe Fabric Upholstered Stacking Chairs, Rounded Back | 731.94   | 3        | 0        | 219.582  |
| 3      | CA-2016-138688 | 2016-06-12 | 2016-06-16 | Second Class   | DV-13045    | Darrin Van Huff | Corporate | United States | Los Angeles     | California | 90036       | West   | OFF-LA-10000240 | Office Supplies | Labels       | Self-Adhesive Address Labels for Typewriters by Universal   | 14.62    | 2        | 0        | 6.8714   |
| 4      | US-2015-108966 | 2015-10-11 | 2015-10-18 | Standard Class | SO-20335    | Sean O'Donnell  | Consumer  | United States | Fort Lauderdale | Florida    | 33311       | South  | FUR-TA-10000577 | Furniture       | Tables       | Bretford CR4500 Series Slim Rectangular Table               | 957.5775 | 5        | 0.45     | -383.031 |
| 5      | US-2015-108966 | 2015-10-11 | 2015-10-18 | Standard Class | SO-20335    | Sean O'Donnell  | Consumer  | United States | Fort Lauderdale | Florida    | 33311       | South  | OFF-ST-10000760 | Office Supplies | Storage      | Eldon Fold 'N Roll Cart System                              | 22.368   | 2        | 0.2      | 2.5164   |



/* renaming  columns */

ALTER TABLE superstore 
	RENAME COLUMN `Customer ID` TO cust_id,
    RENAME COLUMN `Customer Name` to cust_name,
    RENAME COLUMN `Postal Code` TO zip,
    RENAME COLUMN `Sub-Category` TO category_2,
    RENAME COLUMN `Product Name` TO product_name,
    RENAME COLUMN `Product ID` TO product_id;

/* SUBSTRING - separating out order day, month and year */

SELECT
    order_date,
    substring_index(order_date, '/' , 1) AS month,
    substring_index(substring_index(order_date, '/' , 2), "/", -1) AS day,
    substring_index(order_date, '/' , -1) AS year
FROM superstore
LIMIT 10;

/* Add new columns for order day, month, year we previously separated out*/

ALTER TABLE superstore
	ADD COLUMN order_month text,
    ADD COLUMN order_day text,
	ADD COLUMN order_year text;
    
UPDATE superstore SET order_month =  substring_index(order_date, '/' , 1);
UPDATE superstore SET order_day =substring_index(substring_index(order_date, '/' , 2), "/", -1);
UPDATE superstore SET order_year = substring_index(order_date, '/' , -1);

SELECT order_date, order_month, order_day, order_year
FROM superstore
limit 10;

/* Re-order ship_date to yyyy-mm-dd */

SELECT
	ship_date,
	concat (
    substring_index(ship_date, '/' , -1),
    "-",
    substring_index(ship_date, '/' , 1),
    "-",
     substring_index(substring_index(ship_date, '/' , 2), "/", -1)
    ) AS new_ship_date
FROM superstore
LIMIT 10;

/* Insert new ship date column */

ALTER TABLE superstore
	ADD COLUMN new_ship_date date;

/* Insert new re-arranged ship date */

UPDATE superstore SET new_ship_date = 
	(concat (
    substring_index(ship_date, '/' , -1),
    "-",
    substring_index(ship_date, '/' , 1),
    "-",
     substring_index(substring_index(ship_date, '/' , 2), "/", -1)));

/* Create & Fill new order_date column because I can't change the type in mysql :( */

ALTER TABLE superstore ADD COLUMN new_order_date date;

UPDATE superstore SET new_order_date = 
(CONCAT (
	order_year,
    "-",
    order_month,
    "-",
    order_day));

/* view new and old columms */
SELECT
    ship_date,
    new_ship_date,
    order_date,
    new_order_date
FROM superstore
LIMIT 50;

/* drop old columns */

ALTER TABLE superstore 
	DROP COLUMN order_date,
	DROP COLUMN ship_date;

/* Rename new columns */

ALTER TABLE superstore
    RENAME COLUMN new_ship_date TO ship_date,
    RENAME COLUMN new_order_date TO order_date;
