# Logstash

[Logstash](https://www.elastic.co/cn/logstash)是免费且开放的服务器端数据处理管道，能够从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的“存储库”中。

Logstash能够动态地**采集、转换和传输数据**，不受格式或复杂度的影响。利用Grok从非结构化数据中派生出结构，从IP地址解码出地理坐标，匿名化或排除敏感字段，并简化整体处理过程。

![logstash-2](./images/logstash-2.png)

## 运行机制

Logstash使用**管道方式**进行日志的搜集处理和输出。有点类似Linux的管道命令 xxx | ccc | ddd，xxx执行完了会执行ccc，然后执行ddd

包括了三个阶段: 输入input --> 处理filter（不是必须的） --> 输出output

![logstash-1](./images/logstash-1.png)

每个阶段都由很多的插件配合工作，比如file、elasticsearch、redis等等。

每个阶段也可以指定多种方式，比如既可以输出到elasticsearch中，也可以指定到stdout在控制台打印。

![logstash-pipeline](./images/logstash-pipeline.png)

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

## APT部署Logstash

``` shell
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install logstash
```

## 运行时参数

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

## 从命令行运行Logstash

- <https://segmentfault.com/a/1190000016602985>