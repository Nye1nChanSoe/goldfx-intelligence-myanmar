import os


class Config:
    INGEST_TARGET = os.getenv("INGEST_TARGET")
    BRONZE_BUCKET = os.getenv("BRONZE_BUCKET")
    SILVER_BUCKET = os.getenv("SILVER_BUCKET")

    GOLD_API_KEY = os.getenv("GOLD_API_KEY")
    EXCHANGE_API_KEY = os.getenv("EXCHANGE_API_KEY")

    GOLD_API_URL = "https://www.goldapi.io/api/XAU/USD"
    FX_API_URL = "https://exchange-rateapi.com/api/v1/rates"

    FX_PAIRS = [
        ("USD", "THB"),
        ("USD", "MMK"),
    ]