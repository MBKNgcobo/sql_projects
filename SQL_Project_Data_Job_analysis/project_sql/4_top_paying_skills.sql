/*
    Question: What are the top skills based on salary?
    - Look at the average salary associated with each skill.
    - Why? It provides insights into the skills that are associated with higher salaries,
      helping job seekers prioritise learning.

    Note: only 22,034 of 787,686 postings (2.8%) carry salary_year_avg, so
    some skills are ranked on very small samples. posting_count is returned
    with every row so the sample size is visible; treat low-count rows with
    caution.
*/
SELECT
    skills_dim.skills,
    ROUND(AVG(job_postings_fact.salary_year_avg), 2) AS avg_salary,
    COUNT(*) AS posting_count
FROM job_postings_fact
INNER JOIN public.skills_job_dim
ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN public.skills_dim
ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_postings_fact.job_title_short = 'Data Analyst'
    AND job_postings_fact.salary_year_avg IS NOT NULL
GROUP BY skills_dim.skills
ORDER BY avg_salary DESC
LIMIT 25;