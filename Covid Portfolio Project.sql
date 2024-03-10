
-- select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2 
;


-- looking at total_cases vs total deaths
-- likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from coviddeaths
-- where location like "%nigeria%"
order by 1,2 
;


-- Looking at the total cases vs population
-- Shows the percentage of population that got covid

select location, date, total_cases, population, (total_cases/population) * 100 as ContractionPercentage
from coviddeaths
-- where location like "%nigeria%"
order by 1,2 
;


-- looking at countries with the highest infection rate compared to their population

select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population)) * 100 as InfectedPercentage
from coviddeaths
-- where location like "%nigeria%"
group by location, population
order by InfectedPercentage desc
;


-- Showing the countries with the highest death count

select location, max(total_deaths) as TotalDeathCount
from coviddeaths
-- where location like "%nigeria%"
where continent is not null
group by location
order by TotalDeathCount desc
;




-- Lets break things up by continent

-- select data that we are going to use

select continent, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2 desc
;


-- looking at total_cases vs total deaths
-- likelihood of dying if you contract covid in your continent

select continent, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from coviddeaths
where continent is not null
-- where location like "%nigeria%"
order by 1,2 desc
;


-- Looking at the total cases vs population
-- Shows the percentage of population that got covid

select continent, date, total_cases, population, (total_cases/population) * 100 as ContractionPercentage
from coviddeaths
where continent is not null
-- where location like "%nigeria%"
order by 1,2 desc
;


-- looking at countries with the highest infection rate compared to their population

select continent, population, max(total_cases) as highestInfectionCount, max((total_cases/population)) * 100 as InfectedPercentage
from coviddeaths
-- where location like "%nigeria%"
where continent is not null 
group by continent, population
order by InfectedPercentage desc
;


-- Showing the continents with the highest death count

select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
-- where location like "%nigeria%"
where continent is not null 
group by continent
order by TotalDeathCount desc
;






-- GLOBAL NUMBERS

select  sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, (sum(new_deaths)/sum(new_cases)) * 100 as DeathPercentage
from coviddeaths
-- where location like "%nigeria%"
where continent is not null 
order by 1,2
;



-- looking at totat population vs vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null 
order by 1,2,3
;

-- use CTE (run with CTE TABLE)

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null 
)
select *, (RollingPeopleVaccinated/population) * 100
from PopVsVac
;


-- Temp Tabl
drop table if exists PercentPeopleVaccinated;
create temporary table PercentPeopleVaccinated
(
	continent nvarchar(255),
    location nvarchar(255),
    date date,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
)
;

insert into PercentPeopleVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null 
;

select *, (RollingPeopleVaccinated/population) * 100
from PercentPeopleVaccinated
;



-- Creating views to store data for visualization later

create view PercentPeopleVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null 
-- order by 2, 3
;


