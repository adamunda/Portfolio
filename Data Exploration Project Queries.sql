SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.covid_deaths
order by 1,2;


#Total Cases vs Total Deaths
SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage,
(total_cases/population) * 100 as population_percentage
FROM CovidProject.covid_deaths
WHERE location = 'Aruba'
order by total_cases desc; 

#Total Cases vs Population
#Shows percentage of population that got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as population_percentage
FROM CovidProject.covid_deaths
WHERE location = 'Canada'
order by 1,2; 

#Countries with highest infection rate compared to population
SELECT location, population, date, Max(total_cases) as highest_infection_count, 
Max((total_cases/population)) * 100 as perc_pop_infected
FROM CovidProject.covid_deaths
#WHERE (Max((total_cases/population)) * 100) is null
GROUP by location, population, date
order by perc_pop_infected desc;

#Countries with highest death count per population
SELECT location, Max(cast(total_deaths as SIGNED)) as death_count
FROM CovidProject.covid_deaths
WHERE continent != ''
GROUP by location
order by death_count desc;

#Showing continent with the highest death count
SELECT continent, Max(cast(total_deaths as SIGNED)) as death_count
FROM CovidProject.covid_deaths
#WHERE continent != ''
GROUP by continent
order by death_count desc;

#Sh
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(SUM(new_deaths)/SUM(new_cases)) * 100 AS death_percentage
FROM CovidProject.covid_deaths
WHERE continent != ''
#GROUP by date 
order by 1,2;

##
SELECT location, SUM(new_deaths) as total_deaths
FROM CovidProject.covid_deaths
WHERE continent = ''
AND location in ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')
GROUP by location
order by 2 desc;


#Total Population vs Vaccinations
SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by vacc.location order by vacc.location, vacc.date)
AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
ON deaths.location = vacc.location
and deaths.date = vacc.date
WHERE vacc.continent != ''
ORDER by 2,3;

#Use CTE
WITH popVsVacc(continet, location, date, population, new_vaccinations, rolling_vaccinated)
as
(SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by vacc.location order by vacc.location, vacc.date)
AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
ON deaths.location = vacc.location
and deaths.date = vacc.date
WHERE vacc.continent != ''
ORDER by 2,3
)
SELECT *, (rolling_vaccinated/population) * 100 as rolling_percentage
FROM popVsVacc;


#TEMP TABLE
DROP TABLE IF EXISTS percentage_vaccinated;
CREATE TABLE percentage_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations varchar(255),
rolling_vaccinated numeric
);

INSERT INTO percentage_vaccinated
SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by vacc.location order by vacc.location, vacc.date)
AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
ON deaths.location = vacc.location
and deaths.date = vacc.date
WHERE vacc.continent != ''
ORDER by 2,3;


#VIEW
CREATE VIEW percentage_vaccinatedView AS
SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by vacc.location order by vacc.location, vacc.date)
AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
ON deaths.location = vacc.location
and deaths.date = vacc.date
WHERE vacc.continent != '';