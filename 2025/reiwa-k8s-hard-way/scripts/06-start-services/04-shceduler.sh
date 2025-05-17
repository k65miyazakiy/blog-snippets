#!/bin/bash

set -e
cd

K8S_VER=v1.33.0

wget https://dl.k8s.io/${K8S_VER}/bin/linux/amd64/kube-scheduler
chmod +x kube-scheduler
sudo mv kube-scheduler /usr/local/bin/

# kube-scheduler サービスファイルの作成
cat <<EOF | sudo tee /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --authentication-kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
  --authorization-kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
  --bind-address=127.0.0.1 \\
  --kubeconfig=/etc/kubernetes/scheduler.kubeconfig \\
  --leader-elect=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# kube-scheduler の起動
sudo systemctl daemon-reload
sudo systemctl enable kube-scheduler
sudo systemctl start kube-scheduler