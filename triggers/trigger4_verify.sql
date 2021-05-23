PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 4 verification --------";
SELECT "-- Verify if the destination storehouse of new transportation meet the temperature requirements of the vaccine";
SELECT "-- that is transported.";

SELECT "";
SELECT "-- Let's start by checking the temperature requirements of the vaccine 6.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT minimum_temperature, maximum_temperature FROM vaccine WHERE id = 6;

.headers off
.mode column
SELECT "";
SELECT "-- Cool, now let's get some storehouse that is not able to meet these temperature requirements.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT * FROM storehouse WHERE maximum_temperature < -5 LIMIT 1;

.headers off
.mode columns
SELECT "";
SELECT "-- As we can see, the storehouse number 4 cannot meet the vaccine number 6 requirements.";
SELECT "-- Now let's try to transport this vaccine to the storehouse number 4, and see if we get the error.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1, 1, 4, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1, 1, 4, 6);
SELECT "-- If an error appeared, then the trigger is working as expected.";