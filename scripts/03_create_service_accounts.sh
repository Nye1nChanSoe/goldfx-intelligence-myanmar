#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

echo "Creating MGM ingestor service account..."

gcloud iam service-accounts create "$INGESTOR_SA" \
  --project="$PROJECT_ID" \
  --display-name="MGM Ingestor Service Account" \
  --description="Service account used by Cloud Run ingestion services for MGM pipeline" \
  || echo "Service account $INGESTOR_SA already exists. Skipping."

echo "Creating MGM scheduler service account..."

gcloud iam service-accounts create "$SCHEDULER_SA" \
  --project="$PROJECT_ID" \
  --display-name="MGM Scheduler Service Account" \
  --description="Service account used by Cloud Scheduler to invoke MGM Cloud Run services" \
  || echo "Service account $SCHEDULER_SA already exists. Skipping."

echo "Service accounts ready:"
echo "Ingestor SA:  ${INGESTOR_SA_EMAIL}"
echo "Scheduler SA: ${SCHEDULER_SA_EMAIL}"