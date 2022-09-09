Select * 
From CovidProject..CovidDeaths
Where continent is not null
Order By 3,4

-- Selecting Data for Queries

Select Location, Date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in Australia

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidProject..CovidDeaths
Where location = 'Australia'
Order By 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of U.S population that contracted Covid

Select Location, Date, Population, total_cases, (total_cases/population)*100 AS InfectedPopulationPercentage
From CovidProject..CovidDeaths
Where location = 'United States'
Order By 1,2

-- Looking at the countries which have the Highest Contraction Rate compared to their population

Select Location, Population, MAX(total_cases) as InfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC


-- Shows the Countries with the Highest Death Count 

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group By Location
Order By TotalDeathCount DESC

-- Shows the Continents with the Highest Death Count

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null
And location not like '%income%'
And location not in ('European Union','International','World')
Group By location
Order By TotalDeathCount DESC


--Looking at the Total Death Count vs Population
--Shows the Countries with the Highest Death Rate compared to their population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount, Population, MAX((total_deaths/population))*100 AS DeathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group By Location, Population
Order By DeathPercentage DESC


-- Global Numbers

Select SUM(new_cases) as TotalGlobalCases, SUM(cast(new_deaths as int)) as TotalGlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidProject..CovidDeaths
Where continent is not null

Select date, SUM(new_cases) as TotalGlobalCases, SUM(cast(new_deaths as int)) as TotalGlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidProject..CovidDeaths
Where continent is not null 
And new_cases is not null
Group By date
Order By 1,2

-- Covid Deaths and Covid Vaccinations Join Queries

Select * 
From CovidProject..CovidDeaths as dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	And dea.date = vac.date

-- Looking at the rolling count of people vaccinated per country
	
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths as dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--And vac.new_vaccinations is not null
Order By 2,3

-- Looking at Total Population vs Vaccinations
-- Using CTE

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths as dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order By 2,3


With PopVsVac (Continent, Location, Date, Population, New_vaccinations, RollingVaccinationCount)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths as dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinationCount/Population)*100 as PercentPopulationVaccinated
From PopVsVac


-- Creating Views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingVaccinationCount
From CovidProject..CovidDeaths as dea
Join CovidProject..CovidVaccinations as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVaccinationCount/Population)*100 as PercentPopulationVaccinated
From PercentPopulationVaccinated

-- Select Queries for first Tableau Visulisation

-- Query 1


Select SUM(new_cases) as TotalGlobalCases, SUM(cast(new_deaths as int)) as TotalGlobalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
From CovidProject..CovidDeaths
Where continent is not null


-- Query 2

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null
And location not like '%income%'
And location not in ('European Union','International','World')
Group By location
Order By TotalDeathCount DESC

-- Query 3

Select Location, Population, MAX(total_cases) as InfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC

-- Query 4

Select Location, Population, date, MAX(total_cases) as InfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From CovidProject..CovidDeaths
Where continent is not null
Group By Location, Population, date
Order By PercentPopulationInfected DESC