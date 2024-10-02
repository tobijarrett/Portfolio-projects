# DATA CLEANING PROJECT

SELECT *
FROM layoffs;

# CREATING A DUPLICATE TABLE TO WORK ON
# IT IS BEST PRACTICE TO LEAVE THE RAW DATA UNTOUCHED AND WORK ON A DUPLICATE

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;


# REMOVING DUPLICATE ROWS

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

# CREATING A CTE TO FILTER OUT THE DUPLICATES

WITH duplicates_cte AS
(SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY company, 
	location, industry, total_laid_off, percentage_laid_off, 
	`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT *
FROM duplicates_cte
WHERE row_num > 1;

# NOW THAT WE KNOW THE DUPLICATES, I WILL CREATE A NEW TABLE THAT INCLUDES THE "ROW NUM" COLUMN
# THEN WE CAN DELETE THE DUPLICATES AND CONTINUE WITH THE CLEANING

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_staging2
SELECT 
	*,ROW_NUMBER() OVER(PARTITION BY company, 
    location, industry, total_laid_off, percentage_laid_off, `date`, 
    stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


# STANDARDIZING THE DATA

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;


SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


# TREATING NULL VALUES

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE  layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


# DROPPING IRRELEVANT COLUMNS

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT *
FROM layoffs_staging2









