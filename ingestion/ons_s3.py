import boto3
import pandas as pd

from botocore import UNSIGNED
from botocore.config import Config


BUCKET_NAME = "ons-aws-prod-opendata"


def get_s3_client():
    """Create an anonymous client for the public ONS S3 bucket."""
    return boto3.client(
        "s3",
        config=Config(signature_version=UNSIGNED),
    )


def list_files(prefix: str, extension: str = ".xlsx") -> pd.DataFrame:
    """
    List files available under an ONS S3 prefix.

    Returns metadata for each matching file.
    """

    s3 = get_s3_client()

    response = s3.list_objects_v2(
        Bucket=BUCKET_NAME,
        Prefix=prefix,
    )

    contents = response.get("Contents", [])

    records = []

    for obj in contents:

        key = obj["Key"]

        if not key.endswith(extension):
            continue

        records.append(
            {
                "s3_key": key,
                "file_name": key.split("/")[-1],
                "size": obj["Size"],
                "etag": obj["ETag"].strip('"'),
                "last_modified": obj["LastModified"],
                "url": (
                    f"https://{BUCKET_NAME}.s3.amazonaws.com/{key}"
                ),
            }
        )
    return pd.DataFrame(records)
