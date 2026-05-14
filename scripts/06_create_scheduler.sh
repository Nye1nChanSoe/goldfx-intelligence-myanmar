#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

GOLD_URL=$(gcloud run services describe mgm-ingest-gold \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --format="value(status.url)")

FX_URL=$(gcloud run services describe mgm-ingest-fx \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --format="value(status.url)")

gcloud run services add-iam-policy-binding mgm-ingest-gold \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:${SCHEDULER_SA_EMAIL}" \
  --role="roles/run.invoker"

gcloud run services add-iam-policy-binding mgm-ingest-fx \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:${SCHEDULER_SA_EMAIL}" \
  --role="roles/run.invoker"

gcloud scheduler jobs create http mgm-ingest-gold-every-15m \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --schedule="*/15 * * * *" \
  --time-zone="Asia/Bangkok" \
  --uri="${GOLD_URL}/ingest" \
  --http-method=POST \
  --oidc-service-account-email="$SCHEDULER_SA_EMAIL" || true

gcloud scheduler jobs create http mgm-ingest-fx-every-15m \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --schedule="*/15 * * * *" \
  --time-zone="Asia/Bangkok" \
  --uri="${FX_URL}/ingest" \
  --http-method=POST \
  --oidc-service-account-email="$SCHEDULER_SA_EMAIL" || true