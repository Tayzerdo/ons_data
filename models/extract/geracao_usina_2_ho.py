# Libraries
import pandas as pd
from datetime import datetime

def model(dbt, session):
    dbt.config(
        materialized='incremental', # Must be incremental to preserve and read existing data
        packages=['pandas', 'openpyxl']
    )

    # 1. Load the S3 metadata DataFrame from your upstream model
    data = dbt.ref("fetch_data").df()

    # 2. Filter for your target source
    data_extract = data[data["source"] == "geracao_usina_2_ho"].copy()

    # Slice to check just the last two files
    data_extract = data_extract.tail(5)

    if data_extract.empty:
        return pd.DataFrame()

    # 3. Fetch existing data from this model's destination table (if it exists)
    existing_files_dict = {}
    existing_timestamps = set()
    
    if dbt.is_incremental:
        # ✅ FIX: Use the session query mechanism to pull the relation into a DataFrame
        existing_df = session.query(f"select * from {dbt.this}").df()
        
        if not existing_df.empty:
            # Ensure proper typing for comparison
            existing_df['file_name'] = existing_df['file_name'].astype(str)
            existing_df['etag'] = existing_df['etag'].astype(str)
            
            # Create a lookup map of {file_name: etag}
            existing_files_dict = dict(zip(existing_df['file_name'], existing_df['etag']))
            
            # Create a lookup set of existing timestamps to prevent true duplicates
            existing_df['din_instante'] = pd.to_datetime(existing_df['din_instante']).astype(str)
            existing_timestamps = set(existing_df['din_instante'].unique())

    # 4. Master DataFrame to accumulate all data to be appended
    final_df = pd.DataFrame()

    # 5. Loop through ALL files found in the fetch_data manifest
    for _, row in data_extract.iterrows():
        target_file = str(row["file_name"])
        current_etag = str(row["etag"])
        s3_key = str(row["data"]) 
        last_mod = str(row["last_modified"])
        
        # Scenario Determination
        should_load_full = target_file not in existing_files_dict
        should_load_partial = (target_file in existing_files_dict) and (existing_files_dict[target_file] != current_etag)

        if not should_load_full and not should_load_partial:
            print(f"✅ Skipping: {target_file} (Already loaded and ETag matches)")
            continue

        # Download the file if it meets either condition
        print(f"📥 Loading: {target_file} (New file: {should_load_full}, Updated ETag: {should_load_partial})")
        try:
            file_url = f"https://ons-aws-prod-opendata.s3.amazonaws.com/{s3_key}"
            df_file = pd.read_excel(file_url)
        except Exception as e:
            print(f"⚠️ Failed to read {target_file}: {e}")
            continue

        # Standardize column names for DuckDB compatibility
        df_file.columns = [str(col).replace(" ", "_").lower() for col in df_file.columns]

        # Handle Partial Loading (ETag changed: filter out existing din_instante rows)
        if should_load_partial and not df_file.empty:
            df_file['din_instante_str'] = pd.to_datetime(df_file['din_instante']).astype(str)
            # Only keep rows where the timestamp does not exist anywhere in our destination database
            df_file = df_file[~df_file['din_instante_str'].isin(existing_timestamps)]
            df_file = df_file.drop(columns=['din_instante_str'])

        if df_file.empty:
            print(f"ℹ️ No new data rows found in updated file {target_file}")
            continue

        # Add tracking, operational, and audit metadata columns
        df_file['file_name'] = target_file
        df_file['etag'] = current_etag
        df_file['file_last_modified'] = last_mod
        df_file['_record_count'] = len(df_file)
        df_file['_has_nulls'] = df_file.isnull().any(axis=1)
        df_file['processed_at'] = datetime.now()

        # Combine into our master batch DataFrame
        final_df = pd.concat([final_df, df_file], ignore_index=True)
    
    
    if final_df.empty:
        print("ℹ️ No new or altered data rows discovered during this pipeline execution.")
        if dbt.is_incremental and not existing_df.empty:
            # Returns 0 records while preserving all identical schemas and column data types
            return existing_df.iloc[:0]
        else:
            # Fallback initialization if running a full refresh without match objects
            return pd.DataFrame(columns=['file_name', 'etag', 'din_instante', 'processed_at'])
    return final_df