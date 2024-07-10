SELECT * 
From CovidDeaths 
where continent is not null

-- looking at total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as Death_Percentage
from CovidDeaths
--where location like '%States%'
where continent is not null
order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from CovidDeaths
--where location like '%States%'
where continent is not null
order by 1,2


-- looing at countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected 
from CovidDeaths
where continent is not null
group by 1,2
order by 4 desc


-- showing countries with highest death count per population
	
SELECT location, max(total_deaths) as total_death_count
from CovidDeaths
where continent is not null and total_deaths is not null
group by 1
order by total_death_count desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, max(total_deaths) as total_death_count
from CovidDeaths
where continent is not null 
group by 1
order by 2 desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing continetns with the highest death count per population

SELECT continent, max(total_deaths) as total_death_count
from CovidDeaths
where continent is not null 
group by 1
order by 2 desc


-- GLOBAL NUMBERS
	
SELECT SUM(new_cases) as total_cases,sum(new_deaths) as total_deaths, sum(new_deaths)/SUM(new_cases) *100 as death_percentage
from CovidDeaths
where continent is not null
--group by 1
order by 1,2

-- Looking at total population vs Vaccinations

SELECT a.continent, a.location,a.date,a.population,b.new_vaccinations
,sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
From CovidDeaths a
JOIN CovidVaccinations b
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent,location, date, population,new_vaccinations,rolling_people_vaccinated)
as
(
SELECT a.continent, a.location,a.date,a.population,b.new_vaccinations
,sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
From CovidDeaths a
JOIN CovidVaccinations b
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null
order by 2,3
)
SELECT *, (rolling_people_vaccinated/population) *100 as percent_vaccinated
from PopvsVac


-- TEMP TABLE

DROP TABLE if exists percent_population_vaccinated
Create temporary table percent_population_vaccinated
(
continent varchar
,location varchar
, date date
, population numeric
,new_vaccinations numeric
,rolling_people_vaccinated numeric
);

Insert into percent_population_vaccinated
SELECT a.continent, a.location,a.date,a.population,b.new_vaccinations
,sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
From CovidDeaths a
JOIN CovidVaccinations b
	on a.location = b.location 
	and a.date = b.date
--where a.continent is not null
order by 2,3

SELECT *, (rolling_people_vaccinated/population) *100 as percent_vaccinated
from percent_population_vaccinated


-- Creating view to store data for later visualizations

CREATE VIEW percent_population_vaccinated as
SELECT a.continent, a.location,a.date,a.population,b.new_vaccinations
,sum(b.new_vaccinations) over (partition by a.location order by a.location,a.date) as rolling_people_vaccinated
From CovidDeaths a
JOIN CovidVaccinations b
	on a.location = b.location 
	and a.date = b.date
where a.continent is not null
--order by 2,3

select *
from percent_population_vaccinated
