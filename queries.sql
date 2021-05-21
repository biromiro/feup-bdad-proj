-- 6
-- What is the disease with the highest vaccination rate?

SELECT MAX(rate) as rate, common_name as disease
FROM (
    SELECT (CAST(COUNT(*) AS REAL) * 100 / (SELECT COUNT(*) FROM citizen)) AS rate, pathology.common_name AS common_name
    FROM inoculation JOIN vaccine ON inoculation.vaccine_id = vaccine.id JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
    GROUP BY pathology.id);


-- 9
-- What is the percentage of people per county that are vaccinated for a given disease (in this case, covid).

CREATE VIEW counties_with_covid_inoculated AS
SELECT COUNT(CASE WHEN vaccine.inoculations_number = inoculation.inoculation_number THEN 1 ELSE null END) as completely_vaccinated_num,
        COUNT(CASE WHEN vaccine.inoculations_number <> inoculation.inoculation_number THEN 1 ELSE null END) as mid_vaccination_num, 
        county.id as county_id, county.name as county_name
    FROM inoculation 
    JOIN vaccine ON inoculation.vaccine_id = vaccine.id 
    JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
    JOIN citizen ON inoculation.citizen_id = citizen.id
    JOIN address ON citizen.address_id = address.id
    JOIN zip_code ON address.zip_code_id = zip_code.id
    JOIN county ON zip_code.county_id = county.id
    WHERE pathology.id = 56 
    GROUP BY county.id;

CREATE VIEW covid_vaccination_per_county AS
SELECT county_name, (CASE WHEN population IS NULL THEN 0 ELSE population END) as population, completely_vaccinated_num, mid_vaccination_num
FROM (SELECT * FROM counties_with_covid_inoculated
    UNION 
    SELECT 0, 0, county.id as county_id, county.name as county_name
    FROM county
    WHERE county.id NOT IN (SELECT county_id from counties_with_covid_inoculated)) as T
    LEFT JOIN
    (SELECT COUNT(*) as population, county.id as county_id
    FROM county
    JOIN zip_code ON county.id = zip_code.county_id
    JOIN address ON zip_code.id = address.zip_code_id
    JOIN citizen ON address.id = citizen.address_id
    GROUP BY county.id) as S
    ON T.county_id = S.county_id;

SELECT county_name, CAST(completely_vaccinated_num AS REAL) * 100 / population as percentage
FROM covid_vaccination_per_county;

-- 10
-- What is the incidence per 100k of infection of a given disease (in this case, covid)? 

SELECT (CAST(covid_infected AS REAL) * 100000 /  (SELECT COUNT(*) FROM citizen)) as covid_infected_per_100k
FROM (SELECT COUNT(*) as covid_infected
      FROM citizen_has_pathology
      WHERE citizen_has_pathology.pathology_id = 56);
     

-- 11
-- What is the incidence per 100k per county of infection of a given disease (in this case, covid)? 

SELECT county_name, 
       (CASE WHEN population <> 0 THEN (completely_vaccinated_num + mid_vaccination_num) * 100000 / CAST(population AS REAL) ELSE 0.0 END)
       as covid_infected_per_100k
FROM covid_vaccination_per_county;

-- 14
-- How many inoculations were administrated for a given pathology (in this case, covid) in a given day (in this case, 2021-03-05)?

SELECT COUNT(*) as number_of_inoculations, date
FROM inoculation
JOIN vaccine ON vaccine.id = inoculation.vaccine_id
JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
WHERE pathology.id = 56 AND date = "2021-03-05";

-- 15
-- What is the capacity per capita to hold vaccines in each district?

CREATE VIEW districts_with_capacity AS
SELECT SUM(maximum_capacity) AS capacity, district.id AS district_id, district.name AS district_name
    FROM storehouse
    JOIN infrastructure ON infrastructure.id = storehouse.infrastructure_id
    JOIN address ON infrastructure.address_id = address.id
    JOIN zip_code ON address.zip_code_id = zip_code.id
    JOIN county ON county.id = zip_code.county_id
    LEFT JOIN district ON district.id = county.district_id
    GROUP BY district.id;

SELECT district_name, (CASE WHEN capacity_per_capita IS NULL THEN 0 ELSE capacity_per_capita END) as capacity_per_capita
FROM (SELECT district_name, CAST((CASE WHEN population IS NULL THEN 0 ELSE capacity END) AS REAL) / (CASE WHEN population IS NULL THEN 0 ELSE population END) AS capacity_per_capita
    FROM 
        (SELECT * FROM districts_with_capacity
        UNION
        SELECT 0, district.id AS district_id, district.name AS district_name
        FROM district WHERE district.id NOT IN (SELECT district_id FROM districts_with_capacity)) as T
        LEFT JOIN
        (SELECT COUNT(*) as population, district.id as district_id
        FROM district
        JOIN county ON county.district_id = district.id
        JOIN zip_code ON county.id = zip_code.county_id
        JOIN address ON zip_code.id = address.zip_code_id
        JOIN citizen ON address.id = citizen.address_id
        GROUP BY district_id) as S
        ON T.district_id = S.district_id);

-- 17
-- Which vaccines do not have a storehouse that could hold it (according to temperature restrictions)?

SELECT vaccine.name, vaccine.minimum_temperature, vaccine.maximum_temperature
FROM vaccine
WHERE vaccine.id NOT IN (
    SELECT vaccine.id
    FROM vaccine
    CROSS JOIN storehouse
    WHERE (vaccine.minimum_temperature >= storehouse.minimum_temperature AND vaccine.minimum_temperature <= storehouse.maximum_temperature)
            OR (vaccine.maximum_temperature >= storehouse.minimum_temperature AND vaccine.maximum_temperature <= storehouse.maximum_temperature));
