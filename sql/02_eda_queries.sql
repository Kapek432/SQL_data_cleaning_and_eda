-- EDA - Exploratory Data Analysis

-- 1. Preview the dataset

-- Preview a sample of the dataset (limit to 100 rows)

SELECT *
FROM layoffs_cleaned
LIMIT 100;

-- 2. Top layoffs by total number and percentage

-- Top 5 records by total number of layoffs

SELECT *
FROM layoffs_cleaned
ORDER BY total_laid_off DESC
LIMIT 5;

-- Top 5 records by highest layoff percentage

SELECT *
FROM layoffs_cleaned
ORDER BY percentage_laid_off DESC
LIMIT 5;

-- 3. Companies with 100% layoffs

-- Companies that laid off 100% of their workforce, sorted by funding

SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Count of such companies

SELECT COUNT(*)
FROM layoffs_cleaned
WHERE percentage_laid_off = 1;

-- 4. Total layoffs by company, location, and country

-- Top 10 companies with the highest total layoffs

SELECT company, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY company
ORDER BY total DESC
LIMIT 10;

-- Top 10 locations with the highest total layoffs

SELECT location, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY location
ORDER BY total DESC
LIMIT 10;

-- Total layoffs by country

SELECT country, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY country
ORDER BY total DESC;

-- 5. Layoffs over time (yearly, monthly, cumulative)

-- Yearly total layoffs

SELECT YEAR(date) AS year, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Monthly total layoffs

SELECT SUBSTRING(date, 1, 7) AS `month`, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY `month`
ORDER BY `month` ASC;

-- Rolling (cumulative) layoffs per month

WITH DATE_CTE AS (
  SELECT SUBSTRING(date, 1, 7) AS `month`, SUM(total_laid_off) AS total
  FROM layoffs_cleaned
  GROUP BY `month`
)
SELECT `month`, SUM(total) OVER (ORDER BY `month` ASC) AS rolling_total
FROM DATE_CTE
ORDER BY `month` ASC;

-- 6. Layoffs by industry and company stage

-- Total layoffs by industry

SELECT industry, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY industry
ORDER BY total DESC;

-- Total layoffs by company stage 

SELECT stage, SUM(total_laid_off) AS total
FROM layoffs_cleaned
GROUP BY stage;

-- 7. Top layoff companies per year

WITH Company_Year AS (
  SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total
  FROM layoffs_cleaned
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS (
  SELECT company, year, total,
         DENSE_RANK() OVER (PARTITION BY year ORDER BY total DESC) AS `rank`
  FROM Company_Year
)
SELECT company, year, total, `rank`
FROM Company_Year_Rank
WHERE `rank` <= 3 AND year IS NOT NULL
ORDER BY year ASC, total DESC;

