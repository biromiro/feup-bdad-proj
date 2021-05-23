.headers on
.mode column
.nullvalue NULL

DROP VIEW IF EXISTS pathology_occurences;
CREATE VIEW pathology_occurences AS
SELECT citizen_has_pathology.pathology_id,
    COUNT(*) AS occurences
FROM citizen_has_pathology
GROUP BY citizen_has_pathology.pathology_id
ORDER BY occurences;

SELECT pathology.scientific_name,
    pathology.common_name,
    pathology_occurences.occurences
FROM pathology_occurences
    JOIN pathology ON pathology_occurences.pathology_id = pathology.id
WHERE NOT EXISTS (
        SELECT *
        FROM pathology_occurences pathology_occurences_rhs
        WHERE pathology_occurences_rhs.occurences > pathology_occurences.occurences
    );