SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of death from covid-19 for each country

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Kenya'
ORDER BY 1,2

-- Shows the population infection rate for each country

SELECT location, date, population, total_cases, (total_cases/population)*100 as infection_rate
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Kenya'
ORDER BY 1,2

-- Shows countries with the highest infection rates

SELECT location, population, MAX(total_cases) AS highest_case_count, MAX((total_cases/population))*100 AS max_infection_rate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC

-- Shows countries with highest death rates

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS max_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY max_deaths DESC

-- Now looking at continents and global regions

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS max_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location, population
ORDER BY max_deaths DESC

-- Global total cases, total deaths and daily deathrates

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY date

-- Global death rate as at 2022-08-11

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL

-- Looking at Vaccinations vs total population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Shows daily vaccination trend

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_trend
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccination_trend)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_trend
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (vaccination_trend/population)*100 AS vaccination_rate
FROM PopvsVac

-- USE TEMP TABLE

DROP TABLE IF EXISTS #PercentVaccinations
CREATE TABLE #PercentVaccinations
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population float,
new_vacinations float,
vaccination_trend float
)
INSERT INTO #PercentVaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_trend
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


SELECT *, (vaccination_trend/population)*100 AS vaccination_trend
FROM #PercentVaccinations

-- Creating view to store for later visualizations

CREATE VIEW PercentVaccinations AS
WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccination_trend)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(FLOAT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccination_trend
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, (vaccination_trend/population)*100 AS vaccination_rate
FROM PopvsVac