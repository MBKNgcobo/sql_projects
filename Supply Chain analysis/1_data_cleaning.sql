/*
Product Type: The type of product associated with specific data in the supply chain. (i.e haircare, skincare)
SKU (Stock Keeping Unit): Unique code used to identify a particular product.
Price: The price of the product or item in the supply chain.
Availability: Information about product availability.
Number of Products Sold: The number of products that have been sold in a certain time period.
Revenue Generated: Total revenue generated from product sales in a certain time period.
Customer demographics: Information about customer characteristics, such as age, gender, geographic location, etc. (e.g:- Male, female, Unknown)
Stock Levels: The number of products still available in stock at any given time.
Lead Times: The time required to order or receive products from suppliers.
Order Quantities: The number of products ordered in one order or shipment.(Economic Order Quantity)
Shipping Times: The time required to ship products from the warehouse or distribution center to customers.
Shipping Carriers: Companies or services used to ship products to customers.
Shipping Costs: Costs associated with shipping products, including delivery fees and additional fees.
Supplier Name: Name of supplier or vendor who provides products or materials to the company.
Location: The physical location associated with the data in the supply chain, such as the location of a warehouse or distribution center.
Lead Time: The time required to obtain products or materials from a particular supplier.
Production Volumes: The number of products produced in a certain time-period.
Manufacturing Lead Time: The time required to produce a product, from ordering materials until the product is ready.
Manufacturing Costs: Costs related to the production process, including raw material costs, labor, etc.
Inspection Results: Results of product or material quality inspection. (e.g:- Pass, Fail, Pending)
Defect Rates: The level of defects or defects in the products produced.
Transportation Modes: The transportation mode used to send products, such as land, sea or air.
Routes: Routes or paths used to send products from one point to another in the supply chain.
Costs: Costs related to various aspects of the supply chain, including transportation, inventory, warehousing, order processing, administration, and other costs.
No time period provided
*/
CREATE TABLE supply_chain (
    product_type VARCHAR(50),
    sku VARCHAR(20),
    price NUMERIC(12,2),
    availability INTEGER,
    number_of_products_sold INTEGER,
    revenue_generated NUMERIC(14,2),
    customer_demographics VARCHAR(50),
    stock_levels INTEGER,
    lead_times INTEGER,
    order_quantities INTEGER,
    shipping_times INTEGER,
    shipping_carriers VARCHAR(50),
    shipping_costs NUMERIC(12,2),
    supplier_name VARCHAR(50),
    location VARCHAR(100),
    lead_time INTEGER,
    production_volumes INTEGER,
    manufacturing_lead_time INTEGER,
    manufacturing_costs NUMERIC(12,2),
    inspection_results VARCHAR(20),
    defect_rates NUMERIC(10,4),
    transportation_modes VARCHAR(50),
    routes VARCHAR(50),
    costs NUMERIC(14,2)
);
--Row count
SELECT 
    COUNT(*) as count 
FROM 
    supply_chain;

--first 5 rows
SELECT 
    *
FROM 
    supply_chain
LIMIT 5;

--NUll value check
SELECT 
    COUNT(*) as null_count
FROM 
    supply_chain
WHERE 
    product_type IS NULL
    OR sku IS NULL
    OR price IS NULL
    OR availability IS NULL
    OR number_of_products_sold IS NULL
    OR revenue_generated IS NULL
    OR customer_demographics IS NULL
    OR stock_levels IS NULL
    OR lead_times IS NULL
    OR order_quantities IS NULL
    OR shipping_times IS NULL
    OR shipping_carriers IS NULL
    OR shipping_costs IS NULL
    OR supplier_name IS NULL
    OR location IS NULL
    OR lead_time IS NULL
    OR production_volumes IS NULL
    OR manufacturing_lead_time IS NULL
    OR manufacturing_costs IS NULL
    OR inspection_results IS NULL
    OR defect_rates IS NULL
    OR transportation_modes IS NULL
    OR routes IS NULL
    OR costs IS NULL;

--Duplicate value check
SELECT
    sku,
    COUNT(*) as duplicate_count
FROM
    supply_chain
GROUP BY
    sku
HAVING
    COUNT(*) > 1;

--Numerical value check(price)
SELECT
    MIN(price) as min_price,
    MAX(price) as max_price,
    ROUND(AVG(price), 2) as avg_price
FROM
    supply_chain;
/*
Price validation: Passed — no zero or negative prices identified from the summary statistics.
*/

--Numerical value check(revenue_generated)
SELECT
    MIN(revenue_generated) as min_revenue,
    MAX(revenue_generated) as max_revenue,
    ROUND(AVG(revenue_generated), 2) as avg_revenue
FROM
    supply_chain;
/*Revenue validation: Passed — no zero or negative revenue values identified from the summary statistics.
*/

--Numerical value check(shipping_costs)
SELECT
    MIN(shipping_costs) as min_shipping_costs,
    MAX(shipping_costs) as max_shipping_costs,
    ROUND(AVG(shipping_costs), 2) as avg_shipping_costs
FROM
    supply_chain;

--Numerical value check(manufacturing_costs)
SELECT
    MIN(manufacturing_costs) as min_manufacturing_costs,
    MAX(manufacturing_costs) as max_manufacturing_costs,
    ROUND(AVG(manufacturing_costs), 2) as avg_manufacturing_costs
FROM
    supply_chain;

--Numerical value check(defect_rates)
SELECT
    MIN(defect_rates) as min_defect_rates,
    MAX(defect_rates) as max_defect_rates,
    ROUND(AVG(defect_rates), 4) as avg_defect_rates 
FROM
    supply_chain;

--Numerical value check(stock_levels)
SELECT
    MIN(stock_levels) as min_stock_levels,
    MAX(stock_levels) as max_stock_levels,
    ROUND(AVG(stock_levels), 2) as avg_stock_levels
FROM
    supply_chain;
/*
Some products may have zero inventory and could potentially be at risk of stockouts.
*/

--Numerical value check(number_of_products_sold)
SELECT
    MIN(number_of_products_sold) as min_products_sold,
    MAX(number_of_products_sold) as max_products_sold,
    ROUND(AVG(number_of_products_sold), 2) as avg_products_sold
FROM
    supply_chain;
COMMIT;





