#!/bin/bash

set -e
cd /etc/kubernetes

## shceduler用のkubeconfigの作成

# kubeconfig の作成
CLUSTER_NAME="kubernetes"
KUBE_USER="system:kube-scheduler"
KUBE_CONFIG="scheduler.kubeconfig"

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/etc/kubernetes/pki/scheduler.crt \
  --client-key=/etc/kubernetes/pki/scheduler.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}