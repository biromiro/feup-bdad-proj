.headers on
.mode column
.nullvalue NULL

SELECT pathology.scientific_name,
    pathology.common_name
FROM pathology
WHERE pathology.id NOT IN (
        SELECT pathology.id
        FROM pathology
            JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
        GROUP BY pathology.id
    );