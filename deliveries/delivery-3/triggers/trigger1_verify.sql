PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 1 verification --------";
SELECT "-- Before inserting a transportation, if the destination infrastructure is a distribution centre, aborts the insertion.";

SELECT "";
SELECT "-- The next insert should fail, infrastructure nr 2 is a distribution centre.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1, 1, 2, 3); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1, 1, 2, 3);

SELECT "";
SELECT "-- The next insert should pass, since infrastructure nr 3 is a storehouse.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (1, 1, 3, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (1, 1, 3, 6);

SELECT "";
SELECT "-- Showing the last 2 transporations:";
.headers on
.mode box
SELECT * FROM transportation ORDER BY id DESC LIMIT 2;
.headers off
.mode column
SELECT "-- There we can see the transportation from 1 to 3, but not the one from 1 to 2.";