vnote_backup_file_826537664 /home/user/Documents/vnote_notebooks/DevOps-Book/3.容器编排/K8S/k8s-服务发现.md
# 服务访问

问题：外部客户端如何访问集群内服务或者说集群如何向外部公开某些服务呢？

1）将服务的类型设置为NodePort：每个集群接节点都会在节点上打开一个端口，对于NodePort服务，每个集群节点在节点本身打开一个端口，这也是为何叫NodePort的原因所在，把将在该端口上接收到的流量重定向到基础服务。

2）将服务的类型设置为LoadBalance：这是NodePort的一种扩展，服务可以通过一个专用的负载均衡器来访问。负载均衡器将流量重定向到跨所有节点的节点端口，客户端通过负载均衡器的ip连接到服务。

3）创建一个Ingress资源：通过一个ip地址公开多个服务，运行在HTTP层（网络协议的第7层），提供的功能比第4层多。



## NodePort

NodePort模式除了使用cluster ip外，也将service的port映射到每个node的一个指定内部port上，映射的每个node的内部port都一样。

为每个节点暴露一个端口，通过nodeip + nodeport可以访问这个服务，同时服务依然会有cluster类型的ip+port。内部通过clusterip方式访问，外部通过nodeport方式访问。

## loadbalance

LoadBalancer在NodePort基础上，K8S可以请求底层云平台创建一个负载均衡器，将每个Node作为后端，进行服务分发。该模式需要底层云平台（例如GCE）支持。

## Ingress

Ingress，是一种HTTP方式的路由转发机制，由Ingress Controller和HTTP代理服务器组合而成。Ingress Controller实时监控Kubernetes API，实时更新HTTP代理服务器的转发规则。HTTP代理服务器有GCE Load-Balancer、HaProxy、Nginx等开源方案。

详细说明请见http://blog.csdn.net/liyingke112/article/details/77066814


https://blog.csdn.net/bbwangj/article/details/82940419

<https://github.com/fungitive/kubernetes/tree/master/ingress-nginx>

```
for file in configmap.yaml default-backend.yaml namespace.yaml rbac.yaml tcp-services-configmap.yaml udp-services-configmap.yaml with-rbac.yaml service-nodeport.yaml；do
    wget https://raw.githubusercontent.com/fungitive/kubernetes/master/ingress-nginx/$file
done


https://www.cnblogs.com/wangrq/p/Kubernetes_minikube_docker.html


<https://stackoverflow.com/questions/50966300/whats-the-difference-between-exposing-nginx-as-load-balancer-vs-ingress-control>

There is a difference between ingress rule (ingress) and ingress controller. So, technically, nginx ingress controller and LoadBalancer type service are not comparable. You can compare ingress resource and LoadBalancer type service, which is below.

Generally speaking:

LoadBalancer type service is a L4(TCP) load balancer. You would use it to expose single app or service to outside world. It would balance the load based on destination IP address and port.

Ingress type resource would create a L7(HTTP/S) load balancer. You would use this to expose several services at the same time, as L7 LB is application aware, so it can determine where to send traffic depending on the application state.

ingress and ingress controller relation:

Ingress, or ingress rules are the rules that ingress controller follows to distribute the load. Ingress controller get the packet, checks ingress rules and determines to which service to deliver the packet.

Nginx Ingress Controller

Nginx ingress controller uses LoadBalancer type service actually as entrypoint to the cluster. Then is checks ingress rules and distributes the load. This can be very confusing. You create an ingress resource, it creates the HTTP/S load balancer. It also gives you an external IP address (on GKE, for example), but when you try hitting that IP address, the connection is refused.

Conclusions:

You would use Loadbalancer type service if you would have a single app, say myapp.com that you want to be mapped to an IP address.

You would use ingress resource if you would have several apps, say myapp1.com, myapp1.com/mypath, myapp2.com, .., myappn.com to be mapped to one IP address.

As the ingress is L7 it is able to distinguish between myapp1.com and myapp1.com/mypath, it is able to route the traffic to the right service.

## port、targetPort、nodePort和containerPort 

- https://blog.csdn.net/xili2532/article/details/104900990?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param

- https://blog.csdn.net/yjk13703623757/article/details/79819415

- https://www.cnblogs.com/veeupup/p/13545361.html

### port
- port是k8s集群内部访问service的端口( service暴露在cluster ip上的端口)，即通过clusterIP: port可以访问到某个service

### nodePort
- nodePort是外部访问k8s集群中service的端口，通过nodeIP: nodePort可以从外部访问到某个service。

该端口号的范围是 kube-apiserver 的启动参数 –service-node-port-range指定的，在当前测试环境中其值是 30000-50000。表示只允许分配30000-50000之间的端口。

### argetPort
- targetPort是pod的端口，从port和nodePort来的流量经过kube-proxy流入到后端pod的targetPort上，最后进入容器。

### containerPort
- containerPort是pod内部容器的端口，targetPort映射到containerPort。

总结
- 总的来说，port和nodePort都是service的端口，前者暴露给集群内客户访问服务，后者暴露给集群外客户访问服务。从这两个端口到来的数据都需要经过反向代理kube-proxy流入后端 pod的targetPod，从而到达pod上的容器内。

![](_v_images/20201012111819245_1120174150.png)