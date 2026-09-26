with staging_data as (
    select * from {{ ref('stg_power_generation') }} -- your renamed model
)

select 
    dtm_power_generation,
    sk_generation_entity_key,
    val_power_generation
from staging_data