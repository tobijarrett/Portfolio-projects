# EXPLORATORY DATA ANALYSIS PROJECT


SELECT * 
FROM layoffs_staging2;

# TAKING A LOOK AT THE COMPANIES WITH THE MOST TOTAL LAID OFF

SELECT company, MAX(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# DOING THE SAME FOR PERCENTAGE LAID OFF

SELECT company, MAX(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# SOME COMPANIES LAID OFF %100 OF THEIR STAFF
# TAKING A LOOK AT THE ONES THAT DID

SELECT company, MAX(percentage_laid_off), stage
FROM layoffs_staging2
GROUP BY company, stage
HAVING MAX(percentage_laid_off) = 1
ORDER BY 3;

# TO FURTHER CHECK THE NUMBER OF COMPANIES WITH %100 TOTAL LAID OFF IN EVERY STAGE

SELECT stage, COUNT(company)
FROM layoffs_staging2
WHERE percentage_laid_off =1
GROUP BY stage
ORDER BY 2 DESC;

# TAKING A LOOK AT THE COMPANIES IN POST IPO STAGE WITH %100 TOTAL LAID OFF

SELECT company, industry, stage, total_laid_off, country
FROM layoffs_staging2
WHERE stage = 'Post-IPO' AND percentage_laid_off = 1;

# CHECKING THE COMPANY THAT HAD THE MOST PEOPLE LAID OFF AMONGST THE ONES WITH %100 TOTAL LAID OFF

SELECT company, industry, total_laid_off
FROM layoffs_staging2
WHERE percentage_laid_off = 1 AND total_laid_off IS NOT NULL
ORDER BY 3 DESC;

# LOOKING AT THE SUM OF EVERY COMPANY'S TOTAL LAID OFF

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

# LOOKING AT THE INDUSTRY THAT GOT HIT THE MOST

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# WHAT COUNTRIES LAID OFF THE MOST EMPLOYEES

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# COMPANIES IN NIGERIA

SELECT company, total_laid_off, `date`
FROM layoffs_staging2
WHERE country = 'nigeria'
ORDER BY 2;

# LOOKING AT THE TOTAL LAID OFF BY YEAR

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

#LOOKING AT THE ROLLING SUM OF TOTAL LAID OFF BY EACH MONTH

SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS sum_total_lo
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1;

WITH Rolling_Total AS
(SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS sum_total_lo
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER BY 1)
SELECT `month`, sum_total_lo, SUM(sum_total_lo) OVER(ORDER BY `month`)
FROM Rolling_Total;

# LOOKING AT THE TOP 5 COMPANIES WITH THE MOST TOTAL LAID OFF PER YEAR

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
ORDER BY 3 DESC;

WITH company_year (company, years, total_laid_off)AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company,  YEAR(`date`)
), company_year_ranking AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_ranking
WHERE ranking <= 5;

# LOOKING AT THE TOP 5 INDUSTRIES WITH THE MOST TOTAL LAID OFF PER YEAR

WITH industry_year (industry, years, total_laid_off)AS
(
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry,  YEAR(`date`)
), industry_year_ranking AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM industry_year
WHERE years IS NOT NULL
)
SELECT *
FROM industry_year_ranking
WHERE ranking <= 5















