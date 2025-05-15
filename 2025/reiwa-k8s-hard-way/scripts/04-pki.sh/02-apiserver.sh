#!/bin/bash

set -e
cd /etc/kubernetes/pki

### api-serverのサーバー証明書および関連クライアント証明書の作成

## サーバー証明書
# 鍵の作成
openssl genrsa -out apiserver.key 2048

# 証明書を作成するための設定ファイル
cat <<EOF > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = MASTER_IP
EOF

# MASTER_IP を実際のマスターノード IP に置き換え
sed -i "s/MASTER_IP/$(hostname -I | awk '{print $1}')/g" openssl.cnf

# CSR の作成, 証明書の署名
openssl req -new -key apiserver.key -subj "/CN=kube-apiserver" -out apiserver.csr -config openssl.cnf
openssl x509 -req -in apiserver.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver.crt -days 10000 -extensions v3_req -extfile openssl.cnf

## etcdへのクライアント証明書
openssl genrsa -out apiserver-etcd-client.key 2048
openssl req -new -key apiserver-etcd-client.key -subj "/CN=kube-apiserver-etcd-client/O=system:masters" -out apiserver-etcd-client.csr
openssl x509 -req -in apiserver-etcd-client.csr -CA etcd/ca.crt -CAkey etcd/ca.key -CAcreateserial -out apiserver-etcd-client.crt -days 10000

## 各コンポーネントからapiserverへ接続する際のクライアント証明書

# 管理ユーザー用クライアント証明書
openssl genrsa -out admin.key 2048
openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
openssl x509 -req -in admin.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out admin.crt -days 10000

# Controller Manager 用クライアント証明書
openssl genrsa -out controller-manager.key 2048
openssl req -new -key controller-manager.key -subj "/CN=system:kube-controller-manager" -out controller-manager.csr
openssl x509 -req -in controller-manager.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out controller-manager.crt -days 10000

# Scheduler 用クライアント証明書
openssl genrsa -out scheduler.key 2048
openssl req -new -key scheduler.key -subj "/CN=system:kube-scheduler" -out scheduler.csr
openssl x509 -req -in scheduler.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out scheduler.crt -days 10000

# kubelet 用クライアント証明書
NODE_NAME=$(hostname -s)  # ノード名を取得
openssl genrsa -out apiserver-kubelet-client.key 2048
openssl req -new -key apiserver-kubelet-client.key -subj "/CN=system:node:${NODE_NAME}/O=system:nodes" -out apiserver-kubelet-client.csr
openssl x509 -req -in apiserver-kubelet-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out apiserver-kubelet-client.crt -days 10000
