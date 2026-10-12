/*
    ====================================================================
    Car Part Sales - data import
    ====================================================================
    Engine:      PostgreSQL. Run inside psql or a psql meta-command aware
                 tool (pgAdmin PSQL Tool, or "psql -f 2_import.sql").
    Prerequisite: run 1_Create_Tables.sql first (optionally preceded by
                 0_create_database.sql if you use a dedicated database).
    Paths:       IMPORTANT - the absolute paths below are machine-specific.
                 Edit the directory prefix if your checkout lives elsewhere,
                 or replace them with relative paths ('archive/vehicle_type.csv')
                 and start psql from this project folder.
    \copy vs COPY: \copy reads the file CLIENT-side, avoiding server
                 permission errors on Windows. Server-side COPY (no
                 backslash) reads as the server account and can fail with
                 "Permission denied".
    Encoding:    All CSVs verified as valid UTF-8. seller.csv carries a BOM
                 on its header line; HEADER TRUE discards that line, so no
                 action is needed. Column order must match the CSVs (it does).
    ====================================================================
*/
\copy vehicle_type 

FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/vehicle_type.csv'
WITH (FORMAT CSV, HEADER TRUE);

\copy application_status 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/application_status.csv' 
WITH (FORMAT CSV, HEADER TRUE);

\copy product_category 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/product_category.csv' 
WITH (FORMAT CSV, HEADER TRUE);

\copy seller 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/seller.csv' 
WITH (FORMAT CSV, HEADER TRUE);

\copy vehicles 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/vehicles.csv' 
WITH (FORMAT CSV, HEADER TRUE);

\copy applications 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/applications.csv' 
WITH (FORMAT CSV, HEADER TRUE);

\copy compatibility 
FROM 'C:/Users/mcngc/Downloads/SQL/Car Part Sales Analysis Project/archive/compatibility.csv' 
WITH (FORMAT CSV, HEADER TRUE);