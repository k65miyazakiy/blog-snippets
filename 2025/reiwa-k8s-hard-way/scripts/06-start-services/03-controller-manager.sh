#!/bin/bash

set -e
cd

K8S_VER=v1.33.0

# kube-controller-manager バイナリのダウンロード
wget https://dl.k8s.io/${K8S_VER}/bin/linux/amd64/kube-controller-manager
chmod +x kube-controller-manager
mv kube-controller-manager /usr/local/bin/

# kube-controller-manager サービスファイルの作成
cat <<EOF > /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --allocate-node-cidrs=true \\
  --authentication-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --authorization-kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --bind-address=127.0.0.1 \\
  --client-ca-file=/etc/kubernetes/pki/ca.crt \\
  --cluster-cidr=10.244.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt \\
  --cluster-signing-key-file=/etc/kubernetes/pki/ca.key \\
  --controllers=*,bootstrapsigner,tokencleaner \\
  --kubeconfig=/etc/kubernetes/controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/etc/kubernetes/pki/ca.crt \\
  --service-account-private-key-file=/etc/kubernetes/pki/sa.key \\
  --service-cluster-ip-range=10.96.0.0/12 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# kube-controller-manager の起動
systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl start kube-controller-manager
systemctl status kube-controller-manager