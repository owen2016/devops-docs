# Logstash 高级

[TOC]

## logstash6.x 架构

![architecuture](./images/logstash-architecuture.png)

箭头代表数据流向。可以有多个input。中间的queue负责将数据分发到不通的pipline中，每个pipline由batcher，filter和output构成。batcher的作用是批量从queue中取数据（可配置）。

## logstash数据流

首先有一个输入数据，例如是一个web.log文件，其中每一行都是一条数据。file input会从文件中取出数据，然后通过`json codec`将数据转换成`logstash event`。

这条event会通过`queue`流入某一条pipline处理线程中，首先会存放在batcher中。当batcher达到处理数据的条件（如一定时间或event一定规模）后，batcher会把数据发送到filter中，filter对event数据进行处理后转到output，output就把数据输出到指定的输出位置。

![codecs](images/codecs.png)

输出后还会返回ACK给queue，包含已经处理的event，queue会将已处理的event进行标记

## queue分类

- In Memory
  在内存中，固定大小，无法处理进程crash、机器宕机等情况，会导致数据丢失。

- Persistent Queue In Disk
  可处理进程crash情况，保证数据不丢失。保证数据至少消费一次；充当缓冲区，可代替kafka等消息队列作用。

### Persistent Queue（PQ）处理流程

1、一条数据经由input进入PQ，PQ将数据备份在disk，然后PQ响应input表示已收到数据；
2、数据从PQ到达filter/output，其处理到事件后返回ACK到PQ；
3、PQ收到ACK后删除磁盘的备份数据；

### 性能对比

PQ性能要低于内存中的queue的，但是差别不是很大。如果不是特殊需求建议打开PQ

![](images/logstash-queue.png)

### PQ配置

`queue.type: persisted` 默认是memory，表示使用内存队列

`queue.max_bytes: 4gb` 队列存储的最大数据量，默认1gb，这个值大一点队列可以存储多一点数据

## 线程

在对logstash进行调优的时候主要是调整线程数，主要是pipeline的线程数，它是主要处理数据的线程

![](images/logstash-thread.png)

### pipeline线程相关配置

`pipeline.workers: 2` pipeline线程数，即filter_output的处理线程数，默认为CPU核数。命令行参数为-w

`pipeline.batch.size: 125` batcher一次批量获取的待处理文档数，默认125，越大会占据越多的heap空间，可通过jvm.options调整。命令行参数-b

`pipeline.batch.delay: 5`  batcher等待时长，默认5ms。命令行参数 -u