DROP TRIGGER IF EXISTS transportation_destination_check_trigger;
CREATE TRIGGER transportation_destination_check_trigger BEFORE
INSERT
    ON transportation FOR EACH ROW BEGIN
select
    CASE
        WHEN EXISTS (
            SELECT
                *
            from
                distribution_centre
            WHERE
                distribution_centre.infrastructure_id = NEW."to"
        ) THEN RAISE (
            abort,
            "The destination of a transportation must not be a distribution centre"
        )
    END;
END;