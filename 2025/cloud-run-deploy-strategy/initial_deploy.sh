#!/bin/bash
set -e

# 変数設定
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-northeast1"
SERVICE_NAME="simplewebapp"

echo "=== Hello Worldアプリ をビルドしてサービスを作成します ==="

CONTAINER_ID="${REGION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-repo/${SERVICE_NAME}"

# イメージをビルドしてプッシュ
echo "=== コンテナイメージレポジトリを作成してプッシュします ==="
gcloud artifacts repositories create ${SERVICE_NAME}-repo --location=$REGION --repository-format=docker
docker build -t $CONTAINER_ID .
docker push $CONTAINER_ID

# Cloud Run にデプロイ
gcloud run deploy ${SERVICE_NAME} \
  --image $CONTAINER_ID \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --set-env-vars TARGET="World!"

echo "=== Hello Worldアプリがデプロイされました ==="