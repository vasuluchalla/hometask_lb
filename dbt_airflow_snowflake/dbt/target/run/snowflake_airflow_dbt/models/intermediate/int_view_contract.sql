
  create or replace   view LB.stage_intermediate.int_view_contract
  
   as (
    

WITH contract_prices AS (
    SELECT
        c.ID AS contract_id,
        c.PRODUCT_ID AS product_id,  -- Fixed column name to match source data
        c.CREATEDAT AS anlagedatum,
        c.USAGE AS verbrauch,
        p_base.PRICE AS base_price,
        p_working.PRICE AS working_price,
        c.MODIFICATIONDATE AS contract_modificationdate,
        p.PRODUCTCODE,
        p.PRODUCTNAME,
        p_base.VALID_FROM,
        p_base.VALID_UNTIL
    FROM
        LB.stage.stg_contract c
    JOIN
        LB.stage.stg_products p
        ON c.PRODUCT_ID = p.ID  -- Fixed column name to match source data
    JOIN
        LB.stage.stg_prices p_base
        ON c.PRODUCT_ID = p_base.PRODUCTID  -- Fixed column name to match source data
        AND p_base.PRODUCTCOMPONENT = 'baseprice'
        AND p_base.VALID_FROM <= c.STARTDATE
        AND (p_base.VALID_UNTIL IS NULL OR p_base.VALID_UNTIL >= c.STARTDATE)
    JOIN
        LB.stage.stg_prices p_working
        ON c.PRODUCT_ID = p_working.PRODUCTID  -- Fixed column name to match source data
        AND p_working.PRODUCTCOMPONENT = 'workingprice'
        AND p_working.VALID_FROM <= c.STARTDATE
        AND (p_working.VALID_UNTIL IS NULL OR p_working.VALID_UNTIL >= c.STARTDATE)
),
new_data AS (
    SELECT
        contract_id,
        product_id,
        anlagedatum,
        verbrauch,
        base_price + (verbrauch * working_price / 100) AS umsatz,
        PRODUCTCODE,
        PRODUCTNAME,
        contract_modificationdate,
        VALID_FROM,
        VALID_UNTIL,
        TRUE AS is_current,
        current_date AS load_date,
        md5(cast(coalesce(cast(contract_id as TEXT), '') || '-' || coalesce(cast(product_id as TEXT), '') || '-' || coalesce(cast(anlagedatum as TEXT), '') as TEXT)) AS id
    FROM
        contract_prices
)

SELECT
    contract_id,
    product_id,
    anlagedatum,
    verbrauch,
    umsatz,
    PRODUCTCODE,
    PRODUCTNAME,
    contract_modificationdate,
    VALID_FROM,
    VALID_UNTIL,
    is_current,
    load_date,
    id,
    current_date AS effective_date,
    NULL AS expiry_date
FROM
    new_data
  );

