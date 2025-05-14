#!/bin/bash

# 05含めて後で整理する

set -e
cd 

## 設定や証明書の保存先の作成
sudo mkdir -p /etc/kubernetes/manifests
sudo mkdir -p /etc/kubernetes/pki
sudo mkdir -p /var/lib/kubernetes
sudo mkdir -p /var/lib/etcd
sudo mkdir -p /var/log/kubernetes

## 認証局(CA,Certificate Authorities)の作成
cd /etc/kubernetes/pki
sudo openssl genrsa -out ca.key 2048
sudo openssl req -x509 -new -nodes -key ca.key -subj "/CN=kubernetes-ca" -days 10000 -out ca.crt
