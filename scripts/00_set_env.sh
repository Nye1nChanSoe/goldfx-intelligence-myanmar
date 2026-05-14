#!/bin/bash

export PROJECT_ID="project-7abcab2d-24a7-4f5d-80a"
export REGION="asia-southeast1"

export BRONZE_BUCKET="mgm-bronze-raw-json-data"
export SILVER_BUCKET="mgm-silver-processed-data"

export INGESTOR_SA="mgm-ingestor-sa"
export SCHEDULER_SA="mgm-scheduler-sa"

export INGESTOR_SA_EMAIL="${INGESTOR_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
export SCHEDULER_SA_EMAIL="${SCHEDULER_SA}@${PROJECT_ID}.iam.gserviceaccount.com"

export BQ_LOCATION=${REGION}