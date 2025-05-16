#!/bin/bash

set -e

## カーネルモジュールの設定など
# 不足しているモジュールがあれば読み込み
sudo modprobe ip_tables
sudo modprobe iptable_nat
sudo modprobe br_netfilter
sudo modprobe vxlan

# IP転送の有効化
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.bridge.bridge-nf-call-iptables=1

## CNI（weavenet）のインストールと設定
wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml -O weave-custom.yaml

# TODO 環境変数など加える