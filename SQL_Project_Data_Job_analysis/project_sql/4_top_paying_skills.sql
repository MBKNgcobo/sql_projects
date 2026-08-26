/*
    Question: What are the top skills based on salary?
    - Look at the avarage salary assiciated with each skill
    - Why? It provides insights into the skills that are associated with higher salaries, helping job
*/

SELECT
    skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS avg_salary
FROM job_postings_fact
INNER JOIN public.skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN public.skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
GROUP BY skills
ORDER BY avg_salary DESC
LIMIT 25;