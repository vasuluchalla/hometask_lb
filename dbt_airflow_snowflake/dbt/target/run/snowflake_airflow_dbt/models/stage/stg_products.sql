
  
    

        create or replace transient table LB.stage.stg_products
         as
        (

with source as (
    select * from lb.raw.products
),
incremental as (
    select
        id,
        productcode,
        productname,
        energy,
        consumptiontype,
        deleted,
        modificationdate
    from source
    
)

select * from incremental
        );
      
  