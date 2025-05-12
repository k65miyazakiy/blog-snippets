#!/bin/bash
set -e

# 変数設定
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-northeast1"
SERVICE_NAME="simplewebapp"

# コマンドライン引数からバージョンとトラフィック分割割合を取得
MSG_TARGET=$1
TRAFFIC_PERCENT=${2:-0}  # デフォルトは0%（トラフィックなし）

if [ -z "$MSG_TARGET" ]; then
  echo "使用法: $0 <Helloターゲット> [トラフィック割合]"
  echo "例: $0 v2 10"
  exit 1
fi

echo "=== Hello $MSG_TARGET アプリをデプロイします（トラフィック: $TRAFFIC_PERCENT%） ==="

CONTAINER_ID="${REGION}-docker.pkg.dev/${PROJECT_ID}/${SERVICE_NAME}-repo/${SERVICE_NAME}"

# デプロイ=新規リビジョンの作成
gcloud run deploy ${SERVICE_NAME} \
  --image $CONTAINER_ID \
  --region ${REGION} \
  --allow-unauthenticated \
  --set-env-vars TARGET="${MSG_TARGET}" \
  --no-traffic

if [ "$TRAFFIC_PERCENT" -eq "0" ]; then
  echo "=== Hello $MSG_TARGET アプリがデプロイされました（トラフィックなし） ==="
else
  # トラフィック割合の指定がある場合、既存のリビジョンと新規リビジョンでトラフィックを分割
  LATEST_REVISION=$(gcloud run revisions list --platform managed --region ${REGION} --service ${SERVICE_NAME} --format="value(name)" --sort-by=~createTime --limit=1)
  REVISIONS=$(gcloud run revisions list --platform managed --region ${REGION} --service ${SERVICE_NAME} --format="value(name)" --sort-by=~createTime --limit=2)
  PREVIOUS_REVISION=$(echo "$REVISIONS" | tail -1)
  
  if [ "$LATEST_REVISION" = "$PREVIOUS_REVISION" ]; then
    # Only one revision exists; route all traffic to the latest revision
    gcloud run services update-traffic ${SERVICE_NAME} \
      --region ${REGION} \
      --to-revisions=${LATEST_REVISION}=100
    
    echo "=== トラフィックを更新しました: ${LATEST_REVISION}=100% ==="
  else
    # 新リビジョンと旧リビジョン間でトラフィックを分割
    gcloud run services update-traffic ${SERVICE_NAME} \
      --region ${REGION} \
      --to-revisions=${LATEST_REVISION}=${TRAFFIC_PERCENT},${PREVIOUS_REVISION}=$((100-TRAFFIC_PERCENT))
    
    echo "=== トラフィックを更新しました: ${LATEST_REVISION}=${TRAFFIC_PERCENT}%, ${PREVIOUS_REVISION}=$((100-TRAFFIC_PERCENT))% ==="
  fi
fi
