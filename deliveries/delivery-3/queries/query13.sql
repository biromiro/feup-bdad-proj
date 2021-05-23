.headers on
.mode column
.nullvalue NULL

DROP VIEW IF EXISTS patients;
CREATE VIEW patients AS
SELECT citizen_has_pathology.citizen_id
FROM citizen_has_pathology
WHERE citizen_has_pathology.pathology_id = 56;
DROP VIEW IF EXISTS patients_job_group;

CREATE VIEW patients_job_group AS
SELECT job.group_id,
    COUNT(*) AS patients
FROM patients
    LEFT JOIN citizen ON citizen.id = patients.citizen_id
    JOIN job ON job.id = citizen.job_id
WHERE citizen.id IN patients
GROUP BY job.group_id;

DROP VIEW IF EXISTS people_per_job_group;
CREATE VIEW people_per_job_group AS
SELECT job.group_id,
    COUNT(*) AS people_count
FROM job
    LEFT JOIN citizen ON citizen.job_id = job.id
GROUP BY job.group_id;

SELECT name,
    ((patients * 100.0 / people_count) || '%') AS has_pathology_percentage
FROM (
        SELECT job_group.name,
            people_per_job_group.*,
            IFNULL(patients, 0) AS patients
        FROM people_per_job_group
            LEFT JOIN patients_job_group ON patients_job_group.group_id = people_per_job_group.group_id
            JOIN job_group ON people_per_job_group.group_id = job_group.id
    );