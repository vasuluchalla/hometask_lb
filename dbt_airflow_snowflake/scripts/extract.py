# extract.py

import boto3
from airflow.models import Variable
from datetime import datetime

# Constants
S3_BUCKET_NAME = 'lb-project'

def get_latest_s3_file(bucket_name, file_suffix):
    session = boto3.Session(
        aws_access_key_id=Variable.get('aws_access_key_id'), 
        aws_secret_access_key=Variable.get('aws_secret_access_key')
    )

    s3 = session.client('s3')

    response = s3.list_objects_v2(Bucket=bucket_name)

    files = [content['Key'] for content in response.get('Contents', []) if file_suffix in content['Key']]

    current_date = datetime.utcnow().strftime('%Y%m%d')
    date_filtered_files = [file for file in files if current_date in file]

    if not date_filtered_files:
        raise ValueError("No valid file found in S3 bucket for the current date.")

    latest_file = max(date_filtered_files)
    return latest_file
