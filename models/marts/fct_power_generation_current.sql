with staging_data as (
    select * from {{ ref('stg_power_generation') }} -- your renamed model
), 
max_date AS (
    select max(dtm_power_generation) AS dtm_power_generation
    from {{ ref('stg_power_generation') }} -- your renamed model
)

select 
    SD.*
from staging_data AS SD
INNER JOIN max_date AS MD
    ON SD.dtm_power_generation = MD.dtm_power_generation