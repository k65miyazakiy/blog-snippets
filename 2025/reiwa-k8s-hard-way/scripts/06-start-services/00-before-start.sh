IP=$(ip -4 addr show scope global | grep -m1 inet | awk '{print $2}' | cut -d/ -f1)
sudo sed -i '/kubernetes/d' /etc/hosts
sudo echo "$IP kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local" >> /etc/hosts