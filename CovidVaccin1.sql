USE portfolioproject1;

select * from dbo.CovidVaccination$
ORDER BY 3,4

select * from dbo.CovidDeaths
ORDER BY 3,4;

SELECT location, date,total_cases,new_cases,total_deaths, population 
from dbo.CovidDeaths

-- Looking at total_cases VS Total_deaths

SELECT location,date,total_cases,total_deaths,(cast (total_deaths as INT )) / (cast (total_cases AS INT))
from dbo.CovidDeaths


SELECT location,date,total_cases,total_deaths, total_deaths/total_cases
from dbo.CovidDeaths


ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INTEGER;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INTEGER;

SELECT location,date,total_cases,total_deaths, CAST((total_deaths * 100.0 / total_cases) AS FLOAT) AS death_percentage
FROM dbo.CovidDeaths
WHERE location LIKE '%india%'
ORDER BY death_percentage DESC


SELECT location,date,total_cases,population,CAST((total_cases * 100.0 / population) AS FLOAT) AS case_percentage
FROM dbo.CovidDeaths
WHERE location LIKE '%india%' and continent IS NOT NULL
ORDER BY case_percentage DESC


SELECT location,population, MAX(total_cases),max( CAST((total_cases * 100.0 / population) AS FLOAT)) AS case_percentage
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY  case_percentage DESC

-- countries with highest death counts

SELECT location, MAX(total_deaths) as max_deaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY  max_deaths DESC

-- By continents

SELECT continent, MAX(total_deaths) as max_deaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  max_deaths DESC

-- Breaking into global

SELECT location,date,total_cases,total_deaths, CAST((total_deaths * 100.0 / total_cases) AS FLOAT) AS death_percentage
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY death_percentage DESC

SELECT date,
SUM(CAST(new_cases AS INT)) AS total_new_cases,
SUM(CAST(new_deaths AS INT)) AS total_new_deaths,
CAST(SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(new_cases), 0) AS FLOAT) AS DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null
group by date


SELECT
sum(cast(new_cases as INT)) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
CAST (sum(cast(new_deaths as int))* 100.0/ NULLIF(SUM(new_cases), 0) AS FLOAT) as DeathPercentage
FROM dbo.CovidDeaths
WHERE continent is not null


-- Looking at total population vs vaccination

SELECT * FROM CovidVaccination$;

ALTER TABLE CovidVaccination$
ALTER COLUMN new_vaccinations INTEGER;


-- CTE

WITH PopVsVac (Continent,Date,Location,Population,New_vaccinations,Rolling_people_vacc)
AS
(
SELECT dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vacc
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
ON dea.location= vac.location AND dea.date= vac.date
WHERE dea.continent is not null
)
SELECT *,
Rolling_people_vacc/population*100
FROM PopVsVac

-- Creating view for later visualization

create view Percent_people_vaccinated as	
SELECT dea.continent,dea.date,dea.location,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vacc
FROM CovidDeaths dea
JOIN CovidVaccination$ vac
ON dea.location= vac.location AND dea.date= vac.date
WHERE dea.continent is not null