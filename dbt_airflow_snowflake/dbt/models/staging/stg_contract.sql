{{ config(materialized='view') }}

WITH ranked_contracts AS (
    SELECT
        id::INTEGER AS id,
        type::VARCHAR(50) AS type,
        energy::VARCHAR(50) AS energy,
        usage::FLOAT AS usage,
        usagenet::FLOAT AS usagenet,
        createdat::TIMESTAMP AS createdat,
        startdate::DATE AS startdate,
        enddate::DATE AS enddate,
        city::VARCHAR(100) AS city,
        status::VARCHAR(50) AS status,
        productid::INTEGER AS productid,
        modificationdate::TIMESTAMP AS modificationdate,
        ROW_NUMBER() OVER (
            PARTITION BY
                id,
                type,
                energy,
                usage,
                usagenet,
                createdat,
                startdate,
                enddate,
                city,
                status,
                productid
            ORDER BY
                modificationdate DESC
        ) AS row_num
    FROM {{ source('source', 'contract') }}
)

SELECT
    id,
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
    modificationdate
FROM ranked_contracts
WHERE row_num = 1
