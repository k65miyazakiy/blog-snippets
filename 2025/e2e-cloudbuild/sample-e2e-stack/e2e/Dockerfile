FROM mcr.microsoft.com/playwright:v1.52.0-noble

WORKDIR /e2e

# テスト関連ファイルをコピー
COPY . .

# 依存関係のインストール
RUN npm install

# テスト設定ファイルの作成
RUN echo 'module.exports = { use: { headless: true } };' > playwright.config.js

# テスト実行
CMD ["npx", "playwright", "test"]
