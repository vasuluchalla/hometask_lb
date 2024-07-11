
  create or replace   view DBT_DEV_DB.LB_SCHEMA.stg_product
  
   as (
    SELECT
    id INTEGER ,
    productcode ,
    productname ,
    energy ,
    consumptiontype ,
    deleted,
    modificationdate 
FROM DBT_DEV_DB.RAW.product
contract
  );

