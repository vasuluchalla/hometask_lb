
  
    

        create or replace transient table LB.stage.dim_contract
         as
        (

SELECT
    contractid,
    type,
    energy,
    usage,
    usagenet,
    createdat,
    startdate,
    enddate,
    city,
    status,
    productid,
    modificationdate
FROM LB.stage.stg_contract
        );
      
  