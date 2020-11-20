# Annotation

Label可用于选择对象并查找满足某些条件的对象集合。相比之下，Annotations不用于标识和选择对象，虽然它也是键值形式。Annotations不会被Kubernetes直接使用，其主要目的是方便用户阅读查找。

用Annotation来记录的信息包括：

- build信息、release信息、Docker镜像信息等，例如时间戳、release id号、PR号、镜像hash值、docker registry地址等；
- 日志库、监控库、分析库等资源库的地址信息；
- 程序调试工具信息，例如工具名称、版本号等；
- 团队的联系信息，例如电话号码、负责人名称、网址等

## 示例

`kubectl annotate pods nginx-deployment-5f948466b7-8sffb description='my nginx pod'`

![annotate](./_images/k8s-annotate.png)