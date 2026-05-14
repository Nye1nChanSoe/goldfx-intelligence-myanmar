import json
from datetime import datetime, timezone
from io import BytesIO
from typing import Any

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from google.cloud import storage

from config import Config


storage_client = storage.Client()


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def read_bronze_json(bucket_name: str, object_name: str) -> dict[str, Any]:
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)

    raw_text = blob.download_as_text()
    return json.loads(raw_text)


def extract_partition_from_object_name(object_name: str) -> dict[str, str]:
    parts = object_name.split("/")

    values = {}

    for part in parts:
        if "=" in part:
            key, value = part.split("=", 1)
            values[key] = value

    required = ["source", "year", "month", "day"]

    missing = [key for key in required if key not in values]
    if missing:
        raise RuntimeError(
            f"Missing partition values {missing} from bronze object: {object_name}"
        )

    return values


def build_silver_object_path(
    table_name: str,
    year: str,
    month: str,
    day: str,
    bronze_object_name: str,
) -> str:
    bronze_file_name = bronze_object_name.split("/")[-1]
    file_stem = bronze_file_name.replace(".json", "")

    return (
        f"table={table_name}/"
        f"year={year}/"
        f"month={month}/"
        f"day={day}/"
        f"{table_name}_{file_stem}.parquet"
    )


def upload_dataframe_as_parquet(
    df: pd.DataFrame,
    bucket_name: str,
    object_name: str,
) -> None:
    table = pa.Table.from_pandas(df, preserve_index=False)

    buffer = BytesIO()
    pq.write_table(table, buffer, compression="snappy")
    buffer.seek(0)

    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)

    blob.upload_from_file(
        buffer,
        content_type="application/octet-stream",
    )


def transform_gold_payload(
    bronze_payload: dict[str, Any],
    bronze_bucket: str,
    bronze_object: str,
) -> pd.DataFrame:
    raw = bronze_payload["raw_payload"]

    row = {
        "ingested_at": bronze_payload.get("ingested_at"),
        "processed_at": utc_now_iso(),

        "api_timestamp": raw.get("timestamp"),
        "metal": raw.get("metal"),
        "currency": raw.get("currency"),
        "exchange": raw.get("exchange"),
        "symbol": raw.get("symbol"),

        "prev_close_price": raw.get("prev_close_price"),
        "open_price": raw.get("open_price"),
        "low_price": raw.get("low_price"),
        "high_price": raw.get("high_price"),
        "open_time": raw.get("open_time"),

        "price": raw.get("price"),
        "change": raw.get("ch"),
        "change_percent": raw.get("chp"),
        "ask": raw.get("ask"),
        "bid": raw.get("bid"),

        "price_gram_24k": raw.get("price_gram_24k"),
        "price_gram_22k": raw.get("price_gram_22k"),
        "price_gram_21k": raw.get("price_gram_21k"),
        "price_gram_20k": raw.get("price_gram_20k"),
        "price_gram_18k": raw.get("price_gram_18k"),
        "price_gram_16k": raw.get("price_gram_16k"),
        "price_gram_14k": raw.get("price_gram_14k"),
        "price_gram_10k": raw.get("price_gram_10k"),

        "bronze_bucket": bronze_bucket,
        "bronze_object": bronze_object,
    }

    return pd.DataFrame([row])


def transform_fx_payload(
    bronze_payload: dict[str, Any],
    bronze_bucket: str,
    bronze_object: str,
) -> pd.DataFrame:
    raw = bronze_payload["raw_payload"]

    rows = []

    provider = raw.get("provider")

    for item in raw.get("pairs", []):
        pair = item.get("pair")
        response = item.get("response")

        if not response:
            continue

        # API response is a list with one object:
        # [{"rate": 32.31, "source": "USD", "target": "THB", "time": "..."}]
        if isinstance(response, list):
            rate_items = response
        else:
            rate_items = [response]

        for rate_item in rate_items:
            rows.append(
                {
                    "ingested_at": bronze_payload.get("ingested_at"),
                    "processed_at": utc_now_iso(),

                    "provider": provider,
                    "pair": pair,
                    "source_currency": rate_item.get("source"),
                    "target_currency": rate_item.get("target"),
                    "rate": rate_item.get("rate"),
                    "api_time": rate_item.get("time"),

                    "bronze_bucket": bronze_bucket,
                    "bronze_object": bronze_object,
                }
            )

    return pd.DataFrame(rows)


def transform_bronze_object_to_silver(
    bronze_bucket: str,
    bronze_object: str,
) -> dict[str, Any]:
    if not Config.SILVER_BUCKET:
        raise RuntimeError("Missing SILVER_BUCKET")

    partitions = extract_partition_from_object_name(bronze_object)
    source = partitions["source"]
    year = partitions["year"]
    month = partitions["month"]
    day = partitions["day"]

    bronze_payload = read_bronze_json(bronze_bucket, bronze_object)

    if source == "goldapi_xau_usd":
        table_name = "gold_prices"
        df = transform_gold_payload(
            bronze_payload=bronze_payload,
            bronze_bucket=bronze_bucket,
            bronze_object=bronze_object,
        )

    elif source == "exchange_rate_api":
        table_name = "fx_rates"
        df = transform_fx_payload(
            bronze_payload=bronze_payload,
            bronze_bucket=bronze_bucket,
            bronze_object=bronze_object,
        )

    else:
        raise RuntimeError(f"Unsupported bronze source: {source}")

    if df.empty:
        raise RuntimeError(f"No rows produced for bronze object: {bronze_object}")

    silver_object = build_silver_object_path(
        table_name=table_name,
        year=year,
        month=month,
        day=day,
        bronze_object_name=bronze_object,
    )

    upload_dataframe_as_parquet(
        df=df,
        bucket_name=Config.SILVER_BUCKET,
        object_name=silver_object,
    )

    return {
        "success": True,
        "source": source,
        "table": table_name,
        "rows": len(df),
        "bronze_bucket": bronze_bucket,
        "bronze_object": bronze_object,
        "silver_bucket": Config.SILVER_BUCKET,
        "silver_object": silver_object,
    }


def parse_eventarc_gcs_event(request_json: dict[str, Any]) -> tuple[str, str]:
    bucket = request_json.get("bucket")
    name = request_json.get("name")

    if not bucket or not name:
        raise RuntimeError(
            f"Invalid Eventarc GCS payload. Expected bucket and name. Got: {request_json}"
        )

    return bucket, name