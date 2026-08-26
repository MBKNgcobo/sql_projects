/*
    Pricing & Market Demand
*/
--What is the average listing price by vehicle type and category
SELECT
    vt.vehicle_type_name as vehicle_type,
   -- pc.category_name as category_name,
    AVG(app.price_usd) as avarage_price
FROM applications app
JOIN vehicle_type vt
    on app.vehicle_type_id = vt.id
JOIN product_category pc
    on app.category_id = pc.id
GROUP BY  vehicle_type;

SELECT
    --vt.vehicle_type_name as vehicle_type,
    pc.category_name as category_name,
    AVG(app.price_usd) as avarage_price
FROM applications app
JOIN vehicle_type vt
    on app.vehicle_type_id = vt.id
JOIN product_category pc
    on app.category_id = pc.id
GROUP BY  category_name
ORDER BY avarage_price DESC;  

--How does pricing vary between different vehicle manufacturers and models?
SELECT 
    v.manufacturer_name,
    AVG(app.price_usd) as avarage_price
FROM applications app
JOIN vehicle_type vt
    on app.vehicle_type_id = vt.id
JOIN  vehicles v
    on vt.id = v.id
GROUP BY v.manufacturer_name;

SELECT 
    v.model_name,
    AVG(app.price_usd) as avarage_price
FROM applications app
JOIN vehicle_type vt
    on app.vehicle_type_id = vt.id
JOIN  vehicles v
    on vt.id = v.id
GROUP BY v.model_name;

--How does listing price differ between item conditions?
SELECT
    item_condition,
    AVG(price_usd) as avarage_price
FROM applications
GROUP BY item_condition;




