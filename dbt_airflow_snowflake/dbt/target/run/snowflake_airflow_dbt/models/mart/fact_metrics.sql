
  
    

        create or replace transient table LB.stage_dwh_mart.fact_metrics
         as
        (

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
        p_base.VALID_FROM AS base_valid_from,
        p_base.VALID_UNTIL AS base_valid_until,
        c.STARTDATE AS startdate,
        c.ENDDATE AS enddate
    FROM
        LB.stage_intermediate.int_view_contract c
    JOIN
        LB.stage.stg_products p
        ON c.product_id = p.ID  -- Fixed column name to match source data
    JOIN
        LB.stage.stg_prices p_base
        ON c.product_id = p_base.PRODUCTID  -- Fixed column name to match source data
        AND p_base.PRODUCTCOMPONENT = 'baseprice'
        AND p_base.VALID_FROM <= c.startdate
        AND (p_base.VALID_UNTIL IS NULL OR p_base.VALID_UNTIL >= c.startdate)
    JOIN
        LB.stage.stg_prices p_working
        ON c.product_id = p_working.PRODUCTID  -- Fixed column name to match source data
        AND p_working.PRODUCTCOMPONENT = 'workingprice'
        AND p_working.VALID_FROM <= c.startdate
        AND (p_working.VALID_UNTIL IS NULL OR p_working.VALID_UNTIL >= c.startdate)
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
        base_valid_from AS valid_from,
        base_valid_until AS valid_to,
        TRUE AS is_current,
        current_date AS load_date,
        md5(cast(coalesce(cast(contract_id as TEXT), '') || '-' || coalesce(cast(product_id as TEXT), '') || '-' || coalesce(cast(anlagedatum as TEXT), '') as TEXT)) AS id
    FROM
        contract_prices
)

SELECT
    contract_id AS CONTRACT_ID,
    product_id AS PRODUCT_ID,
    anlagedatum AS ANLAGEDATUM,
    verbrauch AS VERBRAUCH,
    umsatz AS UMSATZ,
    PRODUCTCODE AS PRODUCTCODE,
    PRODUCTNAME AS PRODUCTNAME,
    contract_modificationdate AS CONTRACT_MODIFICATIONDATE,
    valid_from AS VALID_FROM,
    valid_to AS VALID_TO,
    is_current AS IS_CURRENT,
    load_date AS LOAD_DATE,
    id AS ID,
    current_date AS EFFECTIVE_DATE,
    NULL AS EXPIRY_DATE
FROM
    new_data
        );
      
  