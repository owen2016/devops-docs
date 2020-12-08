# Kubernetes 配置文件

## kubeadm 配置

kubeadm是一个构建k8s集群的工具。它提供的kubeadm init和kubeadm join两个命令是快速构建k8s集群的最佳实践。 其次，kubeadm工具只为构建最小可用集群，它只关心集群中最基础的组件，至于其他的插件（比如dashboard、CNI等）则不会涉及

### /etc/kubernetes/


``` shell
user@k8s-master:~$ tree /etc/kubernetes/
/etc/kubernetes/
├── admin.conf
├── controller-manager.conf
├── kubelet.conf
├── manifests
│   ├── etcd.yaml
│   ├── kube-apiserver.yaml
│   ├── kube-controller-manager.yaml
│   └── kube-scheduler.yaml
├── pki
│   ├── apiserver.crt
│   ├── apiserver-etcd-client.crt
│   ├── apiserver-etcd-client.key
│   ├── apiserver.key
│   ├── apiserver-kubelet-client.crt
│   ├── apiserver-kubelet-client.key
│   ├── ca.crt
│   ├── ca.key
│   ├── etcd
│   │   ├── ca.crt
│   │   ├── ca.key
│   │   ├── healthcheck-client.crt
│   │   ├── healthcheck-client.key
│   │   ├── peer.crt
│   │   ├── peer.key
│   │   ├── server.crt
│   │   └── server.key
│   ├── front-proxy-ca.crt
│   ├── front-proxy-ca.key
│   ├── front-proxy-client.crt
│   ├── front-proxy-client.key
│   ├── sa.key
│   └── sa.pub
└── scheduler.conf

3 directories, 30 files
```



## kubelet 服务配置

如果要修改kubelet的参数，需要修改kubelet对应的系统服务文件，位置一般在  `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`

``` shelll
user@k8s-master:~$ sudo cat  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[sudo] password for user:
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
Environment="KUBELET_EXTRA_ARGS="
```

![](https://gitee.com/owen2016/pic-hub/raw/master/1607441397_20201014173247473_1383821662.png)


### /var/lib/kubelet/

```
user@k8s-master:~$ ls /var/lib/kubelet/
user@k8s-master:~$ tree /var/lib/kubelet/
/var/lib/kubelet/
├── config.yaml
├── cpu_manager_state
├── device-plugins
│   ├── DEPRECATION
│   ├── kubelet_internal_checkpoint
│   └── kubelet.sock
├── kubeadm-flags.env
├── pki
│   ├── kubelet-client-2020-04-30-10-59-03.pem
│   ├── kubelet-client-current.pem -> /var/lib/kubelet/pki/kubelet-client-2020-04-30-10-59-03.pem
│   ├── kubelet.crt
│   └── kubelet.key
├── plugins [error opening dir]
├── plugins_registry [error opening dir]
├── pod-resources [error opening dir]
└── pods [error opening dir]

6 directories, 10 files

```

```
user@k8s-master:~$ cat /var/lib/kubelet/config.yaml
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    cacheTTL: 0s
    enabled: true
  x509:
    clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
  mode: Webhook
  webhook:
    cacheAuthorizedTTL: 0s
    cacheUnauthorizedTTL: 0s
clusterDNS:
- 10.96.0.10
clusterDomain: cluster.local
cpuManagerReconcilePeriod: 0s
evictionPressureTransitionPeriod: 0s
fileCheckFrequency: 0s
healthzBindAddress: 127.0.0.1
healthzPort: 10248
httpCheckFrequency: 0s
imageMinimumGCAge: 0s
kind: KubeletConfiguration
nodeStatusReportFrequency: 0s
nodeStatusUpdateFrequency: 0s
rotateCertificates: true
runtimeRequestTimeout: 0s
staticPodPath: /etc/kubernetes/manifests
streamingConnectionIdleTimeout: 0s
syncFrequency: 0s
volumeStatsAggPeriod: 0s
```