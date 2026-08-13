# Libraries 
import pandas as pd
import numpy as np
import boto3
from botocore import UNSIGNED
from botocore.config import Config
import io

# DEF functions
def list_and_load_ons_s3(prefix):
    """
    Connects to the public ONS S3 bucket anonymously, lists files 
    under a prefix, extracts metadata (URL, Last Modified), and returns a DataFrame.
    """
    # Create an anonymous client (no AWS account or keys required)
    s3 = boto3.client('s3', config=Config(signature_version=UNSIGNED))
    bucket_name = 'ons-aws-prod-opendata'
    
    print(f"Scanning bucket for prefix: {prefix}...")
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    
    if 'Contents' not in response:
        print("No files found.")
        return pd.DataFrame() # Return empty DataFrame to avoid crashes downstream
        
    # Build an structured list of dictionaries containing file metadata
    file_records = []
    for obj in response['Contents']:
        if obj['Key'].endswith('.xlsx'):
            file_records.append({
                "data": obj['Key'],
                "url": f"https://{bucket_name}.s3.amazonaws.com/{obj['Key']}",
                "Size": obj['Size'],
                "ETag": obj['ETag'],
                "last_modified": obj['LastModified'].strftime('%Y-%m-%d %H:%M:%S') # Standard format string
            })
    
    # Convert records directly into a DataFrame
    files = pd.DataFrame(file_records)
    
    # Split the S3 key structure into distinct columns
    files[['dataset', 'source', 'file_name']] = files['data'].str.split('/', expand=True)

    # Save tracking file to seeds directory
    file_name = prefix.split("/")[1]
    files.to_parquet(f"./seeds/{file_name}.parquet")
    
    return files


# MODEL
def model(dbt, session):
    """
    dbt Python model to ingest the latest ONS generation data.
    """
    dbt.config(
        materialized="table" 
    )

    # Execute your custom S3 fetching logic
    df_data_source_details = list_and_load_ons_s3("dataset/geracao_usina_2_ho/")

    # Clean up the DataFrame and standardize column layout
    df = df_data_source_details.astype(str)
    df.columns = [
        str(col).replace(" ", "_").lower() for col in df.columns
    ]

    return df