SELECT county_name,
    (
        CASE
            WHEN population <> 0 THEN (completely_vaccinated_num + mid_vaccination_num) * 100000 / CAST(population AS REAL)
            ELSE 0.0
        END
    ) AS covid_infected_per_100k
FROM covid_vaccination_per_county;