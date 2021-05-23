DROP TRIGGER IF EXISTS check_validity_vaccine_dose;
CREATE TRIGGER check_validity_vaccine_dose BEFORE
INSERT ON inoculation FOR EACH ROW
    WHEN EXISTS (
        SELECT *
        FROM vaccine
        WHERE vaccine.id = NEW.vaccine_id
            AND vaccine.inoculations_number < NEW.inoculation_number
    )
    OR NEW.inoculation_number <= 0 BEGIN
SELECT RAISE (ABORT, "The dose of the vaccine is invalid!");
END;