with staging_data as (
    select * from {{ ref('stg_power_generation') }} -- your renamed model
)

select 
    *
from staging_data
limit 5