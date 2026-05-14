import requests
from config import Config
from storage import write_json_to_bronze


def fetch_fx_pair(source: str, target: str) -> dict:
    response = requests.get(
        Config.FX_API_URL,
        params={
            "source": source,
            "target": target,
        },
        headers={
            "Authorization": f"Bearer {Config.EXCHANGE_API_KEY}",
            "Accept": "application/json",
        },
        timeout=30,
    )

    if not response.ok:
        raise RuntimeError(
            f"FX API failed for {source}/{target}: "
            f"status={response.status_code}, body={response.text}"
        )

    return {
        "pair": f"{source}_{target}",
        "response": response.json(),
    }


def ingest_fx() -> dict:
    if not Config.BRONZE_BUCKET:
        raise RuntimeError("Missing BRONZE_BUCKET")

    if not Config.EXCHANGE_API_KEY:
        raise RuntimeError("Missing EXCHANGE_API_KEY")

    results = []

    for source, target in Config.FX_PAIRS:
        results.append(fetch_fx_pair(source, target))

    payload = {
        "provider": "exchange-rateapi",
        "pairs": results,
    }

    return write_json_to_bronze(
        bucket_name=Config.BRONZE_BUCKET,
        source="exchange_rate_api",
        payload=payload,
    )