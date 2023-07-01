SELECT * 
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM CovidDatabase..CovidVaccinations
--ORDER BY 3,4

--Looking at the data 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths

--Likelihood of Dying if you are living in India and is infected by COVID-19
SELECT Location, date, total_cases,new_Cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDatabase..CovidDeaths
WHERE location = 'India' and date='2022-01-23'
ORDER BY 1,2 


--Looking at total cases vs Population
--Percentage of population got Covid-19
SELECT Location, date, Population, total_cases, (total_cases/population)*100 as infected_percentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
and location ='India'
ORDER BY 1,2 

--Countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population)*100) as infection_percentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
--WHERE location ='India'
GROUP BY location,population
ORDER BY infection_percentage desc

---Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as Highest_Death_Count
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
--WHERE location ='India'
GROUP BY location
ORDER BY Highest_Death_Count desc


---Countries with Highest Death Count per Population
-- Looking in the perspective of Continents

SELECT continent, MAX(cast(total_deaths as int)) as Highest_Death_Count
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY Highest_Death_Count desc



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCasesByDate ,SUM(cast(new_deaths as int)) as TotalDeathsByDate,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 
 
--Total Cases Globally

 SELECT  SUM(new_cases) as TotalCasesByDate ,SUM(cast(new_deaths as int)) as TotalDeathsByDate,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM CovidDatabase..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 





----------------Vaccinations--------------------------

--- Total Vaccinations in each country by date and its percentage of people vaccinated

Select dea.continent,dea.location,dea.population,SUM(cast(vac.new_vaccinations as int))  as vaccinated,
(SUM(cast(vac.new_vaccinations as int))/dea.population)*100 as vaccinated_percentage
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null --and vac.new_vaccinations is not null
GROUP BY dea.location,dea.continent,dea.population
ORDER BY 2,3

SELECT MAX(DATE) FROM CovidDatabase..CovidDeaths

--Countries that haven't started Vaccination till date

Select vac.continent,vac.location,SUM(dea.new_cases)
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
WHERE vac.continent is not null and vac.new_vaccinations is null
GROUP BY vac.location,vac.continent
ORDER BY 1,2

--Count of Countries in each continent that has not started vaccinations yet and has covid cases

Select continent,count(distinct location) as no_of_countries
from CovidDatabase..CovidVaccinations vac
WHERE continent is not null and new_vaccinations is null
GROUP BY vac.continent
ORDER BY 1


--Total Population vs Total Vaccinations 


Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date ) as total_people_vaccinated
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


----

WITH PopVacc (Continent,Location,Date,Population,NewVaccinations,RollingPeopleVaccinated) 
AS(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date ) as total_people_vaccinated
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 
)

Select *,(RollingPeopleVaccinated/Population)*100 
from PopVacc


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date ) as RollingPeopleVaccinated
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
--WHERE dea.continent is not null 

Select *,(RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



--------------------Creating View for storing Data for visualizations----------------------------
DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.Date ROWS UNBOUNDED PRECEDING) as total_people_vaccinated
from CovidDatabase..CovidVaccinations vac
JOIN CovidDatabase..CovidDeaths dea
ON dea.location=vac.location and dea.date=vac.date
WHERE dea.continent is not null 

SELECT * FROM PercentPopulationVaccinated

SELECT * FROM CovidDatabase..CovidDeaths



--------------------Queries for Visualiztion-------------------

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDatabase..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--select @@SERVERNAME
--DESKTOP-3L2BILC\SQLEXPRESS
--CovidDatabase


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDatabase..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International') and location not like '%income%'
Group by location
order by TotalDeathCount desc



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDatabase..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by Location,Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDatabase..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc