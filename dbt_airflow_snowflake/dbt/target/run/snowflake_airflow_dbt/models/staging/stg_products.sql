
  create or replace   view LB.stage.stg_products
  
   as (
    

WITH ranked_products AS (
    SELECT
        id::INTEGER AS productid,
        productcode::VARCHAR(50) AS productcode,
        productname::VARCHAR(100) AS productname,
        energy::VARCHAR(50) AS energy,
        consumptiontype::VARCHAR(50) AS consumptiontype,
        deleted::BOOLEAN AS deleted,
        modificationdate::TIMESTAMP AS modificationdate,
        ROW_NUMBER() OVER (
            PARTITION BY
                id,
                productcode,
                productname,
                energy,
                consumptiontype
            ORDER BY
                modificationdate DESC
        ) AS row_num
    FROM lb.raw.products
)

SELECT
    productid,
    productcode,
    productname,
    energy,
    consumptiontype,
    deleted,
    modificationdate
FROM ranked_products
WHERE row_num = 1
  );

