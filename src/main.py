from flask import Flask, jsonify, request
from config import Config
from ingest_gold import ingest_gold
from ingest_fx import ingest_fx
from transform_silver import (
    parse_eventarc_gcs_event,
    transform_bronze_object_to_silver,
)


app = Flask(__name__)


@app.get("/")
def health_check():
    return jsonify(
        {
            "service": "mgm-ingestion",
            "status": "ok",
            "target": Config.INGEST_TARGET,
        }
    )


@app.post("/ingest")
def ingest():
    try:
        if Config.INGEST_TARGET == "gold":
            result = ingest_gold()
        elif Config.INGEST_TARGET == "fx":
            result = ingest_fx()
        else:
            raise RuntimeError(f"Invalid INGEST_TARGET: {Config.INGEST_TARGET}")

        return jsonify(
            {
                "success": True,
                "result": result,
            }
        ), 200

    except Exception as error:
        app.logger.exception("Ingestion failed")

        return jsonify(
            {
                "success": False,
                "error": str(error),
            }
        ), 500


@app.post("/transform")
def transform():
    try:
        event_payload = request.get_json(silent=True) or {}

        bronze_bucket, bronze_object = parse_eventarc_gcs_event(event_payload)

        result = transform_bronze_object_to_silver(
            bronze_bucket=bronze_bucket,
            bronze_object=bronze_object,
        )

        return jsonify(result), 200

    except Exception as error:
        app.logger.exception("Silver transformation failed")

        return jsonify(
            {
                "success": False,
                "error": str(error),
            }
        ), 500