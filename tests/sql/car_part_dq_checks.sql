-- ============================================================================
-- DB-backed data-quality checks: Car Part Sales Analysis
-- Status: NOT EXECUTED in this audit round.
--   PostgreSQL 17 uses scram-sha-256 authentication and no credentials are
--   stored locally, so these checks could not be run against a live database.
--   The same expectations are verified statically by
--   tests/python/validate_datasets.py, which passes against the source CSVs.
-- How to run (when credentials are available):
--   1. Run 0_create_database.sql, then 1_Create_Tables.sql, then 2_import.sql
--      (all in "Car Part Sales Analysis Project").
--   2. psql -U <user> -d car_part_sales -f tests/sql/car_part_dq_checks.sql
-- Every query below returns (check_name, actual, expected); any row where
-- actual <> expected is a failure.
-- ============================================================================

-- Core row counts
SELECT 'applications rows'          AS check_name, COUNT(*) AS actual, 95588 AS expected FROM applications
UNION ALL
SELECT 'compatibility rows',        COUNT(*), 30927   FROM compatibility
UNION ALL
SELECT 'product_category rows',     COUNT(*), 665     FROM product_category
UNION ALL
SELECT 'seller rows',               COUNT(*), 2554    FROM seller
UNION ALL
SELECT 'vehicles rows',             COUNT(*), 1614    FROM vehicles
UNION ALL
SELECT 'vehicle_type rows',         COUNT(*), 3       FROM vehicle_type
UNION ALL
SELECT 'application_status rows',   COUNT(*), 4       FROM application_status;

-- Referential integrity: every count must be 0
SELECT 'orphans app->category' AS check_name, COUNT(*) AS actual, 0 AS expected
FROM applications a LEFT JOIN product_category c ON a.category_id = c.id
WHERE c.id IS NULL
UNION ALL
SELECT 'orphans app->seller', COUNT(*), 0
FROM applications a LEFT JOIN seller s ON a.seller_id = s.id
WHERE s.id IS NULL
UNION ALL
SELECT 'orphans app->vehicle_type', COUNT(*), 0
FROM applications a LEFT JOIN vehicle_type vt ON a.vehicle_type_id = vt.id
WHERE vt.id IS NULL
UNION ALL
SELECT 'orphans compat->app', COUNT(*), 0
FROM compatibility c LEFT JOIN applications a ON c.app_id = a.app_id
WHERE a.app_id IS NULL
UNION ALL
SELECT 'orphans compat->vehicle', COUNT(*), 0
FROM compatibility c LEFT JOIN vehicles v ON c.vehicles_id = v.id
WHERE v.id IS NULL;

-- Duplicate / invalid compatibility rows (known source-data defects: 292 and 8)
SELECT 'duplicate compatibility pairs' AS check_name, COUNT(*) AS actual, 292 AS expected
FROM (
    SELECT app_id, vehicles_id FROM compatibility
    GROUP BY app_id, vehicles_id HAVING COUNT(*) > 1
) d
UNION ALL
SELECT 'compatibility bottom_year > top_year', COUNT(*), 8
FROM compatibility WHERE bottom_year > top_year;

-- Zero-price share (drives the NULLIF guards in the pricing queries)
SELECT 'applications price_usd = 0' AS check_name, COUNT(*) AS actual, 13323 AS expected
FROM applications WHERE price_usd = 0;
