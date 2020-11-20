# 使用Docker Registry搭建Docker私有仓库

- https://docs.docker.com/registry/
- https://docs.docker.com/registry/spec/api/
- https://www.cnblogs.com/Eivll0m/p/7089675.html

Docker Registry由三个部分组成：index，registry，registry client。
可以把Index认为是负责登录、负责认证、负责存储镜像信息和负责对外显示的外部实现，而registry则是负责存储镜像的内部实现，而Registry Client则是docker客户端。

docker pull registry

Run a local registry: Quick Version

```shell
docker run -d -p 5000:5000 --restart always --name registry \
-v /docker/registry:/var/lib/registry \
-v `pwd`/config.yml:/etc/docker/registry/config.yml \
registry
```

访问http://127.0.0.01:5000/v2/_catalog

```
docker run -d \
  --restart=always \
  --name registry \
  -v `pwd`/auth:/auth \
  -e "REGISTRY_AUTH=htpasswd" \
  -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
  -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
  -v `pwd`/certs:/certs \
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.cer \
  -e REGISTRY_HTTP_TLS_KEY=/certs/hub.ymq.io.key \
  -p 443:443 \
  registry:2

```
### cat config.yml
```
version: 0.1
log:
 fields:
 service: registry
storage:
 delete:
  enabled: true
 cache:
  blobdescriptor: inmemory
 filesystem:
  rootdirectory: /var/lib/registry
http:
 addr: :5000
 headers:
  X-Content-Type-Options: [nosniff]
health:
 storagedriver:
 enabled: true
 interval: 10s
 threshold: 3

```

Now, use it from within Docker:

镜像名称由 repository 和 tag 两部分组成，默认为latest。可以在docker build 时用格式image:tag指定，
而 repository 的完整格式为：[registry-host]:[port]/[username]/xxx

$ docker pull ubuntu
$ docker tag ubuntu localhost:5000/ubuntu
$ docker push localhost:5000/ubuntu

查看镜像名
` curl -s -XGET localhost:5000/v2/_catalog | python -mjson.tool`

查看镜像reversion
```
# ls /var/lib/registry/docker/registry/v2/repositories/jenkins/_manifests/revisions/sha256
0de43cde2c4b864a8e4a84bbd9958e47c5d851319f118203303d040b0a74f159
```
垃圾回收
```
# docker exec -it 507320e9dbd3 \
registry garbage-collect /etc/docker/registry/config.yml
```

## 问题

docker push镜像到仓库的时候，报错了：
Get https://172.16.5.181:5000/v1/_ping: http: server gave HTTP response to HTTPS client

这是因为http的仓库如果本地的docker没有配置非安全的指向是无法直接推送的。那么下来，我们来看看如何配置非安装访问docker仓库。

配置docker服务访问非安全docker仓库


在/etc/docker目录下，添加一个daemon.json文件，写上非安全访问的仓库IP:端口号
```
[root@server81 docker]# cat daemon.json
{"insecure-registries":["172.16.5.181:5000"]}
[root@server81 docker]# 
[root@server81 docker]# pwd
/etc/docker
[root@server81 docker]# 
## 重启docker服务
[root@server81 docker]# service docker restart
Redirecting to /bin/systemctl restart docker.service
[root@server81 docker]# 

```
**这是因为/etc/default/docker文件是为upstart和SysVInit准备的（正如文件第一行注释所言），而使用service命令时并不会读取它，因此我们还需要做如下更改：
https://blog.csdn.net/sch0120/article/details/53160885**


```
vim restartRegistry.sh 

docker stop registry
docker rm registry
docker run -d -p 5000:5000 --name=registry --restart=always \
  --privileged=true \
  --log-driver=none \
  -v /root/registry/registrydata:/var/lib/registry \
  registry:2
```

### Docker registry仓库历史镜像批量清理

https://blog.csdn.net/jiankunking/article/details/89964997
https://blog.csdn.net/ywq935/article/details/83828888


![](https://gitee.com/owen2016/pic-hub/raw/master/1603728288_20200525134404055_1119047090.png)