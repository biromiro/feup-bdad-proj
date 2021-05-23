.headers on
.mode column
.nullvalue NULL

SELECT citizen.citizen_card_number,
    citizen.name
FROM vaccination_group
    JOIN citizen_belongs_to_vaccination_group ON citizen_belongs_to_vaccination_group.vaccination_group_id = vaccination_group.id
    JOIN citizen ON citizen.id = citizen_belongs_to_vaccination_group.citizen_id
WHERE vaccination_group.id = 1;