# Queries<!-- omit in toc -->

## Table of Contents<!-- omit in toc -->

- [Query 1: Who are the citizens that belong to a given vaccination group?](#query-1-who-are-the-citizens-that-belong-to-a-given-vaccination-group)
- [Query 2: What is the most common pathology?](#query-2-what-is-the-most-common-pathology)
- [Query 3: What is the percentage of citizens that took at least one dose and are fully dosed for all pathologies?](#query-3-what-is-the-percentage-of-citizens-that-took-at-least-one-dose-and-are-fully-dosed-for-all-pathologies)
- [Query 4: How many doses are administrated for a given pathology?](#query-4-how-many-doses-are-administrated-for-a-given-pathology)
- [Query 5: How many doses of a given vaccine were administrated to a given citizen, and how many are left?](#query-5-how-many-doses-of-a-given-vaccine-were-administrated-to-a-given-citizen-and-how-many-are-left)
- [Query 6: What is the disease with the highest vaccination rate?](#query-6-what-is-the-disease-with-the-highest-vaccination-rate)
- [Query 7: How many vaccines does a pathology have?](#query-7-how-many-vaccines-does-a-pathology-have)
- [Query 8: What are the vaccines for a pathology?](#query-8-what-are-the-vaccines-for-a-pathology)
- [Query 9: What are the storehouses above 50% of its capacity?](#query-9-what-are-the-storehouses-above-50-of-its-capacity)
- [Query 10: What is the percentage of people per county that are vaccinated for a given disease (in this case, COVID-19)?](#query-10-what-is-the-percentage-of-people-per-county-that-are-vaccinated-for-a-given-disease-in-this-case-covid-19)
- [Query 11: What is the incidence per 100k of infection of a given disease (in this case, COVID-19)?](#query-11-what-is-the-incidence-per-100k-of-infection-of-a-given-disease-in-this-case-covid-19)
- [Query 12: What is the incidence per 100k per county of infection of a given disease (in this case, COVID-19)?](#query-12-what-is-the-incidence-per-100k-per-county-of-infection-of-a-given-disease-in-this-case-covid-19)
- [Query 13: What is the percentage of people with a pathology by job group?](#query-13-what-is-the-percentage-of-people-with-a-pathology-by-job-group)
- [Query 14: What is the number of inoculations administrated per day for all pathologies?](#query-14-what-is-the-number-of-inoculations-administrated-per-day-for-all-pathologies)
- [Query 15: How many inoculations were administrated for a given pathology (in this case, covid) in a given day (in this case, 2021-03-05)?](#query-15-how-many-inoculations-were-administrated-for-a-given-pathology-in-this-case-covid-in-a-given-day-in-this-case-2021-03-05)
- [Query 16: What is the capacity per capita to hold vaccines in each district?](#query-16-what-is-the-capacity-per-capita-to-hold-vaccines-in-each-district)
- [Query 17: What are the pathologies that have no vaccine?](#query-17-what-are-the-pathologies-that-have-no-vaccine)
- [Query 18: Which vaccines do not have a storehouse that could hold it (according to temperature restrictions)?](#query-18-which-vaccines-do-not-have-a-storehouse-that-could-hold-it-according-to-temperature-restrictions)
- [Query 19: What is the number of citizens by age group?](#query-19-what-is-the-number-of-citizens-by-age-group)
- [Query 20: What is the percentage of citizens vaccinated with at least one inoculation for a pathology by age group?](#query-20-what-is-the-percentage-of-citizens-vaccinated-with-at-least-one-inoculation-for-a-pathology-by-age-group)

## Query 1: Who are the citizens that belong to a given vaccination group?

In this case the vaccination group is the vaccination group with id `1`.

```sql
SELECT citizen.citizen_card_number,
    citizen.name
FROM vaccination_group
    JOIN citizen_belongs_to_vaccination_group ON citizen_belongs_to_vaccination_group.vaccination_group_id = vaccination_group.id
    JOIN citizen ON citizen.id = citizen_belongs_to_vaccination_group.citizen_id
WHERE vaccination_group.id = 1;
```

## Query 2: What is the most common pathology?

```sql
DROP VIEW IF EXISTS pathology_occurences;
CREATE VIEW pathology_occurences AS
SELECT citizen_has_pathology.pathology_id,
    COUNT(*) AS occurences
FROM citizen_has_pathology
GROUP BY citizen_has_pathology.pathology_id
ORDER BY occurences;

SELECT pathology.scientific_name,
    pathology.common_name,
    pathology_occurences.occurences
FROM pathology_occurences
    JOIN pathology ON pathology_occurences.pathology_id = pathology.id
WHERE NOT EXISTS (
        SELECT *
        FROM pathology_occurences pathology_occurences_rhs
        WHERE pathology_occurences_rhs.occurences > pathology_occurences.occurences
    );
```

## Query 3: What is the percentage of citizens that took at least one dose and are fully dosed for all pathologies?

```sql
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
where inoculations_remaining = 0
GROUP BY  pathology_id;

DROP view IF EXISTS at_least_one_vaccinated_pathology;
CREATE view at_least_one_vaccinated_pathology AS
SELECT pathology_id,
    COUNT(*) AS one_dose_vaccinated
FROM citizens_vaccine_pathologies
GROUP BY  pathology_id;
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
    LEFT JOIN at_leASt_one_vaccinated_pathology USING(pathology_id),
    citizens;
```

## Query 4: How many doses are administrated for a given pathology?

```sql
SELECT pathology.scientific_name,
    pathology.common_name,
    COUNT(*) AS inoculations
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON pathology.id = vaccine.prevents_pathology_id
WHERE pathology.id = 56;
```

## Query 5: How many doses of a given vaccine were administrated to a given citizen, and how many are left?

```sql
SELECT vaccine.id AS vaccine_id,
    vaccine.name AS vaccine_name,
    vaccine.inoculations_number AS vaccine_total_inoculations,
    vaccine.inoculations_number - IFNULL(inoculation.inoculation_number, 0) AS remaining_inoculations,
    IFNULL(MAX(inoculation.date), 'Never') AS last_inoculation
FROM pathology
    JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
    LEFT JOIN (
        SELECT *
        FROM inoculation
        WHERE citizen_id = 913
    ) AS inoculation ON inoculation.vaccine_id = vaccine.id
WHERE pathology.id = 56
GROUP BY vaccine.id
ORDER BY inoculation.date DESC;
```

## Query 6: What is the disease with the highest vaccination rate?

```sql
SELECT MAX(rate) as rate,
    common_name as disease
FROM (
        SELECT (
                CAST(COUNT(*) AS REAL) * 100 / (
                    SELECT COUNT(*)
                    FROM citizen
                )
            ) AS rate,
            pathology.common_name AS common_name
        FROM inoculation
            JOIN vaccine ON inoculation.vaccine_id = vaccine.id
            JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
        GROUP BY pathology.id
    );
```

## Query 7: How many vaccines does a pathology have?

```sql
SELECT pathology.scientific_name,
    pathology.common_name,
    COUNT(*) AS different_vaccines
FROM pathology
    LEFT JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
GROUP BY pathology.id;
```

## Query 8: What are the vaccines for a pathology?

```sql
SELECT pathology.scientific_name,
    pathology.common_name,
    vaccine.producer,
    vaccine.name
FROM pathology
    JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id;
```

## Query 9: What are the storehouses above 50% of its capacity?

```sql
SELECT id,
    total_stored_vaccines,
    maximum_capacity,
    (
        total_stored_vaccines / CAST(maximum_capacity AS real) * 100
    ) || '%' AS capacity
FROM storehouse
    JOIN infrastructure ON infrastructure.id = storehouse.infrastructure_id;
WHERE total_stored_vaccines / CAST(maximum_capacity AS real) >= 0.5;
```

## Query 10: What is the percentage of people per county that are vaccinated for a given disease (in this case, COVID-19)?

```sql
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
    IFNULL(CAST(completely_vaccinated_num AS REAL) * 100 / population, 0) AS percentage
FROM covid_vaccination_per_county
ORDER BY percentage DESC;
```

## Query 11: What is the incidence per 100k of infection of a given disease (in this case, COVID-19)?

```sql
WITH citizens AS (
        SELECT CAST(COUNT(*) AS real) AS amount
        FROM citizen),
    covid AS (
        SELECT COUNT(*) AS infected
        FROM citizen_has_pathology
        WHERE citizen_has_pathology.pathology_id = 56
    )
SELECT covid.infected * 100000 / citizens.amount AS covid_infected_per_100k
FROM citizens, covid;
```

## Query 12: What is the incidence per 100k per county of infection of a given disease (in this case, COVID-19)?

```sql
SELECT county_name,
    (
        CASE
            WHEN population <> 0 THEN (completely_vaccinated_num + mid_vaccination_num) * 100000 / CAST(population AS REAL)
            ELSE 0.0
        END
    ) AS covid_infected_per_100k
FROM covid_vaccination_per_county;
```

## Query 13: What is the percentage of people with a pathology by job group?

```sql
DROP VIEW IF EXISTS patients;
CREATE VIEW patients AS
SELECT citizen_has_pathology.citizen_id
FROM citizen_has_pathology
WHERE citizen_has_pathology.pathology_id = 56;
DROP VIEW IF EXISTS patients_job_group;

CREATE VIEW patients_job_group AS
SELECT job.group_id,
    COUNT(*) AS patients
FROM patients
    LEFT JOIN citizen ON citizen.id = patients.citizen_id
    JOIN job ON job.id = citizen.job_id
WHERE citizen.id IN patients
GROUP BY job.group_id;

DROP VIEW IF EXISTS people_per_job_group;
CREATE VIEW people_per_job_group AS
SELECT job.group_id,
    COUNT(*) AS people_count
FROM job
    LEFT JOIN citizen ON citizen.job_id = job.id
GROUP BY job.group_id;

SELECT name,
    ((patients * 100.0 / people_count) || '%') AS has_pathology_percentage
FROM (
        SELECT job_group.name,
            people_per_job_group.*,
            IFNULL(patients, 0) AS patients
        FROM people_per_job_group
            LEFT JOIN patients_job_group ON patients_job_group.group_id = people_per_job_group.group_id
            JOIN job_group ON people_per_job_group.group_id = job_group.id
    );
```

## Query 14: What is the number of inoculations administrated per day for all pathologies?

```sql
SELECT pathology.id, pathology.common_name,
    IFNULL((
        COUNT(*) / (julianday(MAX(date)) - julianday(MIN(date)))
    ), 0) || ' per day' AS inoculation_rate
FROM pathology
    LEFT JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
    LEFT JOIN inoculation ON inoculation.vaccine_id = vaccine.id
GROUP BY pathology.id;
```

## Query 15: How many inoculations were administrated for a given pathology (in this case, covid) in a given day (in this case, 2021-03-05)?

```sql
SELECT COUNT(*) as number_of_inoculations,
    date
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
WHERE pathology.id = 56
    AND date = "2021-03-05";
```

## Query 16: What is the capacity per capita to hold vaccines in each district?

```sql
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
```

## Query 17: What are the pathologies that have no vaccine?

```sql
SELECT pathology.scientific_name,
    pathology.common_name
FROM pathology
WHERE pathology.id NOT IN (
        SELECT pathology.id
        FROM pathology
            JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
        GROUP BY pathology.id
    );
```

## Query 18: Which vaccines do not have a storehouse that could hold it (according to temperature restrictions)?

```sql
SELECT vaccine.name,
    vaccine.minimum_temperature,
    vaccine.maximum_temperature
FROM vaccine
WHERE vaccine.id NOT IN (
        SELECT vaccine.id
        FROM vaccine
            CROSS JOIN storehouse
        WHERE (
                    storehouse.minimum_temperature <= vaccine.minimum_temperature
                    AND storehouse.maximum_temperature >= vaccine.minimum_temperature
                )
                OR (
                    storehouse.minimum_temperature <= vaccine.maximum_temperature
                    AND storehouse.maximum_temperature >= vaccine.maximum_temperature
                )
                OR (
                    storehouse.minimum_temperature <= vaccine.maximum_temperature
                    AND storehouse.maximum_temperature IS NULL
                )
                OR (
                    storehouse.maximum_temperature >= vaccine.minimum_temperature
                    AND storehouse.minimum_temperature IS NULL
                )
    );
```

## Query 19: What is the number of citizens by age group?

```sql
SELECT ((age_group * 10) || '-' || (9 + age_group * 10)) AS age_group,
    people_count
FROM (
        SELECT CAST(
                (
                    julianday(date('now')) - julianday(citizen.birth_date)
                ) / 365 / 10 AS INTEGER
            ) AS age_group,
            COUNT(*) AS people_count
        FROM citizen
        GROUP BY age_group
    );
```

## Query 20: What is the percentage of citizens vaccinated with at least one inoculation for a pathology by age group?

```sql
DROP VIEW IF EXISTS vaccines;
CREATE VIEW vaccines AS
SELECT vaccine.id
FROM vaccine
WHERE vaccine.prevents_pathology_id = 56;

DROP VIEW IF EXISTS vaccinated;
CREATE VIEW vaccinated AS
SELECT DISTINCT citizen.id
FROM inoculation
    JOIN citizen ON inoculation.citizen_id = citizen.id
WHERE inoculation.vaccine_id IN vaccines;

DROP VIEW IF EXISTS vaccination_by_age_group;
CREATE VIEW vaccination_by_age_group AS
SELECT age_groups.*,
    (
        CASE
            WHEN vaccinated_age_groups.vaccinated_people IS NULL THEN 0
            ELSE vaccinated_age_groups.vaccinated_people
        END
    ) AS vaccinated_people
FROM (
        SELECT CAST(
                (
                    julianday(date('now')) - julianday(citizen.birth_date)
                ) / 365 / 10 AS INTEGER
            ) AS age_group,
            COUNT(*) AS people_count
        FROM citizen
        GROUP BY age_group
    ) AS age_groups
    LEFT JOIN (
        SELECT CAST(
                (
                    julianday(date('now')) - julianday(citizen.birth_date)
                ) / 365 / 10 AS INTEGER
            ) AS age_group,
            COUNT(*) AS vaccinated_people
        FROM vaccinated
            JOIN citizen ON vaccinated.id = citizen.id
        GROUP BY age_group
    ) AS vaccinated_age_groups ON age_groups.age_group = vaccinated_age_groups.age_group;

SELECT ((age_group * 10) || '-' || (9 + age_group * 10)) AS age_group,
    (100.0 * vaccinated_people / people_count) || '%' AS percentage
FROM vaccination_by_age_group;
```
