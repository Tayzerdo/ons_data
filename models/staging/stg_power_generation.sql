WITH CTE AS (

    SELECT *
    FROM {{ source('ons_raw', 'generation') }}

)

SELECT
    din_instante AS dtm_power_generation,
    id_subsistema AS id_subsystem,
    nom_subsistema AS dsc_subsystem_name,
    nom_tipousina AS dsc_plant_type,
    nom_tipocombustivel AS dsc_fuel_type,
    val_geracao AS val_power_generation

FROM CTE