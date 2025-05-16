#!/bin/bash

set -e

## kubeletの起動設定
# サーバーの設定
cat <<EOF | sudo tee /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
clusterDomain: cluster.local
clusterDNS:
- 10.96.0.10
kubeReserved:
  cpu: 100m
  memory: 100Mi
  ephemeral-storage: 1Gi
kubeAPIQPS: 50
kubeAPIBurst: 100
cgroupDriver: cgroupfs  # または systemd（環境による）
EOF

# ユニットファイルの設定（ドロップイン）
mkdir -p /etc/systemd/system/kubelet.service.d/
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS
EOF

## kubeletを起動する
sysstemctl daemon-reload
systemctl restart kubelet