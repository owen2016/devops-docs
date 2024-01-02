# k8s-setup

## kubeadm

#### manifests

kube-scheduler 是以静态 Pod 的形式运行在集群中的，所以我们只需要更改静态 Pod 目录下面对应的 YAML (kube-scheduler.yaml)文件即可：

``` yaml
$ cd /etc/kubernetes/manifests
将 kube-scheduler.yaml 文件中-command的--address地址更改成0.0.0.0
$ vim kube-scheduler.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ""
  creationTimestamp: null
  labels:
    component: kube-scheduler
    tier: control-plane
  name: kube-scheduler
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --address=0.0.0.0
    - --kubeconfig=/etc/kubernetes/scheduler.conf
    - --leader-elect=true
....
```


### 使用kubeadm构建一个master节点
通过kubeadm init [flags]命令可以启动一个master节点。其中[flags]代表了kubeadm init命令可以传入的参数。

如果查看官方介绍，可以发现kubeadm init可以传入的参数比较多，这里只简单介绍几种（其他的大家可以到 这里查看 ）：

```
–apiserver-bind-port int32 Default: 6443 可以通过这个参数指定API-server的工作端口，默认是6443。
–config string 可以通过这个命令传入kubeadm的配置文件，需要注意的是，这个参数是实验性质的，不推荐使用。
–dry-run 带了这个参数后，运行命令将会把kubeadm做的事情输出到标准输出，但是不会实际部署任何东西。强烈推荐！
-h, --help 输出帮助文档。
–node-name string 指定当前节点的名称。
–pod-network-cidr string 通过这个值来设定pod网络的IP地址网段；设置了这个值以后，控制平面会自动给每个节点设置CIDRs（无类别域间路由，Classless Inter-Domain Routing）。
–service-cidr string Default: “10.96.0.0/12” 设置service的CIDRs，默认为 10.96.0.0/12。
–service-dns-domain string Default: “cluster.local” 设置域名称后缀，默认为cluster.local。
```
其他参数。

### kubeadm-init的工作流

- https://www.cnblogs.com/shoufu/p/13047723.html

在运行了 kubeadm init 命令以后，都进行了那些操作呢？这里主要就是跟着官方文档来翻译一遍了：

1. 首先会运行一系列预检代码来检查系统的状态；大部分的检查只会抛出一个警告，也有一部分会抛出异常错误从而导致工作流推出（比如没有关闭swap或者没有安装docker）。官方给出一个参数–ignore-preflight-errors=， 我估计八成大家用不到，除非真的明白自己在做啥。。。

2. 生成一个用来认证k8s组件间调用的自签名的CA（Certificate Authority，证书授权）；这个证书也可以通过–cert-dir（默认是/etc/kubernetets/pki）的方式传入，那么这一步就会跳过。

3. 把kubelet、controller-manager和scheduler等组件的配置文件写到/etc/kubernets/目录，这几个组件会使用这些配置文件来连接API-server的服务；除了上面几个配置文件，还会生成一个管理相关的`admin.conf`文件。

4. 如果参数中包含–feature-gates=DynamicKubeletConfig，会把kubelet的初始化配置文件写入/var/lib/kubelet/config/init/kubelet这个文件；官方给出一坨文字解释，这里先不探究了，因为我没有用到。。。

5. 接下来就是创建一些 静态pod 的配置文件了，包括API-server、controller-manager和scheduler。假如没有提供外部etcd，还会另外生成一个etcd的静态Pod配置文件。这些静态pod会被写入/etc/kubernetes/manifests，kubelet进程会监控这个目录，从而创建相关的pod。

6. 假如第五步比较顺利，这个时候k8s的控制进程（api-server、controller-manager、scheduler）就全都起来了。

7. 如果传入了参数–feature-gates=DynamicKubeletConfig，又会对kubelet进行一坨操作，因为没有用到，所以这里不做详细探究。

8. 给当前的节点（Master节点）打label和taints，从而防止其他的负载在这个节点运行。

9. 生成token，其他节点如果想加入当前节点（Master）所在的k8s集群，会用到这个token。

10. 进行一些允许节点以 Bootstrap Tokens) 和 TLS bootstrapping 方式加入集群的必要的操作：
- 设置RBAC规则，同时创建一个用于节点加入集群的ConfigMap（包含了加入集群需要的所有信息）。
- 让Bootstrap Tokens可以访问CSR签名的API。
- 给新的CSR请求配置自动认证机制。

11. 通过API-server安装DNS服务器（1.11版本后默认为CoreDNS，早期版本默认为kube-dns）和kube-proxy插件。这里需要注意的是，DNS服务器只有在安装了CNI（flannel或calico）之后才会真正部署，否则会处于挂起（pending）状态。

**The "init" command executes the following phases:**

```
preflight                    Run pre-flight checks
kubelet-start                Write kubelet settings and (re)start the kubelet
certs                        Certificate generation
  /ca                          Generate the self-signed Kubernetes CA to provision identities for other Kubernetes components
  /apiserver                   Generate the certificate for serving the Kubernetes API
  /apiserver-kubelet-client    Generate the certificate for the API server to connect to kubelet
  /front-proxy-ca              Generate the self-signed CA to provision identities for front proxy
  /front-proxy-client          Generate the certificate for the front proxy client
  /etcd-ca                     Generate the self-signed CA to provision identities for etcd
  /etcd-server                 Generate the certificate for serving etcd
  /etcd-peer                   Generate the certificate for etcd nodes to communicate with each other
  /etcd-healthcheck-client     Generate the certificate for liveness probes to healthcheck etcd
  /apiserver-etcd-client       Generate the certificate the apiserver uses to access etcd
  /sa                          Generate a private key for signing service account tokens along with its public key
kubeconfig                   Generate all kubeconfig files necessary to establish the control plane and the admin kubeconfig file
  /admin                       Generate a kubeconfig file for the admin to use and for kubeadm itself
  /kubelet                     Generate a kubeconfig file for the kubelet to use *only* for cluster bootstrapping purposes
  /controller-manager          Generate a kubeconfig file for the controller manager to use
  /scheduler                   Generate a kubeconfig file for the scheduler to use
control-plane                Generate all static Pod manifest files necessary to establish the control plane
  /apiserver                   Generates the kube-apiserver static Pod manifest
  /controller-manager          Generates the kube-controller-manager static Pod manifest
  /scheduler                   Generates the kube-scheduler static Pod manifest
etcd                         Generate static Pod manifest file for local etcd
  /local                       Generate the static Pod manifest file for a local, single-node local etcd instance
upload-config                Upload the kubeadm and kubelet configuration to a ConfigMap
  /kubeadm                     Upload the kubeadm ClusterConfiguration to a ConfigMap
  /kubelet                     Upload the kubelet component config to a ConfigMap
upload-certs                 Upload certificates to kubeadm-certs
mark-control-plane           Mark a node as a control-plane
bootstrap-token              Generates bootstrap tokens used to join a node to a cluster
kubelet-finalize             Updates settings relevant to the kubelet after TLS bootstrap
  /experimental-cert-rotation  Enable kubelet client certificate rotation
addon                        Install required addons for passing Conformance tests
  /coredns                     Install the CoreDNS addon to a Kubernetes cluster
  /kube-proxy                  Install the kube-proxy addon to a Kubernetes cluster
```

####  pod-network-cidr 
kubeadm 集群初始化参数 pod-network-cidr 有什么作用？

- https://blog.csdn.net/shida_csdn/article/details/104334372

在使用kubeadm初始化集群的命令中指定pod-network-cidr是cni网络插件的需求（比如weave)。有些是不需要指定的。

这个pod-network-cidr并不是本地网络ip也不是云服务ip，而是建立起来的k8s集群中每个pod所在的网络，是一个虚拟网络。一般我们会使用非公网网络ip段（比如：192.168.0.0/24等）来作为pod网络为cidr赋值。


创建集群时用的是 --pod-network-cidr=10.244.0.0/16 （当时准备使用Flannel），现在想改为 --pod-network-cidr=192.168.0.0/16 （现在准备使用Calico），请问在不重建集群的情况下如何修改？
打开下面的2个配置，将 10.244.0.0/16 改为 192.168.0.0/16
1）kubectl -n kube-system edit cm kubeadm-config
2）vim /etc/kubernetes/manifests/kube-scheduler.yaml

通过 kubectl cluster-info dump | grep -m 1 cluster-cidr 命令可以检查配置是否生效


### log-kubeadm init

```
user@k8s-master:~$ sudo kubeadm init --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16
[sudo] password for user:
W1014 13:50:25.325887   12096 version.go:102] could not fetch a Kubernetes version from the internet: unable to get URL "https://dl.k8s.io/release/stable-1.txt": Get https://storage.googleapis.com/kubernetes-release/release/stable-1.txt: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
W1014 13:50:25.325965   12096 version.go:103] falling back to the local client version: v1.18.6
W1014 13:50:25.326137   12096 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.6
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.20.249.16]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [172.20.249.16 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [172.20.249.16 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W1014 13:50:29.884820   12096 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W1014 13:50:29.885804   12096 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[kubelet-check] Initial timeout of 40s passed.
[apiclient] All control plane components are healthy after 42.724293 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-master as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: cma8ob.ow9sfv5erqgkkp30
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 172.20.249.16:6443 --token cma8ob.ow9sfv5erqgkkp30 \
    --discovery-token-ca-cert-hash sha256:def379576eacaddbb4bbf4ca12fbb8a0b77383e4521cbf238f21c8dd3cb80fab


```

### log-kubeadm join

```
user@k8s-node-02:~$ sudo kubeadm join 172.20.249.16:6443 --token cma8ob.ow9sfv5erqgkkp30     --discovery-token-ca-cert-hash sha256:def379576eacaddbb4bbf4ca12fbb8a0b77383e4521cbf238f21c8dd3cb80fab
[sudo] user 的密码：
W1014 14:29:05.971731    9020 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

```

### kubeadm reset
如果你的集群安装过程中遇到了其他问题，我们可以使用下面的命令来进行重置：

```
$ kubeadm reset
$ ifconfig cni0 down && ip link delete cni0
$ ifconfig flannel.1 down && ip link delete flannel.1
$ rm -rf /var/lib/cni/

```

### kubeadm token

如果忘记保存上面的 token 和 sha256 值的话也不用担心，我们可以使用下面的命令来查找：

``` shell

user@k8s-master:~$ kubeadm token list
TOKEN                     TTL         EXPIRES                     USAGES                   DESCRIPTION                                                EXTRA GROUPS
cma8ob.ow9sfv5erqgkkp30   20h         2020-10-15T13:51:14+08:00   authentication,signing   The default bootstrap token generated by 'kubeadm init'.   system:bootstrappers:kubeadm:default-node-token

user@k8s-master:~$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
def379576eacaddbb4bbf4ca12fbb8a0b77383e4521cbf238f21c8dd3cb80fab
user@k8s-master:~$ kubectl get scr

```




## dashboard

- https://www.cnblogs.com/lixinliang/p/12217169.html

认证时的账号必须为ServiceAccount：其作用是被dashboard pod拿来由kubenetes进行认证；认证方式有2种：
token：

（1）创建ServiceAccount，根据其管理目标，使用rolebinding或clusterbinding绑定至合理的role或clusterrole；
（2）获取此ServiceAccount的secret，查看secret的详细信息，其中就有token；
（3）复制token到认证页面即可登录。
kubeconfig：把ServiceAccount的token封装为kubeconfig文件

（1）创建ServiceAccount，根据其管理目标，使用rolebinding或clusterbinding绑定至合理的role或clusterrole；
（2）kubectl get secret |awk '/^ServiceAccount/{print $1}'
KUBE_TOKEN=$(kubectl get secret SERVICEACCOUNT_SECRET_NAME -o jsonpath={.data.token} | base64 -d)
（3）生成kubeconfig文件

kubectl config set-credentials NAME --token=$KUBE_TOKEN
kubectl config set-context
kubectl config use-context

```

#创建dashboard管理用户

kubectl create serviceaccount dashboard-admin -n kube-system

#绑定用户为集群管理用户

kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin


DASH_TOCKEN=$(kubectl get secret -n kube-system dashboard-admin-token-l7kpn -o jsonpath={.data.token}|base64 -d)

配置def-ns-admin的集群信息

kubectl config set-cluster kubernetes --server=192.168.0.25:6443 --kubeconfig=/root/dashbord-admin.conf

kubectl config set-credentials dashboard-admin --token=$DASH_TOCKEN --kubeconfig=/root/dashbord-admin.conf

kubectl config set-context dashboard-admin@kubernetes --cluster=kubernetes --user=dashboard-admin --kubeconfig=/root/dashbord-admin.conf

kubectl config user-context dashboard-admin@kubernets --kubeconfig=/root/dashbord-admin.conf

kubectl config view --kubeconfig=/root/dashbord-admin.conf

```

## 问题记录


```
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
```

- https://www.zhihu.com/question/286840018/answer/584055465


```
10月 14 15:47:30 k8s-node-01 kubelet[11362]: F1014 15:47:30.254743   11362 server.go:274] failed to run Kubelet: running with swap on is not supported, please disable swap! or set --fail-swap-on flag to false. /proc/swaps contained: [Filename                                Type                Size        Used        Priority /swapfile 
```

https://www.cnblogs.com/embedded-linux/p/12388586.html


## Demo 

```
# kubectl create namespace sock-shop  
# kubectl apply -n sock-shop -f "https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml?raw=true"
```