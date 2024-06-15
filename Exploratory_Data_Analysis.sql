-- Switch to the 'world_layoffs' database
USE world_layoffs;

-- Display all records from the 'layoff_stages2' table
SELECT * FROM layoff_stages2;

-- Find the maximum values of total_laid_off and percentage_laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoff_stages2;

-- Select records where percentage_laid_off is 100%, ordered by total_laid_off in descending order
SELECT * FROM layoff_stages2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Select records where percentage_laid_off is 100%, ordered by funds_raised_millions in descending order
SELECT * FROM layoff_stages2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Summarize total_laid_off by company, ordered by the sum of total_laid_off in descending order
SELECT company, SUM(total_laid_off)
FROM layoff_stages2
GROUP BY company
ORDER BY 2 DESC;

-- Calculate basic statistics for numeric columns:
SELECT 
    MIN(total_laid_off) AS min_total_laid_off,
    MAX(total_laid_off) AS max_total_laid_off,
    AVG(total_laid_off) AS avg_total_laid_off,
    MIN(funds_raised_millions) AS min_funds_raised,
    MAX(funds_raised_millions) AS max_funds_raised,
    AVG(funds_raised_millions) AS avg_funds_raised
FROM
    layoff_stages2;

-- Check the number of unique values for categorical columns:
SELECT 
    COUNT(DISTINCT company) AS unique_companies,
    COUNT(DISTINCT location) AS unique_locations,
    COUNT(DISTINCT industry) AS unique_industries,
    COUNT(DISTINCT stage) AS unique_stages,
    COUNT(DISTINCT country) AS unique_countries
FROM
    layoff_stages2;


-- Check for missing values in the table:
SELECT 
    SUM(CASE
        WHEN company IS NULL THEN 1
        ELSE 0
    END) AS missing_company,
    SUM(CASE
        WHEN location IS NULL THEN 1
        ELSE 0
    END) AS missing_location,
    SUM(CASE
        WHEN industry IS NULL THEN 1
        ELSE 0
    END) AS missing_industry,
    SUM(CASE
        WHEN total_laid_off IS NULL THEN 1
        ELSE 0
    END) AS missing_total_laid_off,
    SUM(CASE
        WHEN percentage_laid_off IS NULL THEN 1
        ELSE 0
    END) AS missing_percentage_laid_off,
    SUM(CASE
        WHEN date IS NULL THEN 1
        ELSE 0
    END) AS missing_date,
    SUM(CASE
        WHEN stage IS NULL THEN 1
        ELSE 0
    END) AS missing_stage,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS missing_country,
    SUM(CASE
        WHEN funds_raised_millions IS NULL THEN 1
        ELSE 0
    END) AS missing_funds_raised
FROM
    layoff_stages2;


-- Summarize total_laid_off by industry, ordered by the sum of total_laid_off in descending order
SELECT industry, SUM(total_laid_off)
FROM layoff_stages2
GROUP BY industry
ORDER BY 2 DESC;


-- Summarize total_laid_off by country, ordered by the sum of total_laid_off in descending order
SELECT country, SUM(total_laid_off)
FROM layoff_stages2
GROUP BY country
ORDER BY 2 DESC;

-- Summarize total_laid_off by year, ordered by year in descending order
SELECT YEAR(date), SUM(total_laid_off)
FROM layoff_stages2
GROUP BY YEAR(date)
ORDER BY 1 DESC;

-- Summarize total_laid_off by stage, ordered by the sum of total_laid_off in descending order
SELECT stage, SUM(total_laid_off)
FROM layoff_stages2
GROUP BY stage
ORDER BY 2 DESC;

-- Summarize total_laid_off by month, ordered by the sum of total_laid_off in descending order
SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off)
FROM layoff_stages2
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY month
ORDER BY 2 DESC;

-- Calculate rolling total of layoffs by month
WITH Rolling_Total AS (
    SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS tlo
    FROM layoff_stages2
    WHERE SUBSTRING(date, 1, 7) IS NOT NULL
    GROUP BY month
    ORDER BY 2 DESC
)
SELECT month, tlo, SUM(tlo) OVER(ORDER BY month) AS rolling_total
FROM Rolling_Total;

-- Summarize total_laid_off by company and year, ordered by the sum of total_laid_off in descending order
SELECT company, YEAR(date), SUM(total_laid_off)
FROM layoff_stages2
GROUP BY company, YEAR(date)
ORDER BY 3 DESC;

-- Explore the relationship between funds raised and layoffs
SELECT 
    funds_raised_millions, 
    total_laid_off
FROM layoff_stages2
WHERE funds_raised_millions IS NOT NULL
AND total_laid_off IS NOT NULL;

-- Identify the most recent layoffs
SELECT 
    company, location, industry, total_laid_off, date
FROM
    layoff_stages2
ORDER BY date DESC
LIMIT 10;

-- Calculate the variance and standard deviation of layoffs

SELECT 
    VARIANCE(total_laid_off) AS variance_laid_off,
    STDDEV(total_laid_off) AS stddev_laid_off
FROM layoff_stages2;



-- Identify top 5 companies with the most layoffs each year
WITH company_year (company, years, total_laid_off) AS (
    SELECT company, YEAR(date), SUM(total_laid_off)
    FROM layoff_stages2
    GROUP BY company, YEAR(date)
), company_year_rank AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
    WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;

-- Identify top 5 industries with the most layoffs each year
WITH industry_year (industry, years, total_laid_off) AS (
    SELECT industry, YEAR(date), SUM(total_laid_off)
    FROM layoff_stages2
    GROUP BY industry, YEAR(date)
), industry_year_rank AS (
    SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
    FROM industry_year
    WHERE years IS NOT NULL
)
SELECT *
FROM industry_year_rank
WHERE ranking <= 5;
