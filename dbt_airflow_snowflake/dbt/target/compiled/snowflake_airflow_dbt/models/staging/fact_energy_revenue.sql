

WITH latest_contracts AS (
    SELECT
        id AS contract_id,
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
        modificationdate,
        ROW_NUMBER() OVER (
            PARTITION BY id
            ORDER BY modificationdate DESC
        ) AS row_num
    FROM LB.stage.stg_contract
),
latest_products AS (
    SELECT
        productid,
        productcode,
        productname,
        energy,
        modificationdate,
        ROW_NUMBER() OVER (
            PARTITION BY productid
            ORDER BY modificationdate DESC
        ) AS row_num
    FROM LB.stage.stg_products
),
latest_prices AS (
    SELECT
        productid,
        MAX(CASE WHEN productcomponent = 'baseprice' THEN price ELSE NULL END) AS baseprice,
        MAX(CASE WHEN productcomponent = 'workingprice' THEN price ELSE NULL END) AS workingprice
    FROM LB.stage.stg_prices
    GROUP BY productid
)

SELECT
    c.contract_id,
    c.type,
    c.energy,
    c.usage AS verbrauch,
    c.usagenet,
    c.createdat,
    c.startdate,
    c.enddate,
    c.city,
    c.status,
    c.productid,
    p.productcode,
    p.productname,
    lp.baseprice AS grundpreis,
    lp.workingprice AS arbeitspreis,
    (lp.baseprice + c.usage * lp.workingprice) AS revenue,
    c.modificationdate
FROM latest_contracts c
LEFT JOIN latest_products p ON c.productid = p.productid
LEFT JOIN latest_prices lp ON c.productid = lp.productid