WITH CTE AS (
    SELECT *
    FROM {{ source('ons_raw', 'modalidade_usina') }}
)

SELECT
    id_ons AS id_ons_plant,
    ceg AS id_aneel_generation_enterprise,
    nom_usina AS dsc_plant_name,
    nom_modalidadeoperacao AS dsc_operational_modality,
    val_potenciaautorizada AS val_authorized_power,
    sgl_centrooperacao AS cod_operational_center,
    nom_pontoconexao AS dsc_connection_point,
    id_estado AS id_state,
    nom_estado AS dsc_state_name,
    sts_aneel AS id_aneel_status,
     CASE
        WHEN sts_aneel = 'A' THEN 'Active'
        WHEN sts_aneel = 'I' THEN 'Inactive'
        WHEN sts_aneel = 'P' THEN 'Planned'
        WHEN sts_aneel = 'C' THEN 'Cancelled'
        WHEN sts_aneel = 'O' THEN 'Other'
        ELSE 'Unknown'
    END AS dsc_aneel_status,
    
FROM CTE