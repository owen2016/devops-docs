# service mesh

Service Mesh 直译过来是 服务网格，目的是解决系统架构微服务化后的服务间通信和治理问题。`服务网格由 sidecar 节点组成`

## sidecar

Sidecar 在软件系统架构中特指边车模式。这个模式的灵感来源于我们生活中的边三轮：即在两轮摩托车的旁边添加一个边车的方式扩展现有的服务和功能

这个模式的精髓在于实现了数据面（业务逻辑）和控制面的解耦：原来两轮摩托车的驾驶者集中注意力跑赛道，边车上的领航员专注周围信息和地图，专注导航。

具体到微服务架构中，即给每一个微服务实例（也可以是每个宿主机host）同步部署一个 sidecar proxy:

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058451_20201019111010313_2135460460.png)


该 sidecar proxy 负责接管对应服务的入流量和出流量。并将微服务架构中以前有公共库、framework实现的熔断、限流、降级、服务发现、调用链分布式跟踪以及立体监控等功能从服务中抽离到该 proxy 中：

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058452_20201019111035310_128802260.png)

当该 sidecar 在微服务中大量部署时，这些 sidecar 节点自然就形成了一个网格：

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058452_20201019111156820_1183192237.png)

这就是我们说的 service mesh 了。对 service mesh 有了一个感性认识后，我们看一下 Linkerd 和 Conduit 的作者 William Morgan 在What’s a service mesh? And why do I need one? 中是如何诠释什么是 Service Mesh:

> A service mesh is a dedicated infrastructure layer for handling service-to-service communication. It’s responsible for the reliable delivery of requests through the complex topology of services that comprise a modern, cloud native application. In practice, the service mesh is typically implemented as an array of lightweight network proxies that are deployed alongside application code, without the application needing to be aware.

Service Mesh 这个服务网络专注于处理服务和服务间的通讯。其主要负责构造一个稳定可靠的服务通讯的基础设施，并让整个架构更为的先进和 Cloud Native。在工程中，Service Mesh 基本来说是一组轻量级的与应用逻辑服务部署在一起的服务代理，并且对于应用服务是透明的。


### 特点

- 是一个基础设施
- 轻量级网络代理，应用程序间通讯的中间层
- 应用程序无感知，对应用程序透明无侵入
- 解耦应用程序的重试/超时、监控、追踪和服务发现等控制层面的东西

## Service Mesh 的开源实现

Service Mesh 的概念从2016年提出至今，已经发展到了第二代。

第一代 service mesh 以 `Linkerd` 和 `Envoy `为代表。

Linkerd 使用Scala编写，是业界第一个开源的service mesh方案。作者 William Morgan 是 service mesh 的布道师和践行者。Envoy 基于C++ 11编写，无论是理论上还是实际上，后者性能都比 Linkderd 更好。这两个开源实现都是以 sidecar 为核心，绝大部分关注点都是如何做好proxy，并完成一些通用控制面的功能。 但是，当你在容器中大量部署 sidecar 以后，如何管理和控制这些 sidecar 本身就是一个不小的挑战。于是，第二代 Service Mesh 应运而生。

第二代service mesh主要改进集中在更加强大的控制面功能（与之对应的 sidecar proxy 被称之为数据面），典型代表有 `Istio 和 Conduit`。

### istio

> An open platform to connect, secure, control and observe services.

翻译过来，就是”连接、安全加固、控制和观察服务的开放平台“。开放平台就是指它本身是开源的，服务对应的是微服务，也可以粗略地理解为单个应用。 中间的四个动词就是 istio 的主要功能，官方也各有一句话的说明。这里再阐释一下：

- 连接（Connect）：智能控制服务之间的调用流量，能够实现灰度升级、AB 测试和红黑部署等功能
- 安全加固（Secure）：自动为服务之间的调用提供认证、授权和加密
- 控制（Control）：应用用户定义的 policy，保证资源在消费者中公平分配
- 观察（Observe）：查看服务运行期间的各种数据，比如日志、监控和 tracing，了解服务的运行情况

Istio 是 Google 和 IBM 两位巨人联合 Lyft 的合作开源项目。是当前最主流的service mesh方案，也是事实上的第二代 service mesh 标准。

Google 和 IBM 之所以要带上小弟 Lyft 一起玩耍是因为他们不想从头开始做数据面的组件，于是在 Istio 中，直接把 Lyft 家的 Envoy 拿来做 sidecar. 除了sidecar, Istio中的控制面组件都是使用Go编写。Istio架构如下图所示：

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058452_20201019111624365_1777943793.png)

对于一个仅提供服务与服务之间连接功能的基础设施来说，Istio的架构算不上简单。但是架构中的各个组件的理念的确非常先进和超前。


- Envoy: 扮演sidecar的功能（proxy），协调服务网格中所有服务的出入站流量，并提供服务发现、负载均衡、限流熔断等能力，还可以收集大量与流量相关的性能指标。

- Pilot: 负责部署在service mesh中的Envoy实例的生命周期管理。`本质上是负责流量管理和控制`，是将流量和基础设施扩展解耦，这是Istio的核心。感性上，可以把Pilot看做是管理sidecar的sidecar, 但是这个特殊的sidacar并不承载任何业务流量。Pilot让运维人员通过Pilot指定它们希望流量遵循什么规则，而不是哪些特定的pod/VM应该接收流量。有了 Pilot 这个组件，我们可以非常容易的实现 A/B 测试和金丝雀Canary测试：
- 
![](https://gitee.com/owen2016/pic-hub/raw/master/1606058453_20201019112434414_1366813155.png)


- Mixer: Mixer在应用程序代码和基础架构后端之间提供通用中介层。它的设计将策略决策移出应用层，用运维人员能够控制的配置取而代之。应用程序代码不再将应用程序代码与特定后端集成在一起，而是与Mixer进行相当简单的集成，然后Mixer负责与后端系统连接。也就是说，Mixer可以认为是其他后端基础设施（如数据库、监控、日志、配额等）的sidecar proxy:
![](https://gitee.com/owen2016/pic-hub/raw/master/1606058453_20201019112523530_1931319292.png)

- Istio-Auth: 提供强大的服务间认证和终端用户认证，使用交互TLS，内置身份和证书管理。可以升级服务网格中的未加密流量，并为运维人员提供基于服务身份而不是网络控制来执行策略的能力。Istio的未来版本将增加细粒度的访问控制和审计，以使用各种访问控制机制（包括基于属性和角色的访问控制以及授权钩子）来控制和监视访问您的服务，API或资源的人员。


### istio VS ingress

http://software.danielwatrous.com/istio-ingress-vs-kubernetes-ingress/

###  CONDUIT

Conduit 各方面的设计理念与 Istio 非常类似。但是作者抛弃了 Linkerd, 使用Rust重新编写了sidecar, 叫做 Conduit Data Plane, 控制面则由Go编写的 Conduit Control Plane接管：

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058453_20201020090616263_796201500.png)

从Conduit的架构看，作者号称Conduit吸取了很多 Linkerd 的 Scala 的教训，比 Linkerd 更快，还轻，更简单，控制面功能更强可信度还是挺高的。与Istio比较，个人其实更喜欢Conduit的架构，一方面是它足够简单，另一方面对于要解决的问题足够聚焦。

### NginMesh

Service Mesh 最基础的功能毕竟是 sidecar proxy. 提到 proxy 怎么能够少了 nginx? nginx也推出了其 service mesh 的开源实现：nginMesh.

![](https://gitee.com/owen2016/pic-hub/raw/master/1606058453_20201020090724720_1559701443.png)

不过，与 William Morgan 的死磕策略不同，nginMesh 从一开始就没有想过要做一套完整的第二代Service Mesh 开源方案，而是直接宣布兼容Istio, 作为Istio的 sidecar proxy. 由于 nginx 在反向代理方面广泛的使用，以及运维技术的相对成熟，nginMesh在sidecar proxy领域应该会有一席之地。

## 反思

对于大规模部署微服务（微服务数>1000）、内部服务异构程度高(交互协议/开发语言类型>5)的场景，使用service mesh是合适的。但是，可能大部分开发者面临的微服务和内部架构异构复杂度是没有这么高的。在这种情况下，使用service mesh就是一个case by case的问题了。

理论上，service mesh 实现了业务逻辑和控制的解耦。但是这并不是免费的。由于网络中多了一跳，增加了性能和延迟的开销。另一方面，由于每个服务都需要sidecar, 这会给本来就复杂的分布式系统更加复杂，尤其是在实施初期，运维对service mesh本身把控能力不足的情况下，往往会使整个系统更加难以管理。

本质上，service mesh 就是一个成规模的sidecar proxy集群。那么如果我们想渐进的改善我们的微服务架构的话，其实有针对性的部署配置gateway就可以了。该gateway的粒度可粗可细，粗可到整个api总入口，细可到每个服务实例。并且 Gateway 只负责进入的请求，不像 Sidecar 还需要负责对外的请求。因为 Gateway 可以把一组服务给聚合起来，所以服务对外的请求可以交给对方服务的 Gateway。于是，我们只需要用一个只负责进入请求的 Gateway 来简化需要同时负责进出请求的 Sidecar 的复杂度
![](https://gitee.com/owen2016/pic-hub/raw/master/1606058454_20201020090958335_1899583694.png)

## 小结
service mesh不是银弹。对于大规模部署、异构复杂的微服务架构是不错的方案。对于中小规模的微服务架构，不妨尝试一下更简单可控的gateway, 在确定gateway已经无法解决当前问题后，再尝试渐进的完全service mesh化。

## 扩展

[年度盘点2017之Service Mesh：群雄逐鹿烽烟起](http://www.servicemesh.cn/?/article/27)
[微博 Service Mesh 实践](https://zhuanlan.zhihu.com/p/32430051)
[Pattern: Service Mesh](http://philcalcado.com/2017/08/03/pattern_service_mesh.html)





