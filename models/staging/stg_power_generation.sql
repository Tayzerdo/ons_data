WITH CTE AS (

    SELECT *
    FROM {{ source('ons_raw', 'generation') }}

), final AS (
    SELECT
        din_instante AS dtm_power_generation,
        trim(lower(nullif(id_ons, '-'))) AS id_ons_plant,
        trim(lower(nullif(ceg, '-'))) AS id_aneel_generation_enterprise,
        nom_tipousina AS dsc_plant_type,
        nom_tipocombustivel AS dsc_fuel_type,
        lower(trim(nom_usina)) AS dsc_plant_name,
        id_subsistema AS id_subsystem,
        nom_subsistema AS dsc_subsystem_name,
        val_geracao AS val_power_generation
    FROM CTE
)
select 
    dtm_power_generation,
    CASE 
        WHEN id_ons_plant is not null and id_aneel_generation_enterprise is not null
            THEN concat(id_ons_plant,'_',id_aneel_generation_enterprise)
        WHEN id_ons_plant is not null and id_aneel_generation_enterprise is null
            THEN concat(id_ons_plant,'_',replace(dsc_plant_name,' ',''))
        WHEN id_ons_plant is null and id_aneel_generation_enterprise is not null
            THEN concat(id_aneel_generation_enterprise,'_',replace(dsc_plant_name,' ',''))
        ELSE replace(dsc_plant_name,' ','')
    END AS cod_generation_entity_key,
    id_ons_plant,
    id_aneel_generation_enterprise,
    dsc_plant_name,
    dsc_plant_type,
    dsc_fuel_type,
    id_subsystem,
    dsc_subsystem_name,
    val_power_generation
from final