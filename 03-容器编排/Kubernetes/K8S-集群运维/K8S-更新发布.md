# Kubernetes 更新发布

[TOC]

## 制作不同版本的nginx镜像

``` shell
# Dockerfile
FROM harbor.kevin.com/base/nginx-base:1.14.2
MAINTAINER Kevin Hao kevinhao@aliyun.com

ADD nginx.conf /usr/local/nginx/conf/nginx.conf
ADD index.html /usr/local/nginx/html/index.html

EXPOSE 80 443

CMD ["nginx"]
root@k8s-master1:/dockerfile/nginx/dockerfile# vim nginx.conf
user nginx nginx;
worker_processes auto;

daemon off;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    sendfile on;
    keepalive_timeout 60;

    server {
        listen 80;
        location / {
            root html;
            index index.html index.htm;
        }

        location /webapp {
            root html;
            index index.html index.htm;
        }
        error_page 500 502 504 /50x.html;

        location = /50x.html {
            root html;
        }
    }
}
```

``` shell
root@k8s-master1:/dockerfile/nginx/dockerfile# echo "nginx v1" >index.html
root@k8s-master1:/dockerfile/nginx/dockerfile# docker build -t harbor.kevin.com/kevin/nginx:v1.0 .
root@k8s-master1:/dockerfile/nginx/dockerfile# docker push harbor.kevin.com/kevin/nginx:v1.0

root@k8s-master1:/dockerfile/nginx/dockerfile# echo "nginx v1.1" >index.html
root@k8s-master1:/dockerfile/nginx/dockerfile# docker build -t harbor.kevin.com/kevin/nginx:v1.1 .
root@k8s-master1:/dockerfile/nginx/dockerfile# docker push harbor.kevin.com/kevin/nginx:v1.1

root@k8s-master1:/dockerfile/nginx/dockerfile# echo "nginx v2.0" >index.html
root@k8s-master1:/dockerfile/nginx/dockerfile# docker build -t harbor.kevin.com/kevin/nginx:v2.0 .
root@k8s-master1:/dockerfile/nginx/dockerfile# docker push harbor.kevin.com/kevin/nginx:v2.0

root@k8s-master1:/dockerfile/nginx/dockerfile# echo "nginx v3.0" >index.html
root@k8s-master1:/dockerfile/nginx/dockerfile# docker build -t harbor.kevin.com/kevin/nginx:v3.0 .
root@k8s-master1:/dockerfile/nginx/dockerfile# docker push harbor.kevin.com/kevin/nginx:v3.0
```

## 编写yaml 文件

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: kevin
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: harbor.kevin.com/kevin/nginx:v1.0
        ports:
        - containerPort: 80

        resources:
          limits:
            cpu: 2
            memory: 1Gi
          requests:
            cpu: 200m
            memory: 256Mi

---
kind: Service
apiVersion: v1
metadata:
  labels:
    app: k8s-nginx-service-label
  name: k8s-nginx-service
  namespace: kevin
spec:
  type: NodePort
  ports:
  - name: http
    port: 80
    protocol: TCP
    targetPort: 80
    nodePort: 30004
  selector:
    app: nginx
```

`kubectl apply -f nginx.yml --record=true`

## 使用set image进行升级

``` shell
//v1.1
root@k8s-master1:~# kubectl set image deployment/nginx-deployment nginx=harbor.kevin.com/kevin/nginx:v1.1 -n kevin
deployment.apps/nginx-deployment image updated
root@k8s-master1:~# curl 172.16.1.34:30004
nginx v1.1

//v2.0
root@k8s-master1:~# kubectl set image deployment/nginx-deployment nginx=harbor.kevin.com/kevin/nginx:v2.0 -n kevin
deployment.apps/nginx-deployment image updated
root@k8s-master1:~# curl 172.16.1.34:30004
nginx v2.0

//v3.0
root@k8s-master1:~# kubectl set image deployment/nginx-deployment nginx=harbor.kevin.com/kevin/nginx:v3.0 -n kevin
deployment.apps/nginx-deployment image updated
root@k8s-master1:~# curl 172.16.1.34:30004
nginx v3.0
```

## 查看历史版本信息

``` shell
root@k8s-master1:~# kubectl rollout history deployment nginx-deployment -n kevin
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=nginx.yml --record=true
2         kubectl apply --filename=nginx.yml --record=true
3         kubectl apply --filename=nginx.yml --record=true
4         kubectl apply --filename=nginx.yml --record=true
```

## 回滚到上一个版本

``` shell
root@k8s-master1:~# kubectl rollout undo deployment nginx-deployment -n kevin
deployment.apps/nginx-deployment rolled back
root@k8s-master1:~# curl 172.16.1.34:30004
nginx v2.0
root@k8s-master1:~# kubectl rollout history deployment nginx-deployment -n kevin
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
1         kubectl apply --filename=nginx.yml --record=true
2         kubectl apply --filename=nginx.yml --record=true
4         kubectl apply --filename=nginx.yml --record=true
5         kubectl apply --filename=nginx.yml --record=true
```

## 回滚到指定版本

``` shell
root@k8s-master1:~# kubectl rollout undo deployment nginx-deployment --to-revision=1 -n kevin
deployment.apps/nginx-deployment rolled back
root@k8s-master1:~# curl 172.16.1.34:30004
nginx v1
root@k8s-master1:~# kubectl rollout history deployment nginx-deployment -n kevin
deployment.apps/nginx-deployment
REVISION  CHANGE-CAUSE
2         kubectl apply --filename=nginx.yml --record=true
4         kubectl apply --filename=nginx.yml --record=true
5         kubectl apply --filename=nginx.yml --record=true
6         kubectl apply --filename=nginx.yml --record=true
```