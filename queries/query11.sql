SELECT (
        CAST(covid_infected AS REAL) * 100000 / (
            SELECT COUNT(*)
            FROM citizen
        )
    ) AS covid_infected_per_100k
FROM (
        SELECT COUNT(*) AS covid_infected
        FROM citizen_has_pathology
        WHERE citizen_has_pathology.pathology_id = 56
    );