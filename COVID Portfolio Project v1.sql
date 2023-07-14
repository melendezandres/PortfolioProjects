--SELECT *
--FROM PortfolioProject..CovidDeaths
--Where continent is not null
--order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

select location, date, total_cases,new_cases total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


select location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

----Looking at countries with highest infeccion rate compared to population


select location,  population, MAX(total_cases) AS HighestInfeccionCount , MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, Population 
order by PercentPopulationInfected desc


---Showing Countries with Highest Death Count pero population

select location, MAX( cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location
order by  TotalDeathCount desc 



---Showing continents with  the highest death count per population

select continent, MAX( cast (Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by continent
order by  TotalDeathCount desc 

--Global numbers

select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST
(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
Where continent is not null
Group by date
order by  1,2


--Looking at total population vs vaccinations

With PopvsVac(Continent,Location, Date, Population, New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.New_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--temp table 
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.New_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.New_vaccinations,
SUM(convert(int,vac.new_vaccinations )) over (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated