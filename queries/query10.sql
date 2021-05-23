.headers on
.mode column
.nullvalue NULL

DROP VIEW IF EXISTS counties_with_covid_inoculated;
CREATE VIEW counties_with_covid_inoculated AS
SELECT COUNT(
        CASE
            WHEN vaccine.inoculations_number = inoculation.inoculation_number THEN 1
            ELSE NULL
        END
    ) AS completely_vaccinated_num,
    COUNT(
        CASE
            WHEN vaccine.inoculations_number <> inoculation.inoculation_number THEN 1
            ELSE NULL
        END
    ) AS mid_vaccination_num,
    county.id AS county_id,
    county.name AS county_name
FROM inoculation
    JOIN vaccine ON inoculation.vaccine_id = vaccine.id
    JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
    JOIN citizen ON inoculation.citizen_id = citizen.id
    JOIN address ON citizen.address_id = address.id
    JOIN zip_code ON address.zip_code_id = zip_code.id
    JOIN county ON zip_code.county_id = county.id
WHERE pathology.id = 56
GROUP BY county.id;

DROP VIEW IF EXISTS covid_vaccination_per_county;
CREATE VIEW covid_vaccination_per_county AS
SELECT county_name,
    (
        CASE
            WHEN population IS NULL THEN 0
            ELSE population
        END
    ) AS population,
    completely_vaccinated_num,
    mid_vaccination_num
FROM (
        SELECT *
        FROM counties_with_covid_inoculated
        UNION
        SELECT 0,
            0,
            county.id as county_id,
            county.name as county_name
        FROM county
        WHERE county.id NOT IN (
                SELECT county_id
                from counties_with_covid_inoculated
            )
    ) AS inoculations_per_county
    LEFT JOIN (
        SELECT COUNT(*) as population,
            county.id as county_id
        FROM county
            JOIN zip_code ON county.id = zip_code.county_id
            JOIN address ON zip_code.id = address.zip_code_id
            JOIN citizen ON address.id = citizen.address_id
        GROUP BY county.id
    ) AS county_population ON county_population.county_id = inoculations_per_county.county_id;
    
SELECT county_name,
    IFNULL(CAST(completely_vaccinated_num AS REAL) * 100 / population, CAST(0 AS REAL)) AS percentage
FROM covid_vaccination_per_county
ORDER BY percentage DESC;