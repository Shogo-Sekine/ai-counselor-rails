#!/bin/bash

# Rails用Dockerイメージをビルドするスクリプト

set -e

IMAGE_NAME="ai-counselor-rails"
TAG="${1:-latest}"

echo "🔨 Railsイメージをビルドします..."
echo ""

# プロジェクトルートで実行
cd "$(dirname "$0")/.."

# Podmanでビルド
podman build -t "${IMAGE_NAME}:${TAG}" .

echo ""
echo "✅ イメージのビルドが完了しました!"
echo "イメージ名: ${IMAGE_NAME}:${TAG}"
echo ""
echo "次のステップ:"
echo "  ./bin/run-rails.sh でサーバーを起動"
