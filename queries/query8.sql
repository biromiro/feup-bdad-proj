SELECT pathology.scientific_name,
    pathology.common_name,
    vaccine.producer,
    vaccine.name
FROM pathology
    JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id;