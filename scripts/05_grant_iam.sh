#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

echo "Resolving service accounts..."

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" \
  --format="value(projectNumber)")

CLOUDBUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
COMPUTE_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
GCS_SERVICE_AGENT="service-${PROJECT_NUMBER}@gs-project-accounts.iam.gserviceaccount.com"

echo "Cloud Build SA:      ${CLOUDBUILD_SA}"
echo "Compute SA:          ${COMPUTE_SA}"
echo "GCS Service Agent:   ${GCS_SERVICE_AGENT}"
echo "Ingestor SA:         ${INGESTOR_SA_EMAIL}"
echo "Scheduler/Event SA:  ${SCHEDULER_SA_EMAIL}"

echo "Granting Cloud Run ingestor write access to bronze bucket..."

gcloud storage buckets add-iam-policy-binding "gs://${BRONZE_BUCKET}" \
  --member="serviceAccount:${INGESTOR_SA_EMAIL}" \
  --role="roles/storage.objectCreator" \
  || true

echo "Granting Cloud Run ingestor read access to bronze bucket for silver transform..."

gcloud storage buckets add-iam-policy-binding "gs://${BRONZE_BUCKET}" \
  --member="serviceAccount:${INGESTOR_SA_EMAIL}" \
  --role="roles/storage.objectViewer" \
  || true

echo "Granting Cloud Run ingestor write access to silver bucket..."

gcloud storage buckets add-iam-policy-binding "gs://${SILVER_BUCKET}" \
  --member="serviceAccount:${INGESTOR_SA_EMAIL}" \
  --role="roles/storage.objectCreator" \
  || true

echo "Granting Cloud Run ingestor access to Gold API secret..."

gcloud secrets add-iam-policy-binding mgm-gold-api-key \
  --project="$PROJECT_ID" \
  --member="serviceAccount:${INGESTOR_SA_EMAIL}" \
  --role="roles/secretmanager.secretAccessor" \
  || true

echo "Granting Cloud Run ingestor access to Exchange API secret..."

gcloud secrets add-iam-policy-binding mgm-exchange-api-key \
  --project="$PROJECT_ID" \
  --member="serviceAccount:${INGESTOR_SA_EMAIL}" \
  --role="roles/secretmanager.secretAccessor" \
  || true

echo "Granting Cloud Build permission to deploy Cloud Run services..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/run.admin" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to use service accounts..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/iam.serviceAccountUser" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to manage Cloud Scheduler jobs..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/cloudscheduler.admin" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to manage Eventarc triggers..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/eventarc.admin" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to manage Pub/Sub resources..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/pubsub.admin" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to manage Artifact Registry..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/artifactregistry.admin" \
  --condition=None \
  || true

echo "Granting Cloud Build permission to update IAM policies..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${CLOUDBUILD_SA}" \
  --role="roles/resourcemanager.projectIamAdmin" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to deploy Cloud Run services..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/run.admin" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to use service accounts..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/iam.serviceAccountUser" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to manage Cloud Scheduler jobs..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/cloudscheduler.admin" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to manage Eventarc triggers..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/eventarc.admin" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to manage Pub/Sub resources..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/pubsub.admin" \
  --condition=None \
  || true

echo "Granting Eventarc trigger identity permission to receive events..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${SCHEDULER_SA_EMAIL}" \
  --role="roles/eventarc.eventReceiver" \
  --condition=None \
  || true

echo "Granting Cloud Storage service agent permission to publish events to Pub/Sub..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${GCS_SERVICE_AGENT}" \
  --role="roles/pubsub.publisher" \
  --condition=None \
  || true

echo "Granting Compute default SA permission to inspect GCS buckets for Eventarc..."

gcloud storage buckets add-iam-policy-binding "gs://${BRONZE_BUCKET}" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/storage.admin" \
  || true

echo "Granting Compute default SA permission to manage BigQuery resources..."

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${COMPUTE_SA}" \
  --role="roles/bigquery.admin" \
  --condition=None \
  || true

echo "IAM permissions ready."