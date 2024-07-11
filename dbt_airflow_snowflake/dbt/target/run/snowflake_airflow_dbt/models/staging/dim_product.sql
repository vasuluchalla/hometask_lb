
  
    

        create or replace transient table LB.stage.dim_product
         as
        (

WITH products AS (
    SELECT * FROM LB.stage.stg_products
),
current_products AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY productid, productcode, productname, energy, consumptiontype 
               ORDER BY modificationdate DESC
           ) AS rn
    FROM products
),
product_changes AS (
    SELECT 
        productid,
        productcode,
        productname,
        energy,
        consumptiontype,
        modificationdate AS anlagedatum,
        LEAD(modificationdate, 1, '9999-12-31'::DATE) OVER (
            PARTITION BY productid, productcode, productname, energy, consumptiontype
            ORDER BY modificationdate
        ) AS enddate,
        CASE WHEN rn = 1 THEN TRUE ELSE FALSE END AS is_current
    FROM current_products
    WHERE rn = 1
)

SELECT 
    productid,
    productcode,
    productname,
    energy,
    consumptiontype,
    anlagedatum,
    enddate,
    is_current
FROM product_changes
        );
      
  