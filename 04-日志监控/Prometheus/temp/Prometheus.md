# Prometheus
https://docs.foofish.cn/2019/07/02/Prometheus%E3%80%81Alertmanager%E7%AE%80%E5%8D%95%E5%91%8A%E8%AD%A6%E9%85%8D%E7%BD%AE/

https://cloud.tencent.com/developer/article/1579651

![](_v_images/20200604151238690_1191910734.png =694x)

## Docker 安装


```
docker run --name prometheus -d -p 9090:9090 \
    -v /opt/prometheus:/etc/prometheus \
    prom/prometheus:latest
```


https://www.cnblogs.com/iiiiher/p/8252623.html


https://blog.csdn.net/qq_22227087/article/details/104706507

## Prometheus 原理

### 数据采集

#### 指标类型 

1. Counter -统计类数据

Counter 类型代表一种样本数据单调递增的指标，即只增不减，除非监控系统发生了重置。
例如，你可以使用 counter 类型的指标来表示服务的请求数、已完成的任务数、错误发生的次数等

不要将 counter 类型应用于样本数据非单调递增的指标，例如：当前运行的进程数量（应该用 Guage 类型）。

2. Guage（仪表盘）-记录对象或许事物的瞬时值

Guage 类型代表一种样本数据可以任意变化的指标，即可增可减。guage 通常用于像温度或者内存使用率这种指标数据，也可以表示能随时增加或减少的“总数”，例如：当前并发请求的数量。

3. Histogram -(直方图） 度量数据中值的分布情况
> 在大多数情况下人们都倾向于使用某些量化指标的平均值，例如 CPU 的平均使用率、页面的平均响应时间。这种方式的问题很明显，以系统 API 调用的平均响应时间为例：如果大多数 API 请求都维持在 100ms 的响应时间范围内，而个别请求的响应时间需要 5s，那么就会导致某些 WEB 页面的响应时间落到中位数的情况，而这种现象被称为长尾问题。

> 为了区分是平均的慢还是长尾的慢，最简单的方式就是按照请求延迟的范围进行分组。例如，统计延迟在 0~10ms 之间的请求数有多少而 10~20ms 之间的请求数又有多少。通过这种方式可以快速分析系统慢的原因。Histogram 和 Summary 都是为了能够解决这样问题的存在，通过 Histogram 和 Summary 类型的监控指标，我们可以快速了解监控样本的分布情况。

Histogram 在一段时间范围内对数据进行采样（通常是请求持续时间或响应大小等），并将其计入可配置的存储桶（bucket）中，后续可通过指定区间筛选样本，也可以统计样本总数，最后一般将数据展示为直方图


4. Summary
与 Histogram 类型类似，用于表示一段时间内的数据采样结果（通常是请求持续时间或响应大小等），但它直接存储了分位数（通过客户端计算，然后展示出来），而不是通过区间来计算。



## Exporter

https://yunlzheng.gitbook.io/prometheus-book/part-ii-prometheus-jin-jie/exporter/what-is-prometheus-exporter

Memcached exporter 负责收集 Memcached 信息
MySQL server exporter 负责收集 Mysql Sever 信息
MongoDB exporter 负责收集 MongoDB 信息
InfluxDB exporter 负责收集 InfluxDB 信息
JMX exporter 负责收集 Java 虚拟机信息
