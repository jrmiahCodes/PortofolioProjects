Select *
From First_SQL_Project..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From First_SQL_Project..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, New_cases, total_deaths, population
From First_SQL_Project..CovidDeaths$

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From First_SQL_Project..CovidDeaths$
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (Total_cases/population)*100 as InfectedPercentage
From First_SQL_Project..CovidDeaths$
Where location like '%states%'
order by 1,2

--What countries have the highest infection rate compared to Population?

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as InfectedPercentage
From First_SQL_Project..CovidDeaths$
--Where location like '%states%'
group by Location, Population
order by InfectedPercentage desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From First_SQL_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by Location
order by TotalDeathCount desc

-- BREAKING IT DOWN BY CONTINENT 
-- Showing continents with highest death count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From First_SQL_Project..CovidDeaths$
--Where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From First_SQL_Project..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From  First_SQL_Project..CovidDeaths$ dea
Join First_SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From  First_SQL_Project..CovidDeaths$ dea
Join First_SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From  First_SQL_Project..CovidDeaths$ dea
Join First_SQL_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated