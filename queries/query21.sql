SELECT vaccine.id,
    vaccine.name,
    IFNULL(storage.amount, 0) AS amount
FROM vaccine
    LEFT JOIN (
        SELECT *
        FROM vaccine_storage
        WHERE infrastructure_id = 48
    ) AS storage ON storage.vaccine_id = vaccine.id
    LEFT JOIN infrastructure ON infrastructure.id = storage.infrastructure_id
ORDER BY vaccine.id;