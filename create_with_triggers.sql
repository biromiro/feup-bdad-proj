BEGIN TRANSACTION;

PRAGMA foreign_keys = on;

DROP TABLE IF EXISTS job_group_vaccination_group;
DROP TABLE IF EXISTS pathology_vaccination_group;
DROP TABLE IF EXISTS pathology_reacts_adversely_to_vaccine;
DROP TABLE IF EXISTS citizen_belongs_to_vaccination_group;
DROP TABLE IF EXISTS vaccination_group_vaccine;
DROP TABLE IF EXISTS citizen_has_pathology;
DROP TABLE IF EXISTS inoculation;
DROP TABLE IF EXISTS district;
DROP TABLE IF EXISTS county;
DROP TABLE IF EXISTS vaccine_storage;
DROP TABLE IF EXISTS transportation;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS zip_code;
DROP TABLE IF EXISTS address;
DROP TABLE IF EXISTS job_group;
DROP TABLE IF EXISTS job;
DROP TABLE IF EXISTS vaccine;
DROP TABLE IF EXISTS pathology;
DROP TABLE IF EXISTS vaccination_group;
DROP TABLE IF EXISTS citizen;
DROP TABLE IF EXISTS infrastructure;
DROP TABLE IF EXISTS storehouse;
DROP TABLE IF EXISTS vaccination_centre;
DROP TABLE IF EXISTS distribution_centre;

CREATE TABLE district (
    id INTEGER,
    name VARCHAR(64) UNIQUE NOT NULL,
    CONSTRAINT district_pk PRIMARY KEY (id)
);

CREATE TABLE county (
    id INTEGER,
    name VARCHAR(64) NOT NULL,
    district_id INTEGER NOT NULL,
    CONSTRAINT county_pk PRIMARY KEY (id),
    CONSTRAINT county_district_fk FOREIGN KEY (district_id) REFERENCES district
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT county_name_unique UNIQUE (name, district_id)
);

CREATE TABLE zip_code (
    id INTEGER,
    zip_code VARCHAR(16) UNIQUE NOT NULL,
    county_id INTEGER NOT NULL,
    CONSTRAINT zip_code_pk PRIMARY KEY (id),
    CONSTRAINT zip_code_county_fk FOREIGN KEY (county_id) REFERENCES county
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE address (
    id INTEGER,
    zip_code_id INTEGER NOT NULL,
    street_name VARCHAR(128) NOT NULL,
    door_number INTEGER,
    CONSTRAINT address_pk PRIMARY KEY (id),
    CONSTRAINT address_zip_code_fk FOREIGN KEY (zip_code_id) REFERENCES zip_code
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT address_door_number_check CHECK (
        door_number IS NULL
        OR door_number >= 1
    ),
    CONSTRAINT address_unique UNIQUE (zip_code_id, street_name, door_number)
);

CREATE TABLE job_group (
    id INTEGER,
    name VARCHAR(32) UNIQUE NOT NULL,
    vaccinated_on_job BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT job_group_pk PRIMARY KEY (id)
);

CREATE TABLE job (
    id INTEGER,
    name VARCHAR(32) NOT NULL,
    group_id INTEGER NOT NULL,
    address_id INTEGER,
    CONSTRAINT job_pk PRIMARY KEY (id),
    CONSTRAINT job_group_fk FOREIGN KEY (group_id) REFERENCES job_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT job_address_fk FOREIGN KEY (address_id) REFERENCES address
        ON DELETE SET NULL
        ON UPDATE RESTRICT,
    CONSTRAINT job_unique UNIQUE (name, group_id, address_id)
);

CREATE TABLE pathology (
    id INTEGER,
    scientific_name VARCHAR(128) UNIQUE NOT NULL,
    common_name VARCHAR(128),
    CONSTRAINT pathology_pk PRIMARY KEY (id)
);

CREATE TABLE vaccine (
    id INTEGER,
    name VARCHAR(128) UNIQUE NOT NULL,
    producer VARCHAR(128) NOT NULL,
    minimum_temperature FLOAT NOT NULL,
    maximum_temperature FLOAT NOT NULL,
    prevents_pathology_id INTEGER NOT NULL,
    inoculations_number INTEGER NOT NULL,
    route VARCHAR(16),
    additional_info VARCHAR(4096),
    CONSTRAINT vaccine PRIMARY KEY (id),
    CONSTRAINT vaccine_prevents_pathology_fk FOREIGN KEY (prevents_pathology_id) REFERENCES pathology
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT vaccine_inoculations_num_check CHECK (inoculations_number > 0),
    CONSTRAINT vaccine_temperature_range_check CHECK (
        minimum_temperature <= maximum_temperature
    )
);

CREATE TABLE vaccination_group (
    id INTEGER,
    minimum_age INTEGER NOT NULL,
    maximum_age INTEGER,
    priority_level INTEGER NOT NULL,
    CONSTRAINT vaccination_group_pk PRIMARY KEY (id),
    CONSTRAINT vaccination_group_age_range_check CHECK (
        minimum_age >= 0
        AND (
            minimum_age <= maximum_age
            OR maximum_age IS NULL
        )
    ),
    CONSTRAINT vaccination_group_priority_level_check CHECK (priority_level >= 0)
);

CREATE TABLE pathology_reacts_adversely_to_vaccine (
    vaccine_id INTEGER,
    pathology_id INTEGER,
    CONSTRAINT pathology_reacts_adversely_to_vaccine_pk PRIMARY KEY (vaccine_id, pathology_id),
    CONSTRAINT pathology_reacts_adversely_to_vaccine_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT pathology_reacts_adversely_to_vaccine_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE citizen (
    id INTEGER,
    citizen_card_number VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(256) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(32) NOT NULL,
    job_id INTEGER,
    address_id INTEGER,
    CONSTRAINT citizen_pk PRIMARY KEY (id),
    CONSTRAINT citizen_job_fk FOREIGN KEY (job_id) REFERENCES job
        ON DELETE SET NULL
        ON UPDATE RESTRICT,
    CONSTRAINT citizen_address_fk FOREIGN KEY (address_id) REFERENCES address
        ON DELETE SET NULL
        ON UPDATE RESTRICT
);

CREATE TABLE job_group_vaccination_group (
    job_group_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT job_group_vaccination_group_pk PRIMARY KEY (job_group_id, vaccination_group_id),
    CONSTRAINT job_group_vaccination_group_job_group_fk FOREIGN KEY (job_group_id) REFERENCES job_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT job_group_vaccination_group_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE pathology_vaccination_group (
    pathology_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT pathology_vaccination_group_pk PRIMARY KEY (pathology_id, vaccination_group_id),
    CONSTRAINT pathology_vaccination_group_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT pathology_vaccination_group_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE vaccination_group_vaccine (
    vaccination_group_id INTEGER,
    vaccine_id INTEGER,
    CONSTRAINT vaccination_group_vaccine_pk PRIMARY KEY (vaccination_group_id, vaccine_id),
    CONSTRAINT vaccination_group_vaccine_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT vaccination_group_vaccine_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE citizen_has_pathology (
    citizen_id INTEGER,
    pathology_id INTEGER,
    CONSTRAINT citizen_has_pathology_pk PRIMARY KEY (citizen_id, pathology_id),
    CONSTRAINT citizen_has_pathology_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT citizen_has_pathology_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE citizen_belongs_to_vaccination_group (
    citizen_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT citizen_has_pathology_pk PRIMARY KEY (citizen_id, vaccination_group_id),
    CONSTRAINT citizen_has_pathology_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT citizen_has_pathology_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE inoculation (
    id INTEGER,
    inoculation_number INTEGER NOT NULL,
    date DATE,
    vaccination_centre_id INTEGER,
    vaccine_id INTEGER NOT NULL,
    citizen_id INTEGER NOT NULL,
    CONSTRAINT inoculation_pk PRIMARY KEY (id),
    CONSTRAINT inoculation_vaccination_centre_fk FOREIGN KEY (vaccination_centre_id) REFERENCES vaccination_centre
        ON DELETE SET NULL
        ON UPDATE RESTRICT,
    CONSTRAINT inoculation_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT inoculation_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT inoculation_number_check CHECK (inoculation_number >= 1),
    CONSTRAINT inoculation_unique UNIQUE (inoculation_number, date, vaccine_id, citizen_id)
);

CREATE TABLE infrastructure (
    id INTEGER,
    address_id INTEGER NOT NULL,
    total_stored_vaccines INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT infrastructure_pk PRIMARY KEY (id),
    CONSTRAINT infrastructure_address_fk FOREIGN KEY (address_id) REFERENCES address
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT infrastructure_total_stored_vaccines_check CHECK (total_stored_vaccines >= 0)
);

CREATE TABLE storehouse (
    infrastructure_id INTEGER,
    maximum_capacity INTEGER,
    minimum_temperature FLOAT,
    maximum_temperature FLOAT,
    CONSTRAINT storehouse_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT storehouse_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT storehouse_maximum_capacity_check CHECK (
        maximum_capacity IS NULL
        OR maximum_capacity > 0
    ),
    CONSTRAINT storehouse_temperature_check CHECK (
        minimum_temperature IS NULL
        OR maximum_temperature IS NULL
        OR maximum_temperature >= minimum_temperature
    )
);

CREATE TABLE distribution_centre (
    infrastructure_id INTEGER,
    CONSTRAINT distribution_centre_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT distribution_centre_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE vaccination_centre (
    infrastructure_id INTEGER,
    CONSTRAINT vaccination_centre_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT vaccination_centre_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure
        ON DELETE CASCADE
        ON UPDATE RESTRICT
);

CREATE TABLE delivery (
    id INTEGER,
    distribution_centre_id INTEGER NOT NULL,
    vaccine_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    arrival_date DATE,
    CONSTRAINT delivery_pk PRIMARY KEY (id),
    CONSTRAINT delivery_distribution_centre_fk FOREIGN KEY (distribution_centre_id) REFERENCES distribution_centre
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT delivery_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT delivery_amount_check CHECK (amount > 0)
);

CREATE TABLE transportation (
    id INTEGER,
    shipment_date DATE,
    arrival_date DATE,
    amount INTEGER NOT NULL,
    "from" INTEGER,
    "to" INTEGER NOT NULL,
    vaccine_id INTEGER NOT NULL,
    CONSTRAINT transportation_pk PRIMARY KEY (id),
    CONSTRAINT transportation_infrastructre_fk1 FOREIGN KEY ("from") REFERENCES infrastructure
        ON DELETE SET NULL
        ON UPDATE RESTRICT,
    CONSTRAINT transportation_infrastructre_fk2 FOREIGN KEY ("to") REFERENCES infrastructure
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT transportation_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT transportation_amount_check CHECK (amount > 0),
    CONSTRAINT transportation_date_check CHECK (
        shipment_date IS NULL
        OR arrival_date IS NULL
        OR arrival_date >= shipment_date
    )
);

CREATE TABLE vaccine_storage (
    vaccine_id INTEGER,
    infrastructure_id INTEGER,
    amount INTEGER,
    CONSTRAINT vaccine_storage_pk PRIMARY KEY (vaccine_id, infrastructure_id),
    CONSTRAINT vaccine_storage_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT vaccine_storage_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure
        ON DELETE CASCADE
        ON UPDATE RESTRICT,
    CONSTRAINT vaccine_storage_storage_amount_check CHECK (
        amount IS NULL
        OR amount >= 0
    )
);

-- Triggers
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

--
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

--
DROP TRIGGER IF EXISTS transportation_vaccine_storage_trigger;
CREATE TRIGGER transportation_vaccine_storage_trigger
AFTER
INSERT ON transportation FOR EACH ROW BEGIN

    INSERT INTO vaccine_storage(infrastructure_id, vaccine_id, amount) 
    SELECT NEW."to", NEW.vaccine_id, 0
    WHERE NOT EXISTS (
        SELECT * FROM vaccine_storage WHERE NEW."to" = vaccine_storage.infrastructure_id AND NEW.vaccine_id = vaccine_storage.vaccine_id
    );  

    UPDATE vaccine_storage
    SET amount = amount - NEW.amount
    WHERE NEW."from" = vaccine_storage.infrastructure_id
        AND NEW.vaccine_id = vaccine_storage.vaccine_id;

    UPDATE vaccine_storage
    SET amount = amount + NEW.amount
    WHERE NEW."to" = vaccine_storage.infrastructure_id
        AND NEW.vaccine_id = vaccine_storage.vaccine_id;

    UPDATE infrastructure
    SET total_stored_vaccines = total_stored_vaccines + NEW.amount
    WHERE NEW."to" = infrastructure.id;

    UPDATE infrastructure
    SET total_stored_vaccines = total_stored_vaccines - NEW.amount
    WHERE NEW."from" = infrastructure.id;

END;

--
DROP TRIGGER IF EXISTS vaccine_transportation_amount_check_trigger;
CREATE TRIGGER vaccine_transportation_amount_check_trigger BEFORE
INSERT ON transportation FOR EACH ROW BEGIN
SELECT CASE
        WHEN NOT EXISTS (
            SELECT *
            FROM infrastructure AS origin
                JOIN vaccine_storage ON vaccine_storage.infrastructure_id = origin.id
            WHERE origin.id = NEW."from"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
        ) THEN RAISE (
            ABORT,
            "The origin infrastructure does not have that vaccine"
        )
        WHEN EXISTS (
            SELECT *
            FROM infrastructure AS origin
                JOIN vaccine_storage ON vaccine_storage.infrastructure_id = origin.id
            WHERE origin.id = NEW."from"
                AND vaccine_storage.vaccine_id = NEW.vaccine_id
                AND vaccine_storage.amount < NEW.amount
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

--
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

--
DROP TRIGGER IF EXISTS temp_check_on_transp_to_storehouse_trigger;
CREATE TRIGGER temp_check_on_transp_to_storehouse_trigger BEFORE
INSERT ON transportation 
FOR EACH ROW
WHEN EXISTS (SELECT * FROM storehouse WHERE NEW."to" = storehouse.infrastructure_id)
BEGIN
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

COMMIT;