-- ============================================================================
-- DB-backed data-quality checks: SQL_Project_Data_Job_analysis
-- Status: NOT EXECUTED in this audit round.
--   PostgreSQL 17 uses scram-sha-256 authentication and no credentials are
--   stored locally, so these checks could not be run against a live database.
--   The same expectations are verified statically by
--   tests/python/validate_datasets.py (job_postings_fact checks run only
--   when the gitignored 123 MB CSV is present locally).
-- How to run (when credentials are available):
--   1. Load data via sql_load/1_create_database.sql, 2_create_tables.sql and
--      3_modify_tables.sql (client-side \copy).
--   2. psql -U <user> -d sql_course -f tests/sql/job_analysis_dq_checks.sql
-- Every query returns (check_name, actual, expected); actual <> expected fails.
-- ============================================================================

SELECT 'company_dim rows'     AS check_name, COUNT(*) AS actual, 140033 AS expected FROM company_dim
UNION ALL
SELECT 'skills_dim rows',     COUNT(*), 259     FROM skills_dim
UNION ALL
SELECT 'skills_job_dim rows', COUNT(*), 3669604 FROM skills_job_dim
UNION ALL
SELECT 'job_postings_fact rows', COUNT(*), 787686 FROM job_postings_fact;

-- Orphan skill links: every skills_job_dim row must resolve on both sides.
SELECT 'orphans skills_job->posting' AS check_name, COUNT(*) AS actual, 0 AS expected
FROM skills_job_dim sj
LEFT JOIN job_postings_fact jf ON sj.job_id = jf.job_id
WHERE jf.job_id IS NULL
UNION ALL
SELECT 'orphans skills_job->skill', COUNT(*), 0
FROM skills_job_dim sj
LEFT JOIN skills_dim sd ON sj.skill_id = sd.skill_id
WHERE sd.skill_id IS NULL;

-- Salary coverage: only 2.8% of postings carry a yearly salary, which is why
-- 4_top_paying_skills.sql returns posting_count alongside every average.
SELECT 'postings with salary_year_avg' AS check_name,
       COUNT(*) AS actual, 22034 AS expected
FROM job_postings_fact WHERE salary_year_avg IS NOT NULL
UNION ALL
SELECT 'Data Analyst postings', COUNT(*), 196593
FROM job_postings_fact WHERE job_title_short = 'Data Analyst';
