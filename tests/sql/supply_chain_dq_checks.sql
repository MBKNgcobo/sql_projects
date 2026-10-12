-- ============================================================================
-- DB-backed data-quality checks: Supply Chain analysis
-- Status: NOT EXECUTED in this audit round.
--   PostgreSQL 17 uses scram-sha-256 authentication and no credentials are
--   stored locally, so these checks could not be run against a live database.
--   The same expectations are verified statically by
--   tests/python/validate_datasets.py, which passes against the source CSV.
-- How to run (when credentials are available):
--   1. psql -U <user> -d postgres -f "Supply Chain analysis/0_import.sql"
--   2. psql -U <user> -d postgres -f tests/sql/supply_chain_dq_checks.sql
-- Every query returns (check_name, actual, expected); actual <> expected fails.
-- ============================================================================

-- Row count and NULL scan (24 columns; any NULL cell is a failure)
SELECT 'supply_chain rows' AS check_name, COUNT(*) AS actual, 100 AS expected
FROM supply_chain
UNION ALL
SELECT 'cells that are NULL', COUNT(*), 0
FROM supply_chain
WHERE product_type IS NULL OR sku IS NULL OR price IS NULL
   OR availability IS NULL OR number_of_products_sold IS NULL
   OR revenue_generated IS NULL OR customer_demographics IS NULL
   OR stock_levels IS NULL OR lead_times IS NULL OR order_quantities IS NULL
   OR shipping_times IS NULL OR shipping_carriers IS NULL
   OR shipping_costs IS NULL OR supplier_name IS NULL OR location IS NULL
   OR lead_time IS NULL OR production_volumes IS NULL
   OR manufacturing_lead_time IS NULL OR manufacturing_costs IS NULL
   OR inspection_results IS NULL OR defect_rates IS NULL
   OR transportation_modes IS NULL OR routes IS NULL OR costs IS NULL
UNION ALL
SELECT 'duplicate SKUs', COUNT(*) - COUNT(DISTINCT sku), 0 FROM supply_chain
UNION ALL
SELECT 'non-positive prices', COUNT(*), 0 FROM supply_chain WHERE price <= 0;

-- Minimum-sold guard: the division queries rely on NULLIF(sold, 0); the
-- baseline minimum is 8, so no zero divisor exists today.
SELECT 'min number_of_products_sold' AS check_name,
       MIN(number_of_products_sold) AS actual,
       8 AS expected
FROM supply_chain;

-- Smoke test for the corrected profit-margin formula (SUP-001): the aggregate
-- ratio-of-sums must be between 0 and 1, unlike the old sum-of-ratios form.
SELECT 'profit margin within (0,1]' AS check_name,
       CASE WHEN (SUM(revenue_generated) - SUM(manufacturing_costs)
                  - SUM(shipping_costs)) / NULLIF(SUM(revenue_generated), 0)
                 BETWEEN 0 AND 1
            THEN 1 ELSE 0 END AS actual,
       1 AS expected
FROM supply_chain;
