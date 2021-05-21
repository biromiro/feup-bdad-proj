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