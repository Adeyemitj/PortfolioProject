use PortfolioProject;

Select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
where total_deaths is not null
order by 1,2;

--Looking at Total Cases vs Total Death
Select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where total_deaths is not null
And location like '%ger%'
order by 1,2;

--Looking at Countries with Highest Infection Rate compared to population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulatonInfected
from CovidDeaths
group by location, population
order by PercentPopulatonInfected desc;

--Looking at the Counties with Highest Death Rate
select location, max(cast(total_deaths as int)) as HighestDeathRate
from CovidDeaths
where continent is not null
group by location
order by HighestDeathRate desc;

-- Showing continents with the Highest Death Rate per Population
select continent, max(cast(total_deaths as int)) as TotalDeathRate
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathRate desc;

--Looking at the Global Numbers of effected cases and death cases
select SUM(new_cases) as Total_Cases, SUM(cast(New_deaths as int)) as Total_Death_Roll, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--Group by date
order by 1,2;

--Joining CovidDeaths and CovidVaccination table

select *
from CovidDeaths cd
join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date;

--Looking at Total Population vs Vaccination
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (partition by cd.location Order by cd.location,
	cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3;

--Showing Total Number of People Vaccinated over Population
--Using CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinaton, RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (partition by cd.location Order by cd.location,
	cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
where New_Vaccinaton is not null
and RollingPeopleVaccinated is not null;

-- TEMP TABLE
DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (partition by cd.location Order by cd.location,
	cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated;


--Creating View to store data for later vsualization
Create View PercentagePopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int, cv.new_vaccinations)) OVER (partition by cd.location Order by cd.location,
	cd.date) as RollingPeopleVaccinated
From CovidDeaths cd
join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3


Select *
from PercentagePopulationVaccinated;