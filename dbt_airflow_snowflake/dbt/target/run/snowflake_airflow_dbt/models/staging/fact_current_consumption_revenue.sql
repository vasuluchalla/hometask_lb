
  create or replace   view LB.stage.fact_current_consumption_revenue
  
   as (
    

SELECT
    contractid,
    productid,
    anlagedatum,
    verbrauch,
    umsatz
FROM LB.stage.fact_consumption_revenue
WHERE valid_from <= CURRENT_DATE()
AND valid_to >= CURRENT_DATE()
  );

