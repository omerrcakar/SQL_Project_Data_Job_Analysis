SELECT 
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS column_month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    column_month
ORDER BY
    job_posted_count DESC;


SELECT 
    *
FROM 
    job_postings_fact
WHERE
    EXTRACT(MONTH FROM job_posted_date) = 1
LIMIT 10;


-- January
CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

-- February
CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;


-- March
CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

SELECT job_posted_date
FROM february_jobs
LIMIT 5;


SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact;

-- problem
SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;


-- SubQuery
SELECT *
FROM(
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;

-- CTE's
WITH january_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)

SELECT *
FROM january_jobs;


-- subquery example
SELECT 
    company_id,
    name AS company_name
FROM
    company_dim
WHERE
    company_id IN (
        SELECT 
            company_id
        FROM
            job_postings_fact
        WHERE
            job_no_degree_mention = true
        ORDER BY 
            company_id
    )

/*
    CTE's exp
    Find the companies that have the most job openings
    -Get the total number of job postings per company id (job posting fact)
    -Return the total number of jobs with the company name(company dim)
*/

WITH company_job_count AS (
    SELECT 
        company_id,
        COUNT(*) AS total_jobs

    FROM
        job_postings_fact
    GROUP BY
        company_id
)


SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs

FROM
    company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    total_jobs DESC;



/*
    Find the count of the number of remote job posting per skill
    - Display the top 5 skills by their demand in remote jobs
    - Include skill ID , name and count of postings requiring the skill

    Uzaktan iş ilanı sayısının beceri başına sayısını bulun
    - Uzaktan işlerde talebe göre ilk 5 beceriyi görüntüleyin
    - Beceri kimliğini, adını ve beceriyi gerektiren ilan sayısını ekleyin  
*/
WITH remote_job_skills AS (
    SELECT 
        skills_to_job.skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job 
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_work_from_home = true AND
        job_postings.job_title_short = 'Data Analyst'
    GROUP BY
        skill_id
)

SELECT 
    skill.skill_id,
    skills AS skill_name,
    skill_count
FROM
    remote_job_skills
INNER JOIN skills_dim AS skill ON skill.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;

/*

Find job postings from the first quarter that have a salary greater than $70K
-Combine job postings tables from the first quarter of 2023 (JAN Mar)
-Gets job postings with an average yearly salary > $70,000
*/

SELECT 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::DATE,
    quarter1_job_postings.salary_year_avg
FROM (
    SELECT *
    FROM
        january_jobs
    UNION ALL
    SELECT *
    FROM
        february_jobs
    UNION ALL
    SELECT *
    FROM
        march_jobs
) AS quarter1_job_postings
WHERE 
    quarter1_job_postings.salary_year_avg > 70000 AND
    quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC
