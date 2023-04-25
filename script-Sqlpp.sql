 SELECT * FROM "CovidDeaths" order by 3,4;
SELECT * FROM "CovidVaccinations" ORDER BY 3,4; 

SELECT location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths ;

-- likelihood of dying if you contract covid worldwide vs Germany 
SELECT location, date, total_cases, total_deaths, ((1.0 * total_deaths) /total_cases)*100
as deathspercentage from "CovidDeaths" ;

SELECT location, date, total_cases, total_deaths, ((1.0 * total_deaths) /total_cases)*100
as deathspercentage 
from "CovidDeaths" 
WHERE location like "germany";

-- total cases against population in Germany

SELECT location, date, total_cases, population, (total_cases/(1.0*population))*100
as contractedcovidpercentage
from "CovidDeaths" 
WHERE location like "germany";

-- highest infection rate compared to population 

SELECT location, population, MAX(total_cases) as highestinfection, MAX((total_cases/(1.0*population)))*100 as contractedcovidpercentage 
FROM "CovidDeaths" 
GROUP BY location, population 
ORDER BY contractedcovidpercentage desc; 

-- highest death count by country 

SELECT location, MAX(total_deaths) as totaldeathscount 
FROM "CovidDeaths" 
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathscount desc; 

-- highest death count by continent 

SELECT location, MAX(total_deaths) as totaldeathscount 
FROM "CovidDeaths" 
WHERE continent is null
GROUP BY location
ORDER BY totaldeathscount desc;

SELECT continent, MAX(total_deaths) as totaldeathscount 
FROM "CovidDeaths" 
WHERE continent is not null
GROUP BY continent 
ORDER BY totaldeathscount desc; 


SELECT continent, location, date, total_cases, total_deaths, MAX(((1.0 * total_deaths) /total_cases))*100
as deathspercentage from "CovidDeaths"
where continent is not null
GROUP BY continent;


-- World data

SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)*1.0 / SUM(new_cases)*100
as deathspercentage 
from "CovidDeaths" 
where continent is not null
group by date 
order by SUM(new_cases);

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,  SUM(new_deaths)*1.0 / SUM(new_cases)*100
as deathspercentage 
from "CovidDeaths" 
where continent is not null
order by 1, 2;

-- vaccination amoung population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
order by 1, 2, 3; 



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null;

-- CTE 

WITH popvsvac (continent, location, date, population, new_vaccinations, rollingcount ) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null
) 
SELECT *, (rollingcount/population)*100 from popvsvac; 

-- temp table 

DROP TABLE IF EXISTS #temp_table 
CREATE TABLE #temp_table
( continent nvarchar,
location nvarchar, 
date date,
population numeric,
newvaccinations numeric,
rollingcount numeric ) 

INSERT INTO #temp_table 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rollingcount
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null

SELECT * FROM #temp_table; 



-- creating view 

CREATE VIEW test as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent is not null; 
-- order by 1, 2, 3; 


 




