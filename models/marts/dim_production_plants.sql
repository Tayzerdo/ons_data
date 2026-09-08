with staging_data as (
    select * from {{ ref('stg_modalidade_usina') }} -- your renamed model
)

select *
from staging_data