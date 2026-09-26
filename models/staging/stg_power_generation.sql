WITH CTE AS (

    SELECT *
    FROM {{ source('ons_raw', 'generation') }}

)

SELECT
    din_instante AS dtm_power_generation,
    concat(
        replace(lower(trim(nom_usina)), ' ','') 
        , '_' 
        , ifnull(trim(lower(nullif(id_ons, '-'))), 'unknown')
        , '_' 
        , ifnull(trim(lower(nullif(ceg, '-'))), 'unknown')
    ) AS sk_generation_entity_key,
    trim(lower(nullif(id_ons, '-'))) AS id_ons_plant,
    trim(lower(nullif(ceg, '-'))) AS id_aneel_generation_enterprise,
    nom_tipousina AS dsc_plant_type,
    nom_tipocombustivel AS dsc_fuel_type,
    nom_usina AS dsc_plant_name,
    id_subsistema AS id_subsystem,
    nom_subsistema AS dsc_subsystem_name,
    val_geracao AS val_power_generation
FROM CTE