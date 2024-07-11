import boto3
import pandas as pd
import snowflake.connector
from snowflake.connector.pandas_tools import write_pandas
from datetime import datetime, timedelta
import io
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
import pendulum

# Constants
S3_BUCKET_NAME = 'lb-project'
SNOWFLAKE_OPTIONS = {
    "sfURL": "oh95089.eu-central-1",
    "sfUser": "SCHALLADBT",
    "sfPassword": "Hello123",
    "sfDatabase": "lb",
    "sfSchema": "RAW",
    "sfWarehouse": "COMPUTE_WH",
    "sfRole": "ACCOUNTADMIN",
}

tables_load = ['products', 'contract', 'prices']

# extract files from s3 based current date with latest file
def get_latest_s3_file(bucket_name, file_suffix):
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=bucket_name)

    files = [content['Key'] for content in response.get('Contents', []) if file_suffix in content['Key']]

    current_date = datetime.utcnow().strftime('%Y%m%d')
    date_filtered_files = [file for file in files if current_date in file]

    if not date_filtered_files:
        raise ValueError("No valid file found in S3 bucket for the current date.")

    latest_file = max(date_filtered_files)
    return latest_file



# transformation for cleaning clolumns
def clean_column_names(columns):
    cleaned_columns = []
    for col in columns:
        cleaned_col = col.strip().replace(' ', '_').replace('-', '_')
        cleaned_col = ''.join(e for e in cleaned_col if e.isalnum() or e == '_')
        cleaned_columns.append(cleaned_col.upper())
    return cleaned_columns

def transform_data(file_suffix):
    s3_input_path = get_latest_s3_file(S3_BUCKET_NAME, file_suffix)
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket=S3_BUCKET_NAME, Key=s3_input_path)
    data = obj['Body'].read().decode('utf-8')

    df = pd.read_csv(io.StringIO(data), delimiter=';', quotechar='"', header=None)

    if not df.iloc[0].apply(lambda x: str(x).isdigit()).all():
        df.columns = clean_column_names(df.iloc[0])
        df = df[1:]
    else:
        df.columns = clean_column_names([f"col_{i}" for i in range(len(df.columns))])

    df.replace('', pd.NA, inplace=True)
    return df

#load data to snowflake RAW schema

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

def etl_task(file_suffix, table_name):
    df = transform_data(file_suffix)
    print(f"Data for {file_suffix} transformed successfully.")
    success, nchunks, nrows = load_to_snowflake(df, table_name)
    print(f"Data loaded to Snowflake table {table_name}: success={success}, chunks={nchunks}, rows={nrows}")

default_args = {
    'owner': 'airflow',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': pendulum.today('UTC').add(days=1)
}

dag = DAG(
    'S3ToSnowflakeFlow',
    default_args=default_args,
    description='A simple ETL process to load data from S3 to Snowflake',
    schedule='0 22 * * *',  
)

price_file_extract = PythonOperator(
        task_id='Load_Prices',
        python_callable=etl_task,
        op_args=['prices', 'prices'.upper()],
        dag=dag,
    )
    
contract_file_extract = PythonOperator(
        task_id=f'Load_Contract',
        python_callable=etl_task,
        op_args=['contract', 'contract'.upper()],
        dag=dag,
    )
    
product_file_extract = PythonOperator(
        task_id=f'Load_Products',
        python_callable=etl_task,
        op_args=['products', 'products'.upper()],
        dag=dag,
    )
start = BashOperator(
    task_id='Start',
    bash_command='python -c "print(\'start!\')"',
    dag=dag
)
end = BashOperator(
    task_id='End',
    bash_command='python -c "print(\'end!\')"',
    dag=dag
)
run_dbt_model = BashOperator(
    task_id='run_dbt_model',
    bash_command= 'cd /opt/airflow/dbt &&  dbt run --full-refresh --profiles-dir=.',
    dag=dag
)   
start>>price_file_extract>>contract_file_extract>>product_file_extract>>run_dbt_model>>end