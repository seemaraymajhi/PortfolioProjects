

SELECT *
FROM Portfolioproject..CovidDeaths
ORDER BY 3, 4



--SELECT *
--FROM Portfolioproject..CovidVaccinations
--ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE location like '%Nepal%'
ORDER BY 1,2


SELECT location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
--WHERE location like '%Nepal%'
ORDER BY 1,2


SELECT location, population, MAX(total_cases) as Highestcases, MAX((total_cases/population))*100 as 
  Percentpopinfected
FROM Portfolioproject..CovidDeaths
--WHERE location like '%Nepal%'
GROUP BY location, population
ORDER BY Percentpopinfected desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeath desc	



SELECT location, MAX(cast(total_deaths as int)) as TotalDeath
FROM Portfolioproject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeath desc


SELECT date, SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths ,SUM(cast(new_deaths as int))/
SUM(New_cases)*100  as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as Totaldeaths ,SUM(cast(new_deaths as int))/
SUM(New_cases)*100  as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int, VAC.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location,
   DEA.date) as RollingCount
FROM Portfolioproject..CovidDeaths DEA
JOIN Portfolioproject..CovidVaccinations VAC
	 On DEA.location = VAC.location
	 and DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3



With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingCount)
as 
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
,SUM(CONVERT(int, VAC.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location,
   DEA.date) as RollingCount
FROM Portfolioproject..CovidDeaths DEA
JOIN Portfolioproject..CovidVaccinations VAC
	 On DEA.location = VAC.location
	 and DEA.date = VAC.date
WHERE DEA.continent is not null

)
SELECT *, (RollingCount/Population)*100
FROM PopvsVac


Drop Table if exists #Percentpopvac
CREATE TABLE #Percentpopvac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingCount numeric
)

Insert into #Percentpopvac
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int, VAC.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location,
DEA.date) as RollingCount
FROM Portfolioproject..CovidDeaths DEA
JOIN Portfolioproject..CovidVaccinations VAC
On DEA.location = VAC.location
and DEA.date = VAC.date
--WHERE DEA.continent is not null
ORDER BY 2,3

SELECT *, (RollingCount/Population)*100
FROM #Percentpopvac


Create View Percentpopvac as
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int, VAC.new_vaccinations)) OVER (Partition by DEA.Location ORDER BY DEA.location,
DEA.date) as RollingCount
FROM Portfolioproject..CovidDeaths DEA
JOIN Portfolioproject..CovidVaccinations VAC
On DEA.location = VAC.location
and DEA.date = VAC.date
WHERE DEA.continent is not null
