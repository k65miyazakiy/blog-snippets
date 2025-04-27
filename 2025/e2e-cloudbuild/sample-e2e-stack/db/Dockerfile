FROM postgres:17-alpine

# 初期化SQLファイルをコピー
COPY init.sql /docker-entrypoint-initdb.d/

# 環境変数
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=testdb

EXPOSE 5432
