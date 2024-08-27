## 1.	Provide the list of markets in which customer  "Atliq  Exclusive"  
##  operates its  business in the  APAC  region. 
SELECT Market, Customer, region from dim_customer where customer = "atliq Exclusive"
and region = "apac";
## 2.What is the percentage of unique product increase in 2021 vs. 2020? The  final output contains these fields,  
##   unique_products_2020  unique_products_2021  percentage_chg
Select * from fact_sales_monthly;
with Unique_products_2020 as (
Select count(distinct product) as dis2020 from dim_product dp
join fact_sales_monthly fsm on dp.product_code = fsm.product_code 
where fiscal_year = 2020),
Unique_products_2021 as (Select count(distinct product) as dis2021 from dim_product dp
join fact_sales_monthly fsm on dp.product_code = fsm.product_code 
where fiscal_year = 2021)
Select dis2020,dis2021,
Round((dis2021 - dis2020)/dis2020*100,2) as percentage_chg from
Unique_products_2020,Unique_products_2021;
## 3 Provide a report with all the unique product counts for each segment and
##   sort them in descending order of product counts. The final output contains 2 fields
##  segment, product_count
Select segment, count(distinct product) as product_count from dim_product dp
join fact_sales_monthly fsm on dp.product_code = fsm.product_code group by segment;
## 4 Follow-up: Which segment had the most increase in unique products in
## 2021 vs 2020? The final output contains these fields,segment, product_count_2020, product_count_2021,difference
WITH Unique_products_2020 AS (
    SELECT 
        segment, 
        COUNT(DISTINCT product) AS product_count_2020
    FROM 
        dim_product dp
    JOIN 
        fact_sales_monthly fsm 
    ON 
        dp.product_code = fsm.product_code 
    WHERE 
        fiscal_year = 2020 
    GROUP BY 
        segment
),
Unique_products_2021 AS (
    SELECT 
        segment, 
        COUNT(DISTINCT product) AS product_count_2021
    FROM 
        dim_product dp
    JOIN 
        fact_sales_monthly fsm 
    ON 
        dp.product_code = fsm.product_code 
    WHERE 
        fiscal_year = 2021 
    GROUP BY 
        segment
)
SELECT 
    u2020.segment, 
    u2020.product_count_2020, 
    u2021.product_count_2021, 
    (u2021.product_count_2021 - u2020.product_count_2020) AS difference
FROM 
    Unique_products_2020 u2020
JOIN 
    Unique_products_2021 u2021 
ON 
    u2020.segment = u2021.segment
ORDER BY 
    difference DESC;
## 5 Get the products that have the highest and lowest manufacturing costs.
##   The final output should contain these fields,
##   product_code, product, manufacturing_cost
with x as (Select product,dp.product_code,manufacturing_cost from dim_product DP join
fact_manufacturing_cost FMC on DP.Product_code = fmc.Product_code
 order by manufacturing_cost desc limit 1),
 y as (Select product,dp.product_code,manufacturing_cost from dim_product DP join
fact_manufacturing_cost FMC on DP.Product_code = fmc.Product_code
 order by manufacturing_cost asc limit 1)
 select * from x union select * from y;
 WITH ranked_products AS (
  SELECT 
    product, 
    dp.product_code, 
    manufacturing_cost,
    RANK() OVER (ORDER BY manufacturing_cost ASC) AS rank_asc,
    RANK() OVER (ORDER BY manufacturing_cost DESC) AS rank_desc
  FROM dim_product DP
  JOIN fact_manufacturing_cost FMC 
  ON DP.product_code = FMC.product_code
)
SELECT 
  product, 
  product_code, 
  manufacturing_cost
FROM ranked_products
WHERE rank_asc = 1 OR rank_desc = 1;

	## 6 Generate a report which contains the top 5 customers who received an
	##average high pre_invoice_discount_pct for the fiscal year 2021 and in the
	##Indian market. The final output contains these fields,
	## customer_code, customer,average_discount_percentage
	SELECT 
		fsm.customer_code,
		customer,
		AVG(pre_invoice_discount_pct) AS average_discount_percentage
	FROM
		fact_pre_invoice_deductions FPID
			JOIN
		dim_customer dC ON fpid.customer_code = dc.customer_code
			JOIN
		fact_sales_monthly fsm ON dc.customer_code = fsm.customer_code
	WHERE
		fsm.fiscal_year = 2021
			AND market = 'india'
	GROUP BY fsm.customer_code , customer
	ORDER BY average_discount_percentage DESC
	LIMIT 5;
## 7 Get the complete report of the Gross sales amount for the customer “Atliq
##   Exclusive” for each month. This analysis helps to get an idea of low and
##   high-performing months and take strategic decisions.
##   The final report contains these columns:
##   Month, Year, Gross sales Amount.
with x as (SELECT 
    MONTH(date) AS month,
    YEAR(date) AS year,
    ROUND((gross_price * Sold_quantity), 2) AS total_sales
FROM
    fact_gross_price fgp
        JOIN
    fact_sales_monthly fsm ON fgp.product_code = fsm.product_code
        JOIN
    dim_customer dm ON fsm.customer_code = dm.customer_code
WHERE
    customer = 'Atliq Exclusive')
SELECT 
    month, year, SUM(total_sales) AS gross_sales_amount
FROM
    x
GROUP BY month , year
ORDER BY year ASC, month asc;
## 8 In which quarter of 2020, got the maximum total_sold_quantity? The final
##  output contains these fields sorted by the total_sold_quantity,
##  Quarter, total_sold_quantity
SELECT 
    YEAR(date) AS year,
    QUARTER(date) AS quarter,
    SUM(Sold_quantity) AS total_sold_quantity
FROM
    fact_sales_monthly
WHERE
    YEAR(date) = 2020
GROUP BY YEAR(date) , QUARTER(date)
ORDER BY total_sold_quantity DESC
LIMIT 1;
## 9 Which channel helped to bring more gross sales in the fiscal year 2021
##   and the percentage of contribution? The final output contains these fields,
##   channel , gross_sales_mln, percentage
WITH x AS (
    SELECT 
        dm.channel,
        SUM(ROUND(gross_price * Sold_quantity, 2)) AS channel_sales
    FROM
        fact_gross_price fgp
    JOIN
        fact_sales_monthly fsm ON fgp.product_code = fsm.product_code
    JOIN
        dim_customer dm ON fsm.customer_code = dm.customer_code
    WHERE
        fsm.fiscal_year = 2021
    GROUP BY 
        dm.channel
),
y AS (
    SELECT 
        SUM(channel_sales) AS total_sales 
    FROM 
        x
)
SELECT 
    x.channel,
    ROUND((x.channel_sales / y.total_sales) * 100, 2) AS percentage
FROM 
    x, y
ORDER BY 
    percentage DESC;
    ## 10. Get the Top 3 products in each division that have a high
## total_sold_quantity in the fiscal_year 2021? The final output contains these
## fields,division, product_code, product, total_sold_quantity, rank_order
WITH RankedProducts AS (
    SELECT 
        division, 
        dp.product_code, 
        dp.product, 
        SUM(fsm.sold_quantity) AS total_sold_quantity,
        RANK() OVER (PARTITION BY division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
    FROM 
        dim_product dp
    JOIN 
        fact_sales_monthly fsm 
    ON 
        dp.product_code = fsm.product_code
    WHERE 
        fsm.fiscal_year = 2021
    GROUP BY 
        division, dp.product_code, dp.product
)
SELECT 
    *
FROM 
    RankedProducts
WHERE 
    rank_order <= 3
ORDER BY 
    division, rank_order;

    
    


















    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
