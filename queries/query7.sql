SELECT pathology.scientific_name,
    pathology.common_name,
    COUNT(*) AS different_vaccines
FROM pathology
    LEFT JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
GROUP BY pathology.id;