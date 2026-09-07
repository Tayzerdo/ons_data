SELECT
    *
FROM {{ source('ons_raw', 'generation') }}