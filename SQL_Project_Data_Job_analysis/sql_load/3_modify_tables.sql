/*
    Database Load Scripts (SQL_Project_Data_Job_analysis)
    ------------------------------------------------------------------
    Windows file-access pattern:
    The server-side COPY statements (no leading backslash) read the CSV
    from the PostgreSQL server process account. On local Windows setups
    this typically fails with:

        'could not open file <path>' for reading: Permission denied.

    because the service account cannot see your user profile.

    Recommended fix: use the \copy (backslash-copy) form shown below,
    which reads the CSV from your client-side session instead. The only
    difference from server-side COPY is the leading backslash. Point the
    path at the CSV files in this repository's csv_files/ folder and
    re-run from psql (pgAdmin: SQL Tool).

    Server-side equivalent of the statements below (run only if the
    postgres service account can read the path):

        COPY company_dim FROM 'C:/path/to/csv_files/company_dim.csv'
            WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

    Encoding note: every CSV in csv_files/ is valid UTF-8. The *_utf8.csv
    variants carry an extra BOM/line-ending difference and are redundant.
    Expected row counts after load (verified on disk):
        company_dim      140,033
        skills_dim           259
        job_postings_fact 787,686
        skills_job_dim 3,669,604
*/

\copy company_dim FROM 'C:/Users/mcngc/Downloads/SQL/SQL_Project_Data_Job_analysis/csv_files/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM 'C:/Users/mcngc/Downloads/SQL/SQL_Project_Data_Job_analysis/csv_files/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM 'C:/Users/mcngc/Downloads/SQL/SQL_Project_Data_Job_analysis/csv_files/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM 'C:/Users/mcngc/Downloads/SQL/SQL_Project_Data_Job_analysis/csv_files/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');