--1. 

Select SUM(cast(new_cases as float)) as 'Total_Cases', SUM(cast(new_deaths as float)) as Total_Deaths, SUM(cast(new_deaths as float))/SUM(cast(New_cases as float))*100 as Death_Percentage
From [Covid Data]..CovidDeaths
where continent is not null
order by 1,2


--2. 

Select location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
From [Covid Data]..CovidDeaths
--Where location like 'Europe' or location like '%Asia%' or location like '%America%' or location like '%oceania%' or location like 'africa'
where location like '%world%'
group by location
order by Total_Deaths_Count desc


Select location, MAX(cast(Total_deaths as int)) as Total_Deaths_Count
From [Covid Data]..CovidDeaths
Where location like 'Europe' or location like '%Asia%' or location like '%America%' or location like '%oceania%' or location like 'africa'
--where location like '%world%'
group by location
order by Total_Deaths_Count desc


--3.

select location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From [Covid Data]..CovidDeaths
Group by Location, Population
Order by Percent_Population_Infected desc


--4.

select location, population, date, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From [Covid Data]..CovidDeaths
Group by Location, Population, date
--Order by Percent_Population_Infected desc