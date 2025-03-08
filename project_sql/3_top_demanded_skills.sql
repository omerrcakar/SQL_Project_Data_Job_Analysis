/*
Question: What are the most in-demand skills for data analysts?
- Join job postings to inner join table similar to query 2
- Identify the top 5 in-demand skills for a data analyst.
- Focus on all job postings.
- Why? Retrieves the top 5 skills with the highest demand in the job market, 
    providing insights into the most valuable skills for job seekers.
*/
    
/*
    COUNT(skills_job_dim.job_id) → skills_job_dim tablosundaki job_id sütunundaki değerleri sayıyor.
    Amaç: skills sütunundaki her bir beceri için, kaç farklı iş ilanında geçtiğini hesaplamak.
*/

/*
    COUNT(skills_job_dim.job_id) → Bu fonksiyon, skills_job_dim tablosundaki job_id değerlerini sayar.
    Ama "hangi beceriye (skills) ait olduğunu" nasıl biliyor?
    Çünkü GROUP BY skills kullanıyoruz!
    Her bir beceri için COUNT işlemi ayrı ayrı yapılır.
*/

SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND
    job_work_from_home = TRUE

GROUP BY
    skills
ORDER BY
    demand_count DESC
LIMIT 5