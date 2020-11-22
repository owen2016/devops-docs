# 证书认证

- https://www.cnblogs.com/fawaikuangtu123/p/11295376.html

![](https://gitee.com/owen2016/pic-hub/raw/master/202011/1606058777_20201113144038266_1786993979.png)


## 实践：基于客户端证书认证方式新建 Kubeconfig 访问集群

### Kubeconfig 文件详解
在安装完 k8s 集群后会生成 $HOME/.kube/config 文件，这个文件就是 kubectl 命令行工具访问集群时使用的认证文件，也叫 Kubeconfig 文件。这个 Kubeconfig 文件中有很多重要的信息，文件大概结构是这样，这里说明下每个字段的含义

``` yaml
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ...
    server: https://192.168.26.10:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: ...
    client-key-data: ...
```

可以看出文件分为三大部分：clusters、contexts、users
**clusters 部分**
定义集群信息，包括 api-server 地址、certificate-authority-data: 用于服务端证书认证的自签名 CA 根证书（master 节点 /etc/kubernetes/pki/ca.crt 文件内容 ）。

clusters指定了要访问的k8s集群，可以配置多个

**contexts 部分**
集群信息和用户的绑定，kubectl 通过上下文提供的信息连接集群。

contexts指定了使用哪个user，访问哪个集群，current-context 表示使用哪个context。

**users 部分**
多种用户类型，默认是客户端证书（x.509 标准的证书）和证书私钥，也可以是 ServiceAccount Token。这里重点说下前者：

- client-certificate-data: base64 加密后的客户端证书；
- client-key-data: base64 加密后的证书私钥；

一个请求在通过 api-server 的认证关卡后，api-server 会从收到客户端证书中取用户信息，然后用于后面的授权关卡，这里所说的用户并不是服务账号，而是客户端证书里面的 Subject 信息：O 代表用户组，CN 代表用户名。为了证明，可以使用 openssl 手动获取证书中的这个信息：

- 首先，将 Kubeconfig 证书的 user 部分 client-certificate-data 字段内容进行 base64 解密，保存文件为 client.crt，然后使用 openssl 解析证书信息即可看到 Subject 信息：

`openssl x509 -in client.crt -text`

解析集群默认的 Kubeconfig 客户端证书得到的 Subject 信息是：

`Subject: O=system:masters, CN=kubernetes-admin`

![](https://gitee.com/owen2016/pic-hub/raw/master/202011/1606058777_20201113153212158_1183374741.png)


可以看出该证书绑定的用户组是 system:masters，用户名是 kubernetes-admin，而集群中默认有个 ClusterRoleBinding 叫 cluster-admin，它将名为 cluster-admin 的 ClusterRole 和用户组 system:masters 进行了绑定，而名为 cluster-admin 的 ClusterRole 有集群范围的 Superadmin 权限，这也就理解了为什么默认的 Kubeconfig 能拥有极高的权限来操作 k8s 集群了。

## 新建具有只读权限的 Kubeconfig 文件

上面我们已经解释了为什么默认的 Kubeconfig 文件具有 Superadmin 权限，这个权限比较高，有点类型 Linux 系统的 Root 权限。有时我们会将集群访问权限开放给其他人员，比如供研发人员查看 Pod 状态、日志等信息，这个时候直接用系统默认的 Kubeconfig 就不太合理了，权限太大，集群的安全性没有了保障。更合理的做法是给研发人员一个只读权限的账号，避免对集群进行一些误操作导致故障。

我们以客户端证书认证方式创建 Kubeconfig 文件，所以需要向集群自签名 CA 机构（master 节点）申请证书，然后通过 RBAC 授权方式给证书用户授予集群只读权限，具体方法如下：

`假设我们设置证书的用户名为：developer – 证书申请时 -subj 选项 CN 参数。`

### 生成客户端 TLS 证书

1. 创建证书私钥

`openssl genrsa -out developer.key 2048`

2. 用上面私钥创建一个 csr(证书签名请求)文件，其中我们需要在 subject 里带上用户信息(CN为用户名，O为用户组)

`openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"`

其中/O参数可以出现多次，即可以有多个用户组

3. 找到 k8s 集群(API Server)的 CA 根证书文件，其位置取决于安装集群的方式，通常会在 master 节点的 /etc/kubernetes/pki/ 路径下，会有两个文件，一个是 CA 根证书(ca.crt)，一个是 CA 私钥(ca.key) 。

4. 通过集群的 CA 根证书和第 2 步创建的 csr 文件，来为用户颁发证书

`openssl x509 -req -in developer.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out developer.crt -days 365`

至此，客户端证书颁发完成，我们后面会用到文件是 developer.key 和 developer.crt


### 基于 RBAC 授权方式授予用户只读权限
在 k8s 集群中已经有个默认的名为 view 只读 ClusterRole 了，我们只需要将该 ClusterRole 绑定到 developer 用户即可：

`kubectl create clusterrolebinding kubernetes-viewer --clusterrole=view --user=developer`

### 基于客户端证书生成 Kubeconfig 文件

前面已经生成了客户端证书，并给证书里的用户赋予了集群只读权限，接下来基于客户端证书生成 Kubeconfig 文件：

拷贝一份 $HOME/.kube.config，假设名为 developer-config，在其基础上做修改：

1. contexts 部分 user 字段改为 developer，name 字段改为 developer@kubernetes。（这些改动随意命名，只要前后统一即可）；

2. users 部分 name 字段改为 developer，client-certificate-data 字段改为 developer.crt base64 加密后的内容，client-key-data 改为 developer.key base64 加密后的内容；

注意：证书 base64 加密时指定 --wrap=0 参数
cat developer.crt | base64 --wrap=0
cat developer.key | base64 --wrap=0

接下来测试使用新建的 Kubeconfig 文件:

```
[root@master ~]# kubectl --kubeconfig developer-config --context=developer@kubernetes get pod
NAME READY STATUS RESTARTS AGE
nginx-deployment-5754944d6c-dqsdj 1/1 Running 0 5d9h
nginx-deployment-5754944d6c-q675s 1/1 Running 0 5d9h

[root@master ~]# kubectl --kubeconfig developer-config --context=developer@kubernetes delete pod nginx-deployment-5754944d6c-dqsdj
Error from server (Forbidden): pods “nginx-deployment-5754944d6c-dqsdj” is forbidden: User “developer” cannot delete resource “pods” in API group “” in the namespace “default”
```

可以看出新建的 Kubeconfig 文件可以使用，写权限是被 forbidden 的，说明前面配的 RBAC 权限机制是起作用的。


## 实践：Kubeconfig 或 token 方式登陆 Kubernetes dashboard

我们打开 kubernetes dashboard 访问地址首先看到的是登陆认证页面，有两种登陆认证方式可供选择：Kubeconfig 和 Token 方式

其实两种方式都需要服务账号的 Token，对于 Kubeconfig 方式直接使用集群默认的 Kubeconfig: $HOME/.kube/config 文件不能登陆，因为文件中缺少 Token 字段，所以直接选择本地的 Kubeconfig 文件登陆会报错。正确的使用方法是获取某个服务账号的 Token，然后将 Token 加入到 $HOME/.kube/config 文件。下面具体实践下两种登陆 dashboard 方式：

### 准备工作
首先，两种方式都需要服务账号，所以我们先创建一个服务账号，然后为了测试，给这个服务账号一个查看权限（RBAC 授权），到时候登陆 dashboard 后只能查看，不能对集群中的资源做修改。

创建一个服务账号（在 default 命名空间下）；
`kubectl create serviceaccount kube-dashboard-reader`

将系统自带的 ClusterRole：view 角色绑定到上一步创建的服务账号，授予集群范围的资源只读权限；
`kubectl create clusterrolebinding kube-dashboard-reader --clusterrole=view --serviceaccount=default:kube-dashboard-reader`

获取服务账号的 token；
`kubectl get secret `kubectl get secret -n default | grep kube-dashboard-reader | awk '{print $1}'` -o jsonpath={.data.token} -n default | base64 -d `


### Kubeconfig 方式登陆 dashboard

拷贝一份 $HOME/.kube/config，修改内容，将准备工作中获取的 Token 添加入到文件中：在 Kubeconfig 的 Users 下 User 部分添加，类型下面这样:

``` 
...
users:
- name: kubernetes-admin
  user:
    client-certificate-data: ...
    client-key-data: ...
    token: <这里为上面获取的 Token...>
```
然后登陆界面选择 Kubeconfig 单选框，选择该文件即可成功登陆 dashboard。

### Token 方式登陆 dashboard

登陆界面选择 Token 单选框，将准备工作中获取的 Token 粘贴进去即可成功登陆。


### Openssl VS 

https://blog.csdn.net/hylexus/article/details/53058135

https://www.cnblogs.com/foohack/p/4103212.html