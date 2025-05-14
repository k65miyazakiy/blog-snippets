#!/bin/bash

set -e

## etcdサーバー証明書（etcd独自のCA作成）
mkdir -p /etc/kubernetes/pki/etcd
cd /etc/kubernetes/pki/etcd

# 鍵・CSRの作成
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=etcd-ca" -days 10000 -out ca.crt

# 証明書の内容の設定
openssl genrsa -out server.key 2048
cat <<EOF > openssl-etcd.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 127.0.0.1
IP.2 = MASTER_IP
EOF

# 実IPアドレスを設定
sed -i "s/MASTER_IP/$(hostname -I | awk '{print $1}')/g" openssl-etcd.cnf

# etcdサーバー証明書の作成
openssl req -new -key server.key -subj "/CN=kube-etcd" -out server.csr -config openssl-etcd.cnf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 10000 -extensions v3_req -extfile openssl-etcd.cnf

# kube-scheduler, kube-controller-managerが使用するヘルスチェック用のクライアント証明書
openssl genrsa -out healthcheck-client.key 2048
openssl req -new -key healthcheck-client.key -subj "/CN=kube-etcd-healthcheck-client" -out healthcheck-client.csr
openssl x509 -req -in healthcheck-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out healthcheck-client.crt -days 10000

# etcdクラスタのノード間peer通信に使用するクライアント証明書
openssl genrsa -out peer.key 2048
openssl req -new -key peer.key -subj "/CN=etcd-peer" -out peer.csr -config openssl-etcd.cnf
openssl x509 -req -in peer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out peer.crt -days 10000 -extensions v3_req -extfile openssl-etcd.cnf
