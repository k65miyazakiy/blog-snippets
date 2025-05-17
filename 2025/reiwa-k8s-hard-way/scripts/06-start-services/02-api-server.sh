#!/bin/bash

set -e
cd 

## kube-apiserverのインストールと実行

K8S_VER=v1.33.0
wget https://dl.k8s.io/${K8S_VER}/bin/linux/amd64/kube-apiserver
chmod +x kube-apiserver
mv kube-apiserver /usr/local/bin/

# kube-apiserver サービスファイルの作成
cat <<EOF > /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=$(hostname -I | awk '{print $1}') \\
  --allow-privileged=true \\
  --authorization-mode=Node,RBAC \\
  --client-ca-file=/etc/kubernetes/pki/ca.crt \\
  --enable-admission-plugins=NodeRestriction \\
  --enable-bootstrap-token-auth=true \\
  --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt \\
  --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt \\
  --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key \\
  --etcd-servers=https://127.0.0.1:2379 \\
  --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt \\
  --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key \\
  --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname \\
  --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt \\
  --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key \\
  --requestheader-allowed-names=front-proxy-client \\
  --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --secure-port=6443 \\
  --service-account-issuer=https://kubernetes.default.svc.cluster.local \\
  --service-account-key-file=/etc/kubernetes/pki/sa.pub \\
  --service-account-signing-key-file=/etc/kubernetes/pki/sa.key \\
  --service-cluster-ip-range=10.96.0.0/12 \\
  --tls-cert-file=/etc/kubernetes/pki/apiserver.crt \\
  --tls-private-key-file=/etc/kubernetes/pki/apiserver.key \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# kube-apiserver の起動
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
# systemctl status kube-apiserver