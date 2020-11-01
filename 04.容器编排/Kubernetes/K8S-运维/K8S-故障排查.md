# k8s运维和问题排查总结

[TOC]

## kubectl

### 1. kubectl 所有选项

``` shell
--alsologtostderr[=false]: 同时输出日志到标准错误控制台和文件。

--api-version="": 和服务端交互使用的API版本。

--certificate-authority="": 用以进行认证授权的.cert文件路径。

--client-certificate="": TLS使用的客户端证书路径。

--client-key="": TLS使用的客户端密钥路径。

--cluster="": 指定使用的kubeconfig配置文件中的集群名。

--context="": 指定使用的kubeconfig配置文件中的环境名。

--insecure-skip-tls-verify[=false]: 如果为true，将不会检查服务器凭证的有效性，这会导致你的HTTPS链接变得不安全。

--kubeconfig="": 命令行请求使用的配置文件路径。

--log-backtrace-at=0: 当日志长度超过定义的行数时，忽略堆栈信息。

--log-dir="": 如果不为空，将日志文件写入此目录。

--log-flush-frequency=5s: 刷新日志的最大时间间隔。

--logtostderr[=true]: 输出日志到标准错误控制台，不输出到文件。

--match-server-version[=false]: 要求服务端和客户端版本匹配。

-n, --namespace="": 如果不为空，命令将使用此namespace。

--password="": API Server进行简单认证使用的密码。

-s, --server="": Kubernetes API Server的地址和端口号。

--stderrthreshold=2: 高于此级别的日志将被输出到错误控制台。

--token="": 认证到API Server使用的令牌。

--user="": 指定使用的kubeconfig配置文件中的用户名。

--username="": API Server进行简单认证使用的用户名。

-v, --v=0: 指定输出日志的级别。

--vmodule=: 指定输出日志的模块，格式如下：pattern=N，使用逗号分隔。
```

### 格式化输出

要以特定的格式向终端窗口输出详细信息，可以在 kubectl 命令中添加 -o 或者 -output 标志。

``` shell
-o=wide 以纯文本格式输出任何附加信息，对于 Pod ，包含节点名称
-o=yaml 输出 YAML 格式的 API 对象
```

### 2. kubectl命令

``` shell

kubectl annotate 更新资源的注解，支持的资源包括但不限于（大小写不限）pods (po)、services (svc)、 replicationcontrollers (rc)、nodes (no)、events (ev)、componentstatuses (cs)、 limitranges (limits)、persistentvolumes (pv)、persistentvolumeclaims (pvc)、 resourcequotas (quota)和secrets。

kubectl api-versions 以“组/版本”的格式输出服务端支持的API版本。

kubectl apply 通过文件名或控制台输入，对资源进行配置，接受JSON或者YAML格式的描述文件

kubectl attach 连接到一个正在运行的容器

kubectl autoscale 对replication controller进行自动伸缩

kubectl cluster-info 输出集群信息

kubectl config 修改kubeconfig配置文件。

kubectl create 通过文件名或控制台输入，创建资源。

kubectl delete 通过文件名、控制台输入、资源名或者label selector删除资源。

kubectl describe 输出指定的一个/多个资源的详细信息。

kubectl edit 编辑服务端的资源。

kubectl exec 在容器内部执行命令

kubectl expose 输入replication controller，service或者pod，并将其暴露为新的kubernetes service。

kubectl get 输出一个/多个资源。

kubectl label 更新资源的label。

kubectl logs 输出pod中一个容器的日志。

kubectl namespace （已停用）设置或查看当前使用的namespace。

kubectl patch 通过控制台输入更新资源中的字段。

kubectl port-forward 将本地端口转发到Pod。

kubectl proxy 为Kubernetes API server启动代理服务器。

kubectl replace 通过文件名或控制台输入替换资源。

kubectl rolling-update 对指定的replication controller执行滚动升级。

kubectl run 在集群中使用指定镜像启动容器。

kubectl scale 为replication controller设置新的副本数。

kubectl stop（已停用）通过资源名或控制台输入安全删除资源。

kubectl version 输出服务端和客户端的版本信息。
```

## 问题排查

### 1. 常用命令

``` shell
1. 列出所有namespace下所有Container

    $ kubectl get pods --all-namespaces -o jsonpath="{..image}" | \
    tr -s '[[:space:]]' '\n' | \
    sort | \
    uniq -c

2. 进入Pod执行/bin/bash
    $ kubectl exec test-output-b7b965464-xq8s8 -it -n kube-system /bin/bash
    $ kubectl exec test-output-b7b965464-xq8s8 -c ruby-container -it -n kube-system /bin/bash (-c 指定某个container)

3. 重启Depolyment里面的Pod
    $ kubectl delete pods <pod_name> -n namespace （如果只有单个Pod，删除Pod之后Deployment会自动拉取一个新的Pod）

4. 删除某个DaemonSet
    $ kubectl delete ds fluentd -n kube-system

5. 查看node状态
    $ kubectl get nodes

6. 查看某个namespace的events
    $ kubectl get events -n kuby-system

7. 查看DaemonSet滚动升级的进度
    $ kubectl rollout status ds fluentd -n kube-system

8. 强制删除Pod或者DaemonSet
    $ kubectl delete --force --grace-period=0 pod/fluentd-xxxxx -n kube-system (多个pod之间用空格分开)
    $ kubectl delete --force --grace-period=0 ds/fluentd -n kube-system

9. 获取当前集群apiserver地址
    $ (kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")

10. 获取集群认证token
    $ TOKEN=$(kubectl describe secret $(kubectl get secrets | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t')

11. curl请求k8s集群apiserver
    $ curl $APISERVER/api --header "Authorization: Bearer $TOKEN" —insecure

12. kubeconfig配置说明
    1). --certificate-authority: 集群公钥
    2). --client-certification: 客户端证书
    3). --client-key: 客户端私钥
    注意: 客户端的证书需要使用集群公钥也就是–certificate-authority签署，否则是不会被集群认可的
    还可以使用token认证的方式与apiserver进行通信

13. 查询某些pod的pod id
    $ kubectl get all -n mt-xiuxiu -o wide | grep 'po/xiuxiu-php-' | grep 9596c5d6d | cut -d' ' -f1 | grep po | xargs -I {} kubectl get {} -n mt-xiuxiu -o yaml | grep uid | grep -v deb3363a

14. 查看emptydir Volume在node上的目录
    1). 找到pod: $ kubectl get po -n cgltest -o wide | grep k8s-log
    2). 查看pod的node ip: $ kubectl get po k8s-log-7777bbbbcc-9wp6r -n cgltest -o yaml | grep hostIP
    3). 查看pod id: $ kubectl get po k8s-log-7777bbbbcc-9wp6r -n cgltest -o yaml | grep uid
    4). 登录node 查看 /var/lib/kubelet/pods/{pod_id}/volumes/kubernetes.io~empty-dir/ 目录即可

15. 查看所有Namespace下的deployment的yaml
    $ kubectl get deployment --all-namespaces -o yaml

16. 通过kubeconfig访问特定的k8s集群
    $ kubectl get nodes --kubeconfig kubeconfig

17. 查看node对应的污点
    $ kubectl get nodes -o go-template='\t=:\t\n'

18. daemonset滚动更新
    1). 更新yaml配置文件: $ kubectl apply -f daemonset.yaml
    2). 编辑更新策略为: $ kubectl edit ds -n kube-system fluentd (updateStratege.type为RollingUpdate)
    3). 查看更新状态: $ kubectl rollout status ds fluentd -n kube-system

19. 查看pod内某个容器的日志
    $ kubectl logs -f -n kube-system {pod-name} -c {container-name}

20. 删除namespace，将会删除该ns下所有pod
    $ kubectl delete ns my-namespace

21. 拷贝文件到K8s Pod
    1). 拷贝单文件到Pod: $ kubectl cp [file-path] [pod-name]:/[path] 例如 $ kubectl cp sample.dat myapp-759598b9f7-7gbsc:/tmp/
    2). 拷贝目录到Pod: $ kubectl cp [dir-path] [pod-name]:/[path] 例如 $ kubectl cp dir myapp-759598b9f7-7gbsc:/tmp/
    3). 拷贝文件到多个Pod: $ for podname in $(kubectl get pods -n test -o json | jq -r '.items[].metadata.name' | grep cgl-test); do kubectl cp log ${podname}:/tmp/ -n test ; done
    4). 确认文件是否拷贝成功: $ for podname in $(kubectl get pods -n test -o json | jq -r '.items[].metadata.name' | grep cgl-test); do kubectl exec -i ${podname} -n test ls /tmp ; done

```

### kubectl logs

输出pod中一个容器的日志。如果pod只包含一个容器则可以省略容器名。

``` text
kubectl logs [-f] [-p] POD [-c CONTAINER]
kubectl logs 选项

  -c, --container="": 容器名。
  -f, --follow[=false]: 指定是否持续输出日志。
      --interactive[=true]: 如果为true，当需要时提示用户进行输入。默认为true。
      --limit-bytes=0: 输出日志的最大字节数。默认无限制。
  -p, --previous[=false]: 如果为true，输出pod中曾经运行过，但目前已终止的容器的日志。
      --since=0: 仅返回相对时间范围，如5s、2m或3h，之内的日志。默认返回所有日志。只能同时使用since和since-time中的一种。
      --since-time="": 仅返回指定时间（RFC3339格式）之后的日志。默认返回所有日志。只能同时使用since和since-time中的一种。
      --tail=-1: 要显示的最新的日志条数。默认为-1，显示所有的日志。
      --timestamps[=false]: 在日志中包含时间戳
```

``` shell
$ kubectl logs my-pod                                 # dump 输出 pod 的日志（stdout）
$ kubectl logs my-pod -c my-container                 # dump 输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl logs -f my-pod                              # 流式输出 pod 的日志（stdout）
$ kubectl logs -f my-pod -c my-container              # 流式输出 pod 中容器的日志（stdout，pod 中有多个容器的情况下使用）
$ kubectl run -i --tty busybox --image=busybox -- sh  # 交互式 shell 的方式运行 pod
$ kubectl attach my-pod -i                            # 连接到运行中的容器
$ kubectl attach -it nginx -c shell                   # 连接到 shell 容器的 tty
$ kubectl port-forward my-pod 5000:6000               # 转发 pod 中的 6000 端口到本地的 5000 端口
$ kubectl exec my-pod -- ls /                         # 在已存在的容器中执行命令（只有一个容器的情况下）
$ kubectl exec my-pod -c my-container -- ls /         # 在已存在的容器中执行命令（pod 中有多个容器的情况下）
$ kubectl top pod POD_NAME --containers               # 显示指定 pod 和容器的指标度量

# 返回仅包含一个容器的pod nginx的日志快照
$ kubectl logs nginx

# 返回pod ruby中已经停止的容器web-1的日志快照
$ kubectl logs -p -c ruby web-1

# 持续输出pod ruby中的容器web-1的日志
$ kubectl logs -f -c ruby web-1

# 仅输出pod nginx中最近的20条日志
$ kubectl logs --tail=20 nginx

# 输出pod nginx中最近一小时内产生的所有日志
$ kubectl logs --since=1h nginx

```

### 2. 常用问题排查步骤

``` shell
1. 查看Pod状态以及运行的节点
    $ kubectl get pods -n kube-system -o wide

2. 查看Pod事件
    $ kubectl describe pod {pod_name} -n kube-system
    或
    $ kubectl get event -n kube-system --field-selector involvedObject.name=my-pod-zl6m6

3. 查看Events
    $ kubectl get events -n kube-system

4. 查看Node状态
    $ kubectl get nodes
    $ kubectl describe node {node_name}

5. 查看kubelet日志
    $ journalctl -l -u kubelet (Kubelet通常以 systemd 管理)

6. 查看dockerd日志
    $ grep dockerd /var/log/messages

7. 查看containerd日志
    $ grep containerd /var/log/messages

8. 查看containerd-shim日志
    $ grep containerd-shim /var/log/messages

9. 查看docker-runc日志
    $ grep docker-runc /var/log/messages
```

### 3. 相关目录

``` shell
1. Linux K8s(操作系统为Centos)，使用device mapper做为storage driver

    rootfs(镜像)挂载点文件:
    /var/lib/docker/image/devicemapper/layerdb/mounts/{container_id}/mount-id

    rootfs挂载点目录:
    /var/lib/docker/devicemapper/mnt/{mount_id}/rootfs

    容器输出stdout/stderr日志目录:
    /var/log/containers

    容器cgroup配置目录:
    /sys/fs/cgroup/{resource}/docker/{container_id}

    容器配置文件目录:
    /var/lib/docker/containers/{container_id}/config.v2.json

    docker containerd目录:
    /run/docker/containerd/{container_id}

    docker runc状态目录:
    /run/docker/runtime-runc/moby/{container_id}/state.json

    docker runtime目录:
    /run/docker/containerd/daemon/io.containerd.runtime.v1.linux/moby/{container_id}

    emptyDir Volume在Node上目录:
    /var/lib/kubelet/pods/{pod_id}/volumes/kubernetes.io~empty-dir/

2. Mac K8s，使用overlay2做为storage driver

    rootfs(镜像)挂载点文件:
    /var/lib/docker/image/overlay2/layerdb/mounts/{container_id}/mount-id

    rootfs挂载点目录: /var/lib/docker/overlay2/{mount_id}/merged

    容器输出stdout/stderr日志目录: /var/log/containers

    容器cgroup配置目录:
    /sys/fs/cgroup/{resource}/podruntime/docker/kubepods/{container_id}

    容器配置文件目录:
    /var/lib/docker/containers/{container_id}/config.v2.json

    docker containerd目录:
    /run/desktop/docker/containerd/{container_id}

    docker runc状态目录:
    /run/desktop/docker/runtime-runc/moby/{container_id}/state.json

    docker runtime目录:
    /run/desktop/docker/containerd/daemon/io.containerd.runtime.v1.linux/moby/{container_id}

    emptyDir Volume在Node上目录:
    /var/lib/kubelet/pods/{pod_id}/volumes/kubernetes.io~empty-dir/

```