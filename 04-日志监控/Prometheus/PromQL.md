# PromQL

[TOC]

- https://prometheus.io/docs/prometheus/latest/querying/basics/
- https://itwithauto.com/post/prometheus-search/

PromeQL是prometheus内置的数据查询语言，其提供对时间序列数据丰富的查询，聚合以及逻辑运算能力的支持。并且被广泛应用在prometheus的日常应用当中，包括数据查询，可视化，告警处理当中，grafana绘图就是利用了prometheus里面的PromQL的功能

## 时序选择器
### 瞬时向量选择器

prometheus通过exporter采集到相对应的监控指标样本数据后，我们就可以通过promQL对监控样本数据进行查询，
当我们直接使用监控指标名称查询是，可以查询该指标下面的所有时间序列，例如

```
prometheus_http_requests_total  #等同于prometheus_http_requests_total{}
#得到的就是countr类型
```
![](https://gitee.com/owen2016/pic-hub/raw/master/1607270187_20200603133653358_2063347953.png)

PromQL还支持用户根据时间序列的标签匹配模式来对时间序列进行过滤，目前主要支持两种匹配模式：完全匹配和正则匹配。

#### 完全匹配
PromeQL支持使用=和!=两种完全匹配模式
我们先过滤出请求头为/alerts的次数：

```
prometheus_http_requests_total{handler="/alerts"}

返回结果
prometheus_http_requests_total{code="200",handler="/alerts",instance="192.168.4.240:9090",job="node_monitor"}

然后在过滤请求头不包含/status和/api的
prometheus_http_requests_total{handler!="/status",handle!="/api"}

```
#### 正则匹配

PromQL还可以支持使用正则表达式作为匹配条件，多个表达式之间使用｜ 进行分离：

使用**label=~regx** 表示选择那些标签符合正则表达式定义的时间序列；反之使用label!~regx进行排除

**注意**
当我们使用正则表达式的时候，表达式里面必须指定一个能被完全匹配的值，和一个正则表达式；

```
prometheus_http_requests_total{handler=~"/api/v1/.*"} #不合法
prometheus_http_requests_total{handler=~"/api/v1/.*",job="prometheus"} # 合法
```

##  区间向量选择器
直接通过类似于PromQL表达式prometheus_http_requests_total查询时间序列时，返回值中只会包含该时间序列中的最新的一个样本值，这样的返回结果我们称之为瞬时向量，而相应的这样的表达式称之为瞬时向量表达式。

而我们如果想得到**过去一段时间范围内的样本数据**时，我们则需要使用区间向量表达式，区间向量表达式和瞬时向量表达式之间的差异在于区间向量表达式中我们需要定义时间选择的范围，是假范围通过时间范围选择器[] 来定义。

`prometheus_http_requests_total{code="200"}[5m]`
该表达式将会返回查询到的时间序列中最近5分钟的所有样本数据

通过区间向量表达式查询到的结果我们成为区间向量
支持的单位：s 秒/m 分钟/h 小时/d 天/w 周/y 年

### 时间位移操作
在瞬间向量表达式或者区间向量表达式中，都是以当前时间为基准的：

```
prometheus_http_requests_total{} #瞬间向量表达式，选择当前最新的数据
prometheus_http_requests_total{}[5m] #区间向量表达式，选择以当前时间为基准，5分钟内的数据
```
而如果我们想查询，5分钟前的瞬时样本数据，或昨天一天的区间内的样本数据呢? 这个时候我们就可以使用位移操作，位移操作的关键字为offset。

可以使用offset时间位移操作：

```
prometheus_http_requests_total{} offset 5m
prometheus_http_requests_total{}[1d] offset 1d
```

## PromQL函数

### sum求和函数
一般来说，如果描述样本特征的标签(label)在并非唯一的情况下，通过PromQL查询数据，会返回多条满足这些特征维度的时间序列。而PromQL提供的聚合操作可以用来对这些时间序列进行处理，形成一条新的时间序列：

`sum(prometheus_http_requests_total{code=~"400|200",instance="192.168.1.56:9090"}) by (code)`

### min 求最小值·
` min(sum(prometheus_http_requests_total{instance="192.168.1.56:9090"}) by(code))`

### max 求最大值
` max(sum(prometheus_http_requests_total{instance="192.168.1.56:9090"}) by(code))`

### avg 求平均值
`avg(sum(prometheus_http_requests_total{instance="192.168.1.56:9090"}) by(code))`

### count 记数
`count(sum(prometheus_http_requests_total{instance="192.168.1.56:9090"}) by(code))`

### increase(v range-vector)增长率
其中参数v 是一个区间向量，increase函数获取区间向量中的第一个和最后一个样本并返回其增长量。

` increase(node_cpu_seconds_total{cpu="0"}[2m])/120`

这个通过node_cpu_seconds_total获取时间序列cpu总使用时间内进两分钟的所有样本，increase计算出近两分钟的增长量，最后除以时间120s 得到node_cpu_seconds_total的平均增长率。

### rate 求平均增长率
rate函数可以直接计算区间向量v在时间窗口内平均增长速率。因此，通过以下表达式可以得到与increase函数相同的结

` rate(node_cpu_seconds_total{cpu="0"}[2m])`

需要注意的是使用rate或者increase函数去计算样本的平均增长速率，容易陷入“长尾问题”当中，其无法反应在时间窗口内样本数据的突发变化。 例如，对于主机而言在2分钟的时间窗口内，可能在某一个由于访问量或者其它问题导致CPU占用100%的情况，但是通过计算在时间窗口内的平均增长率却无法反应出该问题。

### irate 求平均值
为了解决上述问题，PromQL提供了另外一个灵敏度更高的函数irate(v range-vector)。irate同样用于计算区间向量的计算率，但是其反应出的是瞬时增长率。irate函数是通过区间向量中最后两个两本数据来计算区间向量的增长速率。这种方式可以避免在时间窗口范围内的“长尾问题”，并且体现出更好的灵敏度，通过irate函数绘制的图标能够更好的反应样本数据的瞬时变化状态。

irate函数相比于rate函数提供了更高的灵敏度，不过当需要分析长期趋势或者在告警规则中，irate的这种灵敏度反而容易造成干扰。因此在长期趋势分析或者告警中更推荐使用rate函数。

## PromQL 操作符
### 基本运算符
 加/ 减/ 乘/ 除/% 求余/^ 幂运算

### 布尔运算符
- == (相等)
- != (不相等)
- > (大于)
- < (小于)
- >= (大于等于)
- <= (小于等于)

### 集合运算符
- and (并且)
- or (或者)
- unless (排除)

### 操作符优先级
PromQL操作运算符优先级从高到低

- ^
- *, /, %
- +, -
- ==, !=, <=, <, >=, >
- and, unless
- or


## Node Exporter 常用查询

CPU 使用率

`100 - (avg by (instance) (irate(node_cpu{instance="xxx", mode="idle"}[5m])) * 100)`

CPU 各 mode 占比率
`avg by (instance, mode) (irate(node_cpu{instance="xxx"}[5m])) * 100`

机器平均负载
```
node_load1{instance="xxx"} // 1分钟负载
node_load5{instance="xxx"} // 5分钟负载
node_load15{instance="xxx"} // 15分钟负载
```

内存使用率

`100 - ((node_memory_MemFree{instance="xxx"}+node_memory_Cached{instance="xxx"}+node_memory_Buffers{instance="xxx"})/node_memory_MemTotal) * 100`

磁盘使用率

`100 - node_filesystem_free{instance="xxx",fstype!~"rootfs|selinuxfs|autofs|rpc_pipefs|tmpfs|udev|none|devpts|sysfs|debugfs|fuse.*"} / node_filesystem_size{instance="xxx",fstype!~"rootfs|selinuxfs|autofs|rpc_pipefs|tmpfs|udev|none|devpts|sysfs|debugfs|fuse.*"} * 100
或者你也可以直接使用 {fstype="xxx"} 来指定想查看的磁盘信息`

网络 IO
```
// 上行带宽
sum by (instance) (irate(node_network_receive_bytes{instance="xxx",device!~"bond.*?|lo"}[5m])/128)

// 下行带宽
sum by (instance) (irate(node_network_transmit_bytes{instance="xxx",device!~"bond.*?|lo"}[5m])/128)
网卡出/入包
// 入包量
sum by (instance) (rate(node_network_receive_bytes{instance="xxx",device!="lo"}[5m]))

// 出包量
sum by (instance) (rate(node_network_transmit_bytes{instance="xxx",device!="lo"}[5m]))
```