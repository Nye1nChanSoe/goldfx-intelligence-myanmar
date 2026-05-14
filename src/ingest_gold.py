import requests
from config import Config
from storage import write_json_to_bronze


def ingest_gold() -> dict:
    if not Config.BRONZE_BUCKET:
        raise RuntimeError("Missing BRONZE_BUCKET")

    if not Config.GOLD_API_KEY:
        raise RuntimeError("Missing GOLD_API_KEY")

    response = requests.get(
        Config.GOLD_API_URL,
        headers={
            "x-access-token": Config.GOLD_API_KEY,
        },
        timeout=30,
    )

    if not response.ok:
        raise RuntimeError(
            f"Gold API failed: status={response.status_code}, body={response.text}"
        )

    payload = response.json()

    return write_json_to_bronze(
        bucket_name=Config.BRONZE_BUCKET,
        source="goldapi_xau_usd",
        payload=payload,
    )