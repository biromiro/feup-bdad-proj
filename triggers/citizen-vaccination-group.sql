--ttrigger para quando o job do citizen é alterado, alterar o vaxx group
DROP TRIGGER IF EXISTS update_citizen_group_on_job_change;
CREATE TRIGGER update_citizen_group_on_job_change AFTER
UPDATE ON citizen
FOR EACH ROW
BEGIN
    CASE
        WHEN EXISTS(
            SELECT *
        )
END;