/*
    Pricing & Market Demand
*/

--What is the average listing price by vehicle type?
SELECT
    vt.vehicle_type_name AS vehicle_type,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(app.price_usd, 0)), 2) AS avg_price_usd
FROM applications app
JOIN vehicle_type vt
    ON app.vehicle_type_id = vt.id
GROUP BY vehicle_type
ORDER BY avg_price_usd DESC;

--What is the average listing price by category?
SELECT
    pc.category_name,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(app.price_usd, 0)), 2) AS avg_price_usd
FROM applications app
JOIN product_category pc
    ON app.category_id = pc.id
GROUP BY pc.category_name
ORDER BY avg_price_usd DESC;

--How does pricing vary between different vehicle manufacturers?
SELECT
    v.manufacturer_name,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(app.price_usd, 0)), 2) AS avg_price_usd
FROM applications app
JOIN compatibility comp
    ON app.app_id = comp.app_id
JOIN vehicles v
    ON comp.vehicles_id = v.id
GROUP BY v.manufacturer_name
ORDER BY avg_price_usd DESC;

--How does pricing vary between different vehicle models?
SELECT
    v.model_name,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(app.price_usd, 0)), 2) AS avg_price_usd
FROM applications app
JOIN compatibility comp
    ON app.app_id = comp.app_id
JOIN vehicles v
    ON comp.vehicles_id = v.id
GROUP BY v.model_name
ORDER BY avg_price_usd DESC;

--How does listing price differ between item conditions?
SELECT
    item_condition,
    COUNT(*) AS listing_count,
    ROUND(AVG(NULLIF(price_usd, 0)), 2) AS avg_price_usd
FROM applications
GROUP BY item_condition
ORDER BY avg_price_usd DESC;





