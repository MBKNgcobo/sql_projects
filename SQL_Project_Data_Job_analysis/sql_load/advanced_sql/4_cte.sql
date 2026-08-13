
WITH job_postings_count AS (
    SELECT
        company_id,
        COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY  company_id
)

SELECT
    company_dim.name AS company_name,
    job_postings_count.job_count AS total_job_postings,
    CASE
        WHEN job_postings_count.job_count < 10 THEN 'Low'
        WHEN job_postings_count.job_count >= 10 AND job_postings_count.job_count < 50 THEN 'Medium'
        WHEN job_postings_count.job_count >= 50 THEN 'High'
    END AS job_posting_range
FROM company_dim
JOIN job_postings_count ON company_dim.company_id = job_postings_count.company_id
GROUP BY company_dim.name, job_postings_count.job_count;
