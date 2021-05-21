SELECT vaccine.name,
    vaccine.minimum_temperature,
    vaccine.maximum_temperature
FROM vaccine
WHERE vaccine.id NOT IN (
        SELECT vaccine.id
        FROM vaccine
            CROSS JOIN storehouse
        WHERE (
                vaccine.minimum_temperature >= storehouse.minimum_temperature
                AND vaccine.minimum_temperature <= storehouse.maximum_temperature
            )
            OR (
                vaccine.maximum_temperature >= storehouse.minimum_temperature
                AND vaccine.maximum_temperature <= storehouse.maximum_temperature
            )
    );