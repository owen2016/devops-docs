# Logstash

[TOC]

[Logstash](https://www.elastic.co/cn/logstash)是免费且开放的服务器端数据处理管道，能够从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的“存储库”中。

Logstash能够动态地**采集、转换和传输数据**，不受格式或复杂度的影响。利用Grok从非结构化数据中派生出结构，从IP地址解码出地理坐标，匿名化或排除敏感字段，并简化整体处理过程。

![logstash-2](./images/logstash-2.png)

## 工作原理

### 处理过程

Logstash使用**管道方式**进行日志的搜集处理和输出。有点类似Linux的管道命令 xxx | ccc | ddd，xxx执行完了会执行ccc，然后执行ddd

![logstash-1](./images/logstash-1.png)

如上图，Logstash的数据处理过程主要包括：Inputs, Filters, Outputs 三部分， 另外在Inputs和Outputs中可以使用Codecs对数据格式进行处理。这四个部分均以插件形式存在，用户通过定义pipeline配置文件，设置需要使用的input，filter，output, codec插件，以实现特定的数据采集，数据处理，数据输出等功能  

1. Inputs：用于从数据源获取数据，常见的插件如file, syslog, redis, beats 等
2. Filters：用于处理数据如格式转换，数据派生等，常见的插件如grok, mutate, drop,  clone, geoip等  
    ![logstash-pipeline](./images/logstash-pipeline.png)
3. Outputs：用于数据输出，常见的插件如elastcisearch，file, graphite, statsd等
4. Codecs：Codecs不是一个单独的流程，而是在输入和输出等插件中用于数据转换的模块，用于对数据进行编码处理，常见的插件如json，multiline

### 执行模型

1. 每个Input启动一个线程，从对应数据源获取数据  
2. Input会将数据写入一个队列：默认为内存中的有界队列（意外停止会导致数据丢失）。为了防止数丢失Logstash提供了两个特性:
    - Persistent Queues：通过磁盘上的queue来防止数据丢失
    - Dead Letter Queues：保存无法处理的event（仅支持Elasticsearch作为输出源）
3. Logstash会有多个pipeline worker, 每一个pipeline worker会从队列中取一批数据，然后执行filter和output（worker数目及每次处理的数据量均由配置确定）

## 安装

- <https://www.elastic.co/guide/en/logstash/current/index.html>

### Docker部署

```shell
    docker run -d -it --restart=always \
    --privileged=true \
    --name=logstash -p 5040:5040 -p 9600:9600  \
    -v /data/logstash/pipeline/:/usr/share/logstash/pipeline/  \
    logstash:6.8.0
```

```shell
    docker run -d -it --restart=always \
    --privileged=true \
    --name=logstash -p 4560-4570:4560-4570  -p 9600:9600  \
    --link elasticsearch \
    --net efk_default \
    -v /data/logstash/pipeline/:/usr/share/logstash/pipeline/  \
    logstash:6.8.0
```

### Apt部署Logstash

``` shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install logstash
```

## logstash 相关配置

## jvm.options

这个配置文件是有关jvm的配置，可以配置运行时内存的最大最小值，垃圾清理机制等

`-Xms256m   #设置内存大小`

### pipeline配置文件

定义数据处理流程的文件，一般是用户自定义，以.conf结尾。

``` yaml
user@owen-ubuntu:/etc/logstash$ cat pipelines.yml
# This file is where you define your pipelines. You can define multiple.
# For more information on multiple pipelines, see the documentation:
#   https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html

- pipeline.id: main
  path.config: "/etc/logstash/conf.d/*.conf"

```

### logstash.yml

`/etc/logstash/logstash.yml`：主要用于控制logstash运行时的状态

参数|用途|默认值
:--|:--|:--
参数|用途|默认值
node.name|节点名称|主机名称
path.data|/数据存储路径 |LOGSTASH_HOME/data/
pipeline.workers|输出通道的工作workers数据量（提升输出效率）|cpu核数
pipeline.output.workers|每个输出插件的工作wokers数量|1
pipeline.batch.size|每次input数量|125
path.config|过滤配置文件目录|
config.reload.automatic|自动重新加载被修改配置|false or true
config.reload.interval|配置文件检查时间|
path.logs|日志输出路径|
http.host|绑定主机地址，用户指标收集|“127.0.0.1”
http.port|绑定端口|5000-9700
log.level|日志输出级别,如果config.debug开启，这里一定要是debug日志|info
log.format|日志格式 |*plain*
path.plugins|自定义插件目录|

### startup.options

`/etc/logstash/startup.options`：logstash 运行相关参数

参数|用途
:--|:--|:--
JAVACMD=/usr/bin/java | 本地jdk
LS_HOME=/opt/logstash |logstash所在目录
LS_SETTINGS_DIR="${LS_HOME}/config" |默认logstash配置文件目录
LS_OPTS="–path.settings ${LS_SETTINGS_DIR}" | logstash启动命令参数 指定配置文件目录
LS_JAVA_OPTS="" | 指定jdk目录
LS_PIDFILE=/var/run/logstash.pid |logstash.pid所在目录
LS_USER=logstash |logstash启动用户
LS_GROUP=logstash | logstash启动组
LS_GC_LOG_FILE=/var/log/logstash/gc.log | logstash jvm gc日志路径
LS_OPEN_FILES=65534 | logstash最多打开监控文件数量

### 命令行运行Logstash

<https://segmentfault.com/a/1190000016602985>