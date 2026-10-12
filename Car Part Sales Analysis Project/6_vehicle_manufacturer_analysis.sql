/*
Vehicle & Manufacturer Analysis
*/

--Which manufacturers have the greatest representation in the marketplace?
--(Counted via compatibility: one listing can be compatible with many vehicles,
-- so DISTINCT app_id avoids counting the same listing multiple times.)
SELECT
    v.manufacturer_name,
    COUNT(DISTINCT c.app_id) AS listing_count
FROM compatibility c
JOIN vehicles v
    ON c.vehicles_id = v.id
GROUP BY
    v.manufacturer_name
ORDER BY
    listing_count DESC;

--Which vehicle types appear most frequently in listings?
SELECT
    vt.vehicle_type_name,
    vt.id,
    COUNT(DISTINCT a.app_id) AS application_count
FROM vehicle_type vt
JOIN applications a
    ON vt.id = a.vehicle_type_id
GROUP BY
    vt.id,
    vt.vehicle_type_name
ORDER BY
    application_count DESC;

--Which vehicle models appear most frequently in listings?
SELECT
    v.model_name,
    COUNT(DISTINCT c.app_id) AS listing_count
FROM compatibility c
JOIN vehicles v
    ON c.vehicles_id = v.id
GROUP BY
    v.model_name
ORDER BY
    listing_count DESC;

--Which manufacturers have the highest average listing prices?
SELECT
    v.manufacturer_name,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(a.price_usd, 0)), 2) AS avg_price_usd
FROM applications a
JOIN compatibility comp
    ON a.app_id = comp.app_id
JOIN vehicles v
    ON comp.vehicles_id = v.id
GROUP BY
    v.manufacturer_name
ORDER BY
    avg_price_usd DESC;

--Which vehicle types have the greatest number of compatible applications?
SELECT
    vt.vehicle_type_name,
    COUNT(DISTINCT c.app_id) AS compatible_application_count
FROM vehicle_type vt
JOIN vehicles v
    ON v.vehicle_type_id = vt.id
JOIN compatibility c
    ON c.vehicles_id = v.id
GROUP BY
    vt.vehicle_type_name
ORDER BY
    compatible_application_count DESC;


