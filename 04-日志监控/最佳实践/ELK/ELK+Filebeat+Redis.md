# ELK + Filebeat+ Redis 分析php的laravel项目

1. laravel日志：日志源通过`filebeat`将日志写进redis中间件
2. logstsh：logstash通过input将redis数据拿来分析，通过其filter模块分析所需要的语句，然后输出到elasticsearch
3. elasticsearch 接收logstash发送过来的数据，并提供了一个分布式多用户能力的全文搜索引擎
4. Kibana可以非常详细的将日志转化为各种图表，为用户提供强大的数据可视化支持。

## Filebeat 配置

``` yaml
#写入源
- input_type: log
  paths:
  - /var/www/html/*/storage/logs/laravel-2018-12-29.log

#输出至redis

output.redis:
  # Array of hosts to connect to.

  hosts: ["172.18.215.207:6379"]
  password: "***********"
  db: 0
  timeout: 5
  key: "php-01"

  # Optional protocol and basic auth credentials.
  #protocol: "https"
  #username: "elastic"
  #password: "changeme"
```

## Logstash 配置

```conf
#
# Where to fetch the pipeline configuration for the main pipeline
#

path.config:
/etc/logstash/conf.d

#
# Pipeline configuration string for the main pipeline
#
# config.string:
#
...
path.config: /etc/logstash/conf.d

#
...
http.host: "127.0.0.1"
#
# Bind port for the metrics REST endpoint, this option also accept a range
# (9600-9700) and logstash will pick up the first available ports.
#

# http.port: 9600-9700
#
# ------------ Debugging Settings --------------
#

# Options for log.level:
#   * fatal
#   * error
#   * warn
#   * info (default)
#   * debug
#   * trace
#
# log.level: info
path.logs: /var/log/logstash
...
vim /etc/logstash/conf.d/nginx.conf

# 从redis将数据取出

input {
  redis {
    type => "php-01"
    host => "172.18.215.207"
    port => "6379"
    db => "0"
    password =>"*************"
    data_type => "list"
    key => "php-01"
  }

}

# 格式化laravel日志
filter {
   grok {
       match => [ 
        "message","\[%{TIMESTAMP_ISO8601:logtime}\] %{WORD:env}\.(?<level>[A-Z]{4,5})\: %{GREEDYDATA:msg}}"]
        }
}

output {

#过滤level为ERROR的日志
if
 [level] == "ERROR"
 {
         elasticsearch {

              hosts => ["127.0.0.1:9200"]
              index => "laravellog"
              user => "elastic"
              password => "changeme"
            }

        }
}
```