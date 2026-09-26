with stg_production_plants as (
    select * from {{ ref('stg_production_plants') }} -- your renamed model
),
stg_power_generation as (
    select 
        distinct sk_generation_entity_key,
        id_ons_plant,
        id_aneel_generation_enterprise,
        dsc_plant_name,
        dsc_plant_type,
        id_subsystem
    from {{ ref('stg_power_generation') }}
)

SELECT 
    coalesce(PP.sk_generation_entity_key, PG.sk_generation_entity_key) as sk_generation_entity_key,
    coalesce(PP.id_ons_plant, PG.id_ons_plant) as id_ons_plant,
    coalesce(PP.id_aneel_generation_enterprise, PG.id_aneel_generation_enterprise) as id_aneel_generation_enterprise,
    coalesce(PP.dsc_plant_name, PG.dsc_plant_name) as dsc_plant_name,
    PP.dsc_operational_modality,
    PP.cod_operational_center,
    PP.dsc_connection_point,
    PP.id_state,
    PP.dsc_state_name,
    PP.id_aneel_status,
    PG.dsc_plant_type,
    PG.id_subsystem,
    PP.val_authorized_power
FROM stg_production_plants PP
FULL OUTER JOIN stg_power_generation PG
     ON PG.sk_generation_entity_key = PP.sk_generation_entity_key