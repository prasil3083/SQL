SELECT * FROM
Project.dbo.CovidDeaths ORDER BY 3,4 ;


SELECT Location, date, total_cases, new_cases,total_deaths, population 
FROM Project.dbo.CovidDeaths ORDER BY 1,2 ;


-- Looking at total cases and total cases
-- Show the likeliyhood of dying if you get the covid in your country

SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM Project.dbo.CovidDeaths
WHERE location like '%india%'
ORDER BY 1,2 ;


--Looking At Total Cases Vs The Population

SELECT location, date, population , total_cases  ,(total_cases/population)*100 as Total_infected_ratio 
FROM Project.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking At Countries With Higest Infection Rate Compared To Population

SELECT location , population ,MAX(total_cases) AS HigestInfection ,MAX((total_cases/population)*100 ) AS PercentagePopulationInfected
FROM Project.dbo.CovidDeaths 
GROUP BY location , population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with higest death couunts
SELECT Location , MAX(cast(Total_deaths AS INT)) AS Total_death_counts
FROM Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY Total_death_counts DESC

-- Let's Break things down by continent
SELECT continent , MAX(cast(Total_deaths AS INT)) AS Total_death_counts
FROM Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_counts DESC


--GLOBAL NUMBERS
SELECT SUM(new_cases) AS Total_cases, SUM(cast(new_deaths AS INT)) AS Total_Deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM Project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2 

-- Total above the 2% infected people died (accurate : 2.11204149810363)


SELECT date , SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM Project.dbo.CovidDeaths
where continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2 


--JOIN THE TWO TABLES

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.location , dea.date) as Rolling_People_Vaccinated
FROM Project.dbo.CovidDeaths as dea
JOIN Project.dbo.CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


--USE CTE

WITH PopVsVac (Continent, Location, Date, Population, New_vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_People_Vaccinated
FROM Project.dbo.CovidDeaths AS dea
JOIN Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac


-- Using Temp Table
DROP TABLE IF EXISTS #PersentPopulationVaccinated
CREATE TABLE #PersentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PersentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_People_Vaccinated
FROM Project.dbo.CovidDeaths AS dea
JOIN Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PersentPopulationVaccinated


-- Createing a view to store the data for later visualization

CREATE VIEW PersentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location , dea.date) AS Rolling_People_Vaccinated
FROM Project.dbo.CovidDeaths AS dea
JOIN Project.dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT * FROM PersentPopulationVaccinated

