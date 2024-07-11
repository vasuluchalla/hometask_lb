import pandas as pd
import io
from dbt_airflow_snowflake.scripts.extract import get_latest_s3_file
import boto3

def clean_column_names(columns):
    cleaned_columns = []
    for col in columns:
        cleaned_col = col.strip().replace(' ', '_').replace('-', '_')
        cleaned_col = ''.join(e for e in cleaned_col if e.isalnum() or e == '_')
        cleaned_columns.append(cleaned_col.upper())
    return cleaned_columns

def transform_data(file_suffix):
    s3_input_path = get_latest_s3_file('lb-project', file_suffix)
    s3 = boto3.client('s3')
    obj = s3.get_object(Bucket='lb-project', Key=s3_input_path)
    data = obj['Body'].read().decode('utf-8')

    df = pd.read_csv(io.StringIO(data), delimiter=';', quotechar='"', header=None)

    if not df.iloc[0].apply(lambda x: str(x).isdigit()).all():
        df.columns = clean_column_names(df.iloc[0])
        df = df[1:]
    else:
        df.columns = clean_column_names([f"col_{i}" for i in range(len(df.columns))])

    df.replace('', pd.NA, inplace=True)
    return df
