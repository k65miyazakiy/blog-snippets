#!/bin/bash
set -e

REGION="asia-northeast1"
SERVICE_NAME="simplewebapp"

# サービスとイメージレジストリの削除
gcloud run services delete ${SERVICE_NAME} --region=$REGION --quiet
gcloud artifacts repositories delete ${SERVICE_NAME}-repo --location=$REGION --quiet