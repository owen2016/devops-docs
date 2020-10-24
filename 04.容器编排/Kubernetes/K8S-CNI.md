# CNI

## CNI 是什么

CNI (Container Network Interface)，即容器网络的 API 接口,是一个云原生计算基础项目，旨在统一容器网络的规范，并提供配置Linux容器中的网络接口的库。

它是 K8s 中标准的一个调用网络实现的接口。Kubelet 通过这个标准的 API 来调用不同的网络插件以实现不同的网络配置方式，实现了这个接口的就是 CNI 插件，它实现了一系列的 CNI API 接口。常见的 CNI 插件包括 Calico、flannel、Terway、Weave Net 以及 Contiv。

- <https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy>

## 为什么使用 CNI 插件

插件负责为接口配置和管理IP地址，并且通常提供与IP管理、每个容器的IP分配、以及多主机连接相关的功能。容器运行时会调用网络插件，从而在容器启动时分配IP地址并配置网络，并在删除容器时再次调用它以清理这些资源。

运行时或调度器决定了容器应该加入哪个网络以及它需要调用哪个插件。插件会将接口添加到容器网络命名空间中，作为一个veth对（我们都只veth pair都是成对出现的）的其中一个。

接着，它会在主机上进行更改，包括将veth pair另外一个tap连接到网桥。然后，它会通过调用单独的IPAM（IP地址管理）插件来分配IP地址并设置路由。

## Kubernetes 中如何使用 CNI

K8s 通过 CNI 配置文件来决定使用什么 CNI。

基本的使用方法为：

1.首先在每个结点上配置 CNI 配置文件 (/etc/cni/net.d/xxnet.conf)，其中 xxnet.conf 是某一个网络配置文件的名称；

![k8s-cni-config](images/k8s-cni-config.png)

2.安装 CNI 配置文件中所对应的二进制插件；

![k8s-cni-bin](images/k8s-cni-bin.png)

3.在这个节点上创建 Pod 之后，Kubelet 就会根据 CNI 配置文件执行前两步所安装的 CNI 插件；
4.上步执行完之后，Pod 的网络就配置完成了

具体的流程如下图所示：

![k8s-cni](images/k8s-cni.png)

在集群里面创建一个 Pod 的时候，首先会通过 apiserver 将 Pod 的配置写入。apiserver 的一些管控组件（比如 Scheduler）会调度到某个具体的节点上去。Kubelet 监听到这个 Pod 的创建之后，会在本地进行一些创建的操作。

当执行到创建网络这一步骤时，它首先会读取刚才我们所说的配置目录中的配置文件，配置文件里面会声明所使用的是哪一个插件，然后去执行具体的 CNI 插件的二进制文件，再由 CNI 插件进入 Pod 的网络空间去配置 Pod 的网络。配置完成之后，Kuberlet 也就完成了整个 Pod 的创建过程，这个 Pod 就在线了

上述流程有很多步（比如要对 CNI 配置文件进行配置、安装二进制插件等等）, 但作为一个用户去使用 CNI 插件的话就比较简单，因为很多 CNI 插件都已提供了一键安装的能力。以我们常用的 Flannel 为例，如下图所示：只需要我们使用 kubectl apply Flannel 的一个 Deploying 模板，它就能自动地将配置、二进制文件安装到每一个节点上去。

![cni-flannel](images/cni-flannel.png)

## 如何选择合适的CNI插件

社区有很多的 CNI 插件，比如 Calico, flannel, Terway 等等。那么在一个真正具体的生产环境中，我们要选择哪一个 CNI 插件呢？

我们需要根据不同的场景选择不同的实现模式，再去选择对应的具体某一个插件。

通常来说，CNI 插件可以分为三种：Overlay、路由及 Underlay

![cni-mode](images/cni-mode.png)

- Overlay 模式的典型特征是容器独立于主机的 IP 段，这个 IP 段进行跨主机网络通信时是通过在主机之间创建隧道的方式，将整个容器网段的包全都封装成底层的物理网络中主机之间的包。该方式的好处在于它不依赖于底层网络；

- 路由模式中主机和容器也分属不同的网段，它与 Overlay 模式的主要区别在于它的跨主机通信是通过路由打通，无需在不同主机之间做一个隧道封包。但路由打通就需要部分依赖于底层网络，比如说要求底层网络有二层可达的一个能力；

- Underlay 模式中容器和宿主机位于同一层网络，两者拥有相同的地位。容器之间网络的打通主要依靠于底层网络。因此该模式是强依赖于底层能力的

## 参考

- <https://yq.aliyun.com/articles/751611?spm=a2c4e.11155472.0.0.357a5b8a8vjbqQ>
- <https://segmentfault.com/a/1190000019956620>