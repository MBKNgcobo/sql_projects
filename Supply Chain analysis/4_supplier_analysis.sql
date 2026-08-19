--Supplier Analysis
SELECT
    supplier_name,
    COUNT(*) as number_of_products,
    ROUND(AVG(defect_rates), 2) as avg_defect_rate,
    ROUND(AVG(manufacturing_costs), 2) as avg_manufacturing_cost,
    ROUND(AVG(lead_time), 2) as avg_lead_time
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_defect_rate DESC;
/*
Supplier 5 — highest defect rate
Supplier 5 has the highest average defect rate at 2.67%.
That's potentially concerning because they're not the cheapest supplier either.

Supplier 3 has the longest average lead time: 20.13 days
while also having a relatively high defect rate of 2.47%.

Supplier 1 has:
Lowest defect rate: 1.80%
Shortest lead time: 14.78 days
Largest supplier volume: 27 products
That makes Supplier 1 look particularly strong operationally.
*/

--Which suppliers combine low manufacturing costs with low defect rates?
SELECT
    supplier_name,
    ROUND(AVG(manufacturing_costs), 2) as avg_manufacturing_cost,
    ROUND(AVG(defect_rates), 2) as avg_defect_rate,
    ROUND(AVG(lead_time), 2) as avg_lead_time
FROM supply_chain
GROUP BY supplier_name
ORDER BY avg_manufacturing_cost, avg_defect_rate;

--Quality-adjusted cost
/*
Average manufacturing cost × (1 + average defect rate / 100)
Quality-adjusted cost is an analytical proxy calculated 
by adjusting average manufacturing cost for 
the supplier's average defect rate. 
It is used to compare supplier performance rather 
than represent an actual accounting cost.
*/
WITH quality_adjusted_cost AS (
    SELECT
        supplier_name,
        ROUND(AVG(manufacturing_costs), 2) * (1 + ROUND(AVG(defect_rates/100), 4)) as quality_adjusted_cost
    FROM supply_chain
    GROUP BY supplier_name
)
SELECT
    supplier_name,
    quality_adjusted_cost
FROM quality_adjusted_cost
ORDER BY quality_adjusted_cost;

--Which suppliers are associated with Critical and High-Risk inventory products?
WITH inventory_sales_ratio AS (
    SELECT
        stock_levels::numeric / number_of_products_sold::numeric AS ratio,
        sku,
        product_type,
        supplier_name,
        stock_levels,
        number_of_products_sold,
        lead_time
    FROM supply_chain
),
risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        supplier_name,
        stock_levels,
        number_of_products_sold,
        lead_time,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
)
SELECT
    supplier_name,
    COUNT(*) AS total_products,
    COUNT(
        CASE
            WHEN risk_level = 'Critical' THEN 1
            ELSE NULL
        END
    ) AS critical_products,
    COUNT(
        CASE
            WHEN risk_level = 'High Risk' THEN 1
            ELSE NULL
        END
    ) AS high_risk_products,
    COUNT(
        CASE
            WHEN risk_level IN ('Critical', 'High Risk') THEN 1
            ELSE NULL
        END
    ) AS total_at_risk,
    ROUND(
        COUNT(
            CASE
                WHEN risk_level IN ('Critical', 'High Risk') THEN 1
                ELSE NULL
            END
        )::numeric
        / COUNT(*)::numeric * 100,
        2
    ) AS risk_percentage
FROM risk_levels
GROUP BY supplier_name
ORDER BY risk_percentage DESC;
/*
 Supplier 2 is the most cost-efficient supplier in our analysis, 
 but more than half of its products are classified as Critical or High Risk.
*/

--Does supplier defect rate appear to be associated with inventory risk?

WITH inventory_sales_ratio AS (
    SELECT
        stock_levels::numeric / number_of_products_sold::numeric AS ratio,
        sku,
        product_type,
        supplier_name,
        stock_levels,
        number_of_products_sold,
        lead_times,
        defect_rates,
        manufacturing_costs
    FROM supply_chain
),
risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        supplier_name,
        stock_levels,
        number_of_products_sold,
        lead_times,
        defect_rates,
        manufacturing_costs,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
)
SELECT 
    supplier_name,
    ROUND(AVG(defect_rates), 2) AS avg_defect_rate,
    ROUND(AVG(lead_times), 2) AS avg_lead_time,
    ROUND(AVG(manufacturing_costs), 2) AS avg_manufacturing_cost,
    ROUND(
        COUNT(
            CASE
                WHEN risk_level IN ('Critical', 'High Risk') THEN 1
                ELSE NULL
            END
        )::numeric
        / COUNT(*)::numeric * 100,
        2
    ) AS risk_percentage
FROM risk_levels
GROUP BY supplier_name
ORDER BY risk_percentage DESC;
/*
Key Project Findings So Far
Inventory Risk
45% of products were classified as Critical or High Risk.
Skincare products had the highest inventory risk (52.5%).

Lead Time Analysis
High-Risk products had the longest average lead time (19.03 days).
Critical products had relatively short lead times (7.14 days).
Lead time alone does not fully explain inventory risk.

Supplier Analysis
Supplier 2 had the lowest manufacturing cost.
Supplier 1 had the lowest defect rate.
Supplier 4 had the highest manufacturing cost.
Supplier 2 and Supplier 3 had the highest inventory-risk percentages.

Business Recommendation
Supplier selection should not be based solely on manufacturing cost. 
Supplier 1 appears to provide the strongest balance between quality, 
operational performance, and inventory stability, 
while Supplier 2 offers the lowest cost but exhibits the highest inventory risk.
*/