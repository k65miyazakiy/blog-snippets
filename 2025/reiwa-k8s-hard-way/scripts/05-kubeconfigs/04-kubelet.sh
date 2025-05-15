#!/bin/bash

set -e
cd /etc/kubernetes

## kubelet用のkubeconfigの作成

# kubelet.kubeconfig の作成
KUBE_USER="system:node:${NODE_NAME}"
KUBE_CONFIG="kubelet.kubeconfig"

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://${MASTER_IP}:6443 \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/var/lib/kubelet/pki/kubelet.crt \
  --client-key=/var/lib/kubelet/pki/kubelet.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}

# 権限設定
chmod 600 ${KUBE_CONFIG}  # kubeletのみが読み取れるよう権限を制限