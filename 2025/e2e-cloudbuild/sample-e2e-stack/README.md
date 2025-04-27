# E2Eテスト用サンプルアプリケーション

このリポジトリは、Cloud Buildパイプライン内でE2Eテストを実行するサンプルアプリケーションを提供します。

## アプリケーション構成

- **フロントエンド/バックエンド**: Goによるシンプルなウェブアプリケーション
- **データベース**: PostgreSQL
- **E2Eテスト**: Playwright

## ローカルでの実行方法

```bash
# Docker Composeでアプリケーションを起動
docker compose up -d app db

# E2Eテストの実行
docker compose up e2e
```

## Cloud Buildでの実行方法

CloudBuildと連携可能な任意のリポジトリに`sample-e2e-stack`以下の内容を丸ごとアップロードします。
その後、Cloudbuildのトリガーを作成して、リポジトリとの連携を行って、その後実行してください。
