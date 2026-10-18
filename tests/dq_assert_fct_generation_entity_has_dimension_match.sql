with fct_power_generation as (
    select distinct cod_generation_entity_key as cod_generation_entity_key 
    from {{ ref('fct_power_generation') }} -- your renamed model
), dim_power_generation_information as (
    select distinct cod_generation_entity_key as cod_generation_entity_key 
    from {{ ref('dim_power_generation_information') }} -- your renamed model
)


select 
    FPG.cod_generation_entity_key
from fct_power_generation AS FPG
WHERE NOT EXISTS (select DPGI.cod_generation_entity_key 
                from dim_power_generation_information DPGI 
                WHERE DPGI.cod_generation_entity_key = FPG.cod_generation_entity_key)