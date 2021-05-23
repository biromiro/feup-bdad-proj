.headers on
.mode column
.nullvalue NULL

SELECT MAX(rate) as rate,
    common_name as disease
FROM (
        SELECT (
                CAST(COUNT(*) AS REAL) * 100 / (
                    SELECT COUNT(*)
                    FROM citizen
                )
            ) AS rate,
            pathology.common_name AS common_name
        FROM inoculation
            JOIN vaccine ON inoculation.vaccine_id = vaccine.id
            JOIN pathology ON vaccine.prevents_pathology_id = pathology.id
        GROUP BY pathology.id
    );