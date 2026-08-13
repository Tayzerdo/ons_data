with staging_data as (
    select * from {{ ref('stg_geracao_usina_2_ho') }} -- your renamed model
)

select distinct
    din_instante,
    ceg,
    val_geracao
from staging_data