--trigger para verificar se existem vacinas do sitio de onde vem e se há espaço do sitio para onde vai - Transportation
DROP TRIGGER IF EXISTS vaccine_transportation_amount_check_trigger;
CREATE TRIGGER vaccine_transportation_amount_check_trigger BEFORE
INSERT
    ON transportation FOR EACH ROW BEGIN
SELECT
    CASE
        WHEN EXISTS (
            SELECT
                *
            FROM
                infrastructure AS origin
                JOIN vaccine_storage ON vaccine_storage.infrastructure_id = origin.id
            WHERE
                origin.id = NEW."from"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
                AND (vaccine_storage.amount < NEW.amount)
        ) THEN RAISE (
            abort,
            "The origin infrastructure does not have the vaccine amount"
        )
        WHEN EXISTS (
            SELECT
                *
            FROM
                infrastructure AS destination
                JOIN storehouse ON storehouse.infrastructure_id = destination.id
            WHERE
                destination.id = NEW."to"
                AND destination.total_stored_vaccines + NEW.amount > storehouse.maximum_capacity
        ) THEN RAISE (
            abort,
            "The destination infrastructure does not have space for the vaccines"
        )
    END;
END;