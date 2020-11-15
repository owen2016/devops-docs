# Pod

## 生命周期

## 静态Pod

除了DaemonSet，还可以使用静态Pod来在每台机器上运行指定的Pod，这需要kubelet在启动的时候指定manifest目录

`kubelet --pod-manifest-path=/etc/kubernetes/manifests`

然后将所需要的Pod定义文件放到指定的manifest目录中。

**注意：**静态Pod不能通过API Server来删除，但可以通过删除manifest文件来自动删除对应的Pod。
