with extract_data as (

    select * from {{ ref('modalidade_usina') }}

)
select 
    *
from extract_data