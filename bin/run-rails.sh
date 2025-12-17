#!/bin/bash

# Railsサーバーを起動するスクリプト

set -e

IMAGE_NAME="ai-counselor-rails"
TAG="${1:-latest}"
CONTAINER_NAME="ai-counselor-rails-server"
PORT="${2:-3000}"

echo "🚀 Railsサーバーを起動します..."
echo ""

# プロジェクトルートで実行
cd "$(dirname "$0")/.."

# AI APIコンテナが起動しているか確認
if ! podman ps --format "{{.Names}}" | grep -q "ai-counselor-api-server"; then
  echo "⚠️  警告: AI APIサーバーが起動していません"
  echo "   AI APIを先に起動することを推奨します:"
  echo "   cd ../ai-counselor-backend-prototype"
  echo "   ./api/scripts/run-api.sh"
  echo ""
  read -p "このまま続行しますか? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 既存のコンテナを停止・削除
if podman ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  echo "🛑 既存のコンテナを停止・削除中..."
  podman stop "${CONTAINER_NAME}" 2>/dev/null || true
  podman rm "${CONTAINER_NAME}" 2>/dev/null || true
fi

# AI APIのIPアドレスを取得
AI_API_HOST="localhost"
if podman ps --format "{{.Names}}" | grep -q "ai-counselor-api-server"; then
  AI_API_IP=$(podman inspect ai-counselor-api-server --format '{{.NetworkSettings.IPAddress}}' 2>/dev/null || echo "")
  if [ -n "$AI_API_IP" ]; then
    AI_API_HOST="$AI_API_IP"
    echo "🔗 AI APIコンテナを検出: ${AI_API_IP}"
  fi
fi

AI_API_URL="http://${AI_API_HOST}:5000/generate"

echo "📡 ポート: ${PORT}"
echo "🤖 AI API URL: ${AI_API_URL}"
echo ""

# コンテナを起動
# AI APIがコンテナで動作している場合はそのIPを使用
# そうでない場合はホストのlocalhostを使用(--network=host)
if [ "$AI_API_HOST" = "localhost" ]; then
  # AI APIがホスト上で動作している場合
  podman run -d \
    --name "${CONTAINER_NAME}" \
    --network=host \
    -v "$(pwd):/rails" \
    -e "AI_API_URL=${AI_API_URL}" \
    "${IMAGE_NAME}:${TAG}"
else
  # AI APIがコンテナで動作している場合
  podman run -d \
    --name "${CONTAINER_NAME}" \
    -p "${PORT}:3000" \
    -v "$(pwd):/rails" \
    -e "AI_API_URL=${AI_API_URL}" \
    "${IMAGE_NAME}:${TAG}"
fi

# 起動待機
echo "⏳ サーバーの起動を待機中..."
sleep 5

echo ""
echo "✅ Railsサーバーが起動しました!"
echo "URL: http://localhost:${PORT}"
echo ""
echo "動作確認:"
echo "  curl http://localhost:${PORT}"
echo ""
echo "ログ確認: podman logs -f ${CONTAINER_NAME}"
echo "停止: podman stop ${CONTAINER_NAME}"
echo "再起動: podman restart ${CONTAINER_NAME}"
