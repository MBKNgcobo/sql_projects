/*
Marketplace Performance
*/

--How many vehicle/part listings are being created over time, 
--and what are the overall marketplace trends?
SELECT 
    app_register_date,
    COUNT(DISTINCT app_id) as number_of_application
FROM applications
GROUP BY app_register_date
ORDER BY number_of_application DESC;

SELECT
    DATE_TRUNC('week', app_register_date) AS week,
    COUNT(app_id) AS application_count
FROM applications
GROUP BY week
ORDER BY week DESC;

--Which categories generate the highest number of listings?
SELECT 
    pro.category_name,
    COUNT(app.app_id) AS application_count
FROM applications app
JOIN product_category pro
    ON app.category_id = pro.id
GROUP BY pro.category_name
ORDER BY application_count DESC;

--Which vehicle types are most frequently represented in the marketplace?
SELECT 
    vt.vehicle_type_name,
    COUNT(DISTINCT app.app_id) as application_count
FROM applications app
JOIN vehicle_type vt
    on app.vehicle_type_id = vt.id
JOIN vehicles ve
    on vt.id = ve.vehicle_type_id
GROUP BY vt.vehicle_type_name
ORDER BY application_count;


