SELECT ((age_group * 10) || '-' || (9 + age_group * 10)) AS age_group,
    people_count
FROM (
        SELECT CAST(
                (
                    julianday(date('now')) - julianday(citizen.birth_date)
                ) / 365 / 10 AS INTEGER
            ) AS age_group,
            COUNT(*) AS people_count
        FROM citizen
        GROUP BY age_group
    );