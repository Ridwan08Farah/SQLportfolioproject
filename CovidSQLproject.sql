---------------------------------- Dataset downloaded from https://ourworldindata.org/covid-deaths
-- Data roughly cleaned using excel and imported on mysql
-- Initial look at the dataset
select * from covid2.dbo
;

-- Filtering my the main columns I'll be using in this project
select location, date, total_cases, total_deaths, population
from covid2.dbo
order by 1, 2;

-- Looking at Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid2.dbo
order by 1, 2;

-- Looking at Total Cases vs Population
-- Shows what percantage of population contracted covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulation
from covid2.dbo
order by 1, 2
;

-- Looking at countries with highesst infections per capita
select location, population, max(total_cases), max((total_cases/population))*100 as InfectedPop
from covid2.dbo
group by location, population
order by InfectedPop desc;

-- Showing Countries with Highest Death Counts & Mortality Rates
select location, max(total_deaths) as DeathCount, max(total_deaths/population)*100 as DeathRate
from covid2.dbo
group by location 
order by DeathRate desc;

-- DeathCount by Continent
select continent, max(total_deaths) as DeathCount
from covid2.dbo
where continent is not null
group by continent
order by DeathCount desc;

-- Showing Global Mortality Rates by date
select date, sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as GlobalMortalityRate
from covid2.dbo
where continent is not null
group by date
order by 1, 2;

-- Total Cases and Deaths Globally and Mortality Rate
select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, sum(new_deaths)/sum(new_cases)*100 as GlobalMortalityRate
from covid2.dbo
where continent is not null
order by 1, 2;

-- A quick look at Total Population vs Vaccination
-- Using a CTE to determine the Rolling people vaccinated percentage
With PopVsVax(continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, population, vax.new_vaccinations, sum(vax.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid2.dbo dea 
join covid2.vaccination vax
on dea.location = vax.location
and dea.date = vax.date
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopVsVax ;

drop table if exists PercentagePopulationVaccinated;
create table PercentagePopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date text,
Population int,
New_vaccinations int,
RollingPeopleVaccinated int
);

insert into PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, population, vax.new_vaccinations, sum(vax.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from covid2.dbo dea 
join covid2.vaccination vax
on dea.location = vax.location
and dea.date = vax.date
;
select *, (RollingPeopleVaccinated/Population)*100 
from PercentagePopulationVaccinated;


-----------------------------------------------------------------


-- PART 2
-- The Data to use in the Tableau Dashboards
-- 1, Total Death Count by Continent
Select continent, MAX(Total_deaths) as TotalDeathCount
from covid2.dbo
group by continent 
order by TotalDeathCount Desc;




-- Global Mortality Rate, cases vs totals deaths
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From covid2.dbo
-- Where location like '%states%' 
where continent is not null
-- Group By date
order by 1,2;

-- Visualisation 2 

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vaxx.total_vaccinations)
, (MAX(vaxx.total_vaccinations)/population)*100 
From covid2.dbo dea
Join covid2.vaccination vaxx
	On dea.location = vaxx.location
	and dea.date = vaxx.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3 ;

-- Visualisation 3
Select location, SUM(new_deaths) as TotalDeathCount
From covid2.dbo
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 4 
-- countries with highest percentage of population infected
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid2.dbo
Group by Location, Population
order by PercentPopulationInfected desc
;
-- 5
-- Total Deaths and Cases by continent
Select Location, date, population, total_cases, total_deaths
From Covid2.dbo
where continent is not null 
order by 1,2
;
-- 7
-- Visualisation showing the Countries with highest infection rates
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid2.dbo
Group by location, population, date
order by PercentPopulationInfected desc;






 














