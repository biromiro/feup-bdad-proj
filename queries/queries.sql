-- pessoas que estejam num determinado priority level para uma vacina
select citizen.citizen_card_number, citizen.name
from vaccination_group
    join citizen_belongs_to_vaccination_group on citizen_belongs_to_vaccination_group.vaccination_group_id = vaccination_group.id
    join citizen on citizen.id = citizen_belongs_to_vaccination_group.citizen_id
where vaccination_group.id = 1;

-- perguntar quantas doses administradas para uma certa patologia
-- fiz desta forma porque passar o nome de uma patologia mesmo é :\ porque nomes grandes tipo Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)
select pathology.scientific_name, pathology.common_name, count(*) as inoculations
from inoculation
    join vaccine on vaccine.id = inoculation.vaccine_id
    join pathology on pathology.id = vaccine.prevents_pathology_id
where pathology.id = 56;

-- perguntar quantas inoculações faltam para a dosagem completa e quantas tem de uma vacina para uma certa pessoa
-- pode haver loop, tipo tomar 1, 2, 3, 4, 5, 1, 2 (estas duas ultimos no ano seguinte ou assim), entao tem de dizer que sao 5 e faltam 3
-- select vaccine.id as vaccine_id, vaccine.inoculations_number - inoculation.inoculation_number as remaining_inoculations, vaccine.inoculations_number
select
    vaccine.id as vaccine_id,
    vaccine.name as vaccine_name,
    vaccine.inoculations_number as vaccine_total_inoculations,
    vaccine.inoculations_number - ifnull(inoculation.inoculation_number, 0) as remaining_inoculations,
    ifnull(max(inoculation.date), 'Never') as last_inoculation
from pathology
    join vaccine on vaccine.prevents_pathology_id = pathology.id
    left join (select * from inoculation where citizen_id = 913) as inoculation on inoculation.vaccine_id = vaccine.id
where pathology.id = 56
group by vaccine.id
order by inoculation.date desc;

-- storehouses acima de 90% da sua capacidade
select id, total_stored_vaccines, maximum_capacity, (total_stored_vaccines / cast(maximum_capacity as real) * 100) || '%' as capacity
from storehouse
    join infrastructure on infrastructure.id = storehouse.infrastructure_id
where total_stored_vaccines / cast(maximum_capacity as real) >= 0.9;

-- inoculações por dia para uma determinada patologia
select pathology.id, ((julianday(max(date)) - julianday(min(date))) / count(*)) || ' per day' as inoculation_rate
from inoculation
    join vaccine on vaccine.id = inoculation.vaccine_id
    join pathology on pathology.id = vaccine.prevents_pathology_id
group by pathology.id;

-- número de vacinas por cada infrastructure
select vaccine.id, vaccine.name, ifnull(storage.amount, 0) as amount
from vaccine
    left join (select * from vaccine_storage where infrastructure_id = 48) as storage on storage.vaccine_id = vaccine.id
    left join infrastructure on infrastructure.id = storage.infrastructure_id
order by vaccine.id;

-- perguntar a taxa de pessoas vacinadas para uma certa patologia e quantas tem pelo menos uma dose
DROP VIEW IF EXISTS vaccines;
CREATE VIEW vaccines AS
SELECT vaccine.id
FROM vaccine
WHERE vaccine.prevents_pathology_id = 56;
-- change this ihihi, 56 is covid btw
DROP VIEW IF EXISTS vaccinated;
CREATE VIEW vaccinated AS
SELECT DISTINCT citizen.id
FROM
    inoculation
    JOIN citizen ON inoculation.citizen_id = citizen.id
WHERE
    inoculation.vaccine_id IN vaccines;
---
DROP VIEW IF EXISTS vaccinated_with_doses;
CREATE VIEW vaccinated_with_doses AS
SELECT
    citizen_id,
    inoculation_number,
    vaccine_inoculations_number,
    (
        CASE
            WHEN inoculation_number = vaccine_inoculations_number THEN 1
            ELSE 0
        END
    ) AS fully_vaccinated
FROM
    (
        SELECT
            vaccinated.id AS citizen_id,
            inoculation.date,
            inoculation.inoculation_number,
            vaccine.inoculations_number AS vaccine_inoculations_number,
            MAX(inoculation.date) AS most_recent_date
        FROM
            vaccinated
            JOIN inoculation ON vaccinated.id = inoculation.citizen_id
            JOIN vaccine ON vaccine.id = inoculation.vaccine_id
        GROUP BY
            citizen_id
    );
SELECT
    *
FROM
    vaccinated_with_doses;
---
SELECT
    (
        (
            100.0 * (
                SELECT
                    COUNT(*)
                FROM
                    vaccinated_with_doses
                WHERE
                    fully_vaccinated = 1
            ) / people_count
        ) || '%'
    ) AS fully_vaccinated,
    (
        (
            100.0 * (
                SELECT
                    COUNT(*)
                FROM
                    vaccinated_with_doses
                WHERE
                    fully_vaccinated = 0
            ) / people_count
        ) || '%'
    ) AS at_least_one_those
FROM
    (
        SELECT
            COUNT(*) AS people_count
        FROM
            citizen
    );

-- mine
-- perguntar a taxa de pessoas vacinadas para uma certa patologia e quantas tem pelo menos uma dose
drop view if exists citizen_vaccine_numbers;
create view citizen_vaccine_numbers as
select inoculation.citizen_id,
        vaccine.id as vaccine_id,
        pathology.id as pathology_id,
        count(*) as inoculations_taken,
        vaccine.inoculations_number, vaccine.inoculations_number - count(*) as inoculations_remaining
from inoculation
    join vaccine on vaccine.id = inoculation.vaccine_id
    join pathology on pathology.id = vaccine.prevents_pathology_id
group by inoculation.citizen_id, vaccine.id;

drop view if exists citizens_vaccine_pathologies;
create view citizens_vaccine_pathologies as
select citizen_id, pathology_id, inoculations_taken, min(inoculations_remaining) as inoculations_remaining
from citizen_vaccine_numbers
group by citizen_id, pathology_id;

drop view if exists fully_vaccinated_pathology;
create view fully_vaccinated_pathology as
select pathology_id, count(*) as fully_vaccinated
from citizens_vaccine_pathologies
where inoculations_remaining = 0
group by pathology_id;

drop view if exists at_least_one_vaccinated_pathology;
create view at_least_one_vaccinated_pathology as
select pathology_id, count(*) as one_dose_vaccinated
from citizens_vaccine_pathologies
group by pathology_id;

with citizens as (select cast(count(*) as real) as amount from citizen)
select pathology.id,
        pathology.common_name,
        (ifnull(one_dose_vaccinated, 0) / citizens.amount * 100) || '%' as one_dose_vaccinated,
        (ifnull(fully_vaccinated, 0) / citizens.amount * 100) || '%' as fully_vaccinated
from pathology
    left join fully_vaccinated_pathology on fully_vaccinated_pathology.pathology_id = pathology.id
    left join at_least_one_vaccinated_pathology using(pathology_id),
    citizens;

  a  