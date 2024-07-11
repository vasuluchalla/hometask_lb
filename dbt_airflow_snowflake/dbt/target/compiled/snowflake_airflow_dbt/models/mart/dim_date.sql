

with date_series as (
    select
        dateadd(day, seq4(), '2020-01-01') as date
    from table(generator(rowcount => 365*10))
)

select
    date as date_id,
    year(date) as year,
    month(date) as month,
    day(date) as day,
    dayofweek(date) as day_of_week,
    dayofyear(date) as day_of_year,
    week(date) as week,
    quarter(date) as quarter
from date_series