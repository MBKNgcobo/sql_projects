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