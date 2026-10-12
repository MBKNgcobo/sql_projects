/*
    Supply Chain - data import.
    Engine: PostgreSQL.
    HOW TO RUN (portable - no machine-specific paths):
        1. Open a terminal in THIS folder ("Supply Chain analysis").
        2. psql -U postgres -d postgres -f 0_import.sql
       (Relative \copy paths are resolved against the psql working directory,
        so the commands below work from any checkout location as long as the
        terminal starts in this folder.)
    Column order below matches the CSV header exactly:
        Product type, SKU, Price, Availability, Number of products sold,
        Revenue generated, Customer demographics, Stock levels, Lead times,
        Order quantities, Shipping times, Shipping carriers, Shipping costs,
        Supplier name, Location, Lead time, Production volumes,
        Manufacturing lead time, Manufacturing costs, Inspection results,
        Defect rates, Transportation modes, Routes, Costs
    The CSV carries a UTF-8 BOM; HEADER TRUE discards the header line,
    including the BOM, so no special handling is needed.
*/
CREATE TABLE IF NOT EXISTS supply_chain (
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

\copy supply_chain FROM 'archive/supply_chain_data.csv' WITH (FORMAT CSV, HEADER TRUE);

-- Sanity check: the dataset contains exactly 100 rows.
SELECT COUNT(*) AS row_count FROM supply_chain;
