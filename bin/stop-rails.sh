#!/bin/bash

# Railsサーバーを停止するスクリプト

set -e

CONTAINER_NAME="ai-counselor-rails-server"

echo "🛑 Railsサーバーを停止します..."

if podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
  podman stop "${CONTAINER_NAME}"
  echo "✅ サーバーを停止しました"
else
  echo "⚠️  サーバーは起動していません"
fi
