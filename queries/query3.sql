DROP view IF EXISTS citizen_vaccine_numbers;
CREATE view citizen_vaccine_numbers AS
SELECT inoculation.citizen_id,
    vaccine.id AS vaccine_id,
    pathology.id AS pathology_id,
    COUNT(*) AS inoculations_taken,
    vaccine.inoculations_number,
    vaccine.inoculations_number - COUNT(*) AS inoculations_remaining
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON pathology.id = vaccine.prevents_pathology_id
GROUP BY  inoculation.citizen_id,
    vaccine.id;

DROP view IF EXISTS citizens_vaccine_pathologies;
CREATE view citizens_vaccine_pathologies AS
SELECT citizen_id,
    pathology_id,
    inoculations_taken,
    MIN(inoculations_remaining) AS inoculations_remaining
FROM citizen_vaccine_numbers
GROUP BY  citizen_id,
    pathology_id;

DROP view IF EXISTS fully_vaccinated_pathology;
CREATE view fully_vaccinated_pathology AS
SELECT pathology_id,
    COUNT(*) AS fully_vaccinated
FROM citizens_vaccine_pathologies
WHERE inoculations_remaining = 0
GROUP BY  pathology_id;

DROP view IF EXISTS at_least_one_vaccinated_pathology;
CREATE view at_least_one_vaccinated_pathology AS
SELECT pathology_id,
    COUNT(*) AS one_dose_vaccinated
FROM citizens_vaccine_pathologies
GROUP BY pathology_id;

WITH citizens AS (
    SELECT CAST(COUNT(*) AS real) AS amount
    FROM citizen
)
SELECT pathology.id,
    pathology.common_name,
    (
        IFNULL(one_dose_vaccinated, 0) / citizens.amount * 100
    ) || '%' AS one_dose_vaccinated,
    (
        IFNULL(fully_vaccinated, 0) / citizens.amount * 100
    ) || '%' AS fully_vaccinated
FROM pathology
    LEFT JOIN fully_vaccinated_pathology ON fully_vaccinated_pathology.pathology_id = pathology.id
    LEFT JOIN at_least_one_vaccinated_pathology USING(pathology_id),
    citizens;
