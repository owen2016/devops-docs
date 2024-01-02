# Nginx-跨域访问

web 领域开发中，经常采用前后端分离模式。这种模式下，前端和后端分别是独立的 web 应用程序，例如：后端是 Java 程序，前端是 React 或 Vue 应用。

各自独立的 web app 在互相访问时，势必存在跨域问题。解决跨域问题一般有两种思路：
**CORS**
在后端服务器设置 HTTP 响应头，把你需要运行访问的域名加入加入 Access-Control-Allow-Origin 中。

**jsonp**
把后端根据请求，构造json数据，并返回，前端用 jsonp 跨域。

这两种思路，本文不展开讨论。

需要说明的是，nginx 根据第一种思路，也提供了一种解决跨域的解决方案。
举例：www.helloworld.com 网站是由一个前端 app ，一个后端 app 组成的。前端端口号为 9000， 后端端口号为 8080。
前端和后端如果使用 http 进行交互时，请求会被拒绝，因为存在跨域问题。来看看，nginx 是怎么解决的吧：

首先，在 enable-cors.conf 文件中设置 cors ：

```
# allow origin list 
set $ACAO '*';
 
# set single origin 
if ($http_origin ~* (www.helloworld.com)$) {
  set $ACAO $http_origin;
 }
 
if ($cors = "trueget") {
    add_header 'Access-Control-Allow-Origin' "$http_origin";
    add_header 'Access-Control-Allow-Credentials' 'true'; 
    add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS'; 
    add_header 'Access-Control-Allow-Headers' 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type'; 
}
 
if ($request_method = 'OPTIONS') { 
 set $cors "${cors}options"; 
}
 
if ($request_method = 'GET') { 
 set $cors "${cors}get"; 
}
 
if ($request_method = 'POST') { 
 set $cors "${cors}post";

}
```

接下来，在你的服务器中 include enable-cors.conf 来引入跨域配置：

```
# ----------------------------------------------------
# 此文件为项目 nginx 配置片段 
# 可以直接在 nginx config 中 include（推荐） 
# 或者 copy 到现有 nginx 中，自行配置 
# www.helloworld.com 域名需配合 dns hosts 进行配置 
# 其中，api 开启了 cors，需配合本目录下另一份配置文件
 
# ----------------------------------------------------
 
upstream front_server{ 
 server www.helloworld.com:9000; 
}
 
upstream api_server{ 
 server www.helloworld.com:8080; 
}
 
server {
 
 listen       80; 
 server_name  www.helloworld.com; 
 
 location ~ ^/api/ { 
   include enable-cors.conf; 
   proxy_pass http://api_server; 
   rewrite "^/api/(.*)$" /$1 break; 
 }
 
 location ~ ^/ { 
   proxy_pass http://front_server; 
 }
 
}
```



开发nginx跨站访问设置：

![](_v_images/20200624145905670_1295638033.png)

在响应中指定 Access-Control-Allow-Credentials 为 true 时，Access-Control-Allow-Origin 不能指定为 *，需要指定到具体域名。

相关跨域内容可参考 Laravel 跨域功能中间件 使用代码实现跨域，原理与nginx跨域配置相同。
