DROP TRIGGER IF EXISTS transportation_vaccine_storage_trigger;
CREATE TRIGGER transportation_vaccine_storage_trigger
AFTER INSERT ON transportation
FOR EACH ROW
BEGIN
    UPDATE vaccine_storage SET amount = (
        (SELECT amount FROM vaccine_storage WHERE vaccine_storage.infrastructure_id = NEW."to" AND vaccine_storage.vaccine_id = NEW.vaccine_id)
        +
    NEW.amount
    )
    WHERE
        NEW."to" = vaccine_storage.infrastructure_id
        AND NEW."vaccine_id" = vaccine_storage.vaccine_id;
        
    UPDATE vaccine_storage SET amount = (
        (SELECT amount FROM vaccine_storage WHERE vaccine_storage.infrastructure_id = NEW."from" AND vaccine_storage.vaccine_id = NEW.vaccine_id)
        -
        NEW.amount
    )
    WHERE
        NEW."from" = vaccine_storage.infrastructure_id
        AND NEW."vaccine_id" = vaccine_storage.vaccine_id;
        
    UPDATE infrastructure SET total_stored_vaccines = (
        (SELECT total_stored_vaccines FROM infrastructure WHERE infrastructure.id = NEW."to")
        +
        NEW.amount
    )
    WHERE
        NEW."to" = infrastructure.id;
        
    UPDATE infrastructure SET total_stored_vaccines = (
        (SELECT total_stored_vaccines FROM infrastructure WHERE infrastructure.id = NEW."from")
        -
        NEW.amount
    )
    WHERE
        NEW."from" = infrastructure.id;
END;