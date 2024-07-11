

WITH contracts AS (
    SELECT * FROM LB.stage.stg_contract
    
    WHERE createdat > (SELECT MAX(createdat) FROM LB.stage.fact_energy_consumption)
    
),
prices AS (
    SELECT * FROM LB.stage.stg_prices
),
consumption_with_price AS (
    SELECT
        c.contractid,
        c.productid,
        c.usage AS consumption,
        c.createdat,
        MAX(CASE WHEN p.productcomponent = 'baseprice' THEN p.price ELSE 0 END) AS base_price,
        MAX(CASE WHEN p.productcomponent = 'workingprice' THEN p.price ELSE 0 END) AS working_price
    FROM contracts c
    LEFT JOIN prices p ON c.productid = p.productid
    WHERE c.createdat BETWEEN p.valid_from AND COALESCE(p.valid_until, '9999-12-31'::DATE)
    GROUP BY c.contractid, c.productid, c.usage, c.createdat
)
SELECT
    cwp.contractid,
    cwp.productid,
    cwp.createdat,
    cwp.consumption,
    cwp.base_price + (cwp.working_price * cwp.consumption) AS revenue
FROM consumption_with_price cwp