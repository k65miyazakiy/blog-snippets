#!/bin/bash

set -e
cd /etc/kubernetes

## Controller Mnager用のkubeconfigの作成

# kubeconfig の作成
KUBE_USER="system:kube-controller-manager"
KUBE_CONFIG="controller-manager.kubeconfig"

kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-credentials ${KUBE_USER} \
  --client-certificate=/etc/kubernetes/controller-manager.crt \
  --client-key=/etc/kubernetes/controller-manager.key \
  --embed-certs=true \
  --kubeconfig=${KUBE_CONFIG}

kubectl config set-context ${KUBE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${KUBE_USER} \
  --kubeconfig=${KUBE_CONFIG}

kubectl config use-context ${KUBE_USER}@${CLUSTER_NAME} --kubeconfig=${KUBE_CONFIG}