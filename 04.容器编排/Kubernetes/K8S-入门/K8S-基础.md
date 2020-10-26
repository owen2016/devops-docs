# Kubernetes 基础

Kubernetes 是容器编排管理系统，是一个开源的平台，可以实现容器集群的自动化部署、自动扩缩容、维护等功能。Kubernetes 是Google 2014年创建管理的，是Google 10多年大规模容器管理技术Borg的开源版本。Kubernetes 基本上已经是私有云部署的一个标准。

Kubernets有以下几个特点

- 可移植: 支持公有云，私有云，混合云，多重云（multi-cloud）
- 可扩展: 模块化, 插件化, 可挂载, 可组合
- 自动化: 自动部署，自动重启，自动复制，自动伸缩/扩展

K8s 是将8个字母 “ubernete” 替换为 “8” 的缩写，后续我们将使用 K8s 代替 Kubernetes

## 参考

- [A Beginner’s Guide to Kubernetes](https://dzone.com/articles/a-beginners-guide-to-kubernetes)

## 架构

![](https://gitee.com/owen2016/pic-hub/raw/master/1603723019_20201023084340816_1313476094.png)

### 1. master

Master节点组件提供集群的管理控制中心，通常在一台VM/机器上启动所有Master组件，并且不会在此VM/机器上运行用户容器。

- `Etcd`: 是用来存储所有Kubernetes集群状态的，它除了具备状态存储的功能，还有事件监听和订阅、Leader选举的功能。事件监听和订阅指，其他组件各个通信并不是互相调用API来完成的，而是把状态写入Etcd（相当于写入一个消息），其他组件通过监听Etcd的状态的的变化（相当于订阅消息），然后做后续的处理，然后再一次把更新的数据写入Etcd。Leader选举指，其它一些组件比如 Scheduler，为了做实现高可用，通过Etcd从多个（通常是3个）实例里面选举出来一个做Master，其他都是Standby。

- `API Server`: Etcd是整个系统的最核心，所有组件之间通信都需要通过Etcd。实际上组件并不是直接访问Etcd，而是访问一个代理，这个代理是通过标准的RESTFul API，重新封装了对Etcd接口调用，除此之外，这个代理还实现了一些附加功能，比如身份的认证、缓存等，这个代理就是 API Server。

- `Controller manager`: 负责任务调度，简单说直接请求Kubernetes做调度的都是任务，例如Deployment 、DeamonSet、Pod等等，每一个任务请求发送给Kubernetes之后，都是由Controller Manager来处理的，每一种任务类型对应一个Controller Manager，比如 Deployment对应一个叫做Deployment Controller，DaemonSet对应一个DaemonSet Controller。

- `Scheduler`: 负责资源调度，Controller Manager 会把Pod对资源要求写入到Etcd里面，Scheduler监听到有新的Pod需要调度，就会根据整个集群的状态，把Pod分配到具体的worker节点上。

- `Kubectl`: 是一个命令行工具，它会调用API Server发送请求写入状态到Etcd，或者查询Etcd的状态。

### 2. worker

worker节点组件运行在每个k8s Node上，提供K8s运行时环境，以及维护Pod。

- `Kubelet`: 运行在每一个worker节点上的Agent，它会监听Etcd中的Pod信息，运行分配给它所在节点的Pod，并把状态更新回Etcd。通过docker部署

- `Kube-proxy`: 负责为Service提供cluster内部的服务发现和负载均衡。通过k8s部署

- `Docker`: Docker引擎，负责容器运行。

- `Container`: 负责镜像管理以及Pod和容器的真正运行（CRI）。

通过部署一个多实例Nginx服务来描述Kubernets内部的流程

1. 创建一个nginx_deployment.yaml配置文件。

2. 通过kubectl命令行创建一个包含Nginx的Deployment对象，kubectl会调用 `API Server` 往`Etcd`里面写入一个Deployment对象。

3. Deployment Controller监听到有新的Deployment对象被写入，获取到Deployment对象信息然后根据对象信息来做任务调度，创建对应的Replica Set对象。

4. Replica Set Controller监听到有新的对象被创建，获取到Replica Set对象信息然后根据对象信息来做任务调度，创建对应的Pod对象。

5. Scheduler监听到有新的Pod被创建，获取到Pod对象信息，根据集群状态将Pod调度到某一个worker节点上，然后更新Pod。

6. Kubelet监听到当前的节点被指定了的Pod，就根据对象信息运行Pod。

## 核心概念

1. Cluster: 集群指的是由K8s使用一序列的物理机、虚拟机和其它基础资源来运行你的应用程序。

2. Node: 一个Node就是一个运行着K8s的物理机或虚拟机，并且Pod可以在其上面被调度。

3. Pod: 一个Pod对应一个由相关容器和卷组成的容器组。

4. Label: 一个label是一个被附加到资源上的键值对，比如附加到一个Pod上为它传递一个用户自定的属性，label还可以被应用来组织和选择子网中的资源。

5. Selector: 是一个通过匹配labels来定义资源之间关系的表达式，例如为一个负载均衡的service指定目标Pod。

6. Replication Controller: replication controller 是为了保证Pod一定数量的复制品在任何时间都能正常工作，它不仅允许复制的系统易于扩展，还会处理当Pod在机器重启或发生故障的时候再创建一个。

7. Service: 一个service定义了访问Pod的方式，就像单个固定的IP地址和与其相对应的DNS名之间的关系。

8. Volume: 一个Volume是一个目录。

9. Kubernets Volume: 构建在Docker Volumes之上，并且支持添加和配置Volume目录或者其他存储设备。

10. Secret: Secret存储了敏感数据，例如能运行容器接受请求的权限令牌。

11. Name: 用户为Kubernets中资源定义的名字。

12. Namespace: namespace好比一个资源名字的前缀，帮助不同的项目可以共享cluster，防止出现命名冲突。

13. Annotation: 相对于label来说可以容纳更大的键值对，它对我们来说是不可读的数据，只是为了存储不可识别的辅助数据，尤其是一些被工具或系统扩展用来操作的数据。