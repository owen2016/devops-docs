# 持久化存储 - PV&&PVC

[TOC]

## PV

- <https://kubernetes.io/docs/concepts/storage/persistent-volumes/>

PV全称叫做Persistent Volume，持久化存储卷。它是`用来描述或者说用来定义一个存储卷的`，这个通常都是有运维或者数据存储工程师来定义

- PV与普通Volume的区别
  普通Volume和使用它的Pod之间是一种静态绑定关系，在定义Pod的文件里，同时定义了它使用的Volume。Volume是Pod的附属品，我们无法单独创建一个Volume，因为它不是一个独立的K8S资源对象。

Persistent Volumes 提供了一个抽象层，向用户屏蔽了具体的存储实现形式。

比如下面定义一个NFS类型的PV：

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:  # PV建立不要加名称空间，因为PV属于集群级别的
  name: nfs-pv001  # PV名称
  labels: # 这些labels可以不定义
    name: nfs-pv001
    storetype: nfs
spec:  # 这里的spec和volumes里面的一样
  storageClassName: normal
  accessModes:  # 设置访问模型
    - ReadWriteMany
    - ReadWriteOnce
    - ReadOnlyMany
  capacity: # 设置存储空间大小
    storage: 500Mi
  persistentVolumeReclaimPolicy: Retain # 回收策略
  nfs:
    path: /work/volumes/v1
    server: stroagesrv01.contoso.com
```

### 访问类型 - accessModes

accessModes：支持三种类型

- ReadWriteMany 多路读写，卷能被集群多个节点挂载并读写
- ReadWriteOnce 单路读写，卷只能被单一集群节点挂载读写
- ReadOnlyMany 多路只读，卷能被多个集群节点挂载且只能读

在命令行中，访问模式缩写为：

- RWO - ReadWriteOnce
- ROX - ReadOnlyMany
- RWX - ReadWriteMany

这里的访问模型总共有三种，但是不同的存储类型支持的访问模型不同，具体支持什么需要查询官网。比如这里使用nfs，它支持全部三种。但是ISCI就不支持ReadWriteMany；HostPath就不支持ReadOnlyMany和ReadWriteMany。

### 回收策略 -persistentVolumeReclaimPolicy

这个策略是当与之关联的PVC被删除以后，这个PV中的数据如何被处理

- 保留 Retain：保留现场，Kubernetes等待用户手工处理数据。
  当删除与之绑定的PVC时候，这个PV被标记为released（PVC与PV解绑但还没有执行回收策略）且之前的数据依然保存在该PV上，但是该PV不可用，`需要手动来处理这些数据并删除该PV`。

- 删除 Delete：Kubernetes会自动删除数据

- 重用 Recycle： 这个在1.14版本中以及被废弃，取而代之的是推荐使用 动态存储供给策略（Dynamic Provisioning），它的功能是当删除与该PV关联的PVC时，自动删除该PV中的所有数据

**注意：** `PV必须先与POD创建，而且只能是网络存储不能属于任何Node，`虽然它支持HostPath类型但由于你不知道POD会被调度到哪个Node上，所以你要定义HostPath类型的PV就要保证所有节点都要有HostPath中指定的路径。

## PVC

PVC是`用来描述希望使用什么样的或者说是满足什么条件的存储`，它的全称是Persistent Volume Claim，也就是持久化存储声明。开发人员使用这个来描述该容器需要一个什么存储。

PV 和 PVC类似Pods和Nodes的关系，Pod 消耗节点资源，PVC 消耗 PV 资源。PV 是提供了各种存储资源，PVC 提出需要的存储标准，然后从现有存储资源中匹配或者动态建立新的资源，最后将两者进行绑定。

比如下面使用NFS的PVC：

``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc001
  namespace: default
  labels: # 这些labels可以不定义
    name: nfs-pvc001
    storetype: nfs
    capacity: 500Mi
spec:
  storageClassName: normal
  accessModes:  # PVC也需要定义访问模式，不过它的模式一定是和现有PV相同或者是它的子集，否则匹配不到PV
  - ReadWriteMany
  resources: # 定义资源要求PV满足这个PVC的要求才会被匹配到
    requests:
      storage: 500Mi  # 定义要求有多大空间
```

这个PVC就会和上面的PV进行绑定，为什么呢？它有一些原则：

- PV和PVC中的spec关键字段要匹配，比如存储（storage）大小。

- PV和PVC中的storageClassName字段必须一致

上面的labels中的标签只是增加一些描述，对于PVC和PV的绑定没有关系

![pv&pvc](./images/pv&pvc.png)

### PVC状态

- Available（可用） —— 一块空闲资源还没有被任何声明绑定
- Bound（已绑定）   —— 卷已经被声明绑定
- Released（已释放）—— 声明被删除，但是资源还未被集群重新声明
- Failed（失败）    —— 该卷的自动回收失败

## 在Pod中如何使用PVC

Pods使用的是PersistentVolumeClaim,而非PersistentVolume。

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      appname: myapp
  template:
    metadata:
      name: myapp
      labels:
        appname: myapp
    spec:
      containers:
      - name: myapp
        image: tomcat:8.5.38-jre8
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP
        volumeMounts:
          - name: tomcatedata
            mountPath : "/data"
      volumes:
        - name: tomcatedata
          persistentVolumeClaim:
            claimName: nfs-pvc001
```

![pvc-pod-1](images/pvc-pod-1.png)

![pvc-pod-2](images/pvc-pod-2.png)

这里通过volumes来声明使用哪个PVC，可以看到和自己定义持久化卷类似，但是这里更加简单了，直接使用PVC的名字即可。在容器中使用/data目录就会把数据写入到NFS服务器上的目录中。

- 删除 pvc

    当执行 `delete pvc` 命令时候，命令窗口会一直Pending，但是 pvc状态已经变为 `Terminating`; 然后执行`delete pod` 之后，pvc才会被删除，同时PV 变成`Released`状态

    ``` shell
    user@owen-ubuntu:~$ kubectl delete persistentvolumeclaim/nfs-pvc001
    persistentvolumeclaim "nfs-pvc001" deleted
    ```

   ![delete-pvc-1](images/delete-pvc-1.png)

- PV在Retain策略Released状态下，PV资源不可用
  
  如果想让这个PV变为可用，就需要手动清理数据并删除这个PV。这里你可能会觉得矛盾，你让这个PV变为可用，为什么还要删除这个PV呢？其实所谓可用就是删除这个PV然后建立一个同名的, 否认，即使重新创建pvc,还是无法直接使用已经存在的PV 
  
  如图所示，PV的元数据里包含删除的 PVC 信息

    ![delete-pvc-1](images/delete-pvc-1.png)

可以看出来PVC就相当于是容器和PV之间的一个接口，使用人员只需要和PVC打交道即可。另外你可能也会想到如果当前环境中没有合适的PV和PVC绑定，那么我创建的POD不就失败了么？的确是这样的，不过如果发现这个问题，那么就赶快创建一个合适的PV，那么这时候`持久化存储循环控制器`会不断的检查PVC和PV，当发现有合适的可以绑定之后它会自动给你绑定上然后被挂起的POD就会自动启动，而不需要你重建POD。
