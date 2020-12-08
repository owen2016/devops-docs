# IP & Port & Endpoint

[TOC]

当新手刚学习k8s时候，会被各种的IP 和port 搞晕，其实它们都与k8s service的访问有密切关系，梳理它们之间的差异可以更好了解k8s的服务访问机制。

![IP&Port](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201122230932.png)

## 不同类型的IP

- Node IP：Node节点的IP地址。 节点物理网卡ip
- Pod IP：Pod的IP地址。 Docker Engine根据docker0网桥的IP地址段进行分配的，通常是一个虚拟的二层网络
- Cluster IP：Service的IP地址。 属于Kubernetes集群内部的地址，无法在集群外部直接使用这个地址

### Pod IP

Pod IP 地址是实际存在于某个网卡(可以是虚拟设备)上的，但Service Cluster IP就不一样了，没有网络设备为这个地址负责。它是由kube-proxy使用Iptables规则重新定向到其本地端口，再均衡到后端Pod的。

例如，当Service被创建时，Kubernetes给它分配一个地址10.0.0.1。这个地址从我们启动API的service-cluster-ip-range参数(旧版本为portal_net参数)指定的地址池中分配，比如--service-cluster-ip-range=10.0.0.0/16。假设这个Service的端口是1234。集群内的所有kube-proxy都会注意到这个Service。当proxy发现一个新的service后，它会在本地节点打开一个任意端口，建相应的iptables规则，重定向服务的IP和port到这个新建的端口，开始接受到达这个服务的连接。

当一个客户端访问这个service时，这些iptable规则就开始起作用，客户端的流量被重定向到kube-proxy为这个service打开的端口上，kube-proxy随机选择一个后端pod来服务客户。

### Cluster IP

Service的IP地址，此为虚拟IP地址。外部网络无法ping通，只有kubernetes集群内部访问使用。通过命令 `kubectl -n 命名空间 get Service` 即可查询ClusterIP

Cluster IP是一个虚拟的IP，但更像是一个伪造的IP网络，原因有以下几点

- Cluster IP仅仅作用于Kubernetes Service这个对象，并由Kubernetes管理和分配P地址
- Cluster IP无法被ping，他没有一个“实体网络对象”来响应
- Cluster IP只能结合Service Port组成一个具体的通信端口`Endpoint`，单独的Cluster IP不具备通信的基础，并且他们属于Kubernetes集群这样一个封闭的空间。
- 在不同Service下的pod节点在集群间相互访问可以通过Cluster IP

    ![不同服务的Pod访问](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201022001845.png)

为了实现图上的功能主要需要以下几个组件的协同工作：

- apiserver：在创建service时，apiserver接收到请求以后将数据存储到etcd中。
- kube-proxy：k8s的每个节点中都有该进程，负责实现service功能，这个进程负责感知service，pod的变化，并将变化的信息写入本地的iptables中。
- iptables：使用NAT等技术将virtualIP的流量转至endpoint中

根据是否生成ClusterIP又可分为普通Service和Headless Service两类：

1. **普通Service：**通过为Kubernetes的Service分配一个集群内部可访问的固定虚拟IP（Cluster IP），实现集群内的访问。为最常见的方式。

2. **Headless Service：**该服务不会分配Cluster IP，也不通过kube-proxy做反向代理和负载均衡。而是通过DNS提供稳定的网络ID来访问，DNS会将headless service的后端直接解析为Pod IP列表。`主要供StatefulSet使用`。

## 不同类型的Port

``` yaml
apiVersion: v1
kind: Service
metadata:
 name: nginx-service
spec:
 type: NodePort         // 有配置NodePort，外部流量可访问k8s中的服务
 ports:
 - port: 30080          // 服务访问端口，集群内部访问的端口
   targetPort: 80       // pod控制器中定义的端口（应用访问的端口）
   nodePort: 30001      // NodePort，外部客户端访问的端口
 selector:
  name: nginx-pod
```

### port

- port是k8s集群`内部访问service的端口`(service暴露在Cluster IP上的端口)，即通过`clusterIP: port`可以访问到某个service

### nodePort

- nodePort是`外部访问`k8s集群中service的端口，通过`nodeIP: nodePort`可以从外部访问到某个service。

该端口号的范围是 kube-apiserver 的启动参数 –service-node-port-range指定的，在当前测试环境中其值是 30000-50000。表示只允许分配30000-50000之间的端口。

比如外部用户要访问k8s集群中的一个Web应用，那么我们可以配置对应service的type=NodePort，nodePort=30001。其他用户就可以通过浏览器<http://node:30001>访问到该web服务。而数据库等服务可能不需要被外界访问，只需被内部服务访问即可，那么我们就不必设置service的NodePort

### TargetPort

- targetPort 是`pod的端口`，从port和nodePort来的流量经过kube-proxy流入到后端pod的targetPort上，最后进入容器。

### containerPort

- containerPort是`pod内部容器的端口`，`targetPort映射到containerPort`。

### hostPort

这是一种直接定义Pod网络的方式。hostPort是直接将容器的端口与所调度的节点上的端口路由，这样用户就可以通过宿主机的IP加上来访问Pod了，如

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: influxdb
spec:
  containers:
    - name: influxdb
      image: influxdb
      ports:
        - containerPort: 8086 # 此处定义暴露的端口
          hostPort: 8086
```

这样做有个缺点，因为Pod重新调度的时候该Pod被调度到的宿主机可能会变动，这样就变化了，用户必须自己维护一个Pod与所在宿主机的对应关系。

使用了 hostPort 的容器只能调度到端口不冲突的 Node 上，除非有必要（比如运行一些系统级的 daemon 服务），不建议使用端口映射功能。如果需要对外暴露服务，建议使用 NodePort Service。

总的来说，port和nodePort都是service的端口，前者暴露给集群内客户访问服务，后者暴露给集群外客户访问服务。从这两个端口到来的数据都需要经过反向代理kube-proxy流入后端 pod的targetPod，从而到达pod上的容器内。

## Endpoint

创建Service的同时，会自动创建跟Service同名的Endpoints。

Endpoint 是k8s集群中一个资源对象，存储在etcd里面，用来记录一个service对应的所有pod的访问地址。service通过selector和pod建立关联。

`Endpoint = Pod IP + Container Port`

service配置selector endpoint controller 才会自动创建对应的endpoint 对象，否则是不会生产endpoint 对象

一个service由一组后端的pod组成，这些后端的pod通过service endpoint暴露出来，如果有一个新的pod创建创建出来，且pod的标签名称(label:pod)跟service里面的标签（label selector 的label）一致会自动加入到service的endpoints 里面，如果pod对象终止后，pod 会自动从edponts 中移除。在集群中任意节点 可以使用curl请求service `<CLUSTER-IP>:<PORT>`

### Endpoint Controller

Endpoint Controller是k8s集群控制器的其中一个组件，其功能如下：

- 负责生成和维护所有endpoint对象的控制器
- 负责监听service和对应pod的变化
- 监听到service被删除，则删除和该service同名的endpoint对象
- 监听到新的service被创建，则根据新建service信息获取相关pod列表，然后创建对应endpoint对象
- 监听到service被更新，则根据更新后的service信息获取相关pod列表，然后更新对应endpoint对象
- 监听到pod事件，则更新对应的service的endpoint对象，将podIp记录到endpoint中

### 定义 Endpoint

对于Service，我们还可以定义Endpoint，Endpoint 把Service和Pod动态地连接起来，Endpoint 的名称必须和服务的名称相匹配。

创建mysql-service.yaml

``` yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-production
spec:
  ports:
    - port: 3306
```

创建mysql-endpoints.yaml

``` yaml
kind: Endpoints
apiVersion: v1
metadata:
  name: mysql-production
  namespace: default
subsets:
  - addresses:
      - ip: 192.168.1.25
    ports:
      - port: 3306
```

``` yaml
[root@k8s-master endpoint]# kubectl describe svc mysql-production
Name:           mysql-production
Namespace:      default
Labels:         <none>
Annotations:        <none>
Selector:       <none>
Type:           ClusterIP
IP:         10.254.218.165
Port:           <unset> 3306/TCP
Endpoints:      192.168.1.25:3306
Session Affinity:   None
Events:         <none>
```

### 使用Endpoint引用外部服务

service 不仅可以代理pod, 还可以代理任意其它的后端(运行在k8s集群外部的服务，比如mysql mongodb）。如果需要从k8s里面链接外部服务（mysql），可定义同名的service和endpoint

在实际生成环境中，像mysql mongodb这种IO密集型应用，性能问题会显得非常突出，所以在实际应用中，一般不会把这种有状态的应用（mysql 等）放入k8s里面，而是使用单独的服务来部署，而像web这种无状态的应用更适合放在k8s里面 里面k8s的自动伸缩，和负载均衡，故障自动恢复 等强大功能

创建service (mongodb-service-exten)

``` yaml
kind: Service
apiVersion: v1
metadata:
  name: mongodb
  namespace: name
spec:
  ports:
  - port: 30017
    name: mongodb
    targetPort: 30017
```

创建 endpoint(mongodb-endpoint)

``` yaml
kind: Endpoints
apiVersion: v1
metadata:
  name: mongodb
  namespace: tms-test
subsets:
- addresses:
  - ip: xxx.xxx.xx.xxx
  ports:
   - port: 30017
     name: mongod
```

可以看到service跟endpoint成功挂载一起了，表面外面服务成功挂载到k8s里面了，在应用中配置链接的地方使用`mongodb://mongodb:30017` 链接数据

### 创建ExternalName类型的服务

除了手动配置服务的endpoint来代替公开外部服务方法，还可以通过`完全限定域名（FQDN）`访问外部服务——创建ExternalName类型的服务。

![20201020135304113_1274858680](https://gitee.com/owen2016/pic-hub/raw/master/1606053762_20201122220236684_720492790.png)

ExternalName类型的服务创建后，pod可以通过`external-service.default.svc.cluster.local`域名连接到外部服务，或者通过`externale-service`。当需要指向其他外部服务时，只需要修改spec.externalName的值即可。