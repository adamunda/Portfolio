/*

Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Select Data to start with
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject.covid_deaths
WHERE continent != ''
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows likilihood of dying if you contract covid in a country

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
FROM CovidProject.covid_deaths
WHERE location = 'Canada' AND continent != ''
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows percentage of population that got Covid

SELECT location, date, population, total_cases, (total_cases/population) * 100 as percentage_infected
FROM CovidProject.covid_deaths
ORDER BY 1,2;


-- Countries with highest infection rate compared to population

SELECT location, population, Max(total_cases) as highest_infection_count, Max((total_cases/population)) * 100 as percentage_infected
FROM CovidProject.covid_deaths
GROUP BY location, population
ORDER BY percentage_infected desc;


-- Countries with highest death count per population

SELECT location, Max(cast(total_deaths as SIGNED)) as total_death_count
FROM CovidProject.covid_deaths
WHERE continent != ''
GROUP BY location
ORDER BY total_death_count desc;


-- Showing continents with the highest death count per population

SELECT continent, Max(cast(total_deaths as UNSIGNED)) as total_death_count
FROM CovidProject.covid_deaths
WHERE continent != ''
GROUP BY continent
ORDER BY total_death_count desc;


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS death_percentage
FROM CovidProject.covid_deaths
WHERE continent != ''
ORDER BY 1,2;


-- Total population VS Vaccinated
-- Shows percentage of population that has received at least one Covid Vaccine

SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY vacc.location order by vacc.location, vacc.date) AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE vacc.continent != ''
ORDER BY 2,3;


-- Using CTE to perform calculation on PARTITION BY in previous query

WITH pop_vs_vacc(continet, location, date, population, new_vaccinations, rolling_vaccinated)
AS
(SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (PARTITION BY vacc.location order by vacc.location, vacc.date)
AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
ON deaths.location = vacc.location
and deaths.date = vacc.date
WHERE vacc.continent != ''
#ORDER BY 2,3
)
SELECT *, (rolling_vaccinated/population) * 100 as rolling_percentage
FROM pop_vs_vacc;


-- Using temp table to perform calculation on PARTITION BY in previous query

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
SUM(vacc.new_vaccinations) OVER (PARTITION BY vacc.location order by vacc.location, vacc.date) AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE vacc.continent != '';
#ORDER BY 2,3;


-- Creating a view to store data for visualizations

CREATE VIEW percentage_vaccinated_view AS
SELECT vacc.continent, vacc.location, vacc.date, vacc.population, vacc.new_vaccinations,
SUM(vacc.new_vaccinations) OVER (partition by vacc.location order by vacc.location, vacc.date) AS rolling_vaccinated
FROM CovidProject.covid_deaths deaths
JOIN CovidProject.covid_vaccinations vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE vacc.continent != '';
