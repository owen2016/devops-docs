# Logstash 日常使用

## 参考

- <https://www.elastic.co/guide/en/logstash/current/configuration-file-structure.html>
- <https://www.elastic.co/guide/en/logstash/current/event-dependent-configuration.html>

## 多个配置文件（conf）

- 绍如何来处理多个配置文件
    https://cloud.tencent.com/developer/article/1674717
    - 多个 pipeline
    - 一个 pipleline 处理多个配置文件

## 处理多个 input

- 介绍了如何使用在同一个配置文件中处理 多个 input 的情况
    https://cloud.tencent.com/developer/article/1671480?from=10680

``` json
input {
  file {
    path => "/var/log/messages"
    type => "syslog"
  }

  file {
    path => "/var/log/apache/access.log"
    type => "apache"
  }
}
```

## 日志同时保存到两台 ElasticSearch

``` json
output {
    elasticsearch {
        hosts => ["http://192.168.0.1:9200"]
        index => "logstash-%{+YYYY.MM.dd}"
    }

    elasticsearch {
        hosts => ["http://192.168.0.2:9200"]
        index => "logstash-%{+YYYY.MM.dd}"
    }
}
```

## 条件判断

如果需要根据某些条件保存到不同的索引，则需要写一些判断条件。

Logstash 的配置文件支持如下格式的语法

``` json
if EXPRESSION {
  ...
} else if EXPRESSION {
  ...
} else {
  ...
}

```

其中 EXPRESSION 支持如下运算符：

- 比较运算符

    equality: ==, !=, <, >, <=, >=
    regexp: =~, !~ (checks a pattern on the right against a string value on the left)
    inclusion: in, not in

- 布尔运算符

    and : 与
    or : 或
    nand : 与非（有 false 则 true，全 true 则 false）
    xor : 异或（只有在两个比较的值不同时其结果才是 true，否则结果为 false）

- 一元运算符

    ! : 非

另外，在判断条件中访问日志中的字段需要使用中括号 [fieldname] 的形式。

``` json
filter {
  if [action] == "login" {
    mutate { remove_field => "secret" }
  }
}
```

如果是在 Logstash 中调用 sprintf format 输出的字段时，需使用 %{fieldname} 的形式，多个字段时可以使用 %{[fieldname1][fieldname2]}。

``` json
output {
  statsd {
    increment => "apache.%{[response][status]}"
  }
}
```

## 使用示例

1. 优先将 type 为 parameter 的日志单独输出到保存参数的索引，然后根据日志的 level 输出到各自的索引。

2. 如果是程序的 Exception 则不会包含 type 和 level 字段，判断是否包含 Exception 字符，如果包含则输出到记录错误消息的索引。
3. 最后的 else 则是输出到默认的 info 索引。

每个索引以月为单位，每月创建一个单独的索引，以便将来删除过期的日志信息。
需要注意的是 elasticsearch 插件的 index 字段不支持大写字母，所以这里增加了一个 lowercase 的 filter，将 type 和 level 字段转成了小写。

``` json
input {
    rabbitmq {
        type => "log_type"
        durable => true
        exchange => "logstash"
        exchange_type => "topic"
        key => "service.#"
        host => "192.168.0.1"
        port => 5672
        user => "username"
        password => "password"
        queue => "log_queue"
        auto_delete => false
        tags => ["service"]
    }
}

filter {
    mutate {
        lowercase => [ "type", "level" ]
    }
}

output {
    if [type] and [type] == "parameter" {
        elasticsearch {
            hosts => ["http://192.168.0.1:9200"]
            index => "logstash-parameter-%{+YYYY.MM}"
        }
    } else if [level] and [level] != "" {
        elasticsearch {
            hosts => ["http://192.168.0.1:9200"]
            index => "logstash-%{level}-%{+YYYY.MM}"
        }
    } else if [message] and "Exception" in [message] {
        elasticsearch {
            hosts => ["http://192.168.0.1:9200"]
            index => "logstash-error-%{+YYYY.MM}"
        }
    } else {
        elasticsearch {
            hosts => ["http://192.168.0.1:9200"]
            index => "logstash-info-%{+YYYY.MM}"
        }
    }
}
```

## 配置语法

- array：数组可以是单个或者多个字符串值。

    users => [ {id => 1, name => bob}, {id => 2, name => jane} ]

- Lists：集合

    path => [ "/var/log/messages", "/var/log/*.log" ]
    uris => [ "http://elastic.co", "http://example.net" ]

- Boolean：true 或者false

    ssl_enable => true

- Bytes：字节类型

    my_bytes => "1113"   # 1113 bytes
    my_bytes => "10MiB"  # 10485760 bytes
    my_bytes => "100kib" # 102400 bytes
    my_bytes => "180 mb" # 180000000 bytes

- Codec：编码类型

    codec => "json"

- Hash：哈希（散列）

    ``` conf
    match => {
    "field1" => "value1"
    "field2" => "value2"
    ...
    }
    # or as a single line. No commas between entries:
    match => { "field1" => "value1" "field2" => "value2" }
   ```

- Number：数字类型

    port => 33

- Password：密码类型

    my_password => "password"

- URI：uri类型

    my_uri => "http://foo:bar@example.net"

- Path： 路径类型

    my_path => "/tmp/logstash"

- String：字符串类型，字符串必须是单个字符序列。`注意，字符串值被括在双引号或单引号中`

