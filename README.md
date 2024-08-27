# Data Analysis Results

Welcome to the **Data Analysis Results** repository! This repository contains SQL queries and the resulting visualizations from a series of analyses performed to gain insights into business operations. Each analysis focuses on different aspects such as market presence, product growth, sales performance, and more.

## Table of Contents

- [Introduction](#introduction)
- [Results](#results)
- [SQL Queries](#sql-queries)


## Introduction

This repository showcases various SQL queries and their corresponding results, providing insights into business metrics and performance across different dimensions. The analyses cover topics like market presence, unique product counts, segment growth, manufacturing costs, and more.

## Results

### 1. Market Presence for Atliq Exclusive in APAC
![image](https://github.com/user-attachments/assets/0dfa4068-68bd-45b3-947c-46e3f1d9154b)

- **Description:** This visualization displays the markets in the APAC region where "Atliq Exclusive" operates its business.

### 2. Percentage Increase in Unique Products (2021 vs 2020)
![image](https://github.com/user-attachments/assets/337bef50-1e97-4d52-ab4d-b1633623b9ba)

- **Description:** Shows the percentage change in the number of unique products from 2020 to 2021.

### 3. Unique Product Counts by Segment
![image](https://github.com/user-attachments/assets/287de908-8b60-4bfb-8e8e-9418b7e7a3ac)

- **Description:** Provides the count of unique products for each segment, sorted in descending order.

### 4. Segment with Most Increase in Unique Products (2021 vs 2020)
![image](https://github.com/user-attachments/assets/944101c0-b48f-4120-808a-72a65a0530d7)

- **Description:** Highlights the segment with the highest increase in unique products between 2020 and 2021.

### 5. Products with Highest and Lowest Manufacturing Costs
![image](https://github.com/user-attachments/assets/5266ad49-6ad3-4e62-8a68-c43964f08e3b)

- **Description:** Displays products with the highest and lowest manufacturing costs.

### 6. Top 5 Customers with Highest Average Pre-Invoice Discount (2021)
![image](https://github.com/user-attachments/assets/babc536a-5a9c-46a4-9f17-0649612fa3ee)

- **Description:** Lists the top 5 customers with the highest average pre-invoice discount percentages for 2021 in the Indian market.

### 7. Gross Sales Amount for Atliq Exclusive by Month
![image](https://github.com/user-attachments/assets/7c0aa56a-d827-44aa-8110-aec83cbc68bb)

- **Description:** Shows the gross sales amount for "Atliq Exclusive" for each month, indicating high and low-performing periods.

### 8. Quarter with Maximum Total Sold Quantity in 2020
![image](https://github.com/user-attachments/assets/611236f7-81fb-4e96-8b74-e4dd16182b79)

- **Description:** Identifies the quarter in 2020 with the maximum total sold quantity.

### 9. Top Sales Channel and Contribution Percentage (2021)
![image](https://github.com/user-attachments/assets/99d30f6f-7ebd-4bec-ad19-33a11bd60577)
- **Description:** Reveals the channel with the highest gross sales for 2021 and its contribution percentage.

### 10. Top 3 Products by Division (2021)
![image](https://github.com/user-attachments/assets/ad36e0da-6585-428e-b0bb-e1bb967c289d)
- **Description:** Lists the top 3 products in each division with the highest total sold quantities for 2021.

Your SQL queries and descriptions are clear and well-organized. Here’s a refined version of your SQL queries with comments to help you maintain clarity:

## SQL Queries

### 1. List of Markets for "Atliq Exclusive" in the APAC Region
```sql
SELECT Market, Customer, Region 
FROM dim_customer 
WHERE Customer = 'Atliq Exclusive' AND Region = 'APAC';
```

### 2. Percentage Increase in Unique Products (2021 vs 2020)
```sql
WITH Unique_products_2020 AS (
    SELECT COUNT(DISTINCT product) AS dis2020 
    FROM dim_product dp
    JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code 
    WHERE fiscal_year = 2020
),
Unique_products_2021 AS (
    SELECT COUNT(DISTINCT product) AS dis2021 
    FROM dim_product dp
    JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code 
    WHERE fiscal_year = 2021
)
SELECT 
    dis2020,
    dis2021,
    ROUND((dis2021 - dis2020) / dis2020 * 100, 2) AS percentage_chg 
FROM Unique_products_2020, Unique_products_2021;
```

### 3. Unique Product Counts by Segment
```sql
SELECT segment, COUNT(DISTINCT product) AS product_count 
FROM dim_product dp
JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code 
GROUP BY segment
ORDER BY product_count DESC;
```

### 4. Segment with Most Increase in Unique Products (2021 vs 2020)
```sql
WITH Unique_products_2020 AS (
    SELECT 
        segment, 
        COUNT(DISTINCT product) AS product_count_2020
    FROM dim_product dp
    JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code 
    WHERE fiscal_year = 2020 
    GROUP BY segment
),
Unique_products_2021 AS (
    SELECT 
        segment, 
        COUNT(DISTINCT product) AS product_count_2021
    FROM dim_product dp
    JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code 
    WHERE fiscal_year = 2021 
    GROUP BY segment
)
SELECT 
    u2020.segment, 
    u2020.product_count_2020, 
    u2021.product_count_2021, 
    (u2021.product_count_2021 - u2020.product_count_2020) AS difference
FROM Unique_products_2020 u2020
JOIN Unique_products_2021 u2021 ON u2020.segment = u2021.segment
ORDER BY difference DESC;
```

### 5. Products with Highest and Lowest Manufacturing Costs
```sql
WITH ranked_products AS (
    SELECT 
        product, 
        dp.product_code, 
        manufacturing_cost,
        RANK() OVER (ORDER BY manufacturing_cost ASC) AS rank_asc,
        RANK() OVER (ORDER BY manufacturing_cost DESC) AS rank_desc
    FROM dim_product dp
    JOIN fact_manufacturing_cost fmc ON dp.product_code = fmc.product_code
)
SELECT 
    product, 
    product_code, 
    manufacturing_cost
FROM ranked_products
WHERE rank_asc = 1 OR rank_desc = 1;
```

### 6. Top 5 Customers with Highest Average Pre-Invoice Discount (2021, India)
```sql
SELECT 
    fsm.customer_code,
    customer,
    AVG(pre_invoice_discount_pct) AS average_discount_percentage
FROM fact_pre_invoice_deductions fpid
JOIN dim_customer dc ON fpid.customer_code = dc.customer_code
JOIN fact_sales_monthly fsm ON dc.customer_code = fsm.customer_code
WHERE fsm.fiscal_year = 2021 AND market = 'India'
GROUP BY fsm.customer_code, customer
ORDER BY average_discount_percentage DESC
LIMIT 5;
```

### 7. Gross Sales Amount for "Atliq Exclusive" by Month
```sql
WITH sales_data AS (
    SELECT 
        MONTH(date) AS month,
        YEAR(date) AS year,
        ROUND((gross_price * Sold_quantity), 2) AS total_sales
    FROM fact_gross_price fgp
    JOIN fact_sales_monthly fsm ON fgp.product_code = fsm.product_code
    JOIN dim_customer dm ON fsm.customer_code = dm.customer_code
    WHERE customer = 'Atliq Exclusive'
)
SELECT 
    month, 
    year, 
    SUM(total_sales) AS gross_sales_amount
FROM sales_data
GROUP BY month, year
ORDER BY year ASC, month ASC;
```

### 8. Quarter with Maximum Total Sold Quantity in 2020
```sql
SELECT 
    QUARTER(date) AS quarter,
    SUM(Sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
WHERE YEAR(date) = 2020
GROUP BY QUARTER(date)
ORDER BY total_sold_quantity DESC
LIMIT 1;
```

### 9. Top Sales Channel and Contribution Percentage (2021)
```sql
WITH channel_sales AS (
    SELECT 
        dm.channel,
        SUM(ROUND(gross_price * Sold_quantity, 2)) AS channel_sales
    FROM fact_gross_price fgp
    JOIN fact_sales_monthly fsm ON fgp.product_code = fsm.product_code
    JOIN dim_customer dm ON fsm.customer_code = dm.customer_code
    WHERE fsm.fiscal_year = 2021
    GROUP BY dm.channel
),
total_sales AS (
    SELECT 
        SUM(channel_sales) AS total_sales 
    FROM channel_sales
)
SELECT 
    channel_sales.channel,
    ROUND((channel_sales.channel_sales / total_sales.total_sales) * 100, 2) AS percentage
FROM channel_sales, total_sales
ORDER BY percentage DESC;
```

### 10. Top 3 Products by Division in 2021
```sql
WITH RankedProducts AS (
    SELECT 
        division, 
        dp.product_code, 
        dp.product, 
        SUM(fsm.sold_quantity) AS total_sold_quantity,
        RANK() OVER (PARTITION BY division ORDER BY SUM(fsm.sold_quantity) DESC) AS rank_order
    FROM dim_product dp
    JOIN fact_sales_monthly fsm ON dp.product_code = fsm.product_code
    WHERE fsm.fiscal_year = 2021
    GROUP BY division, dp.product_code, dp.product
)
SELECT 
    division, 
    product_code, 
    product, 
    total_sold_quantity, 
    rank_order
FROM RankedProducts
WHERE rank_order <= 3
ORDER BY division, rank_order;
```

Feel free to adjust or expand on these queries based on your specific requirements or database schema.
