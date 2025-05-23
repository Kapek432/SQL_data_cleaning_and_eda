-- Part 1 - Data cleaning

-- Check what our data looks like

SELECT * FROM layoffs;

-- Our columns are: company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions

-- Count the number of rows

SELECT COUNT(*) FROM layoffs;

-- 2361

-- In order to clean the data we will:
-- 1. Convert column data types
-- 2. Standardize and fix any errors
-- 3. Handle missing values
-- 4. Add new columns if needed

-- Create a table to perform data cleaning

CREATE TABLE layoffs_cleaned LIKE layoffs;

INSERT INTO layoffs_cleaned
SELECT * FROM layoffs;

SELECT * FROM layoffs_cleaned
LIMIT 5;

-- Now we can start data cleaning

-- We need to convert the `date` column from text to date format

-- SET SQL_SAFE_UPDATES = 0; -- if needed

UPDATE layoffs_cleaned
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_cleaned
MODIFY COLUMN `date` DATE;

-- Now we have the correct formats for all the columns

-- Let's standardize data and look for potential errors

SELECT * FROM layoffs_cleaned;

-- Looking at the table, we can see some companies don't have values 
-- for both total_laid_off and percentage_laid_off

-- We can remove them as they are not useful for EDA

DELETE FROM layoffs_cleaned
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_cleaned;

-- We can also notice there are some missing values in the `industry` column

SELECT * FROM layoffs_cleaned
WHERE industry IS NULL 
   OR industry = ''
ORDER BY industry;

-- 1 company has a NULL value and 3 have empty strings — let's make them all NULL

UPDATE layoffs_cleaned
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoffs_cleaned
WHERE industry IS NULL 
   OR industry = ''
ORDER BY industry;

-- We may try to find rows with the same company name where industry is not NULL

-- and use them to fill the missing industry values

UPDATE layoffs_cleaned l1
JOIN layoffs_cleaned l2
  ON l1.company = l2.company
SET l1.industry = l2.industry
WHERE l1.industry IS NULL
  AND l2.industry IS NOT NULL;

SELECT * FROM layoffs_cleaned
WHERE industry IS NULL;

-- We managed to fill 3 NULL values! Now only one company doesn’t have an industry name.

-- I’ll live with that.

-- Let's look at the types of industries

SELECT DISTINCT industry
FROM layoffs_cleaned
ORDER BY 1;

-- Most of them look legitimate, but we have: Crypto, Crypto Currency, and CryptoCurrency

-- We can standardize them all to 'Crypto'

UPDATE layoffs_cleaned
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

SELECT DISTINCT industry
FROM layoffs_cleaned
ORDER BY 1;

-- Now let's look at the country names

SELECT DISTINCT country
FROM layoffs_cleaned
ORDER BY 1;

-- We can see that we have "United States" and "United States." (with a period)

-- Let's correct that

UPDATE layoffs_cleaned
SET country = TRIM(TRAILING '.' FROM country);

-- The problem is solved!

SELECT DISTINCT country
FROM layoffs_cleaned
ORDER BY 1;

-- Inspect the date column
SELECT * FROM layoffs_cleaned
WHERE `date` IS NULL 
   OR `date` = '';

-- All dates are valid

-- Let’s also check whether the percentages are valid

SELECT * FROM layoffs_cleaned
WHERE percentage_laid_off NOT BETWEEN 0 AND 100;

-- This column looks fine too

-- Check the `stage` column
SELECT * FROM layoffs_cleaned
WHERE stage IS NULL 
   OR stage = '';

-- There are five NULL values, but we can't fill them accurately, so we’ll leave them as is

-- Last but not least, check the company names

SELECT * FROM layoffs_cleaned
WHERE company IS NULL 
   OR company = '';

-- There are no missing values — yay!

-- Now that our data is standardized and formatted, let’s check for duplicates

SELECT company, industry, total_laid_off, `date`,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, `date`
       ) AS row_num
FROM layoffs_cleaned;

SELECT * FROM (
    SELECT company, industry, total_laid_off, `date`,
           ROW_NUMBER() OVER (
               PARTITION BY company, industry, total_laid_off, `date`
           ) AS row_num
    FROM layoffs_cleaned
) duplicates
WHERE row_num > 1;

-- We can see that we have some duplicate rows

-- Before deleting them, let’s investigate whether they should be removed

SELECT * 
FROM layoffs_cleaned
WHERE company = 'Cazoo';

-- Cazoo entries are completely the same – safe to delete

SELECT * 
FROM layoffs_cleaned
WHERE company = 'Oda';

-- Here we can see differences in country and funds

-- So we should PARTITION BY all the columns

SELECT * FROM (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_cleaned
) AS duplicates
WHERE row_num > 1;

-- These rows are completely identical, so we can safely delete them

-- We will use a temporary table to achieve that

CREATE TEMPORARY TABLE layoffs_deduplicated AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_cleaned
) AS numbered
WHERE row_num = 1;

DELETE FROM layoffs_cleaned;

INSERT INTO layoffs_cleaned
SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
FROM layoffs_deduplicated;

SELECT * FROM layoffs;

-- Now our data is clean and ready for EDA!
