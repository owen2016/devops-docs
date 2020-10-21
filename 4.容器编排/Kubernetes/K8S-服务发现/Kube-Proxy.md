# Kube-Proxy

Service能将pod的变化屏蔽在集群内部，同时提供负载均衡的能力，自动将请求流量分布到后端的pod，这一功能的实现靠的就是`kube-proxy` 实现的。

共有三种模式，userspace、iptables以及ipvs。

## UserSpace

使用Userspace模式（k8s版本为1.2之前默认模式），外部网络可以直接访问cluster IP。所有的转发都是通过 kube-proxy 软件来实现，如下所示：

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021232933.png)

客户端访问 service-ip （clusterIP）请求会先从用户态切换到内核的 iptables ，然后回到用户态 kube-proxy，kube-proxy 负责代理转发工作，具体的细节如下：
>
>该模式下kube-proxy会为每一个Service创建一个监听端口。发向Cluster IP的请求被Iptables规则重定向到Kube-proxy监听的端口上，Kube-proxy根据LB算法选择一个提供服务的Pod并和其建立链接，以将请求转发到Pod上。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021232433.png)

该模式下，Kube-proxy充当了一个四层Load balancer的角色。由于kube-proxy运行在userspace中，在进行转发处理时会增加两次内核和用户空间之间的数据拷贝，`效率较另外两种模式低一些`；好处是当后端的Pod不可用时，kube-proxy可以重试其他Pod

#### 示例-1

以ssh-service1为例，kube为其分配了一个clusterIP。分配clusterIP的作用还是如上文所说，是方便pod到service的数据访问。
```
[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ kubectl get service
NAME             LABELS                                    SELECTOR              IP(S)            PORT(S)
kubernetes       component=apiserver,provider=kubernetes   <none>                10.254.0.1       443/TCP
ssh-service1     name=ssh,role=service                     ssh-service=true      10.254.132.107   2222/TCP
```
使用describe可以查看到详细信息。可以看到暴露出来的NodePort端口30239。

```
[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ kubectl describe service ssh-service1 
Name:           ssh-service1
Namespace:      default
Labels:         name=ssh,role=service
Selector:       ssh-service=true
Type:           LoadBalancer
IP:         10.254.132.107
Port:           <unnamed>   2222/TCP
NodePort:       <unnamed>   30239/TCP
Endpoints:      <none>
Session Affinity:   None
No events.
```
nodePort的工作原理与clusterIP大致相同，是发送到node上指定端口的数据，通过iptables重定向到kube-proxy对应的端口上。然后由kube-proxy进一步把数据发送到其中的一个pod上。

该node的ip为10.0.0.5
```
[minion@te-yuab6awchg-0-z5nlezoa435h-kube-master-udhqnaxpu5op ~]$ sudo iptables -S -t nat
...
-A KUBE-NODEPORT-CONTAINER -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 30239 -j REDIRECT --to-ports 36463
-A KUBE-NODEPORT-HOST -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 30239 -j DNAT --to-destination 10.0.0.5:36463
-A KUBE-PORTALS-CONTAINER -d 10.254.132.107/32 -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 2222 -j REDIRECT --to-ports 36463
-A KUBE-PORTALS-HOST -d 10.254.132.107/32 -p tcp -m comment --comment "default/ssh-service1:" -m tcp --dport 2222 -j DNAT --to-destination 10.0.0.5:36463
```
可以看到访问node时候的30239端口会被转发到node上的36463端口。而且在访问clusterIP 10.254.132.107的2222端口时，也会把请求转发到本地的36463端口。
36463端口实际被kube-proxy所监听，将流量进行导向到后端的pod上。

## iptables

为了避免增加内核和用户空间的数据拷贝操作，提高转发效率，Kube-proxy提供了iptables模式（在K8S 1.2版本之后，kube-proxy为默认方式, 外部网络不能直接访问cluster IP）。所有转发都是通过Iptables内核模块实现，而kube-proxy只负责生成相应的iptables规则。

具体的细节如下：

> 在该模式下，Kube-proxy为service后端的每个Pod创建对应的iptables规则，iptables 会捕获 clusterIP 上的端口 （targetPort ) 流量重定向到后端的一个 Pod 上，默认情况下，对后端 Pod 的选择是随机的，也可以设置会话保持。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021234004.png)

该模式下Kube-proxy不承担四层代理的角色，只负责创建iptables规则。该模式的优点是较userspace模式效率更高，但不能提供灵活的LB策略，当后端Pod不可用时（如果某个service尚没有Pod创建）也无法进行重试

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021234424.png)

### 原理分析

kube-proxy监听service和endpoint的变化(service创建删除和修改, pod的扩张与缩小)，将需要新增的规则添加到iptables中。
kube-proxy只是作为controller，而不是server，真正服务的是内核的netfilter，体现在用户态则是iptables。
kube-proxy的iptables方式也支持RoundRobin（默认模式）和SessionAffinity负载分发策略。
kubernetes只操作了filter和nat表。

- Filter：在该表中，一个基本原则是只过滤数据包而不修改他们。filter table的优势是小而快，可以hook到input，output和forward。这意味着针对任何给定的数据包，只有可能有一个地方可以过滤它。

- NAT：此表的主要作用是在PREROUTING和POSTROUNTING的钩子中，修改目标地址和原地址。与filter表稍有不同的是，该表中只有新连接的第一个包会被修改，修改的结果会自动apply到同一连接的后续包中。

kube-proxy对iptables的链进行了扩充，自定义了KUBE-SERVICES，KUBE-NODEPORTS，KUBE-POSTROUTING，KUBE-MARK-MASQ和KUBE-MARK-DROP五个链，并主要通过为KUBE-SERVICES chain增加rule来配制traffic routing 规则。我们可以看下自定义的这几个链的作用：

- KUBE-MARK-DROP - [0:0] 对于未能匹配到跳转规则的traffic set mark 0x8000，有此标记的数据包会在filter表drop掉

- KUBE-MARK-MASQ - [0:0] 对于符合条件的包 set mark 0x4000, 有此标记的数据包会在KUBE-POSTROUTING chain中统一做MASQUERADE

- KUBE-NODEPORTS - [0:0] 针对通过nodeport访问的package做的操作

- KUBE-POSTROUTING - [0:0]KUBE-SERVICES - [0:0] 操作跳转规则的主要chain

同时，kube-proxy也为默认的prerouting、output和postrouting chain增加规则，使得数据包可以跳转至k8s自定义的chain，规则如下：

```
 -A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES

 -A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES

 -A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING 
```

如果service类型为nodePort，（从LB转发至node的数据包均属此类）那么将KUBE-NODEPORTS链中每个目的地址是NODE节点端口的数据包导入这个“KUBE-SVC-”链：
```
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS

 -A KUBE-NODEPORTS -p tcp -m comment --comment "default/es1:http" -m tcp --dport 32135 -j KUBE-MARK-MASQ

 -A KUBE-NODEPORTS -p tcp -m comment --comment "default/es1:http" -m tcp --dport 32135 -j KUBE-SVC-LAS23QA33HXV7KBL 

```

Iptables chain支持嵌套并因为依据不同的匹配条件可支持多种分支，比较难用标准的流程图来体现调用关系，简单抽象为下图：

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021235145.png)

#### 示例-1
在本例中，创建了名为mysql-service的service。
```
apiVersion: v1
kind: Service
metadata:
  labels:
    name: mysql
    role: service
  name: mysql-service
spec:
  ports:
    - port: 3306
      targetPort: 3306
      nodePort: 30964
  type: NodePort
  selector:
    mysql-service: "true"
```
mysql-service对应的nodePort暴露出来的端口为30964，对应的cluster IP(10.254.162.44)的端口为3306，进一步对应于后端的pod的端口为3306。

mysql-service后端代理了两个pod，ip分别是192.168.125.129和192.168.125.131。先来看一下iptables。
```
[root@localhost ~]# iptables -S -t nat
...
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A POSTROUTING -m comment --comment "kubernetes postrouting rules" -j KUBE-POSTROUTING
-A KUBE-MARK-MASQ -j MARK --set-xmark 0x4000/0x4000
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/mysql-service:" -m tcp --dport 30964 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/mysql-service:" -m tcp --dport 30964 -j KUBE-SVC-67RL4FN6JRUPOJYM
-A KUBE-SEP-ID6YWIT3F6WNZ47P -s 192.168.125.129/32 -m comment --comment "default/mysql-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-ID6YWIT3F6WNZ47P -p tcp -m comment --comment "default/mysql-service:" -m tcp -j DNAT --to-destination 192.168.125.129:3306
-A KUBE-SEP-IN2YML2VIFH5RO2T -s 192.168.125.131/32 -m comment --comment "default/mysql-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-IN2YML2VIFH5RO2T -p tcp -m comment --comment "default/mysql-service:" -m tcp -j DNAT --to-destination 192.168.125.131:3306
-A KUBE-SERVICES -d 10.254.162.44/32 -p tcp -m comment --comment "default/mysql-service: cluster IP" -m tcp --dport 3306 -j KUBE-SVC-67RL4FN6JRUPOJYM
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
-A KUBE-SVC-67RL4FN6JRUPOJYM -m comment --comment "default/mysql-service:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-ID6YWIT3F6WNZ47P
-A KUBE-SVC-67RL4FN6JRUPOJYM -m comment --comment "default/mysql-service:" -j KUBE-SEP-IN2YML2VIFH5RO2T
```

下面来逐条分析

首先如果是通过node的30964端口访问，则会进入到以下链
```
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/mysql-service:" -m tcp --dport 30964 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/mysql-service:" -m tcp --dport 30964 -j KUBE-SVC-67RL4FN6JRUPOJYM
```

然后进一步跳转到KUBE-SVC-67RL4FN6JRUPOJYM的链
```
-A KUBE-SVC-67RL4FN6JRUPOJYM -m comment --comment "default/mysql-service:" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-ID6YWIT3F6WNZ47P
-A KUBE-SVC-67RL4FN6JRUPOJYM -m comment --comment "default/mysql-service:" -j KUBE-SEP-IN2YML2VIFH5RO2T
```

这里利用了iptables的--probability的特性，使连接有50%的概率进入到KUBE-SEP-ID6YWIT3F6WNZ47P链，50%的概率进入到KUBE-SEP-IN2YML2VIFH5RO2T链。

KUBE-SEP-ID6YWIT3F6WNZ47P的链的具体作用就是将请求通过DNAT发送到192.168.125.129的3306端口。
```
-A KUBE-SEP-ID6YWIT3F6WNZ47P -s 192.168.125.129/32 -m comment --comment "default/mysql-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-ID6YWIT3F6WNZ47P -p tcp -m comment --comment "default/mysql-service:" -m tcp -j DNAT --to-destination 192.168.125.129:3306
```

同理KUBE-SEP-IN2YML2VIFH5RO2T的作用是通过DNAT发送到192.168.125.131的3306端口。
```
-A KUBE-SEP-IN2YML2VIFH5RO2T -s 192.168.125.131/32 -m comment --comment "default/mysql-service:" -j KUBE-MARK-MASQ
-A KUBE-SEP-IN2YML2VIFH5RO2T -p tcp -m comment --comment "default/mysql-service:" -m tcp -j DNAT --to-destination 192.168.125.131:3306
```

分析完nodePort的工作方式，接下里说一下clusterIP的访问方式。
对于直接访问cluster IP(10.254.162.44)的3306端口会直接跳转到KUBE-SVC-67RL4FN6JRUPOJYM。
```
-A KUBE-SERVICES -d 10.254.162.44/32 -p tcp -m comment --comment "default/mysql-service: cluster IP" -m tcp --dport 3306 -j KUBE-SVC-67RL4FN6JRUPOJYM
```
接下来的跳转方式同上文，这里就不再赘述了。

#### 示例-2

这里以我们集群的iptables规则为例介绍数据包的迁移规则：

PREROUTING和OUTPUT两个检查点：即入链和出链都会路由到KUBE-SERVICE这个全局链中

`sudo iptables -S -tnat|grep KUBE-`

接着我们可以看下这个全局链的路由过程，这里只筛选部分规则说明：

```
1、-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y

2、-A KUBE-SVC-NPX46M4PTMTKRN6Y -m comment --comment "default/kubernetes:https" -m recent --rcheck --seconds 10800 --reap --name KUBE-SEP-VFX5D4HWHAGOXYCD --mask 255.255.255.255 --rsource -j KUBE-SEP-VFX5D4HWHAGOXYCD

3、-A KUBE-SEP-VFX5D4HWHAGOXYCD -p tcp -m comment --comment "default/kubernetes:https" -m recent --set --name KUBE-SEP-VFX5D4HWHAGOXYCD --mask 255.255.255.255 --rsource -m tcp -j DNAT --to-destination 172.22.44.62:6443
```

10.96.0.1为clusterip，发往目的地为clusterip的数据包会被转发由KUBE-SVC-NPX46M4PTMTKRN6Y规则处理，接着我们依次找下去，可以看到最后路由到了172.22.44.62:6443，这就是后端的pod服务的对应ip:port。

#### 示例-3

举个例子，在k8s集群中创建了一个名为my-service的服务，其中：

service vip：10.11.97.177
对应的后端两副本pod ip：10.244.1.10、10.244.2.10
容器端口为：80
服务端口为：80

则kube-proxy为该service生成的iptables规则主要有以下几条：

```
 -A KUBE-SERVICES -d 10.11.97.177/32 -p tcp -m comment --comment "default/my-service: cluster IP" -m tcp --dport 80 -j KUBE-SVC-BEPXDJBUHFCSYIC3

 -A KUBE-SVC-BEPXDJBUHFCSYIC3 -m comment --comment “default/my-service:” -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-U4UWLP4OR3LOJBXU  //50%的概率轮询后端pod
 -A KUBE-SVC-BEPXDJBUHFCSYIC3 -m comment --comment "default/my-service:" -j KUBE-SEP-QHRWSLKOO5YUPI7O

 -A KUBE-SEP-U4UWLP4OR3LOJBXU -s 10.244.1.10/32 -m comment --comment "default/my-service:" -j KUBE-MARK-MASQ
 -A KUBE-SEP-U4UWLP4OR3LOJBXU -p tcp -m comment --comment "default/my-service:" -m tcp -j DNAT --to-destination 10.244.1.10:80
 -A KUBE-SEP-QHRWSLKOO5YUPI7O -s 10.244.2.10/32 -m comment --comment "default/my-service:" -j KUBE-MARK-MASQ
 -A KUBE-SEP-QHRWSLKOO5YUPI7O -p tcp -m comment --comment "default/my-service:" -m tcp -j DNAT --to-destination 10.244.2.10:80 

```

不同于userspace，iptables由kube-proxy动态的管理，kube-proxy不再负责转发，数据包的走向完全由iptables规则决定，这样的过程不存在内核态到用户态的切换，效率明显会高很多。但是随着service的增加，iptables规则会不断增加，导致内核十分繁忙（等于在读一张很大的没建索引的表）

### IPVS

- https://www.codercto.com/a/20391.html

从 k8s 1.8 版本之后，新增 kube-proxy 对 ipvs 的支持，并且在新版本的 k8s 1.11 版本中被纳入 GA。之所以会有 ipvs 这种模式，是因为 iptables 添加规则是不增量的，先把当前的 iptables 规则都拷贝出现，再做修改，然后再把修改后的 iptables 规则保存回去，这样一个过程的结果就是，iptables 在更新一条规则时，会把 iptables 锁住，这样的结果在服务数量达到一定量级时，性能基本上是不可接受的。

该模式和iptables类似，kube-proxy监控Pod的变化并创建相应的ipvs rules。ipvs也是在kernel模式下通过netfilter实现的，但采用了hash table来存储规则，因此在规则较多的情况下，Ipvs相对iptables转发效率更高。除此以外，ipvs支持更多的LB算法。如果要设置kube-proxy为ipvs模式，必须在操作系统中安装IPVS内核模块。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201021235356.png)