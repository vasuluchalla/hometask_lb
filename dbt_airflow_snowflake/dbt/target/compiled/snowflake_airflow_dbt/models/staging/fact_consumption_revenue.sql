

WITH contracts AS (
    SELECT * FROM LB.stage.stg_contract
    
    WHERE createdat > (SELECT COALESCE(MAX(anlagedatum), '1900-01-01'::TIMESTAMP) FROM LB.stage.fact_consumption_revenue)
    
),
prices AS (
    SELECT * FROM LB.stage.stg_prices
),
consumption_with_price AS (
    SELECT
        c.contractid,
        c.productid,
        c.usage AS consumption,
        c.createdat AS anlagedatum,
        MAX(CASE WHEN p.productcomponent = 'baseprice' THEN p.price ELSE 0 END) AS base_price,
        MAX(CASE WHEN p.productcomponent = 'workingprice' THEN p.price ELSE 0 END) AS working_price
    FROM contracts c
    LEFT JOIN prices p ON c.productid = p.productid
    AND c.createdat BETWEEN p.valid_from AND COALESCE(p.valid_until, '9999-12-31'::DATE)
    GROUP BY c.contractid, c.productid, c.usage, c.createdat
),
current_data AS (
    SELECT
        cwp.contractid,
        cwp.productid,
        cwp.anlagedatum,
        cwp.consumption AS verbrauch,
        cwp.base_price + (cwp.working_price * cwp.consumption) AS umsatz,
        CURRENT_TIMESTAMP() AS valid_from,
        '9999-12-31'::DATE AS valid_to
    FROM consumption_with_price cwp
)

-- Insert the new records and update the historical ones
SELECT
    c.contractid,
    c.productid,
    c.anlagedatum,
    c.verbrauch,
    c.umsatz,
    c.valid_from,
    c.valid_to
FROM current_data c
LEFT JOIN LB.stage.fact_consumption_revenue t
ON c.contractid = t.contractid
   AND c.productid = t.productid
   AND c.anlagedatum = t.anlagedatum
   AND c.valid_from = t.valid_from
WHERE (t.valid_to >= CURRENT_DATE() OR t.valid_to IS NULL)
   AND (t.valid_from <= CURRENT_DATE())
   OR t.contractid IS NULL