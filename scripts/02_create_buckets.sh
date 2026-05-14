#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

gcloud storage buckets create "gs://${BRONZE_BUCKET}" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --uniform-bucket-level-access || true

gcloud storage buckets create "gs://${SILVER_BUCKET}" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --uniform-bucket-level-access || true