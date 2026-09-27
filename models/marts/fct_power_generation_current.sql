with staging_data as (
    select * from {{ ref('int_power_generation') }} -- your renamed model
), 
max_date AS (
    select max(dtm_power_generation) AS dtm_power_generation
    from {{ ref('int_power_generation') }} -- your renamed model
)

select 
    SD.dtm_power_generation,
    SD.cod_generation_entity_key,
    SD.val_power_generation
from staging_data AS SD
INNER JOIN max_date AS MD
    ON SD.dtm_power_generation = MD.dtm_power_generation