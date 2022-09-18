/*

Queries used for Tableau Project

*/


-- 1. Global Numbers Table
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS death_percentage
FROM CovidProject.covid_deaths
WHERE continent != ''
ORDER BY 1,2;


-- 2. Total Deaths Per Continent Graph
SELECT continent, SUM(new_deaths) as total_deaths
FROM CovidProject.covid_deaths
WHERE continent != ''
GROUP BY continent
ORDER BY total_deaths desc;


-- 3. Percent of Population Infected Per Country Map
SELECT location, population, Max(total_cases) as highest_infection_count, Max((total_cases/population)) * 100 as percentage_infected
FROM CovidProject.covid_deaths
GROUP BY location, population
ORDER BY percentage_infected desc;


-- 4. Percentage of Population Infected
SELECT location, population, date, Max(total_cases) as highest_infection_count, Max((total_cases/population)) * 100 as percentage_infected
FROM CovidProject.covid_deaths
GROUP BY location, population, date
ORDER BY percentage_infected desc;