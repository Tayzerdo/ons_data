WITH data AS (
    SELECT *
    FROM {{ ref('dim_power_generation_information') }}
)

select 
    cod_generation_entity_key,
    SUM(case when is_current = TRUE THEN 1 ELSE 0 END) as true_quantity,
    SUM(case when is_current = FALSE THEN 1 ELSE 0 END) as false_quantity
from data
GROUP BY 1
having true_quantity <> 1