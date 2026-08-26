-- ============================================
-- 1. VEHICLE TYPE
-- ============================================
CREATE TABLE vehicle_type (
    id INTEGER PRIMARY KEY,
    vehicle_type_name VARCHAR(255) NOT NULL
);


-- ============================================
-- 2. VEHICLES
-- ============================================
CREATE TABLE vehicles (
    id INTEGER PRIMARY KEY,
    model_name VARCHAR(255) NOT NULL,
    manufacturer_name VARCHAR(255) NOT NULL,
    vehicle_type_id INTEGER,

    CONSTRAINT fk_vehicles_vehicle_type
        FOREIGN KEY (vehicle_type_id)
        REFERENCES vehicle_type(id)
);


-- ============================================
-- 3. APPLICATION STATUS
-- ============================================
CREATE TABLE application_status (
    id INTEGER PRIMARY KEY,
    status_name VARCHAR(255) NOT NULL
);


-- ============================================
-- 4. PRODUCT CATEGORY
-- ============================================
CREATE TABLE product_category (
    id INTEGER PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    parent_category_id SMALLINT,

    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES product_category(id)
);


-- ============================================
-- 5. SELLER
-- ============================================
CREATE TABLE seller (
    id INTEGER PRIMARY KEY,
    seller_name VARCHAR(255) NOT NULL,
    address TEXT,
    mobile_number TEXT
);


-- ============================================
-- 6. APPLICATIONS
-- ============================================
CREATE TABLE applications (
    app_id INTEGER PRIMARY KEY,
    headline TEXT,
    price_gel INT,
    price_usd INT,
    app_register_date DATE,
    status_id INTEGER,
    category_id INTEGER,
    vehicle_type_id INTEGER,
    seller_id INTEGER,
    item_condition VARCHAR(255),
    insert_date DATE,

    CONSTRAINT fk_app_status
        FOREIGN KEY (status_id)
        REFERENCES application_status(id),

    CONSTRAINT fk_app_category
        FOREIGN KEY (category_id)
        REFERENCES product_category(id),

    CONSTRAINT fk_app_vehicle
        FOREIGN KEY (vehicle_type_id)
        REFERENCES vehicle_type(id),

    CONSTRAINT fk_app_seller
        FOREIGN KEY (seller_id)
        REFERENCES seller(id)
);


-- ============================================
-- 7. COMPATIBILITY
-- ============================================
CREATE TABLE compatibility (
    app_id INTEGER,
    bottom_year SMALLINT,
    top_year SMALLINT,
    vehicles_id INTEGER,

    CONSTRAINT fk_compatibility_app
        FOREIGN KEY (app_id)
        REFERENCES applications(app_id),

    CONSTRAINT fk_compatibility_vehicle
        FOREIGN KEY (vehicles_id)
        REFERENCES vehicles(id)
);
