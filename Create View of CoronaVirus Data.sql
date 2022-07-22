-- SELECT EVERYTHING FROM COVID DEATHS' TABLE

SELECT *
FROM portfolioproject.dbo.CovidDeaths


-- SELECT EVERYTHING FROM COVID VACCINATION TABLE 

SELECT *
FROM portfolioproject.dbo.CovidVaccinations

-- SELECT THE DATA WE ARE GOING TO USE

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.dbo.CovidDeaths
ORDER BY 1, 2

-- TOTAL CASES VS TOTAL DEATH

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DEATH_PERCENTAGE
FROM portfolioproject.dbo.CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

-- TOTAL CASES VS POPULATION

SELECT location, date, total_cases, population, (total_cases/population)*100 PercentPopulationInfected
FROM portfolioproject.dbo.CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

-- COUNTRIES WITH HIGHEST INFECTION RATE  COMPARED TO POPULATION

SELECT location, population, Max(total_cases) Total_cases, Max((total_cases/population))*100 PercentPopulationInfected
FROM portfolioproject.dbo.CovidDeaths
--WHERE location = 'Nigeria'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, Max(cast(total_deaths as int)) TotalDeathCount
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, Max(cast(total_deaths as int)) TotalDeathCount
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) total_cases, SUM(CAST(new_deaths as int)) total_death, 
SUM(CAST(new_deaths as int))/ SUM(new_cases)* 100 DeathPercentage
FROM portfolioproject.dbo.CovidDeaths
WHERE continent is not null


SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date)
FROM portfolioproject..CovidDeaths d
JOIN portfolioproject..CovidVaccinations V
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3


--COMBINED TABLE EXPRESSION

WITH PopvsVac as --(continent, location, date, new_vaccinations, rollingpeoplevaccinated

(SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths d
JOIN portfolioproject..CovidVaccinations V
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3
)

SELECT *, 
(RollingPeopleVaccinated/population)*100 as percentvaccinated
FROM PopvsVac
WHERE location like '%nigeria%'
ORDER BY location, date


--CREATE TEMPORARY TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM portfolioproject..CovidDeaths d
JOIN portfolioproject..CovidVaccinations V
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3

SELECT *, 
(RollingPeopleVaccinated/population)*100 as percentvaccinated
FROM #PercentPopulationVaccinated

-- CREATE VIEW

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated 
AS SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(CONVERT(float, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM portfolioproject.dbo.CovidDeaths d
JOIN portfolioproject.dbo.CovidVaccinations V
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated


