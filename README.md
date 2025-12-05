# Apple Retail Sales SQL Project -- Business Problem Solutions

This project analyzes Apple retail sales, stores, products, and warranty
data using SQL. Below is the list of business questions and their
corresponding SQL queries.

------------------------------------------------------------------------

## **1. Number of stores in each country**

``` sql
SELECT "Country", COUNT(*) AS number_of_stores
FROM stores
GROUP BY 1
ORDER BY 2 DESC;
```

## **2. Total units sold by each store**

``` sql
SELECT s.store_id, st."Store_Name", SUM(s.quantity) AS total_unit_sold
FROM sales AS s
JOIN stores AS st ON s.store_id = st."Store_ID"
GROUP BY 1,2
ORDER BY 3 DESC;
```

## **3. Number of sales in December 2023**

``` sql
SELECT COUNT(sale_id) AS total_sale
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';
```

## **4. Stores with no warranty claim filed**

``` sql
SELECT COUNT(*) 
FROM stores
WHERE "Store_ID" NOT IN (
    SELECT DISTINCT store_id 
    FROM sales AS s
    RIGHT JOIN warranty AS w ON s.sale_id = w.sale_id
);
```

## **5. Percentage of warranty claims marked as Completed**

``` sql
SELECT ROUND(COUNT(claim_id) / (SELECT COUNT(*) FROM warranty)::numeric * 100, 2) AS percentage_of_warranty_claims
FROM warranty
WHERE repair_status = 'Completed';
```

## **6. Store with the highest units sold in the last year**

``` sql
SELECT s.store_id, st."Store_Name", SUM(s.quantity) AS total_unit
FROM sales AS s
JOIN stores AS st ON s.store_id = st."Store_ID"
WHERE sale_date >= (CURRENT_DATE - INTERVAL '2 year')
GROUP BY 1,2
ORDER BY 3 DESC;
```

## **7. Unique products sold in the last year**

``` sql
SELECT COUNT(DISTINCT product_id) AS unique_product
FROM sales
WHERE sale_date >= (CURRENT_DATE - INTERVAL '2 year');
```

## **8. Average price of products by category**

``` sql
SELECT p."Category_ID", c.category_name, ROUND(AVG(p."Price"), 2) AS avg_price
FROM products AS p
JOIN category AS c ON p."Category_ID" = c.category_id
GROUP BY 1,2
ORDER BY 3 DESC;
```

## **9. Warranty claims filed in 2020**

``` sql
SELECT COUNT(*) AS count_of_warranty_claims
FROM warranty
WHERE EXTRACT(YEAR FROM CAST(claim_date AS DATE)) = 2024;
```

## **10. Best-selling day for each store**

``` sql
SELECT * FROM (
    SELECT store_id, TO_CHAR(sale_date,'day') AS day_name,
           SUM(quantity) AS total_quantity_sold,
           RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS ran
    FROM sales
    GROUP BY 1,2
) x1
WHERE ran = 1;
```

## **11. Least-selling product in each country**

``` sql
WITH rank_table AS (
    SELECT st."Country", p."Product_Name", SUM(s.quantity) AS total_quantity_sold,
           RANK() OVER(PARTITION BY st."Country" ORDER BY SUM(s.quantity)) AS rank
    FROM sales AS s
    JOIN stores AS st ON s.store_id = st."Store_ID"
    JOIN products AS p ON s.product_id = p."Product_ID"
    GROUP BY 1,2
)
SELECT * FROM rank_table
WHERE rank = 1;
```

## **12. Warranty claims filed within 180 days of sale**

``` sql
SELECT COUNT(*)
FROM warranty AS w
LEFT JOIN sales AS s ON s.sale_id = w.sale_id
WHERE (w.claim_date::date - s.sale_date::date) <= 180;
```

## **13. Months in last 3 years when USA sales exceeded 5000 units**

``` sql
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS month, SUM(s.quantity) AS total_quantity_sold
FROM sales AS s
JOIN stores AS st ON s.store_id = st."Store_ID"
WHERE st."Country" = 'United States'
  AND s.sale_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1
HAVING SUM(s.quantity) > 5000
ORDER BY 1;
```

## **14. Category with the most warranty claims (last 3 years)**

``` sql
SELECT c.category_name, COUNT(w.claim_id) AS most_warranty_claims
FROM warranty AS w
JOIN sales AS s ON s.sale_id = w.sale_id
JOIN products AS p ON p."Product_ID" = s.product_id
JOIN category AS c ON c.category_id = p."Category_ID"
WHERE w.claim_date::date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY 1;
```

