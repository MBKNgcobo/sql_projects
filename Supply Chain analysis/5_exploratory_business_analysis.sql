/*
Exploratory Business Analysis
*/
--Which product type generates the most revenue?
SELECT 
    product_type,
    SUM(revenue_generated) as total_revenue_per_product_type
FROM supply_chain
GROUP BY product_type
ORDER BY total_revenue_per_product_type DESC;
/*
Skincare generated approximately R241.6k, 
making it the highest-revenue product category.

Skincare is the company's largest revenue category,
while also having the highest proportion of Critical/High inventory risk
*/

--Which products are the top 10 revenue generators?
SELECT
    sku,
    revenue_generated,
    product_type
FROM supply_chain
ORDER BY revenue_generated DESC
LIMIT 10;
/*
Some of the company's highest-revenue 
products are exposed to significant inventory risk, 
creating a potential risk to revenue continuity.
*/

--Does higher price lead to higher revenue?
SELECT
    sku,
    product_type,
    price,
    number_of_products_sold,
    revenue_generated,
    ROUND(
        revenue_generated / NULLIF(number_of_products_sold, 0),
        2
    ) AS revenue_per_unit
FROM supply_chain
ORDER BY revenue_generated DESC;
/*
The company generates a large proportion of 
its revenue from products that may have insufficient inventory 
relative to observed sales volume. This creates a potential revenue-continuity risk, 
particularly within the skincare category.
*/


--Which transportation modes have the highest costs and/or shipping times?
SELECT 
    transportation_modes,
    AVG(shipping_costs) as transportaion_cost,
    AVG(shipping_times) as avg_shipping_times,
    COUNT(*) as transportation_count
FROM supply_chain
GROUP BY transportation_modes;
/*
Road provides the fastest average delivery,
while Sea provides the lowest average shipping cost.
*/

--Which customer demographic generates the most revenue?
SELECT
    sku,
    product_type,
    price,
    number_of_products_sold,
    revenue_generated,
    ROUND(
        revenue_generated / NULLIF(number_of_products_sold, 0),
        2
    ) AS revenue_per_unit
FROM supply_chain
ORDER BY revenue_generated DESC
LIMIT 10;

--Do longer shipping times appear to be associated with higher shipping costs?
SELECT
    shipping_times,
    COUNT(*) AS number_of_shipments,
    ROUND(AVG(shipping_costs), 2) AS avg_shipping_cost
FROM supply_chain
GROUP BY shipping_times
ORDER BY shipping_times;
/*
Average shipping cost varies considerably across delivery times,
but the relationship is not consistently linear. 
The highest average cost occurred at 2 days, 
while 10-day shipments also showed relatively high costs
*/

--Are the company's most important revenue-generating products exposed to inventory risk?
WITH inventory_sales_ratio AS (
    SELECT
        sku,
        product_type,
        revenue_generated,
        number_of_products_sold,
        stock_levels,
        stock_levels::numeric / NULLIF(number_of_products_sold, 0) AS ratio
    FROM supply_chain
),
risk_levels AS (
    SELECT
        *,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio < 0.10 THEN 'High Risk'
            WHEN ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
)
SELECT
    sku,
    product_type,
    revenue_generated,
    number_of_products_sold,
    stock_levels,
    ROUND(ratio, 4) AS inventory_sales_ratio,
    risk_level
FROM risk_levels
ORDER BY revenue_generated DESC
LIMIT 20;

--Shipping carrier performance
SELECT 
    shipping_carriers,
    Count(*) as number_of_shipments,
    AVG(shipping_costs) as avg_shipping_cost,
    AVG(shipping_times) as avg_shipping_time
FROM supply_chain
GROUP bY shipping_carriers;
/*
Carrier B provides the strongest observed cost-speed performance, 
combining the lowest average shipping cost (5.51) with the shortest average delivery time (5.30 days),
while also handling the largest share of shipments.
*/