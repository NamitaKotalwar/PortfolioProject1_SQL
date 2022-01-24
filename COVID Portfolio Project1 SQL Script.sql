




--Select data from Tabels
Select * from CovidDeaths


Select * from CovidVaccinations 


--Select data that we are going to be using
Select location , date ,total_cases ,new_cases,total_deaths ,population from 
CovidDeaths 
where continent is NOT NULL  Order By 1,2

--Looking at Total Cases VS Total Deaths
--Calculate Death Percentage according to specific Country

Select location , date ,total_cases ,total_deaths , (total_deaths / total_cases)*100 as DeathPercentage from 
CovidDeaths where location like '%State%' AND continent is NOT NULL Order By 1,2


--Looking at total cases Vs Population
--Shows what percentage of population got Covid
Select location , date  ,population ,total_cases, (total_cases/population)*100 as PercentPopulationInfected from 
CovidDeaths where continent is NOT NULL 
--where location like '%State%' 
Order By 1,2


--Looking at Countries with highest Infection rate Compared to population
Select  location , population ,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected from 
CovidDeaths where continent is NOT NULL 
Group By location ,Population
Order By PercentPopulationInfected Desc

--Showing countries with Highest DeathCount per population
Select  location  ,MAX(cast (total_deaths as int)) TotalDeaths from 
CovidDeaths where continent is NOT NULL 
Group By location
Order By TotalDeaths Desc

--LET'S BREAK DOWN THINGS BY CONTINENT

--SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

Select  continent  ,MAX(cast (total_deaths as int)) TotalDeaths from 
CovidDeaths where continent is not NULL 
Group By continent 
Order By TotalDeaths Desc

--GLOBAL NUMBERS

Select  SUM (new_cases) as NewCases ,SUM (cast (new_deaths as int)) as NewDeaths, 
(SUM (cast (new_deaths as int))/SUM (new_cases))*100 as DeathPercentage from CovidDeaths 
where continent is NOT NULL  
--GROUP BY date 
Order By 1,2


--LOOKING AT POPULATION VS VACCINATION
select dea.continent ,dea .location,dea.date,dea.population ,vac.new_vaccinations   from CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location and dea.date =vac.date  
where dea.continent is NOT NULL  
Order By 1,2

select dea.continent ,dea .location,dea.date,dea.population ,vac.new_vaccinations ,
SUM(CONVERT (bigint ,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location and dea.date =vac.date  
where dea.continent is NOT NULL  
Order By 2,3 



--USE CTE

with PopVsVac (continent ,location,date,population,New_Vaccination,RollingPeopleVaccination)
as
(select dea.continent ,dea .location,dea.date,dea.population ,vac.new_vaccinations ,
SUM(CONVERT (bigint ,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location and dea.date =vac.date  
where dea.continent is NOT NULL  
--Order By 2,3
 )

 select * , (RollingPeopleVaccination /population )*100 from PopVsVac 

 --USE TEMP TABLE

 DROP TABLE IF EXISTS #PercentPopulationVaccinated

 CREATE TABLE #PercentPopulationVaccinated
 (Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,
 NewVaccinations numeric ,RollingPeopleVaccinated  numeric)

 Insert into #PercentPopulationVaccinated
 select dea.continent ,dea .location,dea.date,dea.population ,vac.new_vaccinations ,
SUM(CONVERT (bigint ,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location and dea.date =vac.date  
--where dea.continent is NOT NULL  
--Order By 2,3

select * , (RollingPeopleVaccinated /population )*100 from #PercentPopulationVaccinated 

 --CREATE VIEW

 CREATE VIEW PercentPopulationVaccinated as 
 select dea.continent ,dea .location,dea.date,dea.population ,vac.new_vaccinations ,
SUM(CONVERT (bigint ,vac.new_vaccinations )) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from CovidDeaths dea
JOIN CovidVaccinations vac
ON  dea.location =vac.location and dea.date =vac.date  
where dea.continent is NOT NULL  
--Order By 2,3

select * from PercentPopulationVaccinated

