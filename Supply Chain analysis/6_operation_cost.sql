/*

*/

--Which SKUs generate the highest estimated profit?
SELECT 
    sku,
    (revenue_generated - manufacturing_costs-shipping_costs) as estimated_profit,
    revenue_generated,
    manufacturing_costs,
    shipping_costs,
    price,
    product_type,
    number_of_products_sold,
    costs
FROM  supply_chain
ORDER BY estimated_profit DESC;
/*
 SKU51 has the highest estimated profit, with only 154 products sold
 SKU2 has a discripency with high estimated profit at 9555.11,
 this is due to the high revenue generated while only having 8 units sold. Might be a data quality issue
Dataset is inconsistant
*/

--Which product type has the highest profit margin?
SELECT 
    product_type,
    SUM((revenue_generated - (manufacturing_costs-shipping_costs))/ revenue_generated) as profit_margin,
    SUM(number_of_products_sold) as type_sold
FROM supply_chain
GROUP BY product_type
ORDER BY profit_margin DESC;
/*
skincare has the largest profit margin with the highest number of product sold
the other two follow the same pattern of the profit margin correlating to the number of units sold
*/

--Which categories have the highest manufacturing costs?
SELECT 
    product_type,
    SUM(manufacturing_costs) as manufacturing_costs
FROM supply_chain
GROUP BY product_type
ORDER BY manufacturing_costs DESC;
/*

*/

--Which products/categories have the highest shipping-cost burden?
SELECT
    product_type,
   ROUND((SUM(shipping_costs)/ SUM(revenue_generated)), 5) as shipping_cost
FROM supply_chain
GROUP BY product_type
ORDER BY shipping_cost

--Which suppliers provide the best cost-quality balance?
SELECT 
    supplier_name,
    ROUND(AVG(manufacturing_costs) * (1+ (AVG(defect_rates)/100)), 2) as cost_quality
FROM supply_chain
GROUP BY supplier_name
ORDER BY cost_quality;

--Are profitable products exposed to inventory risk?
WITH product_analysis AS (
    SELECT
        sku,
        product_type,
        revenue_generated,
        manufacturing_costs,
        shipping_costs,
        stock_levels,
        number_of_products_sold,

        revenue_generated
            - manufacturing_costs
            - shipping_costs AS estimated_profit,

        (
            revenue_generated
            - manufacturing_costs
            - shipping_costs
        ) / NULLIF(revenue_generated, 0) * 100 AS profit_margin,

        stock_levels::numeric
            / NULLIF(number_of_products_sold, 0) AS inventory_sales_ratio

    FROM supply_chain
),

risk_analysis AS (
    SELECT
        sku,
        product_type,
        revenue_generated,
        manufacturing_costs,
        shipping_costs,
        stock_levels,
        number_of_products_sold,
        estimated_profit,
        profit_margin,
        inventory_sales_ratio,

        CASE
            WHEN inventory_sales_ratio < 0.01 THEN 'Critical'
            WHEN inventory_sales_ratio >= 0.01
                 AND inventory_sales_ratio < 0.10 THEN 'High Risk'
            WHEN inventory_sales_ratio >= 0.10
                 AND inventory_sales_ratio < 0.50 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS risk_level

    FROM product_analysis
)

SELECT
    sku,
    product_type,
    ROUND(revenue_generated, 2) AS revenue,
    ROUND(estimated_profit, 2) AS estimated_profit,
    ROUND(profit_margin, 2) AS profit_margin,
    stock_levels,
    number_of_products_sold,
    ROUND(inventory_sales_ratio, 4) AS inventory_sales_ratio,
    risk_level

FROM risk_analysis
ORDER BY estimated_profit DESC;