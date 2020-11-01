# PersistentVolumes (PV) && PersistentVolumeClaims (PVC)

[TOC]

## PersistentVolumes (PV)

**Volume主要是为了存储一些有必要保存的数据,而Persistent Volume主要是为了管理集群的存储***

Persistent Volumes 提供了一个抽象层，向用户屏蔽了具体的存储实现形式。

PV 对具体的存储进行配置和分配，而Pods等则可以使用Persistent Volume抽象出来的存储资源，不需要知道集群的存储细节

集群管理员提供的一块存储，是Volumes的插件。类似于Pod，但是具有独立于Pod的生命周期。具体存储可以是NFS、云服务商提供的存储服务。

## PersistentVolumeClaims (PVC)

是用户存储的请求。它与 Pod 相似。Pod 消耗节点资源，PVC 消耗 PV 资源。

PV 和 PVC类似Pods和Nodes的关系，创建Pods需要消耗一定的Nodes的资源。而Persistent Volume则是提供了各种存储资源，而 PVC 提出需要的存储标准，然后从现有存储资源中匹配或者动态建立新的资源，最后将两者进行绑定。

### PV的创建

Persistent Volume相对独立于Pods,单独创建

``` yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 192.168.207.121
    path: "/nas/dg_vd"
```

### PVC的创建

``` yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
```

### Pods的使用

Pods使用的是PersistentVolumeClaim而非PersistentVolume。

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: testpv
  labels:
    role: web-frontend
spec:
  containers:
  - name: web
    image: nginx
    ports:
      - name: web
        containerPort: 80
    volumeMounts:
        - name: nfs
          mountPath: "/usr/share/nginx/html"
  volumes:
  - name: nfs
    persistentVolumeClaim:
      claimName: nfs
```

**生命周期：**

- 供给
  - 静态供给
  - 动态供给：动态供给的请求基于StorageClass，集群针对用户的PVC请求，可以产生动态供给。

- 绑定 Binding

- 使用

- 在用对象保护：对于正在使用的PV提供了保护机制，正在使用的PV如果被用户删除，PV的删除会推迟到用户对PV的使用结束。

- 重用 Reclaim 策略
  - 保留 Retain：保留现场，Kubernetes等待用户手工处理数据。
  - 删除 Delete：Kubernetes会自动删除数据
  - 重用：这个策略已经不推荐使用了，应该使用 Dynamic Provisioning 代替。

- 扩容。主要是对于一些云存储类型，例如gcePersistentDisk、Azure Disk提供了扩容特性，在1.11版本还处于测试阶段。

**Persistent Volumes 的一些属性:**

- Capacity：一般情况PV拥有固定的容量
- Volume Mode：在1.9版本中是alpha特性，允许设置 filesystem 使用文件系统（默认），设置 raw 使用裸设备。
- Access Modes
- Class：可以设置成StorageClass的名称。具有Class属性的PV只能绑定到还有相同CLASS名称的PVC上。没有CLASS的PV只能绑定到没有CLASS的PVC上。
- Reclaim Policy

## PVC状态

- Available（可用）——一块空闲资源还没有被任何声明绑定
- Bound（已绑定）——卷已经被声明绑定
- Released（已释放）——声明被删除，但是资源还未被集群重新声明
- Failed（失败）——该卷的自动回收失败

## PV访问类型

PersistentVolume 可以以资源提供者支持的任何方式挂载到主机上。如下表所示，供应商具有不同的功能，每个PV 的访问模式都将被设置为该卷支持的特定模式。例如，NFS 可以支持多个读/写客户端，但特定的 NFS PV 可能以只读方式导出到服务器上。每个 PV 都有一套自己的用来描述特定功能的访问模式

- ReadWriteOnce——该卷可以被单个节点以读/写模式挂载
- ReadOnlyMany——该卷可以被多个节点以只读模式挂载
= ReadWriteMany——该卷可以被多个节点以读/写模式挂载

在命令行中，访问模式缩写为：

- RWO - ReadWriteOnce
- ROX - ReadOnlyMany
- RWX - ReadWriteMany

## PVC回收策略

- Retain（保留）——手动回收
- Recycle（回收）——基本擦除（ rm -rf /thevolume/* ）
- Delete（删除）——关联的存储资产（例如 AWS EBS、GCE PD、Azure Disk 和 OpenStack Cinder 卷）

将被删除当前，只有 NFS 和 HostPath 支持回收策略。AWS EBS、GCE PD、Azure Disk 和 Cinder 卷支持删除策略


## Storage Class

StorageClass为管理员提供了一种描述存储类型的方法。通常情况下，管理员需要手工创建所需的存储资源。利用动态容量供给的功能，就可以实现动态创建PV的能力。动态容量供给 Dynamic Volume Provisioning 主要依靠StorageClass。