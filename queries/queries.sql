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