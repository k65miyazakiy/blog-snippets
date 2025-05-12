# ビルドステージ
FROM golang:1.24.3-alpine AS builder

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係をコピーしてダウンロード
COPY go.* ./
RUN go mod download

# ソースコードをコピー
COPY *.go ./

# アプリケーションをビルド
RUN CGO_ENABLED=0 GOOS=linux go build -o /simplewebapp

# 実行ステージ
FROM alpine:3.21
RUN apk --no-cache add ca-certificates

# ビルドしたバイナリをコピー
COPY --from=builder /simplewebapp /simplewebapp

# 必要な環境変数を設定
ENV PORT=8080

# 非rootユーザーを使用
RUN adduser -D appuser
USER appuser

# アプリケーションを実行
CMD ["/simplewebapp"]
