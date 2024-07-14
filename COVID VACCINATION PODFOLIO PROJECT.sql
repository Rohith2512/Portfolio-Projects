--select *
--from [covid vaccination]

select *
from [covid vaccination]


select location, date, total_cases, new_cases, total_deaths, population
from ['covid death$']
where continent is not null


--total cases vs total deaths


select location, date, total_cases, total_deaths,( total_deaths/total_cases)*100 as deathpercentage
from ['covid death$']
where location like '%states%'
and continent is not null


--total cases vs population shows the population got covid
select location, date,population,total_cases, ( total_deaths/population)*100 as covidpercentagepopulation
from ['covid death$']
where location like '%india%'



--countries with hightest infection rate compared to population

select  location, population , MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as percentagepopulationinfected
from ['covid death$']
where continent is not null
group by location, population
order by percentagepopulationinfected desc



--countries with highest deathcount per population 
select  location, population , MAX(cast (total_deaths as int)) as higheshtdeath
from ['covid death$']
where continent is not null
group by  location, population
order by  higheshtdeath desc



--contient with highest deathcount
select  location , MAX(cast (total_deaths as int)) as higheshtdeath
from ['covid death$']
where continent is  null
group by  location
order by  higheshtdeath desc


select  continent  , MAX(cast (total_deaths as int)) as higheshtdeath
from ['covid death$']
where continent is  not null
group by  continent 
order by  higheshtdeath desc

select *
from ['covid death$']
where continent is not null

--showing the continent with highest death count

select  continent  , MAX(cast (total_deaths as int)) as higheshtdeath
from ['covid death$']
where continent is  not null
group by  continent 
order by  higheshtdeath desc

--global numbers
select date, sum(new_cases)  newcases,sum(cast(new_deaths as int)) newdeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from ['covid death$']
--where location like '%states%'
where continent is null
group by date 


--to avoid divide by zero errors 
SELECT SUM(new_cases) AS newcases,SUM(CAST(new_deaths AS INT)) AS newdeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  -- To avoid division by zero
        ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100  -- Calculate death percentage
    END AS deathpercentage
FROM  ['covid death$']
-- WHERE location LIKE '%states%'
WHERE continent IS NULL

	--deathrate total in dates 
	SELECT date,SUM(new_cases) AS newcases,SUM(CAST(new_deaths AS INT)) AS newdeaths,
    CASE 
        WHEN SUM(new_cases) = 0 THEN NULL  -- To avoid division by zero
        ELSE (SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0)) * 100  -- Calculate death percentage
    END AS deathpercentage
FROM  ['covid death$']
-- WHERE location LIKE '%states%'
WHERE continent IS NULL
group by date 


--total vaccination in continent 
Select dea.date, dea.continent,dea.location,SUM(CONVERT(bigint,vac.new_vaccinations)) as  added
from  ['covid death$'] dea
Join [covid vaccination] 
 vac
	On dea.continent = vac.continent
	where dea.continent ='south america'and dea.continent is  not null  and dea.location is not null
	group by dea.continent, dea.date,dea.location 
	order by dea.date 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid death$'] dea
Join [covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid death$'] dea
Join [covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid death$'] dea
Join [covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid death$'] dea
Join [covid vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select *
from PercentPopulationVaccinated













