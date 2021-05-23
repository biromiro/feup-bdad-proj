PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 3 verification --------";
SELECT "-- Verify if there are enough vaccines in the origin infrastructure and if there is space in the destination";
SELECT "-- infrastructure for a given transportation to occur.";

SELECT "";
SELECT "-- This trigger makes an insertion of a transportation fail in 3 ocasions:";
SELECT "--   1. When the origin infrastructure does not have the transported vaccine;";
SELECT "--   2. When the origin infrastructure has the vaccine, but not in the requested amount;";
SELECT "--   3. When the destination infrastructure does not have enought storage to store the new vaccines;";

SELECT "";
SELECT "-- Starting with the 1st error, unless the initial database was updated, the infrastructure 4 does not have";
SELECT "-- any vaccine. So taking any vaccine from it would generate the first error, so let's do it.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1, 4, 3, 1); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1, 4, 3, 1);

SELECT "";
SELECT "-- Now onto the 2nd error, unless the inital database was updated, the infrastructure 1 has no more than";
SELECT "-- 433056 vaccines of the type 6, let's try to take 1000000 from it.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1000000, 1, 3, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1000000, 1, 3, 6);

SELECT "";
SELECT "-- Now the 3rd error, unless the inital database was updated, the infrastructure 18 has only capacity for";
SELECT "-- 7731 vaccines. Let's see what happens when we try to transport 8000 there.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (8000, 1, 18, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (8000, 1, 18, 6);

SELECT "";
SELECT "-- Let's just do the insanity test, equal to the last one, but transporting only one vaccine.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1, 1, 18, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1, 1, 18, 6);
SELECT "-- If you don't see any error by now it is because it worked! :)";