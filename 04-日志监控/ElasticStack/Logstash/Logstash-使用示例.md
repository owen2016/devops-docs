# Logstash 使用示例

## 1. 基础测试示例

``` shell
bin/logstash -e 'input { stdin { } } output { stdout {} }'
#-e表示在启动时直接指定pipeline配置
```

或者将该配置写入一个配置文件中，然后通过指定配置文件来启动

``` conf
input {
    stdin {
       codec=> line
    }
}

filter {
    }

output {
    stdout{
        codec=>json
    }
}
```

在控制台输入：hello world，可以看到如下输出：

``` json
    {
    "@version" => "1",
    "host" => "localhost",
    "@timestamp" => 2018-09-18T12:39:38.514Z,
    "message" => "hello world"
    }
```

Logstash会自动为数据添加@version, host, @timestamp等字段

在这个示例中Logstash从标准输入中获得数据，仅在数据中添加一些简单字段后将其输出到标准输出

**其数据转换过程如下：**

- 将标准输入通过codec转换成line，filter这里为空即不做处理，然后在输出部分经过codec转换成json输出到标准输出

    ``` shell
    user@owen-ubuntu:/etc/logstash$ echo -e "foo\nbar"| /usr/share/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'
    ....
    [INFO ] 2020-12-01 13:34:37.705 [Agent thread] agent - Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
    {
        "@timestamp" => 2020-12-01T05:34:37.699Z,
        "@version" => "1",
        "host" => "owen-ubuntu",
        "message" => "foo"
    }
    {
        "@timestamp" => 2020-12-01T05:34:37.711Z,
        "@version" => "1",
        "host" => "owen-ubuntu",
        "message" => "bar"
    }
    ```

    ![input](_images/input.png)

    ![output](_images/output.png)

## 2. Nginx log 示例

例如，要处理nginx日志，在/etc/logstash/conf.d 下创建一个 nginx_access.conf的日志。

``` json
input{
    file{
        path => "/var/log/nginx/access.log"
        start_position => "beginning"
        type => "nginx_access_log"
    }
}
filter{
    grok{
        match => {"message" => "%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}\" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) \"(?:-|%{DATA:referrer})\" \"%{DATA:user_agent}\" (?:%{IP:proxy}|-) %{DATA:upstream_addr} %{NUMBER:upstream_request_time:float} %{NUMBER:upstream_response_time:float}"}
        match => {"message" => "%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] \"%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}\" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) \"%{DATA:referrer}\" \"%{DATA:user_agent}\" \"%{DATA:proxy}\""}
    }
    if [request] {
        urldecode {
            field => "request"
        }
       ruby {
           init => "@kname = ['url_path','url_arg']"
           code => "
               new_event = LogStash::Event.new(Hash[@kname.zip(event.get('request').split('?'))])
               event.append(new_event)"
       }
        if [url_arg] {
            ruby {
               init => "@kname = ['key', 'value']"
               code => "event.set('url_args', event.get('url_arg').split('&').collect {|i| Hash[@kname.zip(i.split('='))]})"
                }
        }
    }
    geoip{
        source => "clientip"
    }
    useragent{
        source => "user_agent"
        target => "ua"
        remove_field => "user_agent"
    }
    date {
        match => ["timestamp","dd/MMM/YYYY:HH:mm:ss Z"]
        locale => "en"
    }
    mutate{
        remove_field => ["message","timestamp","request","url_arg"]
    }
}
output{
    elasticsearch {
        hosts => "localhost:9200"
        index => "nginx-access-log-%{+YYYY.MM.dd}"
    }
#　　stdout {
#　　　　 codec => rubydebug
#　　}
}
```

`logstash -t -f /etc/logstash/conf.d/nginx.conf  #测试配置文件`

`logstash -f /etc/logstash/conf.d/nginx_access.conf  #启动logstash`