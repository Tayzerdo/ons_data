from pathlib import Path

import pandas as pd

from ingestion.ons_s3 import list_files
import duckdb


ONS_PREFIX = "dataset/geracao_usina_2_ho"

DB_PATH = "data/ons_data.duckdb"


def get_generation_files() -> pd.DataFrame:
    """Return available generation files from ONS."""

    return list_files(
        prefix=ONS_PREFIX,
        extension=".xlsx",
    )


def download_file(row: pd.Series) -> pd.DataFrame:
    """Download and read a single ONS Excel file."""

    return pd.read_excel(row["url"])


def extract_generation() -> pd.DataFrame:
    """
    Extract generation data from ONS.

    Returns a DataFrame containing the downloaded records.
    """

    files = get_generation_files()

    if files.empty:
        return pd.DataFrame()


    files = files.tail(5)

    dataframes = []

    for _, row in files.iterrows():

        print(f"Downloading {row['file_name']}")

        df = download_file(row)

        df.columns = [
            str(column)
            .strip()
            .replace(" ", "_")
            .lower()
            for column in df.columns
        ]

        df["source_file"] = row["file_name"]
        df["source_etag"] = row["etag"]
        df["source_last_modified"] = row["last_modified"]

        dataframes.append(df)

    return pd.concat(
        dataframes,
        ignore_index=True,
    )


def load_modalidade(df: pd.DataFrame):

    conn = duckdb.connect(DB_PATH)

    conn.execute("CREATE SCHEMA IF NOT EXISTS raw")

    conn.register("generation_df", df)

    conn.execute("""
        CREATE OR REPLACE TABLE raw.generation AS
        SELECT *
        FROM generation_df
    """)

    conn.close()


if __name__ == "__main__":

    df = extract_generation()

    load_modalidade(df)

    print("extract_generation process succeed")
