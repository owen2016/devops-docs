# Fluentd 示例

## 示例1- 监听Apache访问日志

Apache日志文件：/var/log/httpd/access_log
日志文件格式：combined

事件信息收集设定

1. 首先需要配置从哪里收集信息

``` xml
# gather apache access log
<source>
  type tail  ← 指定in_tail插件
  path /var/log/httpd/access_log  ← 指定日志文件路径
  tag apache.access  ← 指定标签，该标签用于 match 条件
  pos_file /var/log/td-agent/httpd-access_log.pos  ← 保存Apache log文件读取位置信息
  format apache2  ← 指定解析的日志文件格式
</source>
```

推荐配置「pos_file」参数，虽然不是必须配置的参数，是记录被监视文件读取位置(如第10行为止已读取)的重要文件。

2. 使用 out_file 插件进行日志文件的保存。

``` xml
<match apache.access>  ← 指定标签
  type file  ← 指定out_file插件
  path /var/log/td-agent/httpd/access.log  ← 指定输出文件
  time_slice_format %Y%m%d  ← 文件添加日期信息
  time_slice_wait 10m  ← 文件添加日期信息
  compress gzip  ← gzip压缩输出文件
</match>
```

out_file插件不仅是输出信息至文件，还可以根据 time_slice_format 参数值进行输出文件的切换，例如参数值为 %Y%m%d 时，输出文件名根据日期后缀变为 .＜年＞＜月＞＜日＞

需注意的是在fluentd，事件发生时间和fluentd接收事件信息时间有时会发生时差，因此会出现输出文件日期和实际内容不相符的情况。例如23:55发生的事件信息的接收事件是0:01，这时用日期切换输出文件可能会导致该事件信息的丢失。

这时可指定 time_slice_wait 参数，该参数是out_file插件根据日期分割输出文件之后，等待多长时间之后向新文件输出信息，在这里10m是10分钟

## 示例2- 监听Nginx访问日志

``` xml
<source>
  @type tail
  @id nginx-access
  @label @nginx
  path /var/log/nginx/access.log
  pos_file /var/lib/fluentd/nginx-access.log.posg
  tag nginx.access
  format /^(?<remote>[^ ]*) (?<host>[^ ]*) \[(?<time>[^\]]*)\] (?<code>[^ ]*) "(?<method>\S+)(?: +(?<path>[^\"]*) +\S*)?" (?<size>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)")?$/
  time_format %d/%b/%Y:%H:%M:%S %z
</source>

<source>
  @type tail
  @id nginx-error
  @label @nginx
  path /var/log/nginx/error.log
  pos_file /var/lib/fluentd/nginx-error.log.posg
  tag nginx.error

  format /^(?<time>\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}) \[(?<log_level>\w+)\] (?<pid>\d+).(?<tid>\d+): (?<message>.*)$/
</source>

<label @nginx>
  <match nginx.access>
    @type mongo
    database nginx
    collection access
    host 10.47.12.119
    port 27016

    time_key time
    flush_interval 10s
  </match>
  <match nginx.error>
    @type mongo
    database nginx
    collection error
    host 10.47.12.119
    port 27016

    time_key time
    flush_interval 10s
  </match>
</label>

```

为了匹配，你也需要修改 Nginx 的 log_format 为：

` log_format main '$remote_addr $host [$time_local] $status "$request" $body_bytes_sent "$http_referer" "$http_user_agent"'; `

## 使用Fluentd管理docker容器日志

配置docker转储日志有两种方法，`指定特定的容器`或者`配置docker daemon将所有容器日志均存储到Fluentd中`。

docker中快速启动Fluentd服务，使用命令

`docker run -d -p 24224:24224 -p 24224:24224/udp -v /data:/fluentd/log fluent/fluentd`

此时会在宿主机/data目录下生成data.<fluentd容器id>.log,所有收集到的日志文件将存储至此。

方法1:启动容器时时指定日志输出方式

`docker run -d --log-driver fluentd --log-opt fluentd-address=localhost:24224 --log-opt tag="nginx-test" --log-opt fluentd-async-connect --name nginx-test -p 8080:80 nginx`

–log-driver: 配置log驱动
–log-opt: 配置log相关的参数
fluentd-address: fluentd服务地址
fluentd-async-connect：fluentd-docker异步设置,避免fluentd挂掉之后导致Docker容器也挂了

配置好之后访问nginx页面，每次刷新会出现如下日志

``` shell
2018-11-02T10:21:55+00:00 nginx-test {
"container_name": "/nginx-test",
"source": "stdout",
"log": "172.96.247.193 - - [03/May/2018:07:21:55 +0000] \"GET / HTTP/1.1\" 304 0 \"-\" \"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36\" \"-\"",
"container_id": "0dafdsdfasweraewrfdasfdsafqwerqwerqwrqwerqwerqwfdafhgggg"
}
```

方法2: 设置全局log-driver

`docker daemon --log-driver=fluentd`

或者

``` shell
cat /etc/docker/daemon.json 
{
"registry-mirrors": ["https://zcg96r7h.mirror.aliyuncs.com"],
"log-driver": "fluentd",
    "log-opts": {
    "fluentd-address": "127.0.0.1:24224"
   }
}
```

注意:
a、使用了fluentd之后，将无法使用docker logs 查看；
b、在配置fluentd之前创建的容器日志不会写入到Fluentd，如果想要存储进去需要重建容器；
c、全局配置fluentd之后，如果fluentd服务异常，将无法启动容器

## 更多配置案例

- <https://docs.fluentd.org/how-to-guides>

``` xml
<source>
  @type tcp
  tag tcp.events # required
  <parse>
    @type regexp
    expression /^(?<field1>\d+):(?<field2>\w+)$/
  </parse>
  port 5170   # optional. 5170 by default
  bind 0.0.0.0 # optional. 0.0.0.0 by default
  delimiter \n # optional. \n (newline) by default
</source>

## built-in TCP input
## @see http://docs.fluentd.org/articles/in_forward
<source>
  @type forward
  @id input_forward
  <security>
    self_hostname input.local
    shared_key liang_handsome
  </security>
</source>

<filter example.*.*>
  @type grep
  regexp1 levelStr (INFO|WARN|ERROR)
</filter>

# Match events tagged with "myapp.access" and
# store them to /var/log/fluent/access.%Y-%m-%d
# Of course, you can control how you partition your data
# with the time_slice_format option.
<match example.*.*>
  @type file
  path E:\software\fluentd\td-agent\log\output_file
</match>

```

