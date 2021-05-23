PRAGMA foreign_keys = on;
.headers off
.mode column

SELECT "";
SELECT "-------- Trigger 2 verification --------";
SELECT "-- The trigger updates vaccine_storage.amount, and the infrastructure.total_stored_vaccines of both parts";
SELECT "-- whenever a transportation is inserted.";

SELECT "";
SELECT "-- Let's start by seeing the amount of vaccines in infrastructures 1 and 3. Let's also see the amount of";
SELECT "-- the vaccine number 6 in both of them.";
SELECT "-- Running ...";
.headers on
.mode box
SELECT infrastructure_id, vaccine_id, total_stored_vaccines, amount as specified_vaccine_amount
FROM infrastructure JOIN vaccine_storage ON vaccine_storage.infrastructure_id = infrastructure.id
WHERE (infrastructure.id = 1 OR infrastructure.id = 3) AND vaccine_id = 6;

.headers off
.mode column
SELECT "";
SELECT "-- Now we insert a transportation of 5 the vaccines number 6 from the infrastructure number 1 to the";
SELECT "-- infrastructure number 3.";
SELECT "-- Running INSERT INTO transportation(amount, from, to, vaccine_id) VALUES (5, 1, 3, 6); ...";
INSERT INTO transportation(amount, "from", "to", vaccine_id) VALUES (5, 1, 3, 6);

SELECT "";
SELECT "-- Now we can check the numbers again, and we can see that they changed, infrastructure 1 lost 5 vaccines, and";
SELECT "-- infrastructure 3 gains 5 vaccines.";
.headers on
.mode box
SELECT infrastructure_id, vaccine_id, total_stored_vaccines, amount as specified_vaccine_amount
FROM infrastructure JOIN vaccine_storage ON vaccine_storage.infrastructure_id = infrastructure.id
WHERE (infrastructure.id = 1 OR infrastructure.id = 3) AND vaccine_id = 6;