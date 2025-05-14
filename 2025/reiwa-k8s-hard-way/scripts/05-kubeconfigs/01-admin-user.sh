#!/bin/bash

set -e
cd /etc/kubernetes

## クラスタ管理者用のkubeconfigの作成

# admin ユーザー用の鍵と証明書
sudo openssl genrsa -out admin.key 2048
sudo openssl req -new -key admin.key -subj "/CN=admin/O=system:masters" -out admin.csr
sudo openssl x509 -req -in admin.csr -CA pki/ca.crt -CAkey pki/ca.key -CAcreateserial -out admin.crt -days 10000

# admin.kubeconfig の作成
MASTER_IP=$(hostname -I | awk '{print $1}')
CLUSTER_NAME="kubernetes"
KUBE_USER="admin"
KUBE_CONFIG="admin.kubeconfig"

sudo kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://${MASTER_IP}:6443 \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/etc/kubernetes/admin.crt \
  --client-key=/etc/kubernetes/admin.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}