WITH data AS (
    SELECT *
    FROM {{ ref('dq_production_plants_reconciliation') }}
)

SELECT 
    dsc_plant_presence,
    count(*) AS total_records,
    sum(
        case when id_ons_plant is null THEN 1 
    END) AS id_ons_missing,
    ROUND( 
        100 * sum(case when id_ons_plant is null THEN 1 END)/count(*)
    , 2 ) AS pct_id_ons_missing,
    sum(
        case when id_aneel_generation_enterprise is null THEN 1 
    END) as id_aneel_missing,
    ROUND( 
        100 * sum(case when id_aneel_generation_enterprise is null THEN 1 END)/count(*)
    , 2 ) AS pct_id_aneel_missing,
FROM data
group by dsc_plant_presence