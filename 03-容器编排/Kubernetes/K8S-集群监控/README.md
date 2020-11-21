# Kubernetes 集群监控方案

Kubernetes通过在容器，pod，服务和整个集群等不同级别创建抽象来考虑集群的管理

## 监控范围

- Pod性能
- Node性能
- k8s资源对象

## 1. Heapster (已废弃)

Kubernetes 原生的集群监控方案

Heapster是由每个节点上运行的Kubelet提供的集群范围的数据聚合器。此容器管理工具在Kubernetes集群上本机支持，并作为pod运行，就像集群中的任何其他pod一样。因此，它基本上发现集群中的所有节点，并通过机上Kubernetes代理查询集群中Kubernetes节点的使用信息。

## 2. Metrics-Server监控

//TODO

## 3. Prometheus Operator

Prometheus Operator 可能是目前功能最全面的 Kubernetes 开源监控方案。除了能够监控 Node 和 Pod，还支持集群的各种管理组件，比如 API Server、Scheduler、Controller Manager 等。

## 4. Kube-Prometheus

### Prometheus Operator vs. kube-prometheus vs. community helm chart

> - The Prometheus Operator uses Kubernetes custom resources to simplifiy the deployment and configuration of Prometheus, Alertmanager, and related monitoring components.
>
> - kube-prometheus provides example configurations for a complete cluster monitoring stack based on Prometheus and the Prometheus Operator. This includes deployment of multiple Prometheus and Alertmanager instances, metrics exporters such as the node_exporter for gathering node metrics, scrape target configuration linking Prometheus to various metrics endpoints, and example alerting rules for notification of potential issues in the cluster.
>
> - The stable/prometheus-operator helm chart provides a similar feature set to kube-prometheus. This chart is maintained by the Helm community. For more information, please see the chart's readme

## 5. Weave Scope

Weave Scope 是 Docker 和 Kubernetes 可视化监控工具。Scope 提供了至上而下的集群基础设施和应用的完整视图，用户可以轻松对分布式的容器化应用进行实时监控和问题诊断