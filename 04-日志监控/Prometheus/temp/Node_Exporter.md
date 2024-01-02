# exporter

Prometheus基本原理是通过HTTP协议周期性抓取被监控组件的状态，这样做的好处是任意组件只要提供HTTP接口就可以接入监控系统，不需要任何SDK或者其他的集成过程。这样做非常适合虚拟化环境比如VM或者Docker 。
Prometheus应该是为数不多的适合Docker、Mesos、Kubernetes环境的监控系统之一。
输出被监控组件信息的HTTP接口被叫做exporter 。目前互联网公司常用的组件大部分都有exporter可以直接使用

## node_exporter

### 安装 Prometheus

sudo tar -zxvf prometheus-2.3.2.linux-amd64.tar.gz -C /data/prometheus/
cd /data/prometheus/prometheus-2.3.2.linux-amd64/
sudo ./prometheus --config.file=prometheus.yml --web.enable-lifecycle

nohup ./prometheus -config.file=prometheus.yml &
或
nohup /opt/prometheus-1.6.2.linux-amd64/prometheus &
nohup ./prometheus > prometheus.log 2>&1 &

解压后，在解压后的路径内执行命令./premetheus ,默认使用的是同目录下的prometheus.yml文件. 通过浏览器访问http://宿主机ip:9090 测试启动


### 安装 Node_exporter

node_exporter – 用于机器系统数据收集, 以Prometheus理解的格式导出大量指标（如磁盘I / O统计数据，CPU负载，内存使用情况，网络统计数据等）。

prometheus可以理解为一个数据库+数据抓取工具，工具从各处抓来统一的数据，放入prometheus这一个时间序列数据库中。那如何保证各处的数据格式是统一的呢？就是通过这个exporter。exporter也是用GO写的程序，它开放一个http接口，对外提供格式化的数据。所以在不同的环境下，需要编写不同的exporter。（https://github.com/prometheus这里可以找到很多exporter）

sudo tar -zxvf node_exporter-0.16.0.linux-amd64.tar.gz -C /data/prometheus/

sudo ./node_exporter &  //启动

使用vim或任何其他文本编辑器来创建一个名为node_exporter.service的单元配置文件。
sudo vim /etc/systemd/system/node_exporter.service
此文件应包含node_exporter可执行文件的路径，并指定应运行可执行文件的用户。因此，添加以下代码：
[Unit]
Description=Node Exporter
​
[Service]
User=prometheus
ExecStart=/home/prometheus/Prometheus/node_exporter/node_exporter
​
[Install]
WantedBy=default.target
保存文件并退出文本编辑器。
重新加载systemd，以便它读取您刚刚创建的配置文件。
sudo systemctl daemon-reload

此时，节点导出程序可用作可使用该systemctl命令管理的服务。启用它以便它在引导时自动启动。
sudo systemctl enable node_exporter.service
您现在可以重新启动服务器，也可以使用以下命令手动启动服务：
sudo systemctl start node_exporter.service

curl 127.0.0.1:9100
curl 127.0.0.1:9100/metric   #会返回很多数据指标

修改prometheus.yml配置文件, 因为这里node_exporter和Prometheus安装在同一台机器,使用localhost即可，node_exporter端口9100

./node_exporter运行后，可以访问http://${IP}:9100/metrics，就会展示对应的指标列表


重启prometheus，点击导航栏中的status->targets可以看到

![](_v_images/20200601152122798_1565509354.png =700x)


![](_v_images/20200601152138410_243287538.png =611x)

### 安装 grafana

Redhat & Centos(64 Bit)
wget https://dl.grafana.com/oss/release/grafana-6.2.5-1.x86_64.rpm
sudo yum localinstall grafana-6.2.5-1.x86_64.rpm

Ubuntu & Debian(64 Bit)
wget https://dl.grafana.com/oss/release/grafana_6.2.5_amd64.deb
sudo dpkg -i grafana_6.2.5_amd64.deb

启动grafana        
sudo service grafana-server start
访问grafana  http://<服务器IP>:3000
默认用户名和密码： admin/admin
   



 
获取dashboard模板
下载地址:https://grafana.com/dashboards/1860
 注:https://grafana.com/dashboards还有很多的dashboard可以下载

可以直接写入1860，也可以再官网上下载json文件load上去
这样node_exporter获取的数据就能展示出来了



node_exporter的常用配置项详解

在Prometheus架构中，exporter是负责收集数据并将信息汇报给Prometheus Server的组件。官方提供了node_exporter内置了对主机系统的基础监控。
 通常，我们使用./node_exporter来启动node_exporter。但是node_exporter其实存在很多内置参数，下面是常用的参数详解。
一、node_exporte基本信息配置
--web.listen-address=":9100"  
#node_exporter监听的端口，默认是9100，若需要修改则通过此参数。

--web.telemetry-path="/metrics"  
#获取metric信息的url，默认是/metrics，若需要修改则通过此参数

--log.level="info" 
#设置日志级别

--log.format="logger:stderr"  
#设置打印日志的格式，若有自动化日志提取工具可以使用这个参数规范日志打印的格式
二、通过正则表达式来屏蔽或选择某些监控项
--collector.diskstats.ignored-devices="^(ram|loop|fd|(h|s|v|xv)d[a-z]|nvme\\d+n\\d+p)\\d+$"
#通过正则表达式忽略某些磁盘的信息收集

--collector.filesystem.ignored-mount-points="^/(dev|proc|sys|var/lib/docker/.+)($|/)"  
#通过正则表达式忽略某些文件系统挂载点的信息收集

--collector.filesystem.ignored-fs-types="^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$"  
#通过正则表达式忽略某些文件系统类型的信息收集

--collector.netclass.ignored-devices="^$"  
#通过正则表达式忽略某些网络类的信息收集

--collector.netdev.ignored-devices="^$"  
#通过正则表达式忽略某些网络设备的信息收集

  --collector.netstat.fields="^$"
 #通过正则表达式配置需要获取的网络状态信息
 
--collector.vmstat.fields="^(oom_kill|pgpg|pswp|pg.*fault).*" 
#通过正则表达式配置vmstat返回信息中需要收集的选项
我们在使用node_exporter的过程中，可以通过使用这些参数来定制自己需要的个性化监控。


## Blackbox_Exporter 

**白盒监控 **：是指我们日常监控主机的资源用量、容器的运行状态、数据库中间件的运行数据。 这些都是支持业务和服务的基础设施，通过白盒能够了解其内部的实际运行状态，通过对监控指标的观察能够预判可能出现的问题，从而对潜在的不确定因素进行优化。

**墨盒监控** ：即以用户的身份测试服务的外部可见性，常见的黑盒监控包括 HTTP探针 、 TCP探针 、 Dns 、 Icmp 等用于检测站点、服务的可访问性、服务的连通性，以及访问效率等。

两者比较 ：黑盒监控相较于白盒监控最大的不同在于黑盒监控是以故障为导向当故障发生时，黑盒监控能快速发现故障，而白盒监控则侧重于主动发现或者预测潜在的问题。一个完善的监控目标是要能够从白盒的角度发现潜在问题，能够在黑盒的角度快速发现已经发生的问题

Blackbox Exporter是Prometheus社区提供的官方黑盒监控解决方案，其允许用户通过：HTTP、HTTPS、DNS、TCP以及ICMP的方式对网络进行探测

- HTTP 测试
  定义 Request Header 信息
  判断 Http status / Http Respones Header / Http Body 内容
- TCP 测试
  业务组件端口状态监听
  应用层协议定义与监听
- ICMP 测试
  主机探活机制
- POST 测试
  接口联通性
- SSL 证书过期时间

### 安装Blackbox_Exporter

```
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.16.0/blackbox_exporter-0.16.0.linux-amd64.tar.gz

tar -zxvf blackbox_exporter-0.16.0.linux-amd64.tar.gz -C /opt/

编辑启动脚本
vim start.sh
nohup ./blackbox_exporter --config.file=./blackbox.yml &

启动 
./start.sh  #默认监听端口为9115

```

#### 创建systemd服务
```
$ vim /lib/systemd/system/blackbox_exporter.service

[Unit]
Description=blackbox_exporter
After=network.target

[Service]
User=root
Type=simple
ExecStart=/usr/local/blackbox_exporter/blackbox_exporter --config.file=/usr/local/blackbox_exporter/blackbox.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### 监控配置
通过 blackbox.yml 定义模块详细信息
在 Prometheus 配置文件中引用该模块以及配置被监控目标主机

#### blackbox.yml 

```
modules:
  http_2xx:
    prober: http
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  pop3s_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^+OK"
      tls: true
      tls_config:
        insecure_skip_verify: false
  ssh_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
  irc_banner:
    prober: tcp
    tcp:
      query_response:
      - send: "NICK prober"
      - send: "USER prober prober prober :prober"
      - expect: "PING :([^ ]+)"
        send: "PONG ${1}"
      - expect: "^:[^ ]+ 001"
  icmp:
    prober: icmp

```

http://192.168.4.240:9115/probe?module=http_2xx&target=baidu.com

![](https://gitee.com/owen2016/pic-hub/raw/master/1603327961_20200602101429694_225665304.png)


https://www.iamle.com/archives/2130.html


### Grafana配置

此模板需要安装饼状图插件 ，重启grafana生效
```
$ grafana-cli plugins install grafana-piechart-panel
$ service grafana-server restart
```



