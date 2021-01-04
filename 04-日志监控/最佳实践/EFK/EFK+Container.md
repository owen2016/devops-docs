# EFK 收集Nginx容器日志

docker默认的日志驱动是json-file,每一个容器都会在本地生成一个/var/lib/docker/containers/containerID/containerID-json.log,而日志驱动是支持扩展的,本章主要讲解的是Fluentd驱动收集docker日志

nginx使用 `fluentd日志驱动` 将nginx docker日志转发到对应fluentd ，fluentd 将日志加工后传递到elasticsearch，存储到elasticsearch的数据就可以使用kibana展示出来

## 部署fluentd环境

``` shell
FROM fluent/fluentd
RUN ["gem", "install", "fluent-plugin-elasticsearch", "--no-document", "--version", "4.3.1"]
```

``` yaml
version: "3"
services:
  fluentd:
    build: ./fluentd
    volumes:
      - ./fluentd/conf:/fluentd/etc
    privileged: true
    ports:
      - "24224:24224"
      - "24224:24224/udp"
    environment:
      - TZ=Asia/Shanghai
    restart: always
    logging:
        driver: "json-file"
        options:
            max-size: 100m

```

**配置文件**

``` xml
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>
<filter nginx>
  @type parser
  key_name log
  <parse>
        @type regexp
        expression (?<remote>[^ ]*) (?<user>[^ ]*) \[(?<localTime>[^\]]*)\] "(?<method>\S+)(?: +(?<path>[^\"]*?)(?: +\S*)?)?" (?<code>[^ ]*) (?<size>[^ ]*) (?<requestTime>[^ ]*)(?: "(?<referer>[^\"]*)" "(?<agent>[^\"]*)"(?:\s+(?<http_x_forwarded_for>[^ ]+))?)?
        time_format %d/%b/%Y:%H:%M:%S %z
  </parse>
</filter>
<match nginx>
  @type copy
  <store>
    @type elasticsearch
    host 172.21.48.48
    port 9200
    logstash_format true
    logstash_prefix nginx
    logstash_dateformat %Y%m%d
    include_tag_key true
    type_name access_log
    flush_interval 1s
    include_tag_key true
    tag_key @log
  </store>
  <store>
    @type stdout
  </store>
```

注意上面的正则表达式对应的nginx日志格式为：

``` shell
log_format  main  '$remote_addr $remote_user [$time_local] "$request" '
                 '$status $body_bytes_sent $request_time "$http_referer" '
               '"$http_user_agent" "$http_x_forwarded_for"';
```

## 部署nginx容器

``` yaml
services:
  nginx:
    restart: always
    image: nginx
    container_name: nginx
    ports:
      - 8081:80
      - 443:443
      - 8084:8084
    volumes:
      - ./conf/nginx.conf:/etc/nginx/nginx.conf
      - ./conf.d:/etc/nginx/conf.d
      - ./www:/usr/share/nginx/html
      #- ./log:/var/log/nginx   #一定不要把nginx docker日志挂载到外部，否则fluentd无法正常工作
    privileged: true
    environment:
      - TZ=Asia/Shanghai
    logging:
        driver: "fluentd"    #日志驱动换成fluentd，默认为json-file
        options:
          fluentd-address: xx.xx.xx.xx:24224  #对应fluentd服务地址
          fluentd-async-connect: 'true'
          tag: nginx
```