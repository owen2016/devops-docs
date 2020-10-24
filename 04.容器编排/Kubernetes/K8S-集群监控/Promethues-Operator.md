# Promethues Operator


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