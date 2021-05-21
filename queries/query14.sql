SELECT pathology.id,
    (
        (julianday(MAX(date)) - julianday(MIN(date))) / COUNT(*)
    ) || ' per day' AS inoculation_rate
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON pathology.id = vaccine.prevents_pathology_id
GROUP BY pathology.id;