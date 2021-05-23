.headers on
.mode column
.nullvalue NULL

SELECT *
FROM vaccine
WHERE vaccine.id NOT IN (
        SELECT vaccine.id
        FROM vaccine
            CROSS JOIN storehouse
        WHERE (
                    storehouse.minimum_temperature <= vaccine.minimum_temperature
                    AND storehouse.maximum_temperature >= vaccine.minimum_temperature
                )
                OR (
                    storehouse.minimum_temperature <= vaccine.maximum_temperature
                    AND storehouse.maximum_temperature >= vaccine.maximum_temperature
                )
                OR (
                    storehouse.minimum_temperature <= vaccine.maximum_temperature
                    AND storehouse.maximum_temperature IS NULL
                )
                OR (
                    storehouse.maximum_temperature >= vaccine.minimum_temperature
                    AND storehouse.minimum_temperature IS NULL
                )
    );