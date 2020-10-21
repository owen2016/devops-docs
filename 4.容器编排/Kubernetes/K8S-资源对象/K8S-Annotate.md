# Annotation

Annotation 与 Label类似，也使用key/value键值对的形式进行定义。

Label具有严格的命名规则，它定义的是Kubernetes对象的元数据（Metadata），并且用于Label Selector。

Annotation则是用户任意定义的“附加”信息，以便于外部工具进行查找。

用Annotation来记录的信息包括：

- build信息、release信息、Docker镜像信息等，例如时间戳、release id号、PR号、镜像hash值、docker registry地址等；
- 日志库、监控库、分析库等资源库的地址信息；
- 程序调试工具信息，例如工具名称、版本号等；
- 团队的联系信息，例如电话号码、负责人名称、网址等

## 示例

`kubectl annotate pods nginx-deployment-5f948466b7-8sffb description='my nginx pod'`

![annotate](./images/k8s-annotate.png)