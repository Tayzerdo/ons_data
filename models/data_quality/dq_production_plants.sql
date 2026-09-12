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

    COALESCE(PP.dsc_plant_name, PG.dsc_plant_name) AS dsc_plant_name,

    CASE
        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NOT NULL
            THEN 'Appear everywhere'

        WHEN PP.dsc_plant_name IS NOT NULL
         AND PG.dsc_plant_name IS NULL
            THEN 'Only in power plants'

        WHEN PP.dsc_plant_name IS NULL
         AND PG.dsc_plant_name IS NOT NULL
            THEN 'Only in power generation'
    END AS dsc_plant_presence,

    CASE
        WHEN PP.id_ons_plant IS NULL OR PP.id_ons_plant = '-'
            THEN 'Missing ID'
        ELSE PP.id_ons_plant
    END AS id_ons_power_plants,

    CASE
        WHEN PP.id_aneel_generation_enterprise IS NULL
          OR PP.id_aneel_generation_enterprise = '-'
            THEN 'Missing ID'
        ELSE PP.id_aneel_generation_enterprise
    END AS aneel_id_power_plants,

    CASE
        WHEN PG.id_ons_plant IS NULL OR PG.id_ons_plant = '-'
            THEN 'Missing ID'
        ELSE PG.id_ons_plant
    END AS id_ons_power_generation,

    CASE
        WHEN PG.id_aneel_generation_enterprise IS NULL
          OR PG.id_aneel_generation_enterprise = '-'
            THEN 'Missing ID'
        ELSE PG.id_aneel_generation_enterprise
    END AS aneel_id_power_generation

FROM production_plants AS PP

FULL OUTER JOIN power_generation AS PG
    ON PP.dsc_plant_name = PG.dsc_plant_name