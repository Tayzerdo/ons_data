SELECT
    *
FROM {{ source('ons_raw', 'modalidade_usina') }}