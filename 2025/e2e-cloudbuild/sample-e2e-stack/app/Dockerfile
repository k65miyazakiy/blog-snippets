FROM golang:1.24-alpine

WORKDIR /app

# 依存関係のインストール
COPY go.mod ./
RUN go mod download

# ソースコードのコピー
COPY . .

# アプリケーションのビルド
RUN go build -o main .

# 実行
EXPOSE 8080
CMD ["./main"]
