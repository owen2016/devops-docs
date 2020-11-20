# Helm

Helm是用于管理Kubernetes图表的理想工具。Kubernetes图表是预配置的Kubernetes资源包。这些图表包含两大部分：软件包的描述，以及一个或多个Kubernetes清单文件的模板。从本质上讲，Helm简化了Kubernetes应用程序的安装和管理。

Helm拥有大量有价值的功能，可帮助DevOps团队顺利运行Kubernetes应用程序。你可以找到并使用打包为官方Kubernetes图表的流行软件。一些图表可以在Kubeapps上找到。你甚至可以创建构建并共享你自己的应用程序作为Kubernetes图表供其他人使用

Helm是由helm CLI和Tiller组成，是典型的C/S应用。helm运行与客户端，提供命令行界面，而Tiller应用运行在Kubernetes内部。Helm管理的kubernetes资源包称之为Chart

- <https://github.com/helm/helm>

Helm 使用了一种叫作 chart 的打包格式。chart 是一组描述了一组相关的 Kubernetes 可用资源的文件。一个 chart 可以用来部署一些简单的东西。

从架构方面看，Helm 有两个端，一个是客户端，即 Helm 命令行工具，我们称之为 Helm CLI，另一个是服务端，即 Tiller。Helm CLI 是运行在本地机器上的命令。它使用模板引擎根据 Helm 中定义的源模板生成易于理解的 Kubernetes YAML。

在生成 YAML 之后，它会将请求发送到运行在 Kubernetes 集群中的 Tiller。接下来，Tiller 在 Kubernetes 集群中执行更新，确保它是最新的并被正确发布，然后添加到历史记录中，在后续可以根据需要进行回滚。在已发布的 Helm 3 中，Tiller 被移除掉了