#!/bin/bash

set -e
cd

## etcdのインストールと起動

ETCD_VER=v3.5.6

sudo wget https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo tar xvf etcd-${ETCD_VER}-linux-amd64.tar.gz
sudo mv etcd-${ETCD_VER}-linux-amd64/etcd* /usr/local/bin/

# etcd サービスファイルの作成
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --name $(hostname) \\
  --cert-file=/etc/kubernetes/pki/etcd/server.crt \\
  --key-file=/etc/kubernetes/pki/etcd/server.key \\
  --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt \\
  --peer-key-file=/etc/kubernetes/pki/etcd/peer.key \\
  --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://$(hostname -I | awk '{print $1}'):2380 \\
  --listen-peer-urls https://$(hostname -I | awk '{print $1}'):2380 \\
  --listen-client-urls https://$(hostname -I | awk '{print $1}'):2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://$(hostname -I | awk '{print $1}'):2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster $(hostname)=https://$(hostname -I | awk '{print $1}'):2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# etcd の起動
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd