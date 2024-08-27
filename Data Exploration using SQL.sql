Select *
from PortfolioProject..CovidDeaths
order by 3,4

Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations


-- Covid death data analysis

select date, location, total_cases, new_cases,total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null


--total cases vs total deaths in India with total death cases

select date, location,total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location = 'India' and total_deaths != 'NULL' and continent is not null

-- total cases vs population, to know the percentage of people who got covid

select date, location,total_cases, population, (total_cases/population)*100 as Infectedpopulation
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
order by 2,3

-- country who have highest covid cases compared to poulation

select location, population, MAX(total_cases) as highestcovidcases, MAX((total_cases/population))*100 as Infectedpopulation
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by population, location
order by Infectedpopulation desc

-- which country having highest death cases

select location, MAX(cast(total_deaths as INT)) as deathcount
from PortfolioProject..CovidDeaths
--where location = 'India'
-- in the data the location was taken as asia and other continents as well therefore had to check if the continents were not null for clear understanding of countries having deathcounts
where continent is not null 
group by location
order by deathcount desc

select location, MAX(cast(total_deaths as INT)) as deathcount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is null
group by location
order by deathcount desc

--by continent 
-- notes: according to the output there might be a chance where South america is excluding loction = canada
select continent, MAX(cast(total_deaths as INT)) as deathcount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
group by continent
order by deathcount desc

-- by world

select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Total_death_rates
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Total_death_rates
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--join operations 
-- total populations vs vaccinations

Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
SUM(convert(int,vaccine.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as rolling_count_vaccination 
--,(rolling_count_vaccination)/ deaths.population
-- adding order by inside over operation helps us to show the sum of new vaccinations as day goes by and not show the total at the beganning, basically rolling count
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
	where deaths.continent is not null
	order by 2,3

-- use CTE

with popvsvacc(continent, location,date,population, new_vaccinations, rolling_count_vaccination)
as
(Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
SUM(convert(int,vaccine.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as rolling_count_vaccination 
--,(rolling_count_vaccination)/ deaths.population
-- adding order by inside over operation helps us to show the sum of new vaccinations as day goes by and not show the total at the beganning, basically rolling count
from PortfolioProject..CovidDeaths deaths join PortfolioProject..CovidVaccinations vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
	where deaths.continent is not null
	--order by 2,3
)
select *, (rolling_count_vaccination/population)*100 as total_vaccinations
from popvsvacc

--temp table (here we are excluding few rows from previous query)

drop table if exists #PercentagepopulationVaccinated

create table #PercentagepopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric , 
new_vaccinations numeric, 
rolling_count_vaccination numeric)

Insert #PercentagepopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
SUM(convert(int,vaccine.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as rolling_count_vaccination 
--,(rolling_count_vaccination)/ deaths.population
-- adding order by inside over operation helps us to show the sum of new vaccinations as day goes by and not show the total at the beganning, basically rolling count
from PortfolioProject..CovidDeaths deaths 
join PortfolioProject..CovidVaccinations vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
	--where deaths.continent is not null
	--order by 2,3

select *, (rolling_count_vaccination/population)*100 as total_vaccinations
from #PercentagepopulationVaccinated


--creating view to store data for future visualization

create view PercentagepopulationVaccined as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations,
SUM(convert(int,vaccine.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location,deaths.date) as rolling_count_vaccination 
--,(rolling_count_vaccination)/ deaths.population
-- adding order by inside over operation helps us to show the sum of new vaccinations as day goes by and not show the total at the beganning, basically rolling count
from PortfolioProject..CovidDeaths deaths 
join PortfolioProject..CovidVaccinations vaccine
	on deaths.location = vaccine.location
	and deaths.date = vaccine.date
	where deaths.continent is not null
	--order by 2,3

select * 
from PercentagepopulationVaccinated