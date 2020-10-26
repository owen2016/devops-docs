# Promethues Operator

Promethues Operator可以让我们更加方便的去使用 Prometheus，而不需要直接去使用最原始的一些资源对象，比如 Pod、Deployment，随着 Prometheus Operator 项目的成功，CoreOS 公司开源了一个比较厉害的工具：Operator Framework，该工具可以让开发人员更加容易的开发 Operator 应用。

Operator 是由 CoreOS 开发的，用来扩展 Kubernetes API，特定的应用程序控制器，它用来创建、配置和管理复杂的有状态应用，如数据库、缓存和监控系统。Operator 基于 Kubernetes 的资源和控制器概念之上构建，但同时又包含了应用程序特定的领域知识。`创建Operator 的关键是CRD（自定义资源）的设计。`

Kubernetes 1.7 版本以来就引入了自定义控制器的概念，该功能可以让开发人员扩展添加新功能，更新现有的功能，并且可以自动执行一些管理任务，这些自定义的控制器就像 Kubernetes 原生的组件一样，Operator 直接使用 Kubernetes API进行开发，也就是说他们可以根据这些控制器内部编写的自定义规则来监控集群、更改 Pods/Services、对正在运行的应用进行扩缩容。

## 架构

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201022224408.png)

以上架构中的各组成部分以不同的资源方式运行在 Kubernetes 集群中，它们各自有不同的作用：

- Operator： Operator 资源会根据`自定义资源`（Custom Resource Definition / CRDs）来部署和管理 Prometheus Server，同时监控这些自定义资源事件的变化来做相应的处理，是整个系统的控制中心。在 Kubernetes 中以 Deployment 运行,根据 ServiceMonitor 动态更新 Prometheus Server 的监控对象。

- Prometheus： Prometheus Server 会作为 Kubernetes 应用部署到集群中。为了更好地在 Kubernetes 中管理 Prometheus，CoreOS 的开发人员专门定义了一个命名为 Prometheus 类型的 `定制化资源`。Prometheus 资源是声明性地描述 Prometheus 部署的期望状态,我们可以把 Prometheus看作是一种特殊的 Deployment，它的用途就是专门部署 Prometheus Server。

- Prometheus Server： Operator 根据自定义资源 Prometheus 类型中定义的内容而部署的 Prometheus Server 集群，这些自定义资源可以看作是用来管理 Prometheus Server 集群的 StatefulSets 资源。

- ServiceMonitor： ServiceMonitor 也是一个`自定义资源`，它描述了一组被 Prometheus 监控的 targets 列表。该资源通过 Labels 来选取对应的 Service Endpoint，让 Prometheus Server 通过选取的 Service 来获取 Metrics 信息。
  
  Operator 能够动态更新 Prometheus 的 Target 列表，ServiceMonitor 就是 Target 的抽象。比如想监控 Kubernetes Scheduler，用户可以创建一个与 Scheduler Service 相映射的 ServiceMonitor 对象。Operator 则会发现这个新的 ServiceMonitor，并将 Scheduler 的 Target 添加到 Prometheus 的监控列表中。

- Service：就是 Cluster 中的 Service 资源，也是 Prometheus 要监控的对象，在 Prometheus 中叫做 Target。每个监控对象都有一个对应的 Service。比如要监控 Kubernetes Scheduler，就得有一个与 Scheduler 对应的 Service。当然，Kubernetes 集群默认是没有这个 Service 的，Prometheus Operator 会负责创建。
  
  Service 资源主要用来对应 Kubernetes 集群中的 Metrics Server Pod，来提供给 ServiceMonitor 选取让 Prometheus Server 来获取信息

- Alertmanager： Alertmanager 也是一个`自定义资源类型`，可以把 Alertmanager 看作是一种特殊的 Deployment,由 Operator 根据资源描述内容来部署 Alertmanager 集群。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201022230624.png)


### Prometheus Operator vs. kube-prometheus vs. community helm chart

- prometheus operator使用kubernetes原生的方式来管理和操作prometheus和alertmanager集群。
- kube-prometheus 联合prometheus operator和一些manifests来帮助监控kubernetes集群本身以及跑在kubernetes上面的应用。
- stable/prometheus-operator Helm chart 提供简单的功能集来创建kube-prometheus。


为了方便操作，coreos 提供了 prometheus-operator 这样一个产品，它包装了 Prometheus，并且还提供了四个自定义的 k8s 类型（CustomResourceDefinitions），让你通过定义 manifest 的方式还完成新监控（job）以及告警规则的添加，而无需手动操作 Prometheus 的配置文件，让整个过程更 k8s。
并且在此基础之上，coreos 还有推出了 kube-prometheus 这样的升级版，它在 prometheus-operator 的基础之上高可用了 Prometheus 和 Alertmanager，提供了 node-exporter 用于宿主机的监控，还有 Kubernetes Metrics APIs 的 Prometheus 适配器和 grafana，让你实现一键部署。