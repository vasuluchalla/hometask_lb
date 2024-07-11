

with source as (
    select * from LB.stage.stg_products
),
current_records as (
    select *
    from LB.dwh_mart.dim_products
    where is_current = true
),
records_to_insert as (
    select
        src.id as product_id,
        src.productcode,
        src.productname,
        src.energy,
        src.consumptiontype,
        src.deleted,
        src.modificationdate as product_modificationdate,
        current_records.is_current,
        current_records.valid_from,
        current_records.valid_to
    from source as src
    left join current_records
    on src.id = current_records.product_id
    where current_records.product_id is null
    or (
        src.productcode != current_records.productcode
        or src.productname != current_records.productname
        or src.energy != current_records.energy
        or src.consumptiontype != current_records.consumptiontype
        or src.deleted != current_records.deleted
        or src.modificationdate != current_records.product_modificationdate
    )
),
final as (
    select
        product_id,
        productcode,
        productname,
        energy,
        consumptiontype,
        deleted,
        product_modificationdate,
        case
            when is_current = true and valid_to is null then false
            else is_current
        end as is_current,
        valid_from,
        case
            when is_current = true and valid_to is null then now()
            else valid_to
        end as valid_to
    from current_records
    
    union all
    
    select
        product_id,
        productcode,
        productname,
        energy,
        consumptiontype,
        deleted,
        product_modificationdate,
        true as is_current,
        now() as valid_from,
        null as valid_to
    from records_to_insert
)

select * from final