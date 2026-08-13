import pandas as pd

def model(dbt, session):
    dbt.config(
        materialized="table"
    )

    # Public S3 URL for the ONS Parquet file
    url = "https://ons-aws-prod-opendata.s3.amazonaws.com/dataset/modalidade_usina/MODALIDADE_USINA.parquet"

    # Read parquet file directly into Pandas
    df = pd.read_parquet(url)

    # Standardize column names (lowercase, replace spaces/special chars)
    df.columns = [
        str(col).strip().replace(" ", "_").replace("-", "_").lower() 
        for col in df.columns
    ]

    return df