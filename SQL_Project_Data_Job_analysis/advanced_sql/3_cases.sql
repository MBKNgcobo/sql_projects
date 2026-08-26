SELECT
 job_id,
    CASE
        WHEN salary_year_avg < 50000 THEN 'Low'
        WHEN salary_year_avg >= 50000 AND salary_year_avg < 100000 THEN 'Medium'
        WHEN salary_year_avg >= 100000 THEN 'High'
    END AS salary_range
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
ORDER BY salary_range DESC;
