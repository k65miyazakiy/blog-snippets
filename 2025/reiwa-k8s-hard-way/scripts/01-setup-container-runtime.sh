#!/bin/bash
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/

set -e
cd

## Enable IPv4 packet forwarding
# sysctl params required by setup, params persist across reboots
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sysctl --system

## Kubeletのsystemd cgroupドライバー設定
# ...はkubeletの設定の時に行う

## containerdの設定（cgroupsの設定とdisables_pluginsの処理）
# ...もcontainerdの設定の時に行う