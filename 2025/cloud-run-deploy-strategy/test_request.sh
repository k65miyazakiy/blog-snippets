#!/bin/bash

# 100回リクエストを送信して、各バージョンのレスポンスを集計するスクリプト
REGION="asia-northeast1"
SERVICE_NAME="simplewebapp"

# Cloud Run サービスのURLを取得
URL=$(gcloud run services describe ${SERVICE_NAME} --platform managed --region ${REGION} --format="value(status.url)")
COUNT=${1:-100}  # デフォルトは100回

echo "=== $URL に $COUNT 回リクエストを送信します ==="

# バージョン別のカウンターを初期化
declare -A message_count

# 指定回数リクエスト送信
for i in $(seq 1 $COUNT)
do
  # リクエスト送信とレスポンス取得
  RESPONSE=$(curl -s $URL)
  echo "リクエスト $i: $RESPONSE"
  
  # バージョン情報を抽出して集計
  if [ ! -z "$RESPONSE" ]; then
    message_count[$RESPONSE]=$((${message_count[$RESPONSE]:-0} + 1))
  fi
  
  # 間隔を開ける
  sleep 0.01
done

# 結果の集計を表示
echo -e "\n=== 集計結果 ==="
for response in "${!message_count[@]}"; do
  percentage=$(echo "scale=2; ${message_count[$response]} * 100 / $COUNT" | bc)
  echo "$response: ${message_count[$response]}回 ($percentage%)"
done