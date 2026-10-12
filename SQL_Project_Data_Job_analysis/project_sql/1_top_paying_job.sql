/*
    Question: What are the top paying data analyst jobs?
    - Identify the top paying data analyst jobs that are available remotely.
    - Focuses on job posting with specified salaries (remove nulls).
    - Why? Highlight the top paying opportunities for Data Analysts, offering insights into 
*/

SELECT
    company_dim.name AS company_name,
    job_postings_fact.job_id,
    job_postings_fact.job_title,
    job_postings_fact.job_location,
    job_postings_fact.job_schedule_type,
    job_postings_fact.salary_year_avg,
    job_postings_fact.job_posted_date
FROM public.job_postings_fact
LEFT JOIN public.company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
  AND job_postings_fact.salary_year_avg IS NOT NULL
  AND job_postings_fact.job_location = 'Anywhere'
ORDER BY job_postings_fact.salary_year_avg DESC
LIMIT 10;

