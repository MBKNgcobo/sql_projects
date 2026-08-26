/*
Vehicle & Manufacturer Analysis
*/

--Which manufacturers have the greatest representation in the marketplace?
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

--Which vehicle models appear most frequently in listings?
SELECT
    vt.vehicle_type_name,
    vt.id,
    COUNT(DISTINCT a.app_id) as listing_count
FROM vehicle_type vt
JOIN applications a
    on vt.id = a.vehicle_type_id
GROUP BY 
    vt.id,
    vt.vehicle_type_name
ORDER BY 
    listing_count DESC;

--Which manufacturers have the highest average listing prices?
SELECT 
    v.manufacturer_name,
    ROUND(AVG(price_usd),2) as avarage_price
FROM applications a
JOIN vehicle_type vt
    on a.vehicle_type_id = vt.id
JOIN vehicles v
    on vt.id = v.vehicle_type_id
GROUP BY 
    v.manufacturer_name
ORDER BY
    avarage_price DESC;

--Which vehicle types have the greatest number of compatible applications?


