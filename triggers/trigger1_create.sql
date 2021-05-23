PRAGMA foreign_keys = on;

DROP TRIGGER IF EXISTS transportation_destination_check_trigger;
CREATE TRIGGER transportation_destination_check_trigger BEFORE
INSERT ON transportation FOR EACH ROW BEGIN
SELECT CASE
        WHEN EXISTS (
            SELECT *
            FROM distribution_centre
            WHERE distribution_centre.infrastructure_id = NEW."to"
        ) THEN RAISE (
            ABORT,
            "The destination of a transportation must not be a distribution centre"
        )
    END;
END;