--Where stock_levels = 0
SELECT
    sku,
    product_type,
    stock_levels,
    number_of_products_sold
FROM supply_chain
WHERE stock_levels = 0;
/*
SKU68 may be experiencing a stockout after meaningful customer demand.
*/

--Low stock levels (less than 20)
SELECT
    sku,
    product_type,
    stock_levels,
    number_of_products_sold
FROM supply_chain
WHERE stock_levels < 20
ORDER BY number_of_products_sold DESC
/*
Products with low stock levels may be at risk of stockouts.
*/

/*
How much inventory remains relative to the number of products sold?
*/
SELECT
    stock_levels::numeric / number_of_products_sold::numeric as inventory_to_sales_ratio,
    sku,
    product_type,
    stock_levels,
    number_of_products_sold
FROM supply_chain
WHERE stock_levels < 20
ORDER BY inventory_to_sales_ratio;
--
WITH inventory_sales_ratio AS (
    SELECT stock_levels::numeric / number_of_products_sold::numeric as ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold
    FROM supply_chain
),
 risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
),
risk_count_per_product_type AS (
    SELECT
        product_type,
        risk_level,
        COUNT(*) as count_per_product_type
    FROM risk_levels
    GROUP BY product_type, risk_level
)
SELECT
     risk_level,
    COUNT(*) as number_of_products
FROM risk_levels
GROUP BY risk_level;
/*
    Inventory Risk: 45% of products have a Critical 
    or High inventory-to-sales risk level,
    indicating that a substantial portion of 
    the product portfolio has relatively low inventory 
    compared with historical sales volume.
*/
--
WITH inventory_sales_ratio AS (
    SELECT stock_levels::numeric / number_of_products_sold::numeric as ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold
    FROM supply_chain
),
 risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
),
risk_count_per_product_type AS (
    SELECT
        product_type,
        risk_level,
        COUNT(*) as count_per_product_type
    FROM risk_levels
    GROUP BY product_type, risk_level
)
SELECT
    product_type,
    risk_level,
    count_per_product_type
FROM risk_count_per_product_type
WHERE risk_level IN ('Critical', 'High Risk')
ORDER BY product_type, risk_level;

--Risk level distribution by product type
WITH inventory_sales_ratio AS (
    SELECT stock_levels::numeric / number_of_products_sold::numeric as ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold
    FROM supply_chain
),
 risk_levels AS (
    SELECT
        ratio,
        sku,
        product_type,
        stock_levels,
        number_of_products_sold,
        CASE
            WHEN ratio < 0.01 THEN 'Critical'
            WHEN ratio >= 0.01 AND ratio < 0.10 THEN 'High Risk'
            WHEN ratio >= 0.10 AND ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level
    FROM inventory_sales_ratio
)
SELECT
    product_type,
    COUNT(*) as total_products,
    COUNT(CASE WHEN risk_level IN ('Critical', 'High Risk') THEN 1 ELSE null END) as critical_high_risk_count,
    ROUND(COUNT(CASE WHEN risk_level IN ('Critical', 'High Risk') THEN 1 ELSE null END)::numeric / COUNT(*)::numeric * 100, 2) as critical_high_risk_percentage
FROM risk_levels
GROUP BY product_type;
/*
Inventory Risk Finding: 
Skincare has the highest inventory risk, 
with 52.5% of its products classified as Critical or High Risk 
based on the inventory-to-sales ratio. 
Haircare follows at 44.12%, 
while cosmetics has the lowest risk proportion at 34.62%. 
This suggests that skincare inventory may require greater monitoring 
and replenishment attention.
*/