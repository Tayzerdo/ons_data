with staging_data as (
    select *
    from {{ ref('stg_power_generation') }}
    --where id_ons_plant = 'papi' -- your renamed model
), cte AS (
    
    select 
        cod_generation_entity_key,
        id_ons_plant,
        id_aneel_generation_enterprise,
        dsc_plant_name,
        dsc_plant_type,
        dsc_fuel_type,
        id_subsystem,
        dsc_subsystem_name, 
        min(dtm_power_generation) AS first_generation,
        max(dtm_power_generation) AS last_generation,
    from staging_data
    where 1=1
    group by all
    order by cod_generation_entity_key, first_generation
)

select
    cte.*,
    CASE
        WHEN row_number() over (partition by cod_generation_entity_key order by last_generation desc) = 1
            and lead(last_generation) over(PARTITION BY cod_generation_entity_key) <= first_generation
    THEN true
    else FALSE
    end as is_current
from cte
