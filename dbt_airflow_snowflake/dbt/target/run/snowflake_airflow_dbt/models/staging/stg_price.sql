
  create or replace   view DBT_DEV_DB.LB_SCHEMA.stg_price
  
   as (
    SELECT
    id::integer AS bank_id,
    productid 
    account_number::integer AS account_number,
    pricecomponentid,
    productcomponent ,
    price ,
    unit ,
    valid_from  ,
    valid_until ,
    modificationdate,
FROM DBT_DEV_DB.RAW.price
  );

