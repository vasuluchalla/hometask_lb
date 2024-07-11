

WITH ranked_prices AS (
    SELECT
        id::INTEGER AS id,
        productid::INTEGER AS productid,
        pricecomponentid::INTEGER AS pricecomponentid,
        productcomponent::VARCHAR(50) AS productcomponent,
        price::FLOAT AS price,
        unit::VARCHAR(20) AS unit,
        modificationdate::TIMESTAMP AS modificationdate,
        ROW_NUMBER() OVER (
            PARTITION BY
                id,
                productid,
                pricecomponentid,
                productcomponent
            ORDER BY
                modificationdate DESC
        ) AS row_num
    FROM lb.raw.prices
)

SELECT
    id,
    productid,
    pricecomponentid,
    productcomponent,
    price,
    unit,
    modificationdate
FROM ranked_prices
WHERE row_num = 1