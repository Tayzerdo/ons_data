with staging_data as (
    select * from {{ ref('stg_power_generation') }} -- your renamed model
)

select 
    dtm_power_generation,
    cod_generation_entity_key,
    count(*) as row_numer,
from staging_data
group by all
having row_numer > 1