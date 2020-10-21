# Pod &&


```yaml
[root@master services]$cat pod_nginx.yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx-container
    image: nginx
    ports:
    - name: nginx-port
      containerPort: 80
```

```yaml
[root@master services]$cat pod_busybox.yml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
spec:
  containers:
  - name: busybox-container
    image: busybox
    command:
      - sleep
      - "360000"
```

`kubectl create -f pod_nginx.yml`
`kubectl create -f pod_busybox.yml`

然后看一下两个pod的ip：

```
[root@master services]$kubectl get pod -o wide
NAME          READY     STATUS    RESTARTS   AGE       IP            NODE
busybox-pod   1/1       Running   0          15m       10.244.1.58   node
nginx-pod     1/1       Running   0          15m       10.244.1.59   node
```

此时，这两个生成的ip，在集群当中任一节点里，都是可以畅通访问的。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021230722.png)
