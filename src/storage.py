import json
from datetime import datetime, timezone
from google.cloud import storage
from zoneinfo import ZoneInfo


storage_client = storage.Client()


def utc_now():
    return datetime.now(timezone.utc)


def bangkok_now():
    return datetime.now(ZoneInfo("Asia/Bangkok"))


def build_partitioned_path(source: str, dt: datetime) -> str:
    year = dt.strftime("%Y")
    month = dt.strftime("%m")
    day = dt.strftime("%d")
    timestamp = dt.strftime("%Y-%m-%dT%H-%M-%SZ")

    return f"source={source}/year={year}/month={month}/day={day}/{timestamp}.json"


def write_json_to_bronze(bucket_name: str, source: str, payload: dict) -> dict:
    now_utc = utc_now()
    partition_dt = bangkok_now()
    object_path = build_partitioned_path(source, partition_dt)

    wrapped_payload = {
        "ingested_at": now_utc.isoformat(),
        "partition_timezone": "Asia/Bangkok",
        "source": source,
        "raw_payload": payload,
    }

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_path)

    blob.upload_from_string(
        json.dumps(wrapped_payload, ensure_ascii=False, indent=2),
        content_type="application/json",
    )

    return {
        "bucket": bucket_name,
        "object": object_path,
        "source": source,
        "ingested_at": wrapped_payload["ingested_at"],
    }