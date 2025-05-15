#!/bin/bash

## デバッグ用途に利用するスニペット集です。

# systemctl cat
echo "alias sccapi='sudo systemctl cat kube-apiserver'" >> ~/.bashrc
echo "alias sccetcd='sudo systemctl cat etcd'" >> ~/.bashrc
echo "alias sccklet='sudo systemctl cat kubelet'" >> ~/.bashrc
echo "alias scccm='sudo systemctl cat kube-controller-manager'" >> ~/.bashrc
echo "alias sccsch='sudo systemctl cat kube-scheduler'" >> ~/.bashrc

# systemctl status
echo "alias scsapi='sudo systemctl status kube-apiserver'" >> ~/.bashrc
echo "alias scsetcd='sudo systemctl status etcd'" >> ~/.bashrc
echo "alias scsklet='sudo systemctl status kubelet'" >> ~/.bashrc
echo "alias scscm='sudo systemctl status kube-controller-manager'" >> ~/.bashrc
echo "alias scssch='sudo systemctl status kube-scheduler'" >> ~/.bashrc

# journalctl
echo "alias tailapi='sudo journalctl -u kube-apiserver -n 10'" >> ~/.bashrc
echo "alias tailetc='sudo journalctl -u etcd -n 10'" >> ~/.bashrc
echo "alias tailklet='sudo journalctl -u kubelet -n 10'" >> ~/.bashrc
echo "alias tailcm='sudo journalctl -u kube-controller-manager -n 10'" >> ~/.bashrc
echo "alias tailsch='sudo journalctl -u kube-scheduler -n 10'" >> ~/.bashrc