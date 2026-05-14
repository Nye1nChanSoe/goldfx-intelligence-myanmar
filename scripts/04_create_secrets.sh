#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

read -rsp "Enter Gold API key: " GOLD_API_KEY
echo

read -rsp "Enter Exchange API key: " EXCHANGE_API_KEY
echo

echo -n "$GOLD_API_KEY" | gcloud secrets create mgm-gold-api-key \
  --project="$PROJECT_ID" \
  --replication-policy="automatic" \
  --data-file=- || \
echo -n "$GOLD_API_KEY" | gcloud secrets versions add mgm-gold-api-key \
  --project="$PROJECT_ID" \
  --data-file=-

echo -n "$EXCHANGE_API_KEY" | gcloud secrets create mgm-exchange-api-key \
  --project="$PROJECT_ID" \
  --replication-policy="automatic" \
  --data-file=- || \
echo -n "$EXCHANGE_API_KEY" | gcloud secrets versions add mgm-exchange-api-key \
  --project="$PROJECT_ID" \
  --data-file=-