with staging_data as (
    select * from {{ ref('stg_power_generation') }} -- your renamed model
)
select 
    dtm_power_generation,
    count(*),
    count(case when val_power_generation is null then 1 end),
    count(case when val_power_generation is not null then 1 end),
    count(case when val_power_generation is not null then 1 end)/count(*) as completeness
from staging_data
where 1=1
group by 1
having completeness < 0.95
order by 1 desc