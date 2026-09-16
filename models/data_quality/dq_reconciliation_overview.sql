WITH data AS (
    SELECT *
    FROM {{ ref('dq_production_plants_reconciliation') }}
)

SELECT 
    dsc_plant_presence,
    count(*) AS val_plants_num,
    ROUND( 
        100 * count(*) / SUM(COUNT(*)) OVER() 
    , 2) AS pct_records
FROM data
group by dsc_plant_presence
order by val_plants_num desc