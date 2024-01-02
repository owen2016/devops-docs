# EFK -->>收集nginx log


## Nginx配置
```
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    #开启下划线识别，并且中划线转下划线
    underscores_in_headers on;

    #设置body达到256k时写入临时文件，默认为两个系统页大小(4096*2)
    client_body_buffer_size 1m;
    client_max_body_size 1m;
    #client_body_in_single_buffer on;
    #client_body_in_file_only on;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    log_format  unimod  '$remote_addr [$time_local] "$request" $request_length $status $http_content_type $http_content_encoding "$request_body" '
                        '1:$http_row_priority_with_crawltime 2:$http_row_priority_without_crawltime 3:$http_column_priority_with_crawltime 4:$http_column_priority_without_crawltime';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    #include /etc/nginx/conf.d/default.conf;
    server {
        listen       80;
        server_name  10.0.0.8;

        #charset koi8-r;
        #if ($request_method !~* POST) {
        #    return 403;
        #}
        proxy_ignore_client_abort on;

        access_log  /var/log/nginx/host.access.log  unimod;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        location ~ ^/v[1-9]*/ingest/(qa|weibo|weixin)/(article|document)$ {
            if ($request_method !~* POST) {
                return 403;
            }
            #ngx_http_read_client_request_body();
            proxy_pass http://127.0.0.1:10086;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504 =200 /index.html;
        location = /index.html {
            root   /usr/share/nginx/html;
        }
    }

}
```

设置滚动日志文件权限，默认为640，会导致td-agent读取日志是没权限
```
[root@vmforplatformjobs nginx]# cat /etc/logrotate.d/nginx
/var/log/nginx/*.log {
        daily
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        create 644 nginx adm
        sharedscripts
        postrotate
                if [ -f /var/run/nginx.pid ]; then
                        kill -USR1 `cat /var/run/nginx.pid`
                fi
        endscript
}

```

## Fluentd参数配置

查看系统文件描述符最大数量限制ulimit -n，如果太小，可做适当的修改，修改/etc/security/limits.conf文件并reboot
root soft nofile 65536   
root hard nofile 65536
* soft nofile 65536
* hard nofile 65536

```
<source>
  @type tail
  encoding utf-8
  from_encoding utf-8
  path /var/log/nginx/host.access.log
  pos_file /var/log/nginx/host.access.log.pos
  tag host.document
  format /^(?<remote>[^ ]*) \[([^\]]*)\] "(?<method>\S+) (?<path>\S+) (?<protocol>\S+)" (?<size>[^ ]*) (?<code>[^ ]*) (?<contentType>[^ ]*) (?<contentEncoding>[^ ]*) "(?<content>[^"]*)" 1:(?<rowPriority>[^ ]*) 2:(?<columnPriority>[^ ]*)$/
  time_format %d/%b/%Y:%H:%M:%S %z
</source>

<filter host.document>
  @type grep
  <and>
    <regexp>
      key code
      pattern 200
    </regexp>
    <regexp>
      key method
      pattern POST
    </regexp>
  </and>
</filter>

<match host.document>
  @type rewrite_tag_filter
  <rule>
    key size
    pattern /^(\d{1,5}|1\d{1,5}|2[0-4]\d{1,4})$/
    tag toolarge.document
    invert true
  </rule>
  <rule>
    key path
    pattern /^/v[1-9]*/ingest/qa/document$/
    tag qa.document
  </rule>
  <rule>
    key path
    pattern /.+/
    tag unmatched.document
  </rule>
</match>

<filter qa.document>
  @type record_transformer
  renew_record true
  keep_keys ["rowPriority","columnPriority","contentType","contentEncoding","content"]
</filter>

<match qa.document>
  @type azureeventhubs_buffered
  connection_string Endpoint=xxx
  hub_name qaarticle
  batch true
  max_batch_size 10000
  print_records false
  <buffer>
    @type memory
    flush_interval 60
    chunk_limit_size 255KB
  </buffer>
</match>

<match toolarge.document>
  @type file
  path /var/log/td-agent/toolarge
</match>

<match unmatched.document>
  @type file
  path /var/log/td-agent/unmatched
</match>

```

- 将Source配置为收集Nginx的日志文件，需要指定pos_file文件记录文件的读取位置，以防td-agent故障重启后可以正确找到读取位置，指定路劲需要考虑用户权限问题

- 配置Filter，保留有用字段，要使keep_keys生效需要配置renew_record为true

- 配置Match，将filter过滤后的数据输出至Event Hub中，注意：需要先安装对应的插件才能使用sudo td-agent-gem install fluent-plugin-azureeventhubs，配置connection_string时要使用具有Manager权限的连接字符串，否则启动时会报错

- 安装fluent-plugin-azureeventhubs时只是安装了0.0.6版本，需要将代码用github中的master分支代码替换才能支持将多条数据写到一个event data中

当正常发送数据到nginx，但是大小超过250k时，fluentd会将该条数据记录到toolarge的文件夹下，而不会输出到event hub
当正常发送数据到nginx，但是未配置fluentd输出到event hub时，会将数据写到unmatched文件夹下

## Fluentd Dockerfile
```
FROM fluent/fluentd:v1.7-1

# Use root account to use apk
USER root

# below RUN includes plugin as examples azureeventhubs is not required
# you may customize including plugins as you wish
RUN apk add --no-cache --update --virtual .build-deps \
        sudo build-base ruby-dev \
 && sudo gem install fluent-plugin-azureeventhubs \
 && sudo gem install fluent-plugin-rewrite-tag-filter \
 && sudo gem sources --clear-all \
 && apk del .build-deps \
 && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem
COPY fluent-plugin-azureeventhubs-0.0.6 /usr/lib/ruby/gems/2.5.0/gems/fluent-plugin-azureeventhubs-0.0.6
# COPY td-agent.conf /fluentd/etc/
# COPY entrypoint.sh /bin/

USER fluent
```


