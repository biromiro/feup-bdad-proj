PRAGMA foreign_keys = on;
DROP TABLE IF EXISTS job_group_vaccination_group;
DROP TABLE IF EXISTS pathology_vaccination_group;
DROP TABLE IF EXISTS pathology_reacts_adversely_to_vaccine;
DROP TABLE IF EXISTS citizen_belogs_to_vaccination_group;
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
    CONSTRAINT district_id_fk FOREIGN KEY (district_id) REFERENCES district ON DELETE CASCADE,
    CONSTRAINT name_unique UNIQUE (name, district_id)
);

CREATE TABLE zip_code (
    id INTEGER,
    zip_code VARCHAR(16) UNIQUE NOT NULL,
    county_id INTEGER,
    CONSTRAINT zip_code_pk PRIMARY KEY (id),
    CONSTRAINT county_id_fk FOREIGN KEY (county_id) REFERENCES county ON DELETE
    SET NULL
);

CREATE TABLE address (
    id INTEGER,
    zip_code_id INTEGER,
    street_name VARCHAR(128) NOT NULL,
    door_number INTEGER,
    CONSTRAINT address_pk PRIMARY KEY (id),
    CONSTRAINT zip_code_id_fk FOREIGN KEY (zip_code_id) REFERENCES zip_code ON DELETE
    SET NULL,
    CONSTRAINT door_number_check CHECK (
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
    name VARCHAR(32) UNIQUE NOT NULL,
    group_id INTEGER,
    address_id INTEGER NOT NULL,
    CONSTRAINT job_pk PRIMARY KEY (id),
    CONSTRAINT group_id_fk FOREIGN KEY (group_id) REFERENCES job_group ON DELETE
    SET NULL,
    CONSTRAINT address_id_fk FOREIGN KEY (address_id) REFERENCES address,
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
    CONSTRAINT prevents_pathology_id_fk FOREIGN KEY (prevents_pathology_id) REFERENCES pathology ON DELETE CASCADE,
    CONSTRAINT inoculations_num_check CHECK (inoculations_number >= 0),
    CONSTRAINT temperature_range_check CHECK (
        minimum_temperature <= maximum_temperature
    ),
    CONSTRAINT vaccine_unique UNIQUE (name, producer)
);

CREATE TABLE vaccination_group (
    id INTEGER,
    minimum_age INTEGER NOT NULL,
    maximum_age INTEGER,
    priority_level INTEGER NOT NULL,
    CONSTRAINT vaccination_group_pk PRIMARY KEY (id),
    CONSTRAINT age_range_check CHECK (
        minimum_age >= 0
        AND minimum_age <= maximum_age
    ),
    CONSTRAINT priority_level_check CHECK (priority_level >= 0)
);

CREATE TABLE pathology_reacts_adversely_to_vaccine (
    vaccine_id INTEGER,
    pathology_id INTEGER,
    CONSTRAINT pathology_reacts_adversely_to_vaccine_pk PRIMARY KEY (vaccine_id, pathology_id),
    CONSTRAINT pathology_reacts_adversely_to_vaccine_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE,
    CONSTRAINT pathology_reacts_adversely_to_vaccine_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology ON DELETE CASCADE
);

CREATE TABLE citizen (
    id INTEGER,
    citizen_card_number VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(256) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(32) NOT NULL,
    job_id INTEGER,
    address_id INTEGER NOT NULL,
    CONSTRAINT citizen_pk PRIMARY KEY (id),
    CONSTRAINT citizen_job_fk FOREIGN KEY (job_id) REFERENCES job ON DELETE
    SET NULL
);

CREATE TABLE job_group_vaccination_group (
    job_group_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT job_group_vaccination_group_pk PRIMARY KEY (job_group_id, vaccination_group_id),
    CONSTRAINT job_group_vaccination_group_job_group_fk FOREIGN KEY (job_group_id) REFERENCES job_group ON DELETE CASCADE,
    CONSTRAINT job_group_vaccination_group_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group ON DELETE CASCADE
);

CREATE TABLE pathology_vaccination_group (
    pathology_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT pathology_vaccination_group_pk PRIMARY KEY (pathology_id, vaccination_group_id),
    CONSTRAINT pathology_vaccination_group_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology ON DELETE CASCADE,
    CONSTRAINT pathology_vaccination_group_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group ON DELETE CASCADE
);

CREATE TABLE vaccination_group_vaccine (
    vaccination_group_id INTEGER,
    vaccine_id INTEGER,
    CONSTRAINT vaccination_group_vaccine_pk PRIMARY KEY (vaccination_group_id, vaccine_id),
    CONSTRAINT vaccination_group_vaccine_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group ON DELETE CASCADE,
    CONSTRAINT vaccination_group_vaccine_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE
);

CREATE TABLE citizen_has_pathology (
    citizen_id INTEGER,
    pathology_id INTEGER,
    CONSTRAINT citizen_has_pathology_pk PRIMARY KEY (citizen_id, pathology_id),
    CONSTRAINT citizen_has_pathology_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen ON DELETE CASCADE,
    CONSTRAINT citizen_has_pathology_pathology_fk FOREIGN KEY (pathology_id) REFERENCES pathology ON DELETE CASCADE
);

CREATE TABLE citizen_belogs_to_vaccination_group (
    citizen_id INTEGER,
    vaccination_group_id INTEGER,
    CONSTRAINT citizen_has_pathology_pk PRIMARY KEY (citizen_id, vaccination_group_id),
    CONSTRAINT citizen_has_pathology_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen ON DELETE CASCADE,
    CONSTRAINT citizen_has_pathology_vaccination_group_fk FOREIGN KEY (vaccination_group_id) REFERENCES vaccination_group ON DELETE CASCADE
);

CREATE TABLE inoculation (
    id INTEGER,
    inoculation_number INTEGER NOT NULL,
    date DATE,
    vaccination_centre_id INTEGER,
    vaccine_id INTEGER NOT NULL,
    citizen_id INTEGER NOT NULL,
    CONSTRAINT inoculation_pk PRIMARY KEY (id),
    CONSTRAINT inoculation_unique UNIQUE (inoculation_number, date, vaccine_id, citizen_id),
    CONSTRAINT inoculation_vaccination_centre_fk FOREIGN KEY (vaccination_centre_id) REFERENCES vaccination_centre ON DELETE
    SET NULL,
    CONSTRAINT inoculation_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE,
    CONSTRAINT inoculation_citizen_fk FOREIGN KEY (citizen_id) REFERENCES citizen ON DELETE CASCADE,
    CONSTRAINT inoculation_number_check CHECK (inoculation_number >= 1)
);

CREATE TABLE infrastructure (
    id INTEGER,
    address_id INTEGER,
    total_stored_vaccines INTEGER,
    CONSTRAINT infrastructure_pk PRIMARY KEY (id),
    CONSTRAINT infrastructure_address_fk FOREIGN KEY (address_id) REFERENCES address ON DELETE
    SET NULL
);

CREATE TABLE storehouse (
    infrastructure_id INTEGER,
    maximum_capacity INTEGER,
    minimum_temperature FLOAT,
    maximum_temperature FLOAT,
    CONSTRAINT storehouse_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT storehouse_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure ON DELETE CASCADE,
    CONSTRAINT temperature_check CHECK (
        minimum_temperature IS NULL
        OR maximum_temperature IS NULL
        OR maximum_temperature >= minimum_temperature
    )
);

CREATE TABLE distribution_centre (
    infrastructure_id INTEGER,
    CONSTRAINT distribution_centre_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT distribution_centre_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure ON DELETE CASCADE
);

CREATE TABLE vaccination_centre (
    infrastructure_id INTEGER,
    CONSTRAINT vaccination_centre_pk PRIMARY KEY (infrastructure_id),
    CONSTRAINT vaccination_centre_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure ON DELETE CASCADE
);

CREATE TABLE delivery (
    distribution_centre_id INTEGER,
    vaccine_id INTEGER NOT NULL,
    amount INTEGER NOT NULL,
    arrival_date DATE,
    CONSTRAINT delivery_pk PRIMARY KEY (distribution_centre_id, vaccine_id),
    CONSTRAINT delivery_distribution_centre_fk FOREIGN KEY (distribution_centre_id) REFERENCES distribution_centre ON DELETE CASCADE,
    CONSTRAINT delivery_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE,
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
    CONSTRAINT transportation_infrastructre_fk1 FOREIGN KEY ("from") REFERENCES infrastructure ON DELETE
    SET NULL,
    CONSTRAINT transportation_infrastructre_fk2 FOREIGN KEY ("to") REFERENCES infrastructure ON DELETE CASCADE,
    CONSTRAINT transportation_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE,
    CONSTRAINT transportation_amount_check CHECK (amount > 0)
);

CREATE TABLE vaccine_storage (
    vaccine_id INTEGER,
    infrastructure_id INTEGER,
    amount INTEGER,
    CONSTRAINT vaccine_storage_pk PRIMARY KEY (vaccine_id, infrastructure_id),
    CONSTRAINT vaccine_storage_vaccine_fk FOREIGN KEY (vaccine_id) REFERENCES vaccine ON DELETE CASCADE,
    CONSTRAINT vaccine_storage_infrastructure_fk FOREIGN KEY (infrastructure_id) REFERENCES infrastructure ON DELETE CASCADE,
    CONSTRAINT storage_amount_check CHECK (
        amount IS NULL
        OR amount >= 0
    )
);