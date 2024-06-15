-- Data Cleaning Process

-- Switch to the 'world_layoffs' database
USE world_layoffs;

-- Display all records from the 'layoffs' table
SELECT * FROM layoffs;

-- Steps for Data Cleaning:
-- 1. Remove duplicate values
-- 2. Standardize the data
-- 3. Remove Null values or blank values
-- 4. Remove any unnecessary columns

-- Create a new table 'layoff_stages' with the same structure as 'layoffs'
CREATE TABLE layoff_stages LIKE layoffs;

-- Insert all records from 'layoffs' into 'layoff_stages'
INSERT INTO layoff_stages
SELECT * FROM layoffs;

-- Display all records from the 'layoff_stages' table to verify the insertion
SELECT * FROM layoff_stages;

-- Add a row number to each record, partitioned by specified columns to detect duplicates
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date'
) AS row_num
FROM layoff_stages;


-- Create a Common Table Expression (CTE) to identify duplicate records
WITH duplicate_cte AS (
    SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', country, funds_raised_millions
    ) AS row_num
    FROM layoff_stages
)
-- Select only the duplicate records (row_num > 1)
SELECT * FROM duplicate_cte WHERE row_num > 1;

-- Create a new table 'layoff_stages2' with an additional 'row_num' column to store row numbers
CREATE TABLE `layoff_stages2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- Display all records from the 'layoff_stages2' table to verify its structure
SELECT * FROM layoff_stages2;

-- Insert records into 'layoff_stages2', assigning row numbers to identify duplicates
INSERT INTO layoff_stages2
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', country, funds_raised_millions
) AS row_num
FROM layoff_stages;



-- Step 1: Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Step 2: Execute your DELETE statement
DELETE FROM layoff_stages2 WHERE row_num > 1;

-- Step 3: Re-enable safe update mode (if desired)
SET SQL_SAFE_UPDATES = 1;


select * from layoff_stages2 where row_num>1;

-- Step 1: Disable safe update mode to allow deletion without key constraints
SET SQL_SAFE_UPDATES = 0;

-- Step 2: Delete duplicate records (row_num > 1) from 'layoff_stages2'
DELETE FROM layoff_stages2 WHERE row_num > 1;

-- Step 3: Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

-- Display records from 'layoff_stages2' to verify the deletion of duplicates
SELECT * FROM layoff_stages2 WHERE row_num > 1;


-- Standardizing  data

select company,trim(company) from layoff_stages2;

-- Step 1: Disable safe update mode to allow deletion without key constraints
SET SQL_SAFE_UPDATES = 0;

update layoff_stages2
set company=trim(company);

select distinct industry from layoff_stages2;

select * from layoff_stages2 where industry like 'Crypto%';

update layoff_stages2
set industry='Crypto'
where industry like 'Crypto%';

select distinct country
 from layoff_stages2;
 

select distinct country
 from layoff_stages2
 where country like 'United%';

update layoff_stages2
set country='United States'
where country like 'United States%';


select date
from layoff_stages2;

update layoff_stages2
set date=str_to_date(date,'%m/%d/%Y');

alter table layoff_stages2
modify column date DATE;

-- Null values and Blank values


select *
from layoff_stages2
where total_laid_off is null
and  percentage_laid_off is null and funds_raised_millions is null;

select *
from layoff_stages2
where industry is NULL
or industry ='';

select t1.industry,t2.industry
from layoff_stages2 t1
join layoff_stages2 t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry ='')
and t2.industry is not null;
    

update layoff_stages2
set industry=null
where industry='';

update layoff_stages2 t1
join layoff_stages2 t2
	on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;


select *
from layoff_stages2
where total_laid_off is null
and  percentage_laid_off is null;

delete
from layoff_stages2
where total_laid_off is null
and  percentage_laid_off is null;

select *
from layoff_stages2
where total_laid_off is null
and  percentage_laid_off is null and funds_raised_millions is null;


delete
from layoff_stages2
where total_laid_off is null
and  percentage_laid_off is null and funds_raised_millions is null;



-- Remove Columns

alter table layoff_stages2
drop column row_num;

select * from layoff_stages2;