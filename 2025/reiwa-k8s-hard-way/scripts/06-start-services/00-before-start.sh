#!/bin/bash

set -e

## kubernetesが期待するホスト名での解決を可能にする

IP=$(ip -4 addr show scope global | grep -m1 inet | awk '{print $2}' | cut -d/ -f1)
sed -i '/kubernetes/d' /etc/hosts
echo "$IP kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local" >> /etc/hosts
