# Secret

[TOC]

Secret对象与ConfigMap对象类似，但它主要用于存储以下敏感信息，例如密码，OAuth token和SSH key等等。将这些信息存储在secret中，和直接存储在Pod的定义中，或Docker镜像定义中相比，更加安全和灵活。

## Secret 类型

Secret有三种类型：

- Opaque：使用base64编码存储信息，可以通过base64 --decode解码获得原始数据，因此安全性弱。

- kubernetes.io/dockerconfigjson：用于存储docker registry的认证信息。

- kubernetes.io/service-account-token：用于被 serviceaccount 引用。serviceaccout 创建时 Kubernetes 会默认创建对应的 secret。Pod 如果使用了 serviceaccount，对应的 secret 会自动挂载到 Pod 的 `/run/secrets/kubernetes.io/serviceaccount` 目录中。

![secret-type](images/secret-type.png)

## 创建 Secret (Opaque类型)

Opaque类型的Secret，其value为base64编码后的值

### 1. 从文件中创建Secret

分别创建两个名为username.txt和password.txt的文件：

``` shell
echo -n "admin" > ./username.txt
echo -n "123456" > ./password.txt
```

使用kubectl create secret命令创建secret：

`kubectl create secret generic db-user-pass --from-file=./username.txt --from-file=./password.txt`

![secret-1](images/secret-1.png)

### 2. 使用 yaml描述文件创建Secret

首先使用base64对数据进行编码：

``` shell
echo -n 'admin' | base64
YWRtaW4=

$ echo -n '123456' | base64
MTIzNDU2
```

创建一个类型为Secret的yaml描述文件：

``` yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MTIzNDU2
```

`kubectl create -f ./secret.yaml`

## 使用 Secret

创建好Secret之后，可以通过两种方式使用：

- 以Volume方式
- 以环境变量方式

### 1. 将Secret挂载到Volume中

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
```

进入pod 查看挂载：

``` shell
user@owen-ubuntu:~$ kubectl exec -it mypod -- /bin/sh
# pwd
/data
# ls /etc/foo
password  username
# cat /etc/foo/password
123456# cat /etc/foo/username
admin#
```

也可以只挂载Secret中特定的key：

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
      items:
      - key: username
        path: my-group/my-username
```

在这种情况下：

- username 存储在/etc/foo/my-group/my-username中
- password未被挂载

### 2. 将Secret设置为环境变量

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```

## kubernetes.io/dockerconfigjson

kubernetes.io/dockerconfigjson用于存储docker registry的认证信息，可以直接使用kubectl create secret命令创建：

``` shell
kubectl create secret docker-registry myregistrykey \
   --docker-server=DOCKER_REGISTRY_SERVER \
   --docker-username=DOCKER_USER --docker-password=DOCKER_PASSWORD \
   --docker-email=DOCKER_EMAIL
```

查看secret的内容：
![secret-docker](images/secret-docker.png)

通过 base64 对 secret 中的内容解码：

``` shell
user@owen-ubuntu:~$ echo "eyJhdXRocyI6eyJET0NLRVJfUkVHSVNUUllfU0VSVkVSIjp7InVzZXJuYW1lIjoiRE9DS0VSX1VTRVIiLCJwYXNzd29yZCI6IkRPQ0tFUl9QQVNTV09SRCIsImVtYWlsIjoiRE9DS0VSX0VNQUlMIiwiYXV0aCI6IlJFOURTMFZTWDFWVFJWSTZSRTlEUzBWU1gxQkJVMU5YVDFKRSJ9fX0="|base64 --decode

{"auths":{"DOCKER_REGISTRY_SERVER":{"username":"DOCKER_USER","password":"DOCKER_PASSWORD","email":"DOCKER_EMAIL","auth":"RE9DS0VSX1VTRVI6RE9DS0VSX1BBU1NXT1JE"}}}
```

也可以直接读取 ~/.dockercfg 的内容来创建

```shell
kubectl create secret docker-registry myregistrykey \
  --from-file="~/.dockercfg"
```

### 使用 imagePullSecrets

``` shell
kubectl create secret docker-registry myregistrykey \
   --docker-server=harbor.augmentum.com.cn \
   --docker-username=owen.li --docker-password=********** \
   --docker-email=owenli@augmentum.com.cn
```

在创建 Pod 的时候，通过 imagePullSecrets 来引用刚创建的 myregistrykey:

``` yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: vuejs
spec:
  replicas: 1
  selector:
    matchLabels:
     app: vuejs
  template:
    metadata:
      labels:
        app: vuejs
    spec:
      containers:
      - name: vuejs
        image: harbor.augmentum.com.cn/augops/vuejs-docker:1.0.61_master_9438c18
        ports:
        - containerPort: 80
      imagePullSecrets:
       - name: myregistrykey

---
apiVersion: v1
kind: Service
metadata:
  name: vuejs-svc
spec:
  type: NodePort
  selector:
    app: vuejs
  ports:
    - protocol: TCP
      port: 8088
      targetPort: 80
      nodePort: 30081
```

## kubernetes.io/service-account-token

用于被 serviceaccount 引用

serviceaccout 创建时 Kubernetes 会默认创建对应的 secret。Pod 如果使用了 serviceaccount，对应的 secret 会自动挂载到 Pod 的 `/run/secrets/kubernetes.io/serviceaccount` 目录中。

![images/secret-pod-token-1](images/secret-pod-token-1.png)

![images/secret-pod-token-2](images/secret-pod-token-2.png)