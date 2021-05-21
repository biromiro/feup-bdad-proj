SELECT pathology.scientific_name,
    pathology.common_name,
    COUNT(*) AS inoculations
FROM inoculation
    JOIN vaccine ON vaccine.id = inoculation.vaccine_id
    JOIN pathology ON pathology.id = vaccine.prevents_pathology_id
WHERE pathology.id = 56;