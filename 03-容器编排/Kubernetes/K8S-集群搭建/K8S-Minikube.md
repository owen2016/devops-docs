# Minikube

[TOC]

## 介绍

- <https://minikube.sigs.k8s.io/docs/>

Minikube 用于快速在本地搭建 Kubernetes 单节点集群环境，它对硬件资源没有太高的要求，方便开发人员学习试用，或者进行日常的开发。

其支持大部分kubernetes的功能，列表如下

- DNS
- NodePorts
- ConfigMaps and Secrets
- Dashboards
- Container Runtime: Docker, and rkt
- Enabling CNI (Container Network Interface)
- Ingress
- ...

[Minikube](https://github.com/kubernetes/minikube) 支持 Windows、macOS、Linux 三种 OS，会根据平台不同，下载对应的虚拟机镜像，并在镜像内安装 k8s。

目前的虚拟机技术都是基于[Hypervisor](https://en.wikipedia.org/wiki/Hypervisor) 来实现的，Hypervisor 规定了统一的虚拟层接口，由此 Minikube 就可以无缝切换不同的虚拟机实现，如 macOS 可以切换[hyperkit](https://github.com/moby/hyperkit) 或 VirtualBox， Windows 下可以切换 [Hyper-V](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v) 或 VirtualBox 等。

虚拟机的切换可以通过 --vm-driver 实现，如`minikube start --vm-driver hyperkit/ minikube start --vm-driver hyperv`

如果 Minikube 安装在内核原生就支持 LXC 的 OS 内，如 Ubuntu 等，再安装一次虚拟机显然就是对资源的浪费了，Minikube 提供了直接对接 OS 底层的方式

- driver!=none mode

    `In this case minikube provisions a new docker-machine (Docker daemon/Docker host) using any supported providers. 
    For instance:
    a) local provider = your Windows/Mac local host: it frequently uses VirtualBox as a hypervisor, and creates inside it a VM based on boot2docker image (configurable). In this case k8s bootstraper (kubeadm) creates all Kubernetes components inside this isolated VM. In this setup you have usually two docker daemons, your local one for development (if you installed it prior), and one running inside minikube VM.
    b) cloud hosts - not supported by minikube`

- driver=none mode

    `In this mode, your local docker host is re-used.
    In case no.1 there will be a performance penalty, because each VM generates some overhead, by running several system processes required by VM itself, in addition to those required by k8s components running inside VM. I think driver-mode=none is similar to " HYPERLINK "https://blog.alexellis.io/be-kind-to-yourself/"kind" version of k8s boostraper, meant for doing CI/integration tests.`

## Minikube 安装

### 下载Minikube

- <https://kubernetes.io/docs/tasks/tools/install-minikube/>

`curl -Lo minikube https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v1.13.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/`

`curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64  && sudo install minikube-linux-amd64 /usr/local/bin/minikube`

### 下载Kubectl

- <https://kubernetes.io/docs/tasks/tools/install-kubectl/>

`curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/`

### 启动Minikube

#### 启动参数

启动命令：`minikube start "参数"`

``` bash
- --image-mirror-country cn 将缺省利用 registry.cn-hangzhou.aliyuncs.com/google_containers 作为安装Kubernetes的容器镜像仓库，
- --iso-url=*** 利用阿里云的镜像地址下载相应的 .iso 文件
- --cpus=2: 为minikube虚拟机分配CPU核数
- --memory=2000mb: 为minikube虚拟机分配内存数
- --kubernetes-version=***: minikube 虚拟机将使用的 kubernetes 版本 ,e.g. --kubernetes-version v 1.17.3
- --docker-env http_proxy 传递代理地址

默认启动使用的是 VirtualBox 驱动，使用 --vm-driver 参数可以指定其它驱动
# https://minikube.sigs.k8s.io/docs/drivers/
- --vm-driver=none 表示用容器；
- --vm-driver=virtualbox 表示用虚拟机；

```

**注意:** To use kubectl or minikube commands as your own user, you may need to relocate them. For example, to overwrite your own settings, run:

``` shell
    sudo mv /root/.kube /root/.minikube $HOME
    sudo chown -R $USER $HOME/.kube $HOME/.minikube
```

#### 示例

##### --vm-driver=kvm2

参考: <https://minikube.sigs.k8s.io/docs/drivers/kvm2/>

`minikube start --image-mirror-country cn  --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers --registry-mirror=https://ovfftd6p.mirror.aliyuncs.com --vm-driver=kvm2`

##### --vm-driver=hyperv

``` shell
# 创建基于Hyper-V的Kubernetes测试环境
minikube.exe start --image-mirror-country cn \
    --iso-url=https://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/iso/minikube-v1.5.0.iso \
    --registry-mirror=https://xxxxxx.mirror.aliyuncs.com \
    --vm-driver="hyperv" \
    --hyperv-virtual-switch="MinikubeSwitch" \
    --memory=4096
```

##### --vm-driver=none

`sudo minikube start --image-mirror-country cn --vm-driver=none`

![minikube-install](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201109232454.png)

`sudo minikube start --vm-driver=none  --docker-env http_proxy=http://$host_IP:8118 --docker-env https_proxy=https:// $host_IP:8118`

其中$host_IP指的是host的IP，可以通过ifconfig查看；比如在我这台机器是10.0.2.15，用virtualbox部署，则用下列命令启动minikube

`sudo minikube start --vm-driver=none  --docker-env http_proxy=http://10.0.2.15:8118 --docker-env https_proxy=https://10.0.2.15:8118`

#### Minikube 状态查看

启动完毕，将会运行一个单节点的Kubernetes集群。Minikube也已经把kubectl配置好，因此无需做额外的工作就可以管理容器。
Minikube 创建一个Host-Only（仅主机模式）网络接口，通过这个接口可以路由到节点。如果要与运行的pods或services进行交互，你应该通过这个地址发送流量。使用 `minikube ip` 命令可以查看这个地址：

![minikube-status](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201109232554.png)

## Minikube 使用

用户使用Minikube CLI管理虚拟机上的Kubernetes环境，比如：启动，停止，删除，获取状态等。一旦Minikube虚拟机启动，用户就可以使用熟悉的Kubectl CLI在Kubernetes集群上执行操作

![](https://gitee.com/owen2016/pic-hub/raw/master/1603727554_20200924133259699_1050517294.png)

``` shell
# 查看集群的所有资源
kubectl get all

# 进入节点服务器
minikube ssh

# 执行节点服务器命令，例如查看节点 docker info
minikube ssh -- docker info

# 删除集群, 删除 ~/.minikube 目录缓存的文件
minikube delete

# 关闭集群
minikube stop

## 销毁集群
minikube stop && minikube delete
```

### Minikube 插件

`sudo minikube addons list`

![](https://gitee.com/owen2016/pic-hub/raw/master/1603727554_20200924163633817_1703858149.png)

Minikube 默认集成了 Kubernetes Dashboard。执行 `minikube dashboard` 命令后，默认会打开浏览器

![minikube-dashboard](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201109232530.png)

## 安装遇到的问题

### 问题-1

Failed to save config: failed to acquire lock for /root/.minikube/profiles/minikube/config.json: unable to open /tmp/juju-mk270d1b5db5965f2dc9e9e25770a63417031943: permission denied

![](https://gitee.com/owen2016/pic-hub/raw/master/1603727554_20200924141404177_1210938693.png)

解决办法：

``` shell
sudo rm -rf /tmp/juju-mk*
sudo rm -rf /tmp/minikube.*
```

### 问题-2

unable to read client-cert /root/.minikube/client.crt for minikube due to open /root/.minikube/client.crt: permission denied
unable to read client-key /root/.minikube/client.key for minikube due to open /root/.minikube/client.key: permission denied
unable to read certificate-authority /root/.minikube/ca.crt for minikube due to open /root/.minikube/ca.crt: permission denied

解决办法：

``` shell
minikube stop
minikube delete
rm -rf ~/.kube
rm -rf ~/.minikube
sudo rm -rf /var/lib/minikube
sudo rm /var/lib/kubeadm.yaml
sudo rm -rf /etc/kubernetes
```

参考：<https://stackoverflow.com/questions/58541104/minikube-wont-work-after-ubuntu-upgrade-to-19-10>

### 问题-3

Error restarting cluster: restarting kube-proxy: waiting for kube-proxy to be up for configmap update: timed out waiting for the condition 

通过 minikube delete，minikube start 可以解决

## 部署应用

``` shell
$ kubectl run hello-minikube --image=k8s.gcr.io/echoserver:1.10 --port=8080
deployment.apps/hello-minikube created

#访问应用
$ kubectl expose deployment hello-minikube --type=NodePort
service/hello-minikube exposed

#获取服务地址
$ minikube service hello-minikube --url
http://192.168.99.105:30555

```

## 参考资料

1. [Minikube - Kubernetes本地实验环境](https://yq.aliyun.com/articles/221687)
2. [Hello Minikube](https://kubernetes.io/docs/tutorials/hello-minikube/)
3. [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/setup/minikube/)
4. [Install Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/")
