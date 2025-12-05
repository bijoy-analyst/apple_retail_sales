select * from sales;
select * from warranty;
select * from products;
select * from category;
select * from stores;

ALTER TABLE sales
ALTER COLUMN sale_date TYPE date
USING TO_DATE(sale_date, 'DD-MM-YYYY');


-- eda
select 
distinct repair_status from warranty;

-- index
create index sales_product_id on sales(product_id);

create index sales_sale_date on sales(sale_date);

create index sales_store_id on sales(store_id);

explain analyze
select * from sales
where product_id = 'P-54';

-- Business Problem
--1 Find the number of stores in each country.
select * from stores

SELECT 
    "Country",
    COUNT(*) AS number_of_stores
FROM stores
GROUP BY 1
ORDER BY 2 DESC;

--2 Calculate the total number of units sold by each store.
 select
 s.store_id,
 st."Store_Name",
 sum(s.quantity)as total_unit_sold
 from sales as s
 join stores as st
 on s.store_id = st."Store_ID"
 group by 1,2
 order by 3 desc
 
--3 Identify how many sales occurred in December 2023.
SELECT 
    COUNT(sale_id) AS total_sale
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';

--4 Determine how many stores have never had a warranty claim filed.
 
 select count(*) from stores
 where "Store_ID" not in
 (
 select distinct store_id 
 from  sales as s
 right join warranty as w
 on s.sale_id = w.sale_id
 );
 
--5 Calculate the percentage of warranty claims marked as "Completed".
 select 
 round(count(claim_id)/(select count(*) from warranty)::numeric * 100,2)as percentage_of_warranty_claims
 from warranty
 where repair_status = 'Completed'
 
--6 Identify which store had the highest total units sold in the last year.
select * from stores
 select
 s.store_id,
 st."Store_Name",
 sum(s.quantity)as total_unit
 from sales as s
 join stores as st
 on s.store_id = st."Store_ID"
 where sale_date >=(current_date - interval'2 year')
 group by 1,2
 order by 3;
 
--7 Count the number of unique products sold in the last year.
select
count(distinct product_id)as unique_product
from sales
where sale_date >= (current_date - interval'2 year')
group by

--8 Find the average price of products in each category.
select 
p."Category_ID",
c.category_name,
round(avg(p."Price"),2)as avg_price
from products as p
join category as c
on p."Category_ID" = c.category_id
group by 1,2
order by 3 desc

--9 How many warranty claims were filed in 2020?
select
count(*)as count_of_warranty_claims
from warranty
WHERE EXTRACT(YEAR FROM CAST(claim_date AS DATE)) = 2024;

--10 For each store, identify the best-selling day based on highest quantity sold.
select * from
(
select
store_id,
to_char(sale_date,'day')as day_name,
sum(quantity) as total_quantity_sold,
rank() over(partition by store_id order by sum(quantity)desc)as ran
from sales
group by 1,2
)x1
where ran = 1

--11 Identify the least selling product in each country for each year based on total units sold.
with rank_table
as
(
select 
st."Country",
p."Product_Name",
sum(s.quantity)as total_quantity_sold,
rank()over(partition by st."Country" order by sum(s.quantity))as rank
from sales as s
join stores as st
on s.store_id = st."Store_ID"
join products as p
on s.product_id = p."Product_ID"
group by 1,2
)
select * from rank_table
where rank = 1

--12 Calculate how many warranty claims were filed within 180 days of a product sale.
SELECT 
    COUNT(*) 
FROM warranty AS w
LEFT JOIN sales AS s
    ON s.sale_id = w.sale_id
WHERE 
    (w.claim_date::date - s.sale_date::date) <= 180;
	
--13 List the months in the last three years where sales exceeded 5,000 units in the USA.
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
    SUM(s.quantity) AS total_quantity_sold
FROM sales AS s
JOIN stores AS st
  ON s.store_id = st."Store_ID"
WHERE st."Country" = 'United States'
  AND s.sale_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY 1
HAVING SUM(s.quantity) > 5000
ORDER BY 1;

--14 Identify the product category with the most warranty claims filed in the last 3 years.
select
c.category_name,
count(w.claim_id)as most_warranty_claims
from warranty as w
join sales as s
on s.sale_id = w.sale_id
join products as p
on p."Product_ID" = s.product_id
join category as c
on c.category_id = p."Category_ID"
where(w.claim_date::date >= current_date - interval '3 year')
group by 1;