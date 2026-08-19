/*
    Question: What are the top paying data analyst jobs?
    - Identify the top paying data analyst jobs that are available remotely.
    - Focuses on job posting with specified salaries (remove nulls).
    - Why? Highlight the top paying opportunities for Data Analysts, offering insights into 
*/

SELECT
    name AS company_name,
     job_id,
     job_title,
     job_location,
     job_schedule_type,
     salary_year_avg,
     job_posted_date
FROM public.job_postings_fact
LEFT JOIN public.company_dim
ON job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short = 'Data Analyst'
  AND salary_year_avg IS NOT NULL
  AND job_location = 'Anywhere'
ORDER BY salary_year_avg DESC
LIMIT 10;

