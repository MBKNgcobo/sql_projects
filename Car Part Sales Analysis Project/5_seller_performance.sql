/*
Seller Performance
*/

--Which sellers contribute the most listings to the marketplace?
SELECT
    se.seller_name,
    COUNT(DISTINCT app.app_id) as application_count
FROM applications app
JOIN seller se
    on app.seller_id = se.id
GROUP BY se.seller_name
ORDER BY application_count DESC;

--Which sellers specialize in particular vehicle types or categories?
WITH seller_categories AS (
    SELECT
        s.id AS seller_id,
        s.seller_name,
        pc.id AS category_id,
        pc.category_name,
        COUNT(a.app_id) AS listing_count,
        ROUND(
            COUNT(a.app_id) * 100.0 /
            SUM(COUNT(a.app_id)) OVER (PARTITION BY s.id),
            2
        ) AS listing_percentage
    FROM seller s
    JOIN applications a
        ON s.id = a.seller_id
    JOIN product_category pc
        ON a.category_id = pc.id
    GROUP BY
        s.id,
        s.seller_name,
        pc.id,
        pc.category_name
),
ranked AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY seller_id
            ORDER BY listing_count DESC
        ) AS specialization_rank
    FROM seller_categories
)
SELECT
    seller_id,
    seller_name,
    category_name AS specialized_category,
    listing_count,
    listing_percentage
FROM ranked
WHERE specialization_rank = 1 AND listing_percentage > 60
ORDER BY listing_count DESC;


WITH seller_vehicle_types AS (
    SELECT
        s.id AS seller_id,
        s.seller_name,
        vt.id AS vehicle_type_id,
        vt.vehicle_type_name,
        COUNT(a.app_id) AS listing_count,
        ROUND(
            COUNT(a.app_id) * 100.0 /
            SUM(COUNT(a.app_id)) OVER (PARTITION BY s.id),
            2
        ) AS listing_percentage
    FROM seller s
    JOIN applications a
        ON s.id = a.seller_id
    JOIN vehicle_type vt
        ON a.vehicle_type_id = vt.id
    GROUP BY
        s.id,
        s.seller_name,
        vt.id,
        vt.vehicle_type_name
),
ranked AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY seller_id
            ORDER BY listing_count DESC
        ) AS specialization_rank
    FROM seller_vehicle_types
)
SELECT
    seller_id,
    seller_name,
    vehicle_type_name AS specialized_vehicle_type,
    listing_count,
    listing_percentage
FROM ranked
WHERE specialization_rank = 1
ORDER BY listing_count DESC;

