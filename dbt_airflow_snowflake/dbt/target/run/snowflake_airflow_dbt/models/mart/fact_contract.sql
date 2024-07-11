
  
    

        create or replace transient table LB.dwh_mart.fact_contract
         as
        (

with source as (
    select
        id as contract_id,
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
    from LB.stage.stg_contract
),

products as (
    select *
    from LB.dwh_mart.dim_product
    where is_current = true
),

current_fact_records as (
    select *
    from LB.dwh_mart.fact_contract
    where is_current = true
),

new_fact_records as (
    select
        c.contract_id,
        c.productid as product_id,
        c.createdat as anlagedatum,
        c.usage as verbrauch,
        c.usagenet as umsatz,
        p.productcode,
        p.productname,
        c.modificationdate as contract_modificationdate,
        current_timestamp() as valid_from,
        null as valid_to,
        true as is_current
    from source c
    left join products p on c.productid = p.product_id
    left join current_fact_records f on c.contract_id = f.contract_id and f.is_current = true
    where f.contract_id is null
    or (
        c.productid != f.product_id
        or c.usage != f.verbrauch
        or c.usagenet != f.umsatz
        or c.createdat != f.anlagedatum
    )
),

final as (
    select
        f.contract_id,
        f.product_id,
        f.anlagedatum,
        f.verbrauch,
        f.umsatz,
        f.productcode,
        f.productname,
        f.contract_modificationdate,
        f.valid_from,
        current_timestamp() as valid_to,
        false as is_current
    from current_fact_records f
    inner join new_fact_records nfr on f.contract_id = nfr.contract_id
    where f.is_current = true

    union all

    select * from new_fact_records
)

select * from final
        );
      
  