.headers on
.mode column
.nullvalue NULL

SELECT pathology.id, pathology.common_name,
    IFNULL((
        COUNT(*) / (julianday(MAX(date)) - julianday(MIN(date)))
    ), 0) || ' per day' AS inoculation_rate
FROM pathology
    LEFT JOIN vaccine ON vaccine.prevents_pathology_id = pathology.id
    LEFT JOIN inoculation ON inoculation.vaccine_id = vaccine.id
GROUP BY pathology.id;