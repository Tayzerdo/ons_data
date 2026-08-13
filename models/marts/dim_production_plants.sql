with staging_data as (
    select * from {{ ref('raw_modalidade_usina') }} -- your renamed model
)

select *
from staging_data