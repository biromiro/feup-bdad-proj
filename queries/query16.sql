DROP VIEW IF EXISTS districts_with_capacity;
CREATE VIEW districts_with_capacity AS
SELECT SUM(maximum_capacity) AS capacity,
    district.id AS district_id,
    district.name AS district_name
FROM storehouse
    JOIN infrastructure ON infrastructure.id = storehouse.infrastructure_id
    JOIN address ON infrastructure.address_id = address.id
    JOIN zip_code ON address.zip_code_id = zip_code.id
    JOIN county ON county.id = zip_code.county_id
    LEFT JOIN district ON district.id = county.district_id
GROUP BY district.id;

SELECT district_name,
    (
        CASE
            WHEN capacity_per_capita IS NULL THEN 0
            ELSE capacity_per_capita
        END
    ) AS capacity_per_capita
FROM (
        SELECT district_name,
            CAST(
                (
                    CASE
                        WHEN population IS NULL THEN 0
                        ELSE capacity
                    END
                ) AS REAL
            ) / (
                CASE
                    WHEN population IS NULL THEN 0
                    ELSE population
                END
            ) AS capacity_per_capita
        FROM (
                SELECT *
                FROM districts_with_capacity
                UNION
                SELECT 0,
                    district.id AS district_id,
                    district.name AS district_name
                FROM district
                WHERE district.id NOT IN (
                        SELECT district_id
                        FROM districts_with_capacity
                    )
            ) AS capacity_per_district
            LEFT JOIN (
                SELECT COUNT(*) AS population,
                    district.id AS district_id
                FROM district
                    JOIN county ON county.district_id = district.id
                    JOIN zip_code ON county.id = zip_code.county_id
                    JOIN address ON zip_code.id = address.zip_code_id
                    JOIN citizen ON address.id = citizen.address_id
                GROUP BY district_id
            ) AS population_per_district ON capacity_per_district.district_id = population_per_district.district_id
    )
ORDER BY district_name ASC;