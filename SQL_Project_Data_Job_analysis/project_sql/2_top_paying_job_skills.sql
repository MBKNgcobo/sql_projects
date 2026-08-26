/*
Question: What skills are required for the top paying data analyst jobs?
- Use the top 10 highest paying Data Analyst jobs from the previous query to identify the skills required for these positions.
- Add the specific skills required for these roles
- Why? It provides insights into the skills that are in demand for high-paying Data Analyst positions, helping job seekers focus on acquiring the right skills to enhance their career prospects.
*/
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        salary_year_avg
    FROM public.job_postings_fact
    WHERE job_title_short = 'Data Analyst'
      AND salary_year_avg IS NOT NULL
      AND job_location = 'Anywhere'
    ORDER BY salary_year_avg DESC
    LIMIT 10
)
SELECT 
    top_paying_jobs.*,
    skills
FROM top_paying_jobs
INNER JOIN public.skills_job_dim
ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN public.skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY top_paying_jobs.salary_year_avg DESC;