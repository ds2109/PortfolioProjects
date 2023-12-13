Select *
FROM Portfolio..CovidDeaths
ORDER BY 3,4

    --selecting data 
--SELECT *
--FROM Portfolio..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
ORDER BY 1,2

-- looking at total cases vs total deaths
-- show the likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- looking at total cases vs population
-- what percentage of the population has gotten covid

Select location, date, total_cases, population, ( total_cases/population)*100 as PercentPopInfected
FROM Portfolio..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopInfected
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%states%'
GROUP By location, population 
ORDER BY 4 desc

-- showing countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP By location
ORDER BY TotalDeathCount desc

-- by continent

-- showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%states%'
where continent is not null
GROUP By continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL 
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS TOTAL ( to date)
Select  SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  AS DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not NULL 
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccByCountry
--, (CummulativeVaccByCountry/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH PopVsVac (continent, location, Date, Population, new_vaccinations, CummulativeVaccByCountry)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccByCountry
--, (CummulativeVaccByCountry/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (CummulativeVaccByCountry/Population)*100
FROM PopVsVac

--USE TEMP TABLE
CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativeVaccByCountry numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccByCountry
--, (CummulativeVaccByCountry/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (CummulativeVaccByCountry/Population)*100
FROM #percentpopulationvaccinated


DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CummulativeVaccByCountry numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccByCountry
--, (CummulativeVaccByCountry/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (CummulativeVaccByCountry/Population)*100
FROM #percentpopulationvaccinated

-- Creating View to store data for later visualisations

CREATE VIEW percentpopulationvaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) AS CummulativeVaccByCountry
--, (CummulativeVaccByCountry/population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated