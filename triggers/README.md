# Triggers

## Table of contents

### Trigger 1: Restriction 8b) - A transportation can not be held to a Distribution Centre

```sql
DROP TRIGGER IF EXISTS transportation_destination_check_trigger;
CREATE TRIGGER transportation_destination_check_trigger
BEFORE INSERT ON transportation
FOR EACH ROW
BEGIN
    select CASE WHEN EXISTS (SELECT * from distribution_centre WHERE distribution_centre.infrastructure_id = NEW."to") THEN
        RAISE (abort, "The destination of a transporation must not be a distribution centre")
    END;
END;
```

### Trigger 2: Maintain vaccine storage with every transportation

```sql
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
END;
```
