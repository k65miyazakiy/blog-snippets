#!/bin/bash

# 05含めて後で整理する

set -e
cd 

## 設定や証明書の保存先の作成
mkdir -p /etc/kubernetes/manifests
mkdir -p /etc/kubernetes/pki
mkdir -p /var/lib/kubernetes
mkdir -p /var/lib/etcd
mkdir -p /var/log/kubernetes

## 認証局(CA,Certificate Authorities)の作成
cd /etc/kubernetes/pki
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -subj "/CN=kubernetes-ca" -days 10000 -out ca.crt
