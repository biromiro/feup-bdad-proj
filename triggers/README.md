# Triggers <!-- omit in toc -->

## Table of Contents <!-- omit in toc -->

- [Trigger 1: Prevent transportation from being held to a Distribution Centre](#trigger-1-prevent-transportation-from-being-held-to-a-distribution-centre)
- [Trigger 2: Keep the storage of an infrastructure updated according to the transportation associated with that infrastructure](#trigger-2-keep-the-storage-of-an-infrastructure-updated-according-to-the-transportation-associated-with-that-infrastructure)
- [Trigger 3: Verify if there are enough vaccines in the origin infrastructure and if there is space in the destination infrastructure for a given transportation to occur](#trigger-3-verify-if-there-are-enough-vaccines-in-the-origin-infrastructure-and-if-there-is-space-in-the-destination-infrastructure-for-a-given-transportation-to-occur)
- [Trigger 4: Verify if the destination storehouse of new transportation meet the temperature requirements of the vaccine that is transported](#trigger-4-verify-if-the-destination-storehouse-of-new-transportation-meet-the-temperature-requirements-of-the-vaccine-that-is-transported)
- [Trigger 5: Verify if an inoculation number is in the range of the number of inoculations of a given vaccine](#trigger-5-verify-if-an-inoculation-number-is-in-the-range-of-the-number-of-inoculations-of-a-given-vaccine)

## Trigger 1: Prevent transportation from being held to a Distribution Centre

```sql
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
```

## Trigger 2: Keep the storage of an infrastructure updated according to the transportation associated with that infrastructure

```sql
DROP TRIGGER IF EXISTS transportation_vaccine_storage_trigger;
CREATE TRIGGER transportation_vaccine_storage_trigger
AFTER
INSERT ON transportation FOR EACH ROW BEGIN
UPDATE vaccine_storage
SET amount = (
        (
            SELECT amount
            FROM vaccine_storage
            WHERE vaccine_storage.infrastructure_id = NEW."to"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
        ) + NEW.amount
    )
WHERE NEW."to" = vaccine_storage.infrastructure_id
    AND NEW."vaccine_id" = vaccine_storage.vaccine_id;
UPDATE vaccine_storage
SET amount = (
        (
            SELECT amount
            FROM vaccine_storage
            WHERE vaccine_storage.infrastructure_id = NEW."from"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
        ) - NEW.amount
    )
WHERE NEW."from" = vaccine_storage.infrastructure_id
    AND NEW."vaccine_id" = vaccine_storage.vaccine_id;
UPDATE infrastructure
SET total_stored_vaccines = (
        (
            SELECT total_stored_vaccines
            FROM infrastructure
            WHERE infrastructure.id = NEW."to"
        ) + NEW.amount
    )
WHERE NEW."to" = infrastructure.id;
UPDATE infrastructure
SET total_stored_vaccines = (
        (
            SELECT total_stored_vaccines
            FROM infrastructure
            WHERE infrastructure.id = NEW."from"
        ) - NEW.amount
    )
WHERE NEW."from" = infrastructure.id;
END;
```

## Trigger 3: Verify if there are enough vaccines in the origin infrastructure and if there is space in the destination infrastructure for a given transportation to occur

```sql
DROP TRIGGER IF EXISTS vaccine_transportation_amount_check_trigger;
CREATE TRIGGER vaccine_transportation_amount_check_trigger BEFORE
INSERT ON transportation FOR EACH ROW BEGIN
SELECT CASE
        WHEN EXISTS (
            SELECT *
            FROM infrastructure AS origin
                JOIN vaccine_storage ON vaccine_storage.infrastructure_id = origin.id
            WHERE origin.id = NEW."from"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
                AND (vaccine_storage.amount < NEW.amount)
        ) THEN RAISE (
            ABORT,
            "The origin infrastructure does not have the vaccine amount"
        )
        WHEN EXISTS (
            SELECT *
            FROM infrastructure AS destination
                JOIN storehouse ON storehouse.infrastructure_id = destination.id
            WHERE destination.id = NEW."to"
                AND destination.total_stored_vaccines + NEW.amount > storehouse.maximum_capacity
        ) THEN RAISE (
            ABORT,
            "The destination infrastructure does not have space for the vaccines"
        )
    END;
END;
```

## Trigger 4: Verify if the destination storehouse of new transportation meet the temperature requirements of the vaccine that is transported

```sql
DROP TRIGGER IF EXISTS check_validity_vaccine_dose;
CREATE TRIGGER check_validity_vaccine_dose BEFORE
INSERT ON inoculation FOR EACH ROW
    WHEN EXISTS (
        SELECT *
        FROM vaccine
        WHERE vaccine.id = NEW.vaccine_id
            AND vaccine.inoculations_number < NEW.inoculation_number
    )
    OR NEW.inoculation_number < 0 BEGIN
SELECT RAISE (ABORT, "The dose of the vaccine is invalid!");
END;
```

## Trigger 5: Verify if an inoculation number is in the range of the number of inoculations of a given vaccine

```sql
DROP TRIGGER IF EXISTS temp_check_on_transp_to_storehouse_trigger;
CREATE TRIGGER temp_check_on_transp_to_storehouse_trigger BEFORE
INSERT ON transportation FOR EACH ROW BEGIN
SELECT CASE
        WHEN NOT EXISTS (
            SELECT *
            FROM (
                    SELECT storehouse.minimum_temperature,
                        storehouse.maximum_temperature
                    FROM storehouse
                    WHERE storehouse.infrastructure_id = NEW."to"
                ) AS storehouse,
                (
                    SELECT vaccine.minimum_temperature,
                        vaccine.maximum_temperature
                    FROM vaccine
                    WHERE vaccine.id = NEW.vaccine_id
                ) AS vaccine
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
        ) THEN RAISE(
            ABORT,
            "The destiny storehouse does not assure that the vaccines can be stored safely!"
        )
    END;
END;
```
