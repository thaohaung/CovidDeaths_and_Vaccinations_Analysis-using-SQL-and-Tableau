  -- Select Data that we are going to be using:
SELECT
  location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
ORDER BY
  1,
  2;
  -- Looking at Total cases vs. Total Deaths: (and check a specific country)
  -- Show the likelihood of dying if you contract convid in your country
SELECT
  location,
  date,
  total_cases,
  total_deaths,
  (total_deaths/total_cases)*100 AS DeathPercentage
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  location LIKE '%States%'
ORDER BY
  1,
  2;
  -- Looking at the total cases vs. population:
  -- Show what percentage of population got covid:
SELECT
  location,
  date,
  total_cases,
  population,
  (total_cases/population)*100 AS DeathPercentage
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  location LIKE '%Vietnam%'
ORDER BY
  1,
  2;
  -- Looking at the country with Highest Infaction rate compared to Population:
SELECT
  location,
  population,
  MAX(total_cases) AS HighestInfactionCount,
  MAX(total_cases/population)*100 AS Percent_Population_Infected
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
GROUP BY
  location,
  population
ORDER BY
  Percent_Population_Infected DESC;
  -- Showing Countries with Highest Death Count per Population:
  -- We see that in the location column, it contains both continent and countries names, so need to fix it: Let's break things down by continent:
SELECT
  location,
  MAX(CAST(total_deaths AS int)) TotalDeathCount
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  TotalDeathCount DESC;
  -- Let's break things down by continent:
SELECT
  continent,
  MAX(CAST(total_deaths AS int)) TotalDeathCount
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  TotalDeathCount DESC;
  -- Showing the continent with the highest death count per population:
SELECT
  continent,
  MAX(total_deaths/population) AS Highest_Death_Percent
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  Highest_Death_Percent;
  -- Global numbers by date for new deaths percent:
SELECT
  date,
  SUM(CAST(new_cases AS int)) AS total_new_cases,
  SUM(CAST(new_deaths AS int)) AS total_new_deaths,
  (SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS int)))*100 AS NewDeathPercent
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  continent IS NOT NULL
GROUP BY
  date
ORDER BY
  1,
  2;
  -- To check the global numbers for new death percent:
SELECT
  SUM(CAST(new_cases AS int)) AS total_new_cases,
  SUM(CAST(new_deaths AS int)) AS total_new_deaths,
  ((SUM(CAST(new_deaths AS int))/SUM(CAST(new_cases AS int))))*100 AS NewDeathPercent
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths`
WHERE
  continent IS NOT NULL
ORDER BY
  1,
  2;
  -- Check the table of Covid Vaccinations:
SELECT
  *
FROM
  `fluid-crane-362215.Covid_project.CovidVaccinations`;
  -- JOIN 2 tables:
SELECT
  *
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths` dea
JOIN
  `fluid-crane-362215.Covid_project.CovidVaccinations`vac
ON
  dea.location = vac.location
  AND dea.date = vac.date;
  -- Looking at the Total Population vs. Vaccinations:
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS accumunated_vac_amounts
FROM
  `fluid-crane-362215.Covid_project.CovidDeaths` dea
JOIN
  `fluid-crane-362215.Covid_project.CovidVaccinations`vac
ON
  dea.location = vac.location
  AND dea.date = vac.date
WHERE
  dea.continent IS NOT NULL
ORDER BY
  1,
  2,
  3;
  -- To calculate the Accumulated Vaccinations Amounts per Population:
WITH
  cte_totalvac AS (
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS accumunated_vac_amounts
  FROM
    `fluid-crane-362215.Covid_project.CovidDeaths` dea
  JOIN
    `fluid-crane-362215.Covid_project.CovidVaccinations`vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL)
SELECT
  continent,
  location,
  date,
  population,
  new_vaccinations,
  accumunated_vac_amounts,
  accumunated_vac_amounts/population AS TotalVacPerPop
FROM
  cte_totalvac
ORDER BY
  1,
  2,
  3;

-- Create View to store data for later visualization:
