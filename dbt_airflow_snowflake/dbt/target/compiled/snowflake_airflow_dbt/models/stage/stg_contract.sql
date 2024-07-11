

with source as (
    select * from lb.raw.contract
),
incremental as (
    select
        id,
        type,
        energy,
        usage,
        usagenet,
        createdat,
        startdate,
        enddate,
        fillingdatecancellation,
        cancellationreason,
        city,
        status,
        productid,
        modificationdate
    from source
    
)

select * from incremental