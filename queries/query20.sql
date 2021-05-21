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