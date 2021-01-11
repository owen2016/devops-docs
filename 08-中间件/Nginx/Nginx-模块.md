# Nginx 模块

Nginx的核心模块包括内核模块和事件驱动模块，即：CoreModule和EventsModule；另外还有第三方模块 HTTP内核模块，HttpCoreModule，它是Nginx服务器的核心模块。

CoreModule和EventsModule模块的配置相对于HttpCoreModule会少一些，但是它们的配置将会影响系统的性能，而非功能上的差异。

1、CoreModule用于控制Nginx服务器的基本功能；
2、EventsModule用于控制Nginx如何处理连接。该模块的指令的一些参数会对应用系统的性能产生重要的影响；
3、HttpCoreModule提供HTTP访问Nginx服务器，该模块是不能缺少的。


Ngx_http_auth_basic_module访问控制模块
    https://blog.51cto.com/gning/1972553

Ngx_http_access_moduleip的访问控制模块
    https://blog.51cto.com/gning/1968243

ngx_http_addition_module向响应内容中追加内容
    https://my.oschina.net/766/blog/211086

ngx_http_fastcgi_module
    https://www.cnblogs.com/ckh2014/p/10881481.html

ngx_http_index_module
    http://tengine.taobao.org/nginx_docs/cn/docs/http/ngx_http_index_module.html

ngx_http_headers_module
    --todo

ngx_http_log_module
    http://tengine.taobao.org/nginx_docs/cn/docs/http/ngx_http_log_module.html

ngx_http_proxy_module
    允许传送请求到其它服务器。
    https://www.jianshu.com/p/18cbef385663

ngx_http_rewrite_module
    模块允许正则替换URI，返回页面重定向，和按条件选择配置
    --todo
    http://tengine.taobao.org/nginx_docs/cn/docs/http/ngx_http_rewrite_module.html

ngx_http_upstream_module
    允许定义一组服务器。它们可以在指令proxy_pass、 fastcgi_pass和 memcached_pass中被引用到
    http://tengine.taobao.org/nginx_docs/cn/docs/http/ngx_http_upstream_module.html