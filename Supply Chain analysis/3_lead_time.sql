--Lead time analysis
SELECT
    MIN(lead_time) as min_lead_time,
    MAX(lead_time) as max_lead_time,
    ROUND(AVG(lead_time), 2) as avg_lead_time
FROM
    supply_chain;

--Does Lead Time Affect Inventory Risk?
WITH inventory_sales_ratio AS (
    SELECT stock_levels::numeric / number_of_products_sold::numeric as ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold,
        Lead_time
    FROM supply_chain
),
 risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold,
        Lead_time,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
)
SELECT
    risk_level,
    COUNT(*) as number_of_products,
    ROUND(AVG(Lead_time), 2) as avg_lead_time
FROM risk_levels
GROUP BY risk_level
ORDER BY avg_lead_time;
/*
High-risk products had the longest average supplier lead time at 19.03 days, 
compared with 16.73 days for low-risk products.
 However, critical products had a substantially shorter average lead time of 7.14 days, 
 indicating that lead time alone does not explain inventory risk.
*/