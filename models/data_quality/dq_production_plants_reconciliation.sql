WITH production_plants AS (

    SELECT DISTINCT
        dsc_plant_name,
        id_ons_plant,
        id_aneel_generation_enterprise,
        dsc_aneel_status
    FROM {{ ref('stg_production_plants') }}

),

power_generation AS (

    SELECT DISTINCT
        dsc_plant_name,
        id_ons_plant,
        id_aneel_generation_enterprise,
        null as dsc_aneel_status
    FROM {{ ref('stg_power_generation') }}

)

SELECT

    COALESCE(
        PP.dsc_plant_name,
        PG.dsc_plant_name
    ) AS dsc_plant_name,

    COALESCE(
        PP.dsc_aneel_status,
        PG.dsc_aneel_status
    ) AS dsc_aneel_status,

    COALESCE(
        PP.id_ons_plant,
        PG.id_ons_plant
    ) AS id_ons_plant,

    COALESCE(
        PP.id_aneel_generation_enterprise,
        PG.id_aneel_generation_enterprise
    ) AS id_aneel_generation_enterprise,

    CASE
        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NOT NULL
            THEN 'Both'

        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NULL
            THEN 'Only plants'

        WHEN PP.dsc_plant_name IS NULL
         AND PG.dsc_plant_name IS NOT NULL
            THEN 'Only generation'
    END AS dsc_plant_presence

FROM production_plants AS PP

FULL OUTER JOIN power_generation AS PG
    ON PP.id_aneel_generation_enterprise = PG.id_aneel_generation_enterprise
    AND PP.id_ons_plant = PG.id_ons_plant
--order by 4