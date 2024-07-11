# load.py

import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas

# Snowflake connection options
SNOWFLAKE_OPTIONS = {
    "sfURL": "oh95089.eu-central-1",
    "sfUser": "SCHALLADBT",
    "sfPassword": "Hello123",
    "sfDatabase": "lb",
    "sfSchema": "RAW",
    "sfWarehouse": "COMPUTE_WH",
    "sfRole": "ACCOUNTADMIN",
}

def load_to_snowflake(df, table_name):
    conn = snowflake.connector.connect(
        user=SNOWFLAKE_OPTIONS['sfUser'],
        password=SNOWFLAKE_OPTIONS['sfPassword'],
        account=SNOWFLAKE_OPTIONS['sfURL'],
        database=SNOWFLAKE_OPTIONS['sfDatabase'],
        schema=SNOWFLAKE_OPTIONS['sfSchema'],
        warehouse=SNOWFLAKE_OPTIONS['sfWarehouse'],
        role=SNOWFLAKE_OPTIONS['sfRole']
    )

    conn.cursor().execute(f"USE DATABASE {SNOWFLAKE_OPTIONS['sfDatabase']}")
    conn.cursor().execute(f"USE SCHEMA {SNOWFLAKE_OPTIONS['sfSchema']}")

    success, nchunks, nrows, _ = write_pandas(conn, df, table_name)
    conn.close()
    return success, nchunks, nrows
