WITH CTE AS (

    SELECT *
    FROM {{ source('ons_raw', 'generation') }}

)

SELECT
    din_instante AS dtm_power_generation,
    nom_tipousina AS dsc_plant_type,
    nom_tipocombustivel AS dsc_fuel_type,
    nom_usina AS dsc_plant_name,
    id_subsistema AS id_subsystem,
    nom_subsistema AS dsc_subsystem_name,
    val_geracao AS val_power_generation

FROM CTE