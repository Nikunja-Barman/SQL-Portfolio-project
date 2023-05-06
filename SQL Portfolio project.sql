select * from Covid_deaths
where continent is not null;

--select * from covid_vaccinations;

--select data that are going to use
select location, date, total_cases, new_cases, total_deaths, population
from Covid_deaths
where continent is not null
order by 1,2; -- ordering on the basis of Location and date

-- Looking at the total cases vs total deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as decimal) /cast (total_cases as decimal))*100 as DeathPercentage
from Covid_deaths
where continent is not null
order by 1,2;

-- looking at the covid death percentage in India
select location, date, total_cases, total_deaths, (cast(total_deaths as decimal) /cast (total_cases as decimal))*100 as DeathPercentage
from Covid_deaths
where location like '%india%'and continent is not null
order by 1,2;

-- Looking at the total_cases vs population 
-- shows what percentage of population got covid
select location, date, population, total_cases, (cast(total_cases as decimal)/population)*100 as Covid_infected_Percentage
from Covid_deaths
where continent is not null
order by 1,2;

-- Looking at the total_cases vs population in india
-- shows what percentage of population got covid
select location, date, population, total_cases, (cast(total_cases as decimal)/population)*100 as Covid_infected_Percentage
from Covid_deaths
where location like '%india%' and continent is not null
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as Highest_Infrction_Count, max(cast(total_cases as decimal)/population)*100 as Covid_infected_Percentage
from Covid_deaths
where continent is not null
group by location, population
order by Covid_infected_Percentage desc;

-- Showing Countries with Highest Death Count per Population
select location, max(total_deaths) as Total_Death_Count
from Covid_deaths
where continent is not null
group by location
order by Total_Death_Count desc;

-- Showing the Highest Death Count per Population across the continents
select continent, max(total_deaths) as Total_Death_Count
from Covid_deaths
where continent is not null
group by continent
order by Total_Death_Count desc;

-- Showing the continenets with the highest Death Count per population
select continent, max(total_deaths) as Total_Death_Count
from Covid_deaths
where continent is not null
group by continent
order by Total_Death_Count desc;

-- Global Numbers
-- Showing the daily New Covid cases added and New Covid deaths happened
-- around the world and its Daily percentage
select date, sum(new_cases) as New_covid_cases, sum(new_deaths) as New_covid_death,
(sum(cast(new_deaths as decimal))/sum(cast(nullif(new_cases,0) as decimal)))*100 
as Death_Percentage
from Covid_deaths
where continent is not null
group by date
order by 1,2

-- Showing the Total Covid cases and Total Covid Deaths during the whole Pandemic
select sum(new_cases) as Toatl_covid_cases, sum(new_deaths) as Total_covid_death,
(sum(cast(new_deaths as decimal))/sum(cast(nullif(new_cases,0) as decimal)))*100 
as Death_Percentage
from Covid_deaths
where continent is not null
--group by date
order by 1,2

-- joining Covid_deaths and Covid_vaccinations table
-- looking at total population vs count of new_vaccination on daily basis around the globe

select d.continent, d.location,d.date, d.population, v.new_vaccinations 
from Covid_deaths as d
join Covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- looking at total population vs count of new_vaccination on daily basis around 
-- the globe and showing the Total vaccination as Running Total

select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by cast(d.location as nvarchar(50)), d.date)
as Cumulative_total_vaccination
from Covid_deaths as d
join Covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

-- Using CTE to find rolling vaccination percentage

with Popvsvac (continent, Location,Date, Population, new_vaccinations, Cumulative_total_vaccination)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by cast(d.location as nvarchar(50)), d.date)
as Cumulative_total_vaccination
from Covid_deaths as d
join Covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
select * , (Cumulative_total_vaccination/cast(Population as decimal))*100
as Rolling_vacc_percent
from Popvsvac 

-- TEMP Table (doing the same thing as done using CTE)

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
Cumulative_total_vaccination numeric
)
insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by cast(d.location as nvarchar(50)), d.date)
as Cumulative_total_vaccination
from Covid_deaths as d
join Covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
select *,(Cumulative_total_vaccination/cast(Population as decimal))*100
as Rolling_vacc_percent
from #PercentPopulationVaccinated

-- creating view to store data for later visualization

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(v.new_vaccinations) over(partition by d.location order by cast(d.location as nvarchar(50)), d.date)
as Cumulative_total_vaccination
from Covid_deaths as d
join Covid_vaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

-- looking the viewed table
select * from PercentPopulationVaccinated