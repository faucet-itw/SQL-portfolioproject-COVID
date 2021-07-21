Select *
From PortfolioProject..covid_deaths
where continent is not null
order by 3,4

--update PortfolioProject..covid_deaths set continent = null where continent = ''
--update PortfolioProject..covid_deaths set total_deaths = null where total_deaths = 0
--update PortfolioProject..covid_deaths set total_cases = null where total_cases = 0
--update PortfolioProject..covid_deaths set new_deaths = null where new_deaths = 0
--update PortfolioProject..covid_deaths set new_cases = null where new_cases = 0
--update PortfolioProject..covid_vaccinations set * = null where * = 0


--Select * 
--From PortfolioProject..covid_deaths
--order by 3,4

-- Select data that we well be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- likelyhood of dying if contract covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
From PortfolioProject..covid_deaths
Where location like '%austra%'
and where continent is not null
order by 1,2


-- looking at total cases vs population
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopInfected
From PortfolioProject..covid_deaths
Where location like '%stat%'
and where continent is not null
order by 1,2

-- which countries have higest rates of infection (vs population)
Select Location, population, max(total_cases) as HighestInfectionCount, (max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Where population > 0
and where continent is not null
Group by Location, population
order by PercentPopulationInfected desc


-- which countries have higest rates of death (vs population)
Select Location, population, max(total_deaths) as HighestDeathCount, (max(total_deaths)/population)*100 as PercentPopulationDeath
From PortfolioProject..covid_deaths
Where population > 0
and where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

Select Location, max(total_deaths) as TotalDeathCount
From PortfolioProject..covid_deaths
Where population > 0 and continent is not null
Group by Location
order by TotalDeathCount desc


-- breakdown by continent
Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..covid_deaths
Where population > 0 and  continent is null
Group by location
order by TotalDeathCount desc




-- Global numbers
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as GlobalDeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as GlobalDeathPercentage
From PortfolioProject..covid_deaths
where continent is not null
--group by date
order by 1,2


-- covid vaccinations
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
	sum(vax.new_vaccinations) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from  PortfolioProject..covid_deaths death
join PortfolioProject..covid_vaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
order by 2,3;


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as ( 
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
sum(vax.new_vaccinations) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from  PortfolioProject..covid_deaths death
join PortfolioProject..covid_vaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as percentVaccinated
from PopvsVac

-- Use Temp Table

DROP table if exists #PercentPopulationVaccinated --clears previously created table if exists
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
sum(vax.new_vaccinations) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from  PortfolioProject..covid_deaths death
join PortfolioProject..covid_vaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null
Select *, (RollingPeopleVaccinated/population)*100 as percentVaccinated
from #PercentPopulationVaccinated


-- creating view to store data for visualisations

Create View PercentPopulationVaccinated as  
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
sum(vax.new_vaccinations) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
from  PortfolioProject..covid_deaths death
join PortfolioProject..covid_vaccinations vax
	on death.location = vax.location
	and death.date = vax.date
where death.continent is not null


select * from PercentPopulationVaccinated