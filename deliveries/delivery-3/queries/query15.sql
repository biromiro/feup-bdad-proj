.headers on
.mode column
.nullvalue NULL

SELECT COUNT(*) as number_of_inoculations,
    date
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
WHERE pathology.id = 56
    AND date = "2021-03-05";