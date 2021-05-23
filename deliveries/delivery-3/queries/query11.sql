.headers on
.mode column
.nullvalue NULL

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
