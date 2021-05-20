DROP TRIGGER IF EXISTS check_validity_vaccine_dose;
CREATE TRIGGER check_validity_vaccine_dose
BEFORE INSERT ON inoculation
FOR EACH ROW
WHEN EXISTS (SELECT * FROM vaccine WHERE vaccine.id = NEW.vaccine_id AND vaccine.inoculations_number < NEW.inoculation_number) OR NEW.inoculation_number < 0
BEGIN
    SELECT RAISE (ABORT, "The dose of the vaccine is invalid!");
END;

DROP TRIGGER IF EXISTS temp_check_on_transp_to_storehouse_trigger;
CREATE TRIGGER temp_check_on_transp_to_storehouse_trigger
BEFORE INSERT ON transportation
FOR EACH ROW
BEGIN
    SELECT CASE WHEN NOT EXISTS 
    (SELECT * FROM 
     (SELECT storehouse.minimum_temperature, storehouse.maximum_temperature FROM storehouse WHERE storehouse.infrastructure_id = NEW."to") AS storehouse,
     (SELECT vaccine.minimum_temperature, vaccine.maximum_temperature FROM vaccine WHERE vaccine.id = NEW.vaccine_id) AS vaccine
     WHERE (storehouse.minimum_temperature <= vaccine.minimum_temperature
     AND storehouse.maximum_temperature >=  vaccine.minimum_temperature) OR 
     (storehouse.minimum_temperature <= vaccine.maximum_temperature AND
     storehouse.maximum_temperature >= vaccine.maximum_temperature) OR 
     (storehouse.minimum_temperature <= vaccine.maximum_temperature AND storehouse.maximum_temperature IS NULL) OR
    (storehouse.maximum_temperature >= vaccine.minimum_temperature AND storehouse.minimum_temperature IS NULL))
    THEN RAISE(ABORT, "The destiny storehouse does not assure that the vaccines can be stored safely!")                    
    END;
END;