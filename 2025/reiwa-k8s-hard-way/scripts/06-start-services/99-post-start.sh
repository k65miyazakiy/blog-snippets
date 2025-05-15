#!/bin/bash

set -e
cd $HOME

## kubectlの使用設定

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.kubeconfig $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config