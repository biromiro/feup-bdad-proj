PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 6 verification --------";
SELECT "-- Keep the storage of an infrastructure updated according to the delivery associated with a distribution";
SELECT "-- center.";

SELECT "";
SELECT "-- Let's start by seeing the amount of vaccines in infrastructure 1. Let's also see the amount of the vaccine";
SELECT "-- number 7 there.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT infrastructure_id, vaccine_id, total_stored_vaccines, amount as specified_vaccine_amount
FROM infrastructure LEFT JOIN vaccine_storage ON vaccine_storage.infrastructure_id = infrastructure.id
WHERE infrastructure.id = 1 AND vaccine_id = 7;
.headers off
.mode columns

SELECT "";
SELECT "-- Nothing was returned. Let's deliver some vaccines there.";
SELECT "-- Runnning INSERT INTO delivery(distribution_centre_id, vaccine_id, amount) VALUES(1, 7, 1); ...";
INSERT INTO delivery(distribution_centre_id, vaccine_id, amount) VALUES(1, 7, 1);

SELECT "";
SELECT "-- Now onto checking the numbers again.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT infrastructure_id, vaccine_id, total_stored_vaccines, amount as specified_vaccine_amount
FROM infrastructure LEFT JOIN vaccine_storage ON vaccine_storage.infrastructure_id = infrastructure.id
WHERE infrastructure.id = 1 AND vaccine_id = 7;
.headers off
.mode columns

SELECT "";
SELECT "-- Yass! The vaccine is there! Let's deliver a thousand more now in order to see if it works when the";
SELECT "distribution centre already has vaccines.";
SELECT "-- Runnning INSERT INTO delivery(distribution_centre_id, vaccine_id, amount) VALUES(1, 7, 1000); ...";
INSERT INTO delivery(distribution_centre_id, vaccine_id, amount) VALUES(1, 7, 1000);

SELECT "";
SELECT "Now checking the numbers one last time...";
SELECT "-- Running ...";
.headers on
.mode box
SELECT infrastructure_id, vaccine_id, total_stored_vaccines, amount as specified_vaccine_amount
FROM infrastructure LEFT JOIN vaccine_storage ON vaccine_storage.infrastructure_id = infrastructure.id
WHERE infrastructure.id = 1 AND vaccine_id = 7;
.headers off
.mode columns