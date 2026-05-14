#!/bin/bash
set -euo pipefail

echo "========================================"
echo "MGM Pipeline Bootstrap Started"
echo "========================================"

echo ""
echo "Step 1: Loading environment..."
source scripts/00_set_env.sh

echo "PROJECT_ID:     $PROJECT_ID"
echo "REGION:         $REGION"
echo "BRONZE_BUCKET:  $BRONZE_BUCKET"
echo "SILVER_BUCKET:  $SILVER_BUCKET"
echo ""

echo "Step 2: Enabling required GCP APIs..."
./scripts/01_enable_apis.sh

echo ""
echo "Step 3: Creating bronze and silver buckets..."
./scripts/02_create_buckets.sh

echo ""
echo "Step 4: Creating service accounts..."
./scripts/03_create_service_accounts.sh

echo ""
echo "Step 5: Creating or updating secrets..."
./scripts/04_create_secrets.sh

echo ""
echo "Step 6: Granting IAM permissions..."
./scripts/05_grant_iam.sh

echo ""
echo "Step 7: Building and deploying Cloud Run services with Cloud Build..."

gcloud builds submit \
  --project="$PROJECT_ID" \
  --config=cloudbuild.yaml

# echo ""
# echo "Step 8: Creating BigQuery datasets and external tables..."
# ./scripts/07_create_bigquery_resources.sh

echo ""
echo "========================================"
echo "MGM Pipeline Bootstrap Completed"
echo "========================================"

echo ""
echo "Cloud Run services deployed:"
echo "- mgm-ingest-gold"
echo "- mgm-ingest-fx"
echo "- mgm-transform-silver"

echo ""
echo "Scheduler jobs:"
echo "- mgm-ingest-gold-every-15m"
echo "- mgm-ingest-fx-every-15m"

echo ""
echo "Eventarc trigger:"
echo "- mgm-bronze-to-silver-trigger"

echo ""
echo "Checking scheduler states..."
echo ""

gcloud scheduler jobs list \
  --location="$REGION" \
  --project="$PROJECT_ID"

echo ""
echo "Checking Eventarc triggers..."
echo ""

gcloud eventarc triggers list \
  --location="$REGION" \
  --project="$PROJECT_ID"

echo ""
echo "To force ingestion manually:"
echo ""

echo "gcloud scheduler jobs run mgm-ingest-gold-every-15m \\"
echo "  --location=$REGION \\"
echo "  --project=$PROJECT_ID"

echo ""
echo "gcloud scheduler jobs run mgm-ingest-fx-every-15m \\"
echo "  --location=$REGION \\"
echo "  --project=$PROJECT_ID"

echo ""
echo "To inspect bronze bucket:"
echo ""

echo "gcloud storage ls -r gs://$BRONZE_BUCKET/**"

echo ""
echo "To inspect silver bucket:"
echo ""

echo "gcloud storage ls -r gs://$SILVER_BUCKET/**"

echo ""
echo "Bootstrap flow completed successfully."