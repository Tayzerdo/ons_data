with stg_power_generation as (
    select * from {{ ref('stg_power_generation') }}
)

select *
from stg_power_generation
where 1=1

