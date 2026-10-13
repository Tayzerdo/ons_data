WITH data AS (
    SELECT *
    FROM {{ ref('dim_power_generation_information') }}
)

select 
    cod_generation_entity_key,
    SUM(case when is_current = TRUE THEN 1 END) as true_quantity,
    SUM(case when is_current = FALSE THEN 1 END) as false_quantity
from data
where cod_generation_entity_key='amelc_ute.pe.am.027120-9.01'
GROUP BY 1