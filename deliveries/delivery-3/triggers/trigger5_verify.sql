PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 5 verification --------";
SELECT "-- Verify if an inoculation number is in the range of the number of inoculations of a given vaccine.";

SELECT "";
SELECT "-- Let's start by checking the number of inoculations for the vaccine number 6.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT id, inoculations_number FROM vaccine WHERE id = 6;
.headers off
.mode column

SELECT "";
SELECT "-- Now, just inserting an inoculation with the number larger than 5, should trigger the trigger, and abort the";
SELECT "-- operation.";
SELECT "-- Running INSERT INTO inoculation (inoculation_number, vaccine_id, citizen_id) VALUES (10, 6, 1); ...";
INSERT INTO inoculation (inoculation_number, vaccine_id, citizen_id) VALUES (10, 6, 1);

SELECT "";
SELECT "-- Let's just insert a valid inoculation for sanity check.";
SELECT "-- Running INSERT INTO inoculation (inoculation_number, vaccine_id, citizen_id) VALUES (1, 6, 1); ...";
INSERT INTO inoculation (inoculation_number, vaccine_id, citizen_id) VALUES (1, 6, 1);
SELECT "-- If you don't see any error by now it is because it worked! :)";