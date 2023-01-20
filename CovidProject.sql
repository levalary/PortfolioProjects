select *
from project_lera.dbo.deathss
order by 3,4

select *
from project_lera.dbo.deathss
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from project_lera.dbo.deathss
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from project_lera.dbo.deathss
where location like '%states'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as CasesPerPopulation
from project_lera.dbo.deathss
where location = 'Ukraine'
order by 1,2

select location, population, MAX(total_cases) as Highest, MAX((total_cases/population)*100) as PercentPopulationInfected
from project_lera.dbo.deathss

group by location, population
order by PercentPopulationInfected desc

select continent,  MAX(cast(total_deaths as int)) as TotslDeathCount, MAX((total_deaths/population)*100) as PercentPopulationDeaths
from project_lera.dbo.deathss
where continent is not null
group by continent
order by TotslDeathCount desc

select location,  continent, MAX(cast(total_deaths as int)) as TotslDeathCount, MAX((total_deaths/population)*100) as PercentPopulationDeaths
from project_lera.dbo.deathss
where continent is null
group by location, continent
order by TotslDeathCount desc

--Global numbers

select  date, SUM(new_cases) as totalCases, sum(Cast(new_deaths as int)) as tottalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from project_lera.dbo.deathss
where continent is not null
group by date
order by 1,2

--looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date)
	as RollingPeopleVaccinated
	
from project_lera.dbo.deathss dea
join project_lera.dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
	
from project_lera.dbo.deathss dea
join project_lera.dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100 as PercentOfVaccinated
From PopvsVac

--TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
	
from project_lera.dbo.deathss dea
join project_lera.dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated