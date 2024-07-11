
  
    

        create or replace transient table LB.stage.dim_products
         as
        (-- models/dimensions/dim_product_scd2.sql



with base as (
    select
        id as product_id,
        productcode,
        productname,
        energy,
        consumptiontype,
        modificationdate
    from LB.stage.stg_products
),

historized as (
    select
        product_id,
        productcode,
        productname,
        energy,
        consumptiontype,
        modificationdate,
        current_date() as effective_from,
        null as effective_to,
        'Active' as record_status
    from base
    where not exists (
        select 1
        from LB.stage.dim_products d
        where d.product_id = base.product_id
        and d.effective_to is null
    )
    union all
    select
        b.product_id,
        b.productcode,
        b.productname,
        b.energy,
        b.consumptiontype,
        b.modificationdate,
        d.effective_from,
        current_date() as effective_to,
        'Inactive' as record_status
    from base b
    join LB.stage.dim_products d
        on b.product_id = d.product_id
        and d.effective_to is null
        and (b.modificationdate > d.modificationdate or (b.modificationdate = d.modificationdate and d.record_status = 'Inactive'))
)

select
    product_id,
    productcode,
    productname,
    energy,
    consumptiontype,
    modificationdate,
    effective_from,
    effective_to,
    record_status
from historized
        );
      
  