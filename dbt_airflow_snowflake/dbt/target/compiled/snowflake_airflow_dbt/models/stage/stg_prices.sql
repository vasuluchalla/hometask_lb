

with source as (
    select * from lb.raw.prices
),
incremental as (
    select
        id,
        productid,
        pricecomponentid,
        productcomponent,
        price,
        unit,
        valid_from,
        valid_until,
        modificationdate
    from source
    
)

select * from incremental