
WITH fct_power_generation_current AS (
    SELECT
        MAX(dtm_power_generation) AS max_date,
        COUNT(DISTINCT dtm_power_generation) AS row_count
    FROM {{ ref('fct_power_generation_current') }}
),
stg_power_generation AS (
    SELECT
        MAX(dtm_power_generation) AS max_date
    FROM {{ ref('stg_power_generation') }}
)

SELECT FPGC.max_date
FROM fct_power_generation_current FPGC
CROSS JOIN stg_power_generation SPG
WHERE
    FPGC.max_date <> SPG.max_date
    OR FPGC.row_count <> 1
    OR SPG.max_date IS NULL
