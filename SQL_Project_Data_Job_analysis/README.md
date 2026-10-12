# SQL Project — Data Job Analysis

Analysis of the data-analyst job market: top-paying jobs, in-demand skills
and salary-skill trade-offs. Based on Luke Barousse's
["SQL for Data Analytics" course](https://www.lukebarousse.com/sql) dataset,
loaded into a PostgreSQL database named `sql_course`.

## Contents

| Folder | Purpose |
|---|---|
| `sql_load/` | `1_create_database.sql` → `2_create_tables.sql` → `3_modify_tables.sql` (load) |
| `project_sql/` | The four core business questions |
| `advanced_sql/` | Date functions, CASE expressions, CTEs |
| `csv_files/` | Source CSVs (see below — one file is not shipped) |

## How to run (PostgreSQL + psql)

```bash
# from this folder
psql -U postgres -f sql_load/1_create_database.sql
psql -U postgres -d sql_course -f sql_load/2_create_tables.sql
psql -U postgres -d sql_course -f sql_load/3_modify_tables.sql
psql -U postgres -d sql_course -f project_sql/1_top_paying_job.sql
```

`3_modify_tables.sql` uses client-side `\copy`, which reads the CSV from your
session instead of the server process. Server-side `COPY` (no leading
backslash) is the source of the classic Windows error
`could not open file ... for reading: Permission denied`.

## Dataset

| File | Rows | Shipped in this repo? |
|---|---|---|
| `company_dim.csv` | 140,033 | Yes |
| `skills_dim.csv` | 259 | Yes |
| `skills_job_dim.csv` | 3,669,604 | Yes |
| `job_postings_fact.csv` | 787,686 | **No — 123 MB, over GitHub's 100 MB file limit** |

**Getting `job_postings_fact.csv`:** download the course dataset from
[lukebarousse.com/sql](https://www.lukebarousse.com/sql) (the "SQL for Data
Analytics" course — the same source as the tracked CSVs), place the file in
`csv_files/`, then run `sql_load/3_modify_tables.sql`. It is listed in the
root `.gitignore`, so it will not be committed by accident.

## Analysis notes

- Only **22,034 of 787,686 postings (2.8%)** carry `salary_year_avg`.
  `4_top_paying_skills.sql` therefore returns `posting_count` next to every
  average — treat small samples with caution.
- Query columns are table-qualified (`job_postings_fact.job_id`,
  `skills_dim.skills`) so joins stay unambiguous if schemas evolve.

Run `python tests/python/validate_datasets.py` from the repository root to
re-verify the row counts and salary-coverage expectations (the
`job_postings_fact` checks are skipped automatically when the file is absent).
