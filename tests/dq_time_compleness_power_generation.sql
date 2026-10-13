WITH data AS (
    SELECT *
    FROM {{ ref('stg_power_generation') }}
)

SELECT
    id_ons_plant,
    id_aneel_generation_enterprise,
    dtm_power_generation,
    count(*) as records
FROM data
where 1=1
    and id_ons_plant is not null
    or id_aneel_generation_enterprise <> '-'
group by all
having records > 1
