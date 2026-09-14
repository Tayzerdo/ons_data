WITH data AS (
    SELECT *
    FROM {{ ref('dq_production_plants_reconciliation') }}
)

SELECT 
    dsc_plant_presence,
    count(*) AS val_plants_num
FROM data
group by dsc_plant_presence
order by val_plants_num desc