WITH production_plants AS (

    SELECT DISTINCT
        dsc_plant_name,
        id_ons_plant,
        id_aneel_generation_enterprise
    FROM {{ ref('stg_production_plants') }}

),

power_generation AS (

    SELECT DISTINCT
        dsc_plant_name,
        id_ons_plant,
        id_aneel_generation_enterprise
    FROM {{ ref('stg_power_generation') }}

)

SELECT

    COALESCE(
        PP.dsc_plant_name,
        PG.dsc_plant_name
    ) AS dsc_plant_name,

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
    END AS dsc_plant_presence,
    CASE
        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NOT NULL
         AND PP.id_ons_plant = PG.id_ons_plant
            THEN 'Match'
    END AS id_ons_match,
    CASE
        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NOT NULL
         AND PP.id_aneel_generation_enterprise = PG.id_aneel_generation_enterprise
            THEN 'Match'
    END AS id_aneel_match,


FROM production_plants AS PP

FULL OUTER JOIN power_generation AS PG
    ON PP.dsc_plant_name = PG.dsc_plant_name
order by 4