#!/bin/bash

set -e
cd /etc/kubernetes

## kubelet用のkubeconfigの作成

# kubelet.kubeconfig の作成
MASTER_IP=$(hostname -I | awk '{print $1}')
NODE_NAME=$(hostname -s)
CLUSTER_NAME="kubernetes"
KUBE_USER="system:node:${NODE_NAME}"
KUBE_CONFIG="kubelet.kubeconfig"

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://${MASTER_IP}:6443 \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \
  --client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}

# 権限設定
chmod 600 ${KUBE_CONFIG}  # kubeletのみが読み取れるよう権限を制限