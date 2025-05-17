## kubectlの権限設定

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.kubeconfig $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## nginxポッドの起動

```
kubectl run nginx --image=nginx
```

## ポートフォワーディング

```
kubectl port-forward nginx 8080:80
```

ポートフォワード後は別のSSGセッションから`curl localhost:8080`としてください。