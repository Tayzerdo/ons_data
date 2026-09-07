import pandas as pd
import duckdb

ONS_MODALIDADE_URL = (
    "https://ons-aws-prod-opendata.s3.amazonaws.com/"
    "dataset/modalidade_usina/MODALIDADE_USINA.parquet"
)

DB_PATH = "data/ons_data.duckdb"


def extract_modalidade() -> pd.DataFrame:
    """
    Extract the ONS modalidade_usina dataset.

    Returns
    -------
    pd.DataFrame
        Raw modalidade_usina data with standardized column names.
    """

    df = pd.read_parquet(ONS_MODALIDADE_URL)

    # Standardize column names
    df.columns = [
        str(col)
        .strip()
        .replace(" ", "_")
        .replace("-", "_")
        .lower()
        for col in df.columns
    ]

    return df


def load_modalidade(df: pd.DataFrame):

    conn = duckdb.connect(DB_PATH)

    conn.execute("CREATE SCHEMA IF NOT EXISTS raw")

    conn.register("modalidade_df", df)

    conn.execute("""
        CREATE OR REPLACE TABLE raw.modalidade_usina AS
        SELECT *
        FROM modalidade_df
    """)

    conn.close()


if __name__ == "__main__":

    df = extract_modalidade()

    load_modalidade(df)

    print("extract_modalidade process succeed")
