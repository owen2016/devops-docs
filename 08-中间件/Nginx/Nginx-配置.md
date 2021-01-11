# Nginx-配置

nginx配置文件主要分成四个部分：

- main，全局设置，影响其它部分所有设置
- server，主机服务相关设置，主要用于指定虚拟主机域名、IP和端口
- location，URL匹配特定位置后的设置，反向代理、内容篡改相关设置 （比如，根目录“/”,“/images”,等等)
- upstream，上游服务器设置，负载均衡相关配置

他们之间的关系：server继承main，location继承server；upstream既不会继承指令也不会被继承

## server-主机配置

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377932_20200629100556471_103626023.png)


- listen指监听的端口 80,81
- server_name 服务器名字指监听的ip，域名
- location指代理的路径。
- 启动server可以配置多个，每个端口可以相同也可以不同。
  - 根据server_name不同，listen不同，代理到location中的路径中。
  - 比如访问aa.com代理到8080，aa.com:81代理到8081，bb.com代理到8082

## upstream -负载均衡

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377932_20200629100920495_1542765222.png)


访问 cszhi.com将会代理到下面这几个服务器，还有配置权重，规则。

## location-路径配置

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377932_20200629101231957_828912682.png)

location根据正则匹配，匹配路径下的静态文件，也可以通过proxy_pass转到别的服务

- 以 =开头表示精确匹配
- ^~ 开头表示uri以某个常规字符串开头，不是正则匹配
- ~开头表示区分大小写的正则匹配;
- ~* 开头表示不区分大小写的正则匹配
- / 通用匹配, 如果没有其它匹配,任何请求都会匹配到

**优先级：**
(location =) > (location 完整路径) > (location ^~ 路径) > (location ~,~* 正则顺序) > (location 部分起始路径) > (/)

## http配置
在配置文件 nginx.conf 中的 http 区域内，配置无数个 server ，每一个 server 对应这一个虚拟主机或者域名

```
http {
    #http 配置项目
    sendfile  on                  #高效传输文件的模式 一定要开启
    keepalive_timeout   65        #客户端服务端请求超时时间
    log_format  main   XXX        #定义日志格式 代号为main
    access_log  /usr/local/access.log  main     #日志保存地址 格式代码 main
    
    server {
        listen 80                          #监听端口;
        server_name localhost              #地址
        location / {                       #访问首页路径
            root /xxx/xxx/index.html       #默认目录
            index index.html index.htm     #默认文件
        }

        error_page  500 504   /50x.html    #当出现以上状态码时从新定义到50x.html
        location = /50x.html {             #当访问50x.html时
            root /xxx/xxx/html             #50x.html 页面所在位置
        }
    }

    server {
        ... ... 
    }
}

```

## https配置

HTTPS是一种通过计算机网络进行安全通信的传输协议，经由HTTP进行通信，利用SSL/TLS建立全信道，加密数据包。HTTPS使用的主要目的是提供对网站服务器的身份认证，同时保护交换数据的隐私与完整性。
PS:TLS是传输层加密协议，前身是SSL协议，由网景公司1995年发布，有时候两者不区分。
ca是ssl证书的签发机构
ssl证书可以购买阿里云免费证书
https://yundunnext.console.al...

下载nginx版证书，添加到服务器中，
配置nginx：
其他和 http 反向代理基本一样，只是在 Server 部分配置有些不同

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377933_20200629101437625_1645312181.png)

```
 server {
 
     #监听443端口。443为知名端口号，主要用于HTTPS协议 
     listen       443 ssl;
     
     #定义使用www.xx.com访问 
     server_name  www.helloworld.com;
 
     #ssl证书文件位置(常见证书文件格式为：crt/pem) 
     ssl_certificate      cert.pem;
 
     #ssl证书key位置 
     ssl_certificate_key  cert.key;
 
     #ssl配置参数（选择性配置） 
     ssl_session_cache    shared:SSL:1m; 
     ssl_session_timeout  5m;
 
     #数字签名，此处使用MD5 
     ssl_ciphers  HIGH:!aNULL:!MD5; 
     ssl_prefer_server_ciphers  on; 
     location / { 
         root   /root; 
         index  index.html index.htm; 
     } 
 }

```
同时监听80和443端口，当使用http访问自动跳转到https，根据if（$schema ==hhtp）完成
ssl_certificate配置证书路径
ssl_certificate_key 配置key路径
保存，重启nginx。
启动发现访问 ailijie.top成功跳转为 https://ailijie.top
使用https后站点内所有的请求都要使用https不然会被浏览器进行拦截。

## 配置rewrite
- rewrite功能就是集合正则表达式和标志位实现url重写和重定向。
- rewrite只能放在server{}、location{}、if(){}块中，并且只能对域名后边的出去传递参数外的字符串起作用。
如URL： http://microloan-sms-platform.yxapp.xyz/proxy/sms/task/querydeleted?page=1&pagesize=10，只对/proxy/sms/task/querydeleted进行重写。

如果相对域名或参数字符串起作用，可以使用全局变量匹配，也可以使用proxy_pass反向代理。

表面看rewrite和location功能有点像，都能实现跳转，**主要区别在于rewrite是在同一域名内更改获取资源的路径，而location是对一类路径做控制访问或反向代理，可以proxy_pass到其他机器**。

很多情况下rewrite也会写在location里，它们的执行顺序是：
- 执行server块的rewrite指令
- 执行location匹配
- 执行选定的location中的rewrite指令

如果其中某步URI被重写，则重新循环执行1-3，直到找到真实存在的文件；循环超过10次，则返回500 Internal Server Error错误。

rewrite规则后边，通常会带有flag标志位：
- last : 相当于Apache的[L]标记，表示完成rewrite
- break : 停止执行当前虚拟主机的后续rewrite指令集
- redirect : 返回 302临时重定向，地址栏会显示跳转后的地址
- permanent : 返回 301永久重定向，地址栏会显示跳转后的地址

` rewrite ^(.*)$  https://$host$1 permanent;  #强制将http请求跳转到https请求`

**last 和 break 区别：**
- last一般写在 server和 if中，而 break一般使用在 location中
- last不终止重写后的url匹配，即新的url会再从 server走一遍匹配流程，而 break终止重写后的匹配
- break和 last都能组织继续执行后面的rewrite指令

**rewrite常用正则：**
- . ： 匹配除换行符以外的任意字符
- ? ： 重复0次或1次
- + ： 重复1次或更多次
- * ： 重复0次或更多次
- \d ：匹配数字
- ^ ： 匹配字符串的开始
- $ ： 匹配字符串的介绍
- {n} ： 重复n次
- {n,} ： 重复n次或更多次
- [c] ： 匹配单个字符c
- [a-z] ： 匹配a-z小写字母的任意一个
可以使用 ()来进行分组，可以通过 $1的形式来引用。

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377933_20200629112504320_1312847232.png)

## nginx.conf

```
user www-data; #设置nginx服务的系统使用用户
worker_processes auto; #工作进程数 一般情况与CPU核数保持一致
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 768; #每个进程允许最大连接数
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on; 	#开启tcp_nopush提高网络包传输效率,将文件一次性一起传输给客户端
	tcp_nodelay on;  #开启实时传输，传输方式与 tcp_nopush 相反，追求实时性，但是它只有在长连接下才生效
	keepalive_timeout 65;
	types_hash_max_size 2048;
	# server_tokens off;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on; #将访问的文件压缩传输 （减少文件资源大小，提高传输速度）

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6; #压缩比，越高压缩越多，压缩越高可能会消耗服务器性能
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1; #服务器传输版本
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}


#mail {
#	# See sample authentication script at:
#	# http://wiki.nginx.org/ImapAuthenticateWithApachePhpScript
#
#	# auth_http localhost/auth.php;
#	# pop3_capabilities "TOP" "USER";
#	# imap_capabilities "IMAP4rev1" "UIDPLUS";
#
#	server {
#		listen     localhost:110;
#		protocol   pop3;
#		proxy      on;
#	}
#
#	server {
#		listen     localhost:143;
#		protocol   imap;
#		proxy      on;
#	}
#}

```

## 示例

```
user www www;
worker_processes 2;
error_log logs/error.log;
#error_log logs/error.log notice;
#error_log logs/error.log info;
pid logs/nginx.pid;
events {
use epoll;
worker_connections 2048;
}
http {
include mime.types;
default_type application/octet-stream;
#log_format main '$remote_addr - $remote_user [$time_local] "$request" '
# '$status $body_bytes_sent "$http_referer" '
# '"$http_user_agent" "$http_x_forwarded_for"';
#access_log logs/access.log main;
sendfile on;
# tcp_nopush on;
keepalive_timeout 65;
# gzip压缩功能设置
gzip on;
gzip_min_length 1k;
gzip_buffers 4 16k;
gzip_http_version 1.0;
gzip_comp_level 6;
gzip_types text/html text/plain text/css text/javascript application/json application/javascript application/x-javascript application/xml;
gzip_vary on;
# http_proxy 设置
client_max_body_size 10m;
client_body_buffer_size 128k;
proxy_connect_timeout 75;
proxy_send_timeout 75;
proxy_read_timeout 75;
proxy_buffer_size 4k;
proxy_buffers 4 32k;
proxy_busy_buffers_size 64k;
proxy_temp_file_write_size 64k;
proxy_temp_path /usr/local/nginx/proxy_temp 1 2;
# 设定负载均衡后台服务器列表
upstream backend {
#ip_hash;
server 192.168.10.100:8080 max_fails=2 fail_timeout=30s ;
server 192.168.10.101:8080 max_fails=2 fail_timeout=30s ;
}
# 很重要的虚拟主机配置
server {
listen 80;
server_name itoatest.example.com;
root /apps/oaapp;
charset utf-8;
access_log logs/host.access.log main;
#对 / 所有做负载均衡+反向代理
location / {
root /apps/oaapp;
index index.jsp index.html index.htm;
proxy_pass http://backend;
proxy_redirect off;
# 后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
}
#静态文件，nginx自己处理，不去backend请求tomcat
location ~* /download/ {
root /apps/oa/fs;
}
location ~ .*\.(gif|jpg|jpeg|bmp|png|ico|txt|js|css)$
{
root /apps/oaapp;
expires 7d;
}
location /nginx_status {
stub_status on;
access_log off;
allow 192.168.10.0/24;
deny all;
}
location ~ ^/(WEB-INF)/ {
deny all;
}
#error_page 404 /404.html;
# redirect server error pages to the static page /50x.html
#
error_page 500 502 503 504 /50x.html;
location = /50x.html {
root html;
}
}
## 其它虚拟主机，server 指令开始
}


```
