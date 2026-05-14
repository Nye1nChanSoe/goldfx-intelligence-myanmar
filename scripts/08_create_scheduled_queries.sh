#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

BQ_LOCATION="asia-southeast1"

MARKET_ADJUSTED_DISPLAY_NAME="mgm_gold_market_adjusted_gold_fx_hourly"
DAILY_SUMMARY_DISPLAY_NAME="mgm_gold_daily_market_summary_hourly"

echo "========================================"
echo "Creating BigQuery scheduled queries..."
echo "========================================"

scheduled_query_exists() {
  local display_name="$1"

  local configs_json

  configs_json=$(bq ls \
    --project_id="$PROJECT_ID" \
    --transfer_config \
    --location="$BQ_LOCATION" \
    --format=json 2>/dev/null || echo "[]")

  if [ -z "$configs_json" ]; then
    configs_json="[]"
  fi

  python3 - "$display_name" <<PY
import json
import sys

display_name = sys.argv[1]
raw = '''$configs_json'''

try:
    configs = json.loads(raw)
except json.JSONDecodeError:
    configs = []

exists = any(
    config.get("displayName") == display_name
    for config in configs
)

print("true" if exists else "false")
PY
}

create_scheduled_query_if_missing() {
  local display_name="$1"
  local schedule="$2"
  local sql_file="$3"

  echo ""
  echo "Checking scheduled query: ${display_name}"

  EXISTS=$(scheduled_query_exists "$display_name")

  if [ "$EXISTS" = "true" ]; then
    echo "Scheduled query already exists: ${display_name}"
    echo "Skipping."
    return
  fi

  echo "Creating scheduled query: ${display_name}"

  PARAMS=$(python3 - "$sql_file" <<'PY'
import json
import sys

sql_file = sys.argv[1]

with open(sql_file, "r", encoding="utf-8") as f:
    query = f.read()

print(json.dumps({
    "query": query
}))
PY
)

  bq mk \
    --project_id="$PROJECT_ID" \
    --transfer_config \
    --location="$BQ_LOCATION" \
    --data_source=scheduled_query \
    --display_name="$display_name" \
    --schedule="$schedule" \
    --params="$PARAMS" \
    --service_account_name="$SCHEDULER_SA_EMAIL"
}

create_scheduled_query_if_missing \
  "$MARKET_ADJUSTED_DISPLAY_NAME" \
  "every 1 hours" \
  "sql/06_build_market_adjusted_gold_fx.sql"

create_scheduled_query_if_missing \
  "$DAILY_SUMMARY_DISPLAY_NAME" \
  "every 1 hours" \
  "sql/07_build_daily_market_summary.sql"

echo ""
echo "========================================"
echo "BigQuery scheduled queries ready."
echo "========================================"