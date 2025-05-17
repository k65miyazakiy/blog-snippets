#!/bin/bash

set -e
cd /etc/kubernetes

## クラスタ管理者用のkubeconfigの作成

# admin.kubeconfig の作成
MASTER_IP=$(hostname -I | awk '{print $1}')
CLUSTER_NAME="kubernetes"
KUBE_USER="admin"
KUBE_CONFIG="admin.kubeconfig"

  # --embed-certs=true \
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --server=https://${MASTER_IP}:6443 \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/etc/kubernetes/pki/admin.crt \
  --client-key=/etc/kubernetes/pki/admin.key \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}