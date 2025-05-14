#!/bin/bash

# 05含めて後で整理する

set -e
cd sudo mkdir -p /etc/kubernetes/pki

# フロントプロキシ CA
sudo openssl genrsa -out front-proxy-ca.key 2048
sudo openssl req -x509 -new -nodes -key front-proxy-ca.key -subj "/CN=front-proxy-ca" -days 10000 -out front-proxy-ca.crt

# フロントプロキシクライアント
sudo openssl genrsa -out front-proxy-client.key 2048
sudo openssl req -new -key front-proxy-client.key -subj "/CN=front-proxy-client" -out front-proxy-client.csr
sudo openssl x509 -req -in front-proxy-client.csr -CA front-proxy-ca.crt -CAkey front-proxy-ca.key -CAcreateserial -out front-proxy-client.crt -days 10000
