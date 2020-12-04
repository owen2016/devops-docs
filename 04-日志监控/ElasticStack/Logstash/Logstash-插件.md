# 插件

[TOC]

## 1. Input：输入数据到logstash

<https://www.elastic.co/guide/en/logstash/current/input-plugins.html>

- file：从文件系统的文件中读取，类似于tail -f命令

    ``` json
    file {
    path => ['/var/log/nginx/access.log']  #要输入的文件路径
    type => 'nginx_access_log'
    start_position => "beginning"
    }
    # path  可以用/var/log/*.log,/var/log/**/*.log，如果是/var/log则是/var/log/*.log
    # type 通用选项. 用于激活过滤器
    # start_position 选择logstash开始读取文件的位置，begining或者end。
    ```

- syslog：在514端口上监听系统日志消息，并根据RFC3164标准进行解析

    ``` json
    syslog{
        port => "514"
        type => "syslog"
    }
    # port 指定监听端口(同时建立TCP/UDP的514端口的监听)

    #从syslogs读取需要实现配置rsyslog：
    # cat /etc/rsyslog.conf   加入一行
    *.* @172.17.128.200:514　  #指定日志输入到这个端口，然后logstash监听这个端口，如果有新日志输入则读取
    # service rsyslog restart   #重启日志服务
    ```

- redis：从redis service中读取

- beats：从filebeat中读取

    ``` json
    beats {
        port => 5044   #要监听的端口
    }
    # 还有host等选项

    # 从beat读取需要先配置beat端，从beat输出到logstash。
    # vim /etc/filebeat/filebeat.yml
    ..........
    output.logstash:
    hosts: ["localhost:5044"]
    ```

- kafka  将 kafka topic 中的数据读取为事件

    ``` json
    kafka{
        bootstrap_servers=> "kafka01:9092,kafka02:9092,kafka03:9092"
        topics => ["access_log"]
        group_id => "logstash-file"
        codec => "json"
    }
    kafka{
        bootstrap_servers=> "kafka01:9092,kafka02:9092,kafka03:9092"
        topics => ["weixin_log","user_log"]  
        codec => "json"
    }
    # bootstrap_servers 用于建立群集初始连接的Kafka实例的URL列表。
    # topics  要订阅的主题列表，kafka topics
    # group_id 消费者所属组的标识符，默认为logstash。kafka中一个主题的消息将通过相同的方式分发到Logstash的group_id
    # codec 通用选项，用于输入数据的编解码器
    ```

## 2. Codecs：基于数据流的过滤器

codec 本质上是流过滤器，可以作为input 或output 插件的一部分运行。可以帮助你轻松的分割发送过来已经被序列化的数据

一些常见的codecs：

- json：使用json格式对数据进行编码/解码。

- multiline：将汇多个事件中数据汇总为一个单一的行。比如：java异常信息和堆栈信息。

    ``` json
    input {
    stdin {
        codec => multiline {
        pattern => "pattern, a regexp"    #正则匹配规则，匹配到的内容按照下面两个参数处理
        negate => "true" or "false"     # 默认为false。处理匹配符合正则规则的行。如果为true，处理不匹配符合正则规则的行。
        what => "previous" or "next"    #指定上下文。将指定的行是合并到上一行或者下一行。
        }
    }
    }
    codec => multiline {
        pattern => "^\s"  
        what => "previous"  
    }
    # 以空格开头的行都合并到上一行

    codec => multiline {
        # Grok pattern names are valid! :)
        pattern => "^%{TIMESTAMP_ISO8601} "
        negate => true
        what => "previous"
    }
    # 任何不以这个时间戳格式开头的行都与上一行合并

    codec => multiline {
    pattern => "\\$"
    what => "next"
    }
    # 以反斜杠结尾的行都与下一行合并
    ```

## 3. Filters：数据中间处理，对数据进行操作

<https://www.elastic.co/guide/en/logstash/current/filter-plugins.html>

一些常用的过滤器为：

- grok：解析文本并构造,把非结构化日志数据通过正则解析成结构化和可查询化。内置120多个解析语法。
  
    官方提供的grok表达式：<https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns>
    grok在线调试：<https://grokdebug.herokuapp.com/>

    ``` json
    grok {
            match => {"message"=>"^%{IPORHOST:clientip} %{USER:ident} %{USER:auth} \[%{HTTPDATE:timestamp}\] "%{WORD:verb} %{DATA:request} HTTP/%{NUMBER:httpversion}" %{NUMBER:response:int} (?:-|%{NUMBER:bytes:int}) %{QS:referrer} %{QS:agent}$"}
        }
    #匹配nginx日志
    # 203.202.254.16 - - [22/Jun/2018:16:12:54 +0800] "GET / HTTP/1.1" 200 3700 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/601.7.7 (KHTML, like Gecko) Version/9.1.2 Safari/601.7.7"
    #220.181.18.96 - - [13/Jun/2015:21:14:28 +0000] "GET /blog/geekery/xvfb-firefox.html HTTP/1.1" 200 10975 "-" "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)"
    ```

    grok 可以有多个match匹配规则，如果前面的匹配失败可以使用后面的继续匹配。例如

    ``` json
     grok {
            match => ["message", "%{IP:clientip} - %{USER:user} \[%{HTTPDATE:raw_datetime}\] \"(?:%{WORD:verb} %{URIPATHPARAM:request} HTTP/%{NUMBER:httpversion})\" (?:\"%{DATA:body}\" )?(?:\"%{DATA:cookie}\" )?%{NUMBER:response} (?:%{NUMBER:bytes:int}|-) \"%{DATA:referrer}\" \"%{DATA:agent}\" (?:(%{IP:proxy},? ?)*|-|unknown) (?:%{DATA:upstream_addr} |)%{NUMBER:request_time:float} (?:%{NUMBER:upstream_time:float}|-)"]

            match => ["message", "%{IP:clientip} - %{USER:user} \[%{HTTPDATE:raw_datetime}\] \"(?:%{WORD:verb} %{URI:request} HTTP/%{NUMBER:httpversion})\" (?:\"%{DATA:body}\" )?(?:\"%{DATA:cookie}\" )?%{NUMBER:response} (?:%{NUMBER:bytes:int}|-) \"%{DATA:referrer}\" \"%{DATA:agent}\" (?:(%{IP:proxy},? ?)*|-|unknown) (?:%{DATA:upstream_addr} |)%{NUMBER:request_time:float} (?:%{NUMBER:upstream_time:float}|-)"]
        }
    ```

- mutate：对字段进行转换。例如对字段进行删除、替换、修改、重命名等

    **covert 类型转换。类型包括：integer，float，integer_eu，float_eu，string和boolean**

    ```json
    filter{
        mutate{
            #covert => ["response","integer","bytes","float"]  #数组的类型转换
            convert => {"message"=>"integer"}
        }
    }
    #测试------->
    {
        "host" => "localhost",
        "message" => 123,    #没带“”,int类型
        "@timestamp" => 2018-06-26T02:51:08.651Z,
        "@version" => "1"
    }
    ```

    **split   使用分隔符把字符串分割成数组**

    ``` json
    mutate{
        split => {"message"=>","}
    }
    #---------->
    aaa,bbb
    {
        "@timestamp" => 2018-06-26T02:40:19.678Z,
        "@version" => "1",
            "host" => "localhost",
        "message" => [
            [0] "aaa",
            [1] "bbb"
        ]}
    192,128,1,100
    {
            "host" => "localhost",
        "message" => [
        [0] "192",
        [1] "128",
        [2] "1",
        [3] "100"
    ],
    "@timestamp" => 2018-06-26T02:45:17.877Z,
        "@version" => "1"
    }
    ```

    **merge  合并字段  。数组和字符串 ，字符串和字符串**

    ``` json
        filter{
        mutate{
            add_field => {"field1"=>"value1"}
        }
        mutate{
            split => {"message"=>"."}   #把message字段按照.分割
        }
        mutate{
            merge => {"message"=>"field1"}   #将filed1字段加入到message字段
        }
    }
    #--------------->
    abc
    {
        "message" => [
            [0] "abc,"
            [1] "value1"
        ],
        "@timestamp" => 2018-06-26T03:38:57.114Z,
            "field1" => "value1",
        "@version" => "1",
            "host" => "localhost"
    }

    abc,.123
    {
        "message" => [
            [0] "abc,",
            [1] "123",
            [2] "value1"
        ],
        "@timestamp" => 2018-06-26T03:38:57.114Z,
            "field1" => "value1",
        "@version" => "1",
            "host" => "localhost"
    }
    ```

    **rename   对字段重命名**

    ``` json
    filter{
        mutate{
            rename => {"message"=>"info"}
        }
    }
    #-------->
    123
    {
        "@timestamp" => 2018-06-26T02:56:00.189Z,
            "info" => "123",
        "@version" => "1",
            "host" => "localhost"
    }
    ```

    **remove_field    移除字段**

    ```json
    mutate {
        remove_field => ["message","datetime"]
    }
    ```

    **join  用分隔符连接数组，如果不是数组则不做处理**

    ``` json
    mutate{
            split => {"message"=>":"}
    }
    mutate{
            join => {"message"=>","}
    }
    ------>
    abc:123
    {
        "@timestamp" => 2018-06-26T03:55:41.426Z,
        "message" => "abc,123",
            "host" => "localhost",
        "@version" => "1"
    }
    aa:cc
    {
        "@timestamp" => 2018-06-26T03:55:47.501Z,
        "message" => "aa,cc",
            "host" => "localhost",
        "@version" => "1"
    }
    ```

    **gsub  用正则或者字符串替换字段值。仅对字符串有效**

    ``` json
    mutate{
            gsub => ["message","/","_"]   #用_替换/
        }

    ------>
    a/b/c/
    {
        "@version" => "1",
        "message" => "a_b_c_",
            "host" => "localhost",
        "@timestamp" => 2018-06-26T06:20:10.811Z
    }
    ```

    **update  更新字段。如果字段不存在，则不做处理**

    ``` json
    mutate{
            add_field => {"field1"=>"value1"}
        }
        mutate{
            update => {"field1"=>"v1"}
            update => {"field2"=>"v2"}    #field2不存在 不做处理
        }
    ---------------->
    {
        "@timestamp" => 2018-06-26T06:26:28.870Z,
            "field1" => "v1",
            "host" => "localhost",
        "@version" => "1",
        "message" => "a"
    }
    ```

    **replace 更新字段。如果字段不存在，则创建**

    ```json
    mutate{
        add_field => {"field1"=>"value1"}
    }
    mutate{
        replace => {"field1"=>"v1"}
        replace => {"field2"=>"v2"}
    }
    ---------------------->
    {
        "message" => "1",
            "host" => "localhost",
        "@timestamp" => 2018-06-26T06:28:09.915Z,
            "field2" => "v2",        #field2不存在，则新建
        "@version" => "1",
            "field1" => "v1"
    }
    ```

- drop：丢弃一部分events不进行处理。

- clone：拷贝 event，这个过程中也可以添加或移除字段。

- geoip：根据来自Maxmind GeoLite2数据库的数据添加有关IP地址的地理位置的信息 (为前台kibana图形化展示使用)

## 4. Outputs：logstash处理管道的最末端组件

参考： <https://www.elastic.co/guide/en/logstash/current/output-plugins.html>

一个event可以在处理过程中经过多重输出，但是一旦所有的outputs都执行结束，这个event也就完成生命周期

一些常见的outputs为：

- elasticsearch：在es中存储日志

    ``` json
    elasticsearch {
            hosts => "localhost:9200"
            index => "nginx-access-log-%{+YYYY.MM.dd}"  
        }
    #index 事件写入的索引。可以按照日志来创建索引，以便于删旧数据和按时间来搜索日志
    ```

- file：将event数据保存到文件中。

   ``` json
    file {
        path => "/data/logstash/%{host}/{application}
        codec => line { format => "%{message}"} }
        }
    ```

- graphite：将event数据发送到图形化组件中，一个很流行的开源存储图形化展示的组件。

## logstash 比较运算符

　　等于:   ==, !=, <, >, <=, >=
　　正则:   =~, !~ (checks a pattern on the right against a string value on the left)
　　包含关系:  in, not in

　　支持的布尔运算符：and, or, nand, xor

　　支持的一元运算符: !

## 插件管理命令

```text
Usage:
    bin/logstash-plugin [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    list                          List all installed Logstash plugins
    install                       Install a Logstash plugin
    remove                        Remove a Logstash plugin
    update                        Update a plugin
    pack                          Package currently installed plugins, Deprecated: Please use prepare-offline-pack instead
    unpack                        Unpack packaged plugins, Deprecated: Please use prepare-offline-pack instead
    generate                      Create the foundation for a new plugin
    uninstall                     Uninstall a plugin. Deprecated: Please use remove instead
    prepare-offline-pack          Create an archive of specified plugins to use for offline installation

Options:
    -h, --help                    print help

```
