{{
    config(
        materialized='incremental',
        unique_key=['din_instante', 'id_ons']
    )
}}

with extract_data as (

    select * from {{ ref('geracao_usina_2_ho') }}

)
select 
    *,
    current_timestamp as last_update_date
from extract_data

{% if is_incremental() %}
  -- Filter to only pull rows where the timestamp is newer than what we already have
  where cast(din_instante as date) > (select max(cast(din_instante as date)) from {{ this }})
{% endif %}