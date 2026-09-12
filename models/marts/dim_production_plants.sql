with staging_data as (
    select * from {{ ref('stg_production_plants') }} -- your renamed model
)

select *
from staging_data