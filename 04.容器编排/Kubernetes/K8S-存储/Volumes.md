# Volumes

Docker提供了Volumes，Volume 是磁盘上的文件夹并且没有生命周期的管理。Kubernetes 中的 Volume 是存储的抽象，并且能够为Pod提供多种存储解决方案。Volume 最终会映射为Pod中容器可访问的一个文件夹或裸设备，但是背后的实现方式可以有很多种。

**Volumes的类型:**

- cephfs
- configMap
- emptyDir
- hostPath
- local
- nfs
- persistentVolumeClaim

## emptyDir

emptyDir在Pod被分配到Node上之后创建，并且在Pod运行期间一直存在。初始的时候为一个空文件夹，当Pod从Node中移除时，emptyDir将被永久删除。Container的意外退出并不会导致emptyDir被删除。emptyDir适用于一些临时存放数据的场景。默认情况下，emptyDir存储在Node支持的介质上，不管是磁盘、SSD还是网络存储，也可以设置为Memory

## hostPath

hostPath就是将Node节点的文件系统挂载到Pod中

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # directory location on host
      path: /data
      # this field is optional
      type: Directory
```

## local

> A local volume represents a mounted local storage device such as a disk, partition or directory.

local类型作为静态资源被PersistentVolume使用，不支持Dynamic provisioning。与hostPath相比，因为能够通过PersistentVolume的节点亲和策略来进行调度，因此比hostPath类型更加适用。local类型也存在一些问题，如果Node的状态异常，那么local存储将无法访问，从而导致Pod运行状态异常。使用这种类型存储的应用必须能够承受可用性的降低、可能的数据丢失等。

对于使用了PV的Pod，Kubernetes会调度到具有对应PV的Node上，因此PV的节点亲和性 nodeAffinity 属性是必须的。

> PersistentVolume nodeAffinity is required when using local volumes. It enables the Kubernetes scheduler to correctly schedule Pods using local volumes to the correct node.