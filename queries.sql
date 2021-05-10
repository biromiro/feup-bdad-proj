-- pessoas que estejam num determinado priority level para uma vacina
select citizen.citizen_card_number, citizen.name
from vaccination_group
    join citizen_belongs_to_vaccination_group on citizen_belongs_to_vaccination_group.vaccination_group_id = vaccination_group.id
    join citizen on citizen.id = citizen_belongs_to_vaccination_group.citizen_id
    join vaccination_group_vaccine on vaccination_group_vaccine.vaccination_group_id = vaccination_group.id
    join vaccine on vaccine.id = vaccination_group_vaccine.vaccine_id
where vaccination_group.priority_level = 1 and vaccine.name = 'Pfizer-BioNTech';

-- perguntar quantas doses administradas para uma certa patologia
-- fiz desta forma porque passar o nome de uma patologia mesmo é :\ porque nomes grandes tipo Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)
select pathology.scientific_name, pathology.common_name, count(*) as inoculations
from inoculation
    join vaccine on vaccine.id = inoculation.vaccine_id
    join pathology on pathology.id = vaccine.prevents_pathology_id
group by pathology.common_name;

-- perguntar quantas inoculações faltam para a dosagem completa e quantas tem de uma vacina para uma certa pessoa
-- pode haver loop, tipo tomar 1, 2, 3, 4, 5, 1, 2 (estas duas ultimos no ano seguinte ou assim), entao tem de dizer que sao 5 e faltam 3
select vaccine.inoculations_number - inoculation.inoculation_number as remaining_inoculations, vaccine.inoculations_number as total_inoculations
from inoculation
    join citizen on citizen.id = inoculation.citizen_id
    join vaccine on vaccine.id = inoculation.vaccine_id
where citizen.citizen_card_number = '1516099575' and vaccine.name = 'Generic'
order by date DESC
limit 1;

-- storehouses acima de 90% da sua capacidade
select id, total_stored_vaccines, maximum_capacity, total_stored_vaccines / cast(maximum_capacity as real) as capacity
from storehouse
    join infrastructure on infrastructure.id = storehouse.infrastructure_id
where total_stored_vaccines / cast(maximum_capacity as real) >= 0.9;

-- inoculações por dia para uma determinada patologia
select pathology.scientific_name, pathology.common_name, (julianday(max(date)) - julianday(min(date))) / count(*) as inoculation_rate
from inoculation
    join vaccine on vaccine.id = inoculation.vaccine_id
    join pathology on pathology.id = vaccine.prevents_pathology_id
group by pathology.id;

-- número de vacinas por cada infrastructure
select *
from infrastructure;