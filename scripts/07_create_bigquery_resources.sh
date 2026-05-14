#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

echo "========================================"
echo "Creating BigQuery MGM resources..."
echo "========================================"

echo ""
echo "Step 1: Creating datasets..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/01_create_datasets.sql

echo ""
echo "Step 2: Creating silver external tables..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/02_create_external_tables.sql

echo ""
echo "Step 3: Creating reference tables..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/03_create_reference_tables.sql

echo ""
echo "Step 4: Seeding today's manual reference inputs..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/04_seed_reference_inputs.sql

echo ""
echo "Step 5: Creating gold table schemas..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/05_create_gold_tables.sql

echo ""
echo "Step 6: Building market-adjusted gold FX table..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/06_build_market_adjusted_gold_fx.sql

echo ""
echo "Step 7: Building daily market summary table..."

bq query --project_id=$PROJECT_ID --location="${BQ_LOCATION}" --use_legacy_sql=false < sql/07_build_daily_market_summary.sql

echo ""
echo "========================================"
echo "BigQuery MGM resources ready."
echo "========================================"