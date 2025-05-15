#!/bin/bash

set -e

## kubeletのサーバー証明書（マニュアル）の作成

mkdir -p  /var/lib/kubelet/pki
cd /var/lib/kubelet/pki

NODE_NAME=$(hostname)
NODE_IP=$(hostname -I | awk '{print $1}')

# 鍵の生成
openssl genrsa -out kubelet-server.key 2048

# OpenSSL設定ファイルの作成
cat > kubelet.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${NODE_NAME}
IP.1 = ${NODE_IP}
EOF

# CSRの生成
openssl req -new -key kubelet-server.key \
    -subj "/CN=system:node:${NODE_NAME}/O=system:nodes" \
    -config kubelet.cnf \
    -out kubelet-server.csr

# 証明書の署名
openssl x509 -req -in kubelet-server.csr \
    -CA /etc/kubernetes/pki/ca.crt \
    -CAkey /etc/kubernetes/pki/ca.key \
    -CAcreateserial \
    -out kubelet-server.crt \
    -extensions v3_req \
    -extfile kubelet.cnf \
    -days 10000