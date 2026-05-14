#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

BQ_LOCATION="asia-southeast1"

echo "========================================"
echo "Creating BigQuery silver resources..."
echo "========================================"

echo ""
echo "Step 1: Creating BigQuery datasets..."

bq --location="${BQ_LOCATION}" query \
  --use_legacy_sql=false \
  < sql/01_create_datasets.sql

echo ""
echo "Step 2: Creating silver external tables..."

bq --location="${BQ_LOCATION}" query \
  --use_legacy_sql=false \
  < sql/02_create_external_tables.sql

echo ""
echo "========================================"
echo "BigQuery silver resources ready."
echo "========================================"