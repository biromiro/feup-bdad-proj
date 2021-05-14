# Queries

## Table of Contents

### Query 2

What is the most common pathology?

```sql
-- What is the most common pathology?
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
WHERE pathology_occurences.occurences = (
        SELECT MAX(occurences)
        FROM pathology_occurences
    );
```

### Query 3

What is the percentage of people vaccinated with at least one dose and fully dosed?

```sql
DROP VIEW IF EXISTS vaccines;
CREATE VIEW vaccines AS
SELECT vaccine.id
FROM vaccine
WHERE vaccine.prevents_pathology_id = 56;
-- change this ihihi, 56 is covid btw
DROP VIEW IF EXISTS vaccinated;
CREATE VIEW vaccinated AS
SELECT DISTINCT citizen.id
FROM inoculation
    JOIN citizen ON inoculation.citizen_id = citizen.id
WHERE inoculation.vaccine_id IN vaccines;
---
DROP VIEW IF EXISTS vaccinated_with_doses;
CREATE VIEW vaccinated_with_doses AS
SELECT citizen_id,
    inoculation_number,
    vaccine_inoculations_number,
    (
        CASE
            WHEN inoculation_number = vaccine_inoculations_number THEN 1
            ELSE 0
        END
    ) AS fully_vaccinated
FROM (
        SELECT vaccinated.id AS citizen_id,
            inoculation.date,
            inoculation.inoculation_number,
            vaccine.inoculations_number AS vaccine_inoculations_number,
            MAX(inoculation.date) AS most_recent_date
        FROM vaccinated
            JOIN inoculation ON vaccinated.id = inoculation.citizen_id
            JOIN vaccine ON vaccine.id = inoculation.vaccine_id
        GROUP BY citizen_id
    );
SELECT *
FROM vaccinated_with_doses;
---
SELECT (
        (
            100.0 * (
                SELECT COUNT(*)
                FROM vaccinated_with_doses
                WHERE fully_vaccinated = 1
            ) / people_count
        ) || '%'
    ) AS fully_vaccinated,
    (
        (
            100.0 * (
                SELECT COUNT(*)
                FROM vaccinated_with_doses
                WHERE fully_vaccinated = 0
            ) / people_count
        ) || '%'
    ) AS at_least_one_those
FROM (
        SELECT COUNT(*) AS people_count
        FROM citizen
    );
```

### Query 7

How many vaccines does a pathology have?

```sql
SELECT pathology.scientific_name,
    pathology.common_name,
    COUNT(*) AS different_vaccines
FROM pathology
    LEFT JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
GROUP BY pathology.id;
```

### Query 7.1 ???

What are the vaccines for a pathology?

```sql
SELECT pathology.scientific_name,
    pathology.common_name,
    vaccine.producer,
    vaccine.name
FROM pathology
    JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id;
```

### Query 12

What is the percentage of people with a pathology by job group?

```sql
-- What is the percentage of people with a pathology by job group?
DROP VIEW IF EXISTS patients;
CREATE VIEW patients AS
SELECT citizen_has_pathology.citizen_id
FROM citizen_has_pathology
WHERE citizen_has_pathology.pathology_id = 56;
DROP VIEW IF EXISTS patients_job_group;
---
CREATE VIEW patients_job_group AS
SELECT job.group_id,
    COUNT(*) AS patients
FROM patients
    LEFT JOIN citizen ON citizen.id = patients.citizen_id
    JOIN job ON job.id = citizen.job_id
WHERE citizen.id IN patients
GROUP BY job.group_id;
---
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

### Query 16

What are the pathologies that have no vaccine?

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

### Query 18

What is the number of citizens by age group?

```sql
SELECT ((age_group * 10) || '-' || (9 + age_group * 10)) AS age_group, people_count FROM (SELECT CAST(
        (
            julianday(date('now')) - julianday(citizen.birth_date)
        ) / 365 / 10 AS INTEGER
    ) AS age_group,
    COUNT(*) AS people_count
FROM citizen
GROUP BY age_group);
```

### Query 19

What is the percentage of citizens vaccinated with at least one inoculation for a pathology by age group?

```sql
DROP VIEW IF EXISTS vaccines;
CREATE VIEW vaccines AS
SELECT vaccine.id
FROM vaccine
WHERE vaccine.prevents_pathology_id = 56; -- change this ihihi, 56 is covid btw

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
    (100.0 * vaccinated_people / people_count) AS percentage
FROM vaccination_by_age_group;
```
