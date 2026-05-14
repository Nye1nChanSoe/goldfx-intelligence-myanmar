#!/bin/bash
set -euo pipefail

source scripts/00_set_env.sh

gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  cloudscheduler.googleapis.com \
  eventarc.googleapis.com \
  pubsub.googleapis.com \
  bigquerydatatransfer.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  --project="$PROJECT_ID"