PRAGMA foreign_keys = on;

DROP TRIGGER IF EXISTS delivery_vaccine_storage_trigger;
CREATE TRIGGER delivery_vaccine_storage_trigger
AFTER INSERT ON delivery
FOR EACH ROW
BEGIN

    INSERT INTO vaccine_storage(infrastructure_id, vaccine_id, amount) 
    SELECT NEW.distribution_centre_id, NEW.vaccine_id, 0
    WHERE NOT EXISTS (
        SELECT * FROM vaccine_storage WHERE NEW.distribution_centre_id = vaccine_storage.infrastructure_id AND NEW.vaccine_id = vaccine_storage.vaccine_id
    );  

    UPDATE vaccine_storage SET amount = amount + NEW.amount
    WHERE
        NEW.distribution_centre_id = vaccine_storage.infrastructure_id
        AND NEW.vaccine_id = vaccine_storage.vaccine_id;
        
    UPDATE infrastructure SET total_stored_vaccines = total_stored_vaccines + NEW.amount
    WHERE
        NEW.distribution_centre_id = infrastructure.id;

END;