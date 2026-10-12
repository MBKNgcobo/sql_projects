/*
    Optional: create a dedicated database for this project.
    Recommended so the analysis never mixes with other work in the default
    'postgres' database. If you keep using the default database (as the
    existing .vscode sqltools connection does), skip this file.

    Steps (psql):
        psql -U postgres -f 0_create_database.sql
        psql -U postgres -d car_part_sales -f 1_Create_Tables.sql
        psql -U postgres -d car_part_sales -f 2_import.sql
        ... then run 3_-6_ analysis scripts against car_part_sales.
*/
CREATE DATABASE car_part_sales;
