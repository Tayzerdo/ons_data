with staging_data as (
    select * from {{ ref('stg_production_plants') }} -- your renamed model
)

select *
from staging_data
--where id_ons_plant = 'pislb1'