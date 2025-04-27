# E2Eテスト用サンプルアプリケーション

このリポジトリは、Cloud Buildパイプライン内でE2Eテストを実行するサンプルアプリケーションを提供します。

## アプリケーション構成

- **フロントエンド/バックエンド**: Goによるシンプルなウェブアプリケーション
- **データベース**: PostgreSQL
- **E2Eテスト**: Playwright

## 機能

- メッセージの投稿と表示
- データベースとの連携
dock
## ローカルでの実行方法

```bash
# Docker Composeでアプリケーションを起動
docker compose up -d app db

# E2Eテストの実行
docker compose up e2e
```

## Cloud Buildでの実行方法

```bash
# Cloud Buildパイプラインを実行
gcloud builds submit --config=cloudbuild.yml
```

## ディレクトリ構造

- `app/` - Goアプリケーション
- `db/` - PostgreSQLデータベース設定
- `e2e/` - Playwrightテスト
- `cloudbuild.yml` - Cloud Build設定ファイル
- `docker-compose.yml` - ローカル開発用Docker Compose設定

## 設計上のポイント

このサンプルプロジェクトは、Cloud Build環境内で複数のサービスを協調させながらE2Eテストを実行する方法を示しています。主なポイントは以下の通りです：

1. Docker in Dockerパターンを利用したサービスの起動
2. ネットワーク設定による各サービス間の通信
3. 依存関係の順序管理とサービス起動の待機
