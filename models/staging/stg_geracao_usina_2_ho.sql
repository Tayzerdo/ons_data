with source AS (
    select * from {{ ref('raw_geracao_usina_2_ho') }}
),
renamed as (
    select 
        din_instante,
        ceg,
        id_ons,
        id_subsistema,
        id_estado,
        cod_modalidadeoperacao as cod_modalidade_operacao,
        nom_subsistema,
        nom_estado,
        nom_tipousina as nom_tipo_usina,
        nom_tipocombustivel as nom_tipo_combustivel,
        nom_usina,
        val_geracao

    from source
)

select *
from renamed