WITH CTE AS (

    SELECT *
    FROM {{ source('ons_raw', 'generation') }}

)

SELECT
    din_instante AS dtm_power_generation,
    id_subsistema AS id_subsystem,
    nom_subsistema AS dsc_subsystem_name,
    id_estado AS id_state,
    nom_estado AS dsc_state_name,
    cod_modalidadeoperacao AS cod_operation_modality,
    nom_tipousina AS dsc_plant_type,
    nom_tipocombustivel AS dsc_fuel_type,
    nom_usina AS dsc_plant_name,
    id_ons AS id_ons_plant,
    ceg AS id_aneel_generation_enterprise,
    val_geracao AS val_power_generation

FROM CTE