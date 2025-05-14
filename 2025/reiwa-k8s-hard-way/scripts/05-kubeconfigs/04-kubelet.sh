#!/bin/bash

set -e
cd /etc/kubernetes

## kubelet用のkubeconfigの作成

# kubelet ユーザー用の鍵と証明書
NODE_NAME=$(hostname -s)  # ノード名を取得
sudo openssl genrsa -out kubelet.key 2048
sudo openssl req -new -key kubelet.key -subj "/CN=system:node:${NODE_NAME}/O=system:nodes" -out kubelet.csr
sudo openssl x509 -req -in kubelet.csr -CA pki/ca.crt -CAkey pki/ca.key -CAcreateserial -out kubelet.crt -days 10000

# kubelet.kubeconfig の作成
KUBE_USER="system:node:${NODE_NAME}"
KUBE_CONFIG="kubelet.kubeconfig"

sudo kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://${MASTER_IP}:6443 \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/var/lib/kubelet/pki/kubelet.crt \
  --client-key=/var/lib/kubelet/pki/kubelet.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

sudo kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}

# 権限設定
sudo chmod 600 ${KUBE_CONFIG}  # kubeletのみが読み取れるよう権限を制限