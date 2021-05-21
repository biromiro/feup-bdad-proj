SELECT id,
    total_stored_vaccines,
    maximum_capacity,
    (
        total_stored_vaccines / CAST(maximum_capacity AS real) * 100
    ) || '%' AS capacity
FROM storehouse
    JOIN infrastructure ON infrastructure.id = storehouse.infrastructure_id
WHERE total_stored_vaccines / CAST(maximum_capacity AS real) >= 0.9;