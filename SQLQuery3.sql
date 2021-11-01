Select * 
From [COVID project]..CovidDeaths
order by 3,4

Select * 
From [COVID project]..CovidVaccinations
order by 3,4


Select * 
From [COVID project]..CovidDeaths
Where continent is not NULL
order by 3,4


-- Select data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
from [COVID project]..CovidDeaths
Where continent is not null
order by 1,2

-- Total cases vs. Population
-- Shows percentage of population infected with Covid 

Select Location, date, Population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from [COVID project]..CovidDeaths
Where Location like '%Brazil%'
order by 1,2


-- Contries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From [COVID project]..CovidDeaths
Group by Location, Population
order by Percent_Population_Infected desc


-- Countries with Highest Death Count 

Select Location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
From [COVID project]..CovidDeaths
Where continent is not null
group by Location
order by Total_Deaths_Count desc


-- Showing continents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
From [COVID project]..CovidDeaths
Where location like '%World%' or location like '%Europe%' or location like '%Asia%' or location like '%America%'
group by location
order by Total_Deaths_Count desc


-- GLOBAL NUMBERS for total cases, total deaths and death as a percentage of cases, up to date

select SUM(cast(new_cases as float)) as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_Percentage
From [COVID project]..CovidDeaths
where continent is not null
order by 1,2

-- Same, but as for Brazil

select SUM(cast(new_cases as float)) as Total_Cases, SUM(cast(new_deaths as float)) as Total_Deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as Death_Percentage
From [COVID project]..CovidDeaths
--where continent is not null 
where location like '%Brazil%'
order by 1,2


-- Total Population vs. Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

--Select deaths.continent, deaths.location, deaths.date, deaths.population, vac.new_vaccinations, SUM(convert(float, vac.new_vaccinations)) OVER (Partition by deaths.location Order by deaths.location, deaths.date) as Rolling_People_Vaccinated
--From [COVID project]..CovidDeaths deaths
--Join [COVID project]..CovidVaccinations vac
	--On deaths.location = vac.location
	--and deaths.date = vac.date
--where deaths.continent is not null
--order by 2,3

select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(float, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as Rolling_People_Vaccinated
From [COVID project]..CovidDeaths d
Join [COVID project]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date 
where d.continent is not null
order by 2,3

-- In Canada 

select d.continent, d.location, d.date, d.population, v.total_vaccinations, v.new_vaccinations, SUM(convert(float, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as Total_Vaccinations_as_SUM
From [COVID project]..CovidDeaths d
Join [COVID project]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date 
where d.location like '%canada%'
order by 2,3

select *
from [COVID project]..CovidVaccinations
where location like '%canada%'
order by 1,4


-- Using CTE to perform Calculation on Partition By in previous query

With Pop_vs_Vac (Continent, Location, Date, Population, Total_Vaccinations, New_Vaccinations, Total_Vaccinations_as_SUM)
as
(
select d.continent, d.location, d.date, cast(d.population as float), v.total_vaccinations, v.new_vaccinations, SUM(convert(float, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as Total_Vaccinations_as_SUM
From [COVID project]..CovidDeaths d
Join [COVID project]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date 
where d.location like '%canada%'
--order by 2,3
)
select *, (Total_Vaccinations_as_SUM/Population)*10 as Number_of_vaccines_per_capta
from Pop_vs_Vac


-- Using temp table to perform calculation on partition by in previous query

DROP Table if exists #Number_of_vaccines_per_capta
Create Table #Number_of_vaccines_per_capta
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
Total_Vaccinations numeric, 
New_Vaccinations numeric, 
Total_Vaccinations_as_SUM numeric
)

Insert into #Number_of_vaccines_per_capta
select d.continent, d.location, d.date, cast(d.population as float), cast(v.total_vaccinations as float), cast(v.new_vaccinations as float), SUM(convert(float, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as Total_Vaccinations_as_SUM
From [COVID project]..CovidDeaths d
Join [COVID project]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date 
where d.location like '%canada%'
--order by 2,3

select *, (Total_Vaccinations_as_SUM/Population)*10 as Number_of_vaccines_per_capta
from #Number_of_vaccines_per_capta


-- Creating view to store data for later visualizations

Create view NumberOfVaccinesPerCapta as 
select d.continent, d.location, d.date, cast(d.population as float) as Population, cast(v.total_vaccinations as float) as Total_vaccinations, cast(v.new_vaccinations as float) as New_Vaccinations, SUM(convert(float, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) as Total_Vaccinations_as_SUM
From [COVID project]..CovidDeaths d
Join [COVID project]..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date 
where d.location like '%canada%'
--order by 2,3

select * 
from NumberOfVaccinesPerCapta