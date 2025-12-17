# AI Counselor Rails

Rails 8アプリケーションで、既存のFlask AI APIと連携してAIカウンセリングサービスを提供します。

## 📋 概要

このプロジェクトは以下の構成で動作します:

- **Rails 8**: フロントエンドとAPIクライアント
- **Flask AI API**: rinna/japanese-gpt2-smallを使ったテキスト生成
- **Podman**: コンテナ環境

## 🚀 クイックスタート

### 前提条件

- Podmanがインストール済み
- 既存のAI APIが起動していること(`ai-counselor-backend-prototype`)

### 1. AI APIを起動

```bash
cd ../ai-counselor-backend-prototype
./api/scripts/run-api.sh
```

### 2. Railsイメージをビルド

```bash
./bin/build-rails.sh
```

### 3. Railsサーバーを起動

```bash
./bin/run-rails.sh
```

### 4. ブラウザでアクセス

```
http://localhost:3000
```

## 📁 プロジェクト構造

```
ai-counselor-rails/
├── app/
│   ├── controllers/
│   │   └── chats_controller.rb      # チャット機能
│   ├── services/
│   │   └── ai_client_service.rb     # AI APIクライアント
│   └── views/
│       └── chats/
│           └── index.html.erb        # チャットUI
├── bin/
│   ├── build-rails.sh                # イメージビルド
│   ├── run-rails.sh                  # サーバー起動
│   └── stop-rails.sh                 # サーバー停止
├── config/
│   └── routes.rb                     # ルーティング設定
├── Dockerfile                        # 開発用Dockerfile
└── Gemfile                           # 依存関係
```

## 🔧 使い方

### コンテナ管理

```bash
# ログ確認
podman logs -f ai-counselor-rails-server

# サーバー停止
./bin/stop-rails.sh

# サーバー再起動
podman restart ai-counselor-rails-server
```

### AI APIとの通信

RailsアプリケーションはAI APIと以下のように通信します:

```ruby
# app/services/ai_client_service.rb
response = AiClientService.generate("こんにちは")
# => "こんにちは、何かお困りですか?"
```

環境変数`AI_API_URL`で接続先を変更可能:

```bash
AI_API_URL=http://別のホスト:5000/generate ./bin/run-rails.sh
```

## 🎨 機能

- ✅ シンプルなチャットUI
- ✅ リアルタイムAI応答
- ✅ エラーハンドリング
- ✅ タイムアウト対策
- ✅ ログ出力

## 🛠 開発

### Railsコンソール

```bash
podman exec -it ai-counselor-rails-server bin/rails console
```

### テスト実行

```bash
podman exec -it ai-counselor-rails-server bin/rails test
```

## 📝 環境変数

| 変数名 | デフォルト値 | 説明 |
|--------|-------------|------|
| `AI_API_URL` | `http://localhost:5000/generate` | AI APIのエンドポイント |
| `RAILS_ENV` | `development` | Rails環境 |

## ⚠️ トラブルシューティング

### AI APIに接続できない

1. AI APIが起動しているか確認
   ```bash
   podman ps | grep ai-counselor-api-server
   ```

2. ポート5000が使用可能か確認
   ```bash
   curl http://localhost:5000/generate -X POST -H "Content-Type: application/json" -d '{"text":"test"}'
   ```

### Podmanでホストに接続できない

`run-rails.sh`で`--add-host=host.containers.internal:host-gateway`を追加しています。
これによりコンテナ内から`host.containers.internal`でホストマシンにアクセス可能です。

## 📚 参考

- [Rails 8リリースノート](https://rubyonrails.org/)
- [ai-counselor-backend-prototype](../ai-counselor-backend-prototype/README.md)

