#!/bin/bash

set -e
cd /etc/kubernetes

## Controller Mnager用のkubeconfigの作成

# 証明書の作成
openssl genrsa -out controller-manager.key 2048
openssl req -new -key controller-manager.key -subj "/CN=system:kube-controller-manager" -out controller-manager.csr
openssl x509 -req -in controller-manager.csr -CA pki/ca.crt -CAkey pki/ca.key -CAcreateserial -out controller-manager.crt -days 10000

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