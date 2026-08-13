import boto3
from botocore import UNSIGNED
from botocore.config import Config
import json

def inspect_s3_object_fields(prefix):
    """
    Connects to the public ONS S3 bucket anonymously and prints out
    all metadata keys and sample data available for an object.
    """
    s3 = boto3.client('s3', config=Config(signature_version=UNSIGNED))
    bucket_name = 'ons-aws-prod-opendata'
    
    print(f"Scanning bucket for prefix: {prefix}...\n")
    response = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    
    if 'Contents' not in response:
        print("No files found.")
        return
        
    # 1. Grab the absolute first item in the contents array
    sample_object = response['Contents'][0]
    
    # 2. Convert datetime objects to string so json.dumps doesn't crash
    serializable_sample = {}
    for key, value in sample_object.items():
        if hasattr(value, 'strftime'):  # Checks if it's a datetime object
            serializable_sample[key] = value.strftime('%Y-%m-%d %H:%M:%S %Z')
        else:
            serializable_sample[key] = value

    # 3. Print the raw dictionary structure beautifully
    print("=========================================")
    print("   ALL AVAILABLE S3 METADATA FIELDS      ")
    print("=========================================")
    print(json.dumps(serializable_sample, indent=4))
    print("=========================================")

# --- Run the inspector ---
inspect_s3_object_fields("dataset/geracao_usina_2_ho/")