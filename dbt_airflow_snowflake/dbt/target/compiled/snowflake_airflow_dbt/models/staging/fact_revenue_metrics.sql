WITH contract_data AS (
    SELECT
        c.id AS contract_id,
        c.productid AS product_id,
        c.createdat AS creation_date,
        c.startdate,
        c.enddate,
        c.status,
        c.city,
        c.usage AS total_consumption
    FROM LB.stage.stg_contract c
),

product_prices AS (
    SELECT
        p.id AS product_id,
        MAX(CASE WHEN pc.productcomponent = 'baseprice' THEN pc.price ELSE NULL END) AS base_price,
        MAX(CASE WHEN pc.productcomponent = 'workingprice' THEN pc.price ELSE NULL END) AS working_price
    FROM LB.stage.stg_products p
    JOIN LB.stage.stg_prices pc
    ON p.id = pc.productid
    GROUP BY p.id
),

revenue_data AS (
    SELECT
        cd.contract_id,
        cd.product_id,
        cd.creation_date,
        cd.startdate,
        cd.enddate,
        cd.status,
        cd.city,
        cd.total_consumption,
        pp.base_price,
        pp.working_price,
        pp.base_price + (cd.total_consumption * pp.working_price) AS total_revenue
    FROM contract_data cd
    JOIN product_prices pp
    ON cd.product_id = pp.product_id
)

SELECT
    contract_id,
    product_id,
    creation_date,
    startdate,
    enddate,
    status,
    city,
    total_consumption,
    working_price * total_consumption AS total_working_revenue,
    base_price AS total_base_revenue,
    total_revenue
FROM revenue_data;