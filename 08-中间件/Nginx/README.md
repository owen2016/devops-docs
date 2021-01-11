# Nginx

[TOC]

Nginx中文文档 - https://www.nginx.cn/doc/

Nginx ("engine x") 是一个高性能的 HTTP 和 反向代理 服务器，也是一个 IMAP/POP3/SMTP 代理服务器。 Nginx 是由 Igor Sysoev 为俄罗斯访问量第二的 Rambler.ru 站点开发的，第一个公开版本0.1.0发布于2004年10月4日。其将源代码以类BSD许可证的形式发布，因它的稳定性、丰富的功能集、示例配置文件和低系统资源的消耗而闻名。

Nginx 解决了服务器的C10K（就是在一秒之内连接客户端的数目为10k即1万）问题。它的设计不像传统的服务器那样使用线程处理请求，而是一个更加高级的机制—`事件驱动机制`，是一种异步事件驱动结构。它可以轻松在百万并发连接下实现高吞吐量的Web服务，同时诸多应用场景下的问题都可以通过种种Nginx模块得以解决，而我们所需的工作量也并不大

![](https://gitee.com/owen2016/pic-hub/raw/master/1610378133_20200624150926016_509393060.png)

## Nginx 特点

- 高并发请求的同时保持高效的服务
- 热部署
- 低内存消耗/很高的可靠性
- 处理响应请求很快
- 非阻塞、高并发连接-IO多路复用epoll（IO复用）
- 轻量级
  - 功能模块少 - Nginx仅保留了HTTP需要的模块，其他都用插件的方式，后天添加
  - 代码模块化 - 更适合二次开发，如阿里巴巴Tengine

- CPU亲和
  - 把CPU核心和Nginx工作进程绑定，把每个worker进程固定在一个CPU上执行，减少切换CPU的cache miss，从而提高性能。

- Nginx接收用户请求是异步的，即先将用户请求全部接收下来，再一次性发送到后端Web服务器，极大减轻后端Web服务器的压力。
- 支持内置服务器检测。Nginx能够根据应用服务器处理页面返回的状态码、超时信息等检测服务器是否出现故障，并及时返回错误的请求重新提交到其它节点上
- 采用Master/worker多进程工作模式

## Nginx 基本功能

Nginx的功能包括基本HTTP功能和扩展功能。和Apache服务器一样，Nginx服务器为了提供更多的功能并且能够有效地扩展这些功能。每一个模块都提供了一个功能，通过编译这些功能模块来实现功能的扩展

1. 基本HTTP功能

a）提供静态文件和index文件，处理静态文件，索引文件以及自动索引，打开文件描述符缓存；
b）使用缓存加速反向代理，反向代理加速（无缓存），简单的负载均衡和容错；
c）使用缓存机制加速远程FastCGI，简单的负载均衡和容错；
d）模块化的结构。过滤器包括gzipping,byte ranges,chunked responses，以及 SSI-filter。在SSI过滤器中，到同一个 proxy 或者 FastCGI 的多个子请求并发处理；
e）支持SSL 和 TLS SNI 支持；
f）IMAP/POP3代理服务功能；
g）使用外部 HTTP 认证服务器重定向用户到 IMAP/POP3 后端；
h）使用外部 HTTP 认证服务器认证用户后连接重定向到内部的 SMTP 后端；

2. 其他HTTP功能
a）基于名称和基于IP的虚拟服务器；
b）支持Keep-alive和管道连接；
c）灵活的配置和重新配置、在线升级的时候不用中断客户访问的处理；
d）访问日志的格式，缓存日志写入和快速日志轮循；
e）3xx-5xx错误代码重定向；
f）速度限制

## Nginx 使用场景

- 搭建静态资源服务器
- 反向代理分发后端服务（可以和nodejs搭配实现前后端分离）和跨域问题
- 根据User Agent来重定向站点
- 开发环境或测试环境切换（切换host）
- url重写，使用rewrie规则本地映射
- 资源内容篡改
- 获取cookie做分流
- 资源合并
- gzip压缩
- 压缩图片
- sourceMap调试

![](https://cdn.devopsing.site/2020/20210112000306.jpeg)

## Nginx 安装/卸载

下载地址：http://nginx.org/en/download.html

### Docker 方式运行

`docker run --name nginx -p 8080:80 -d nginx`

### Ubuntu上安装

- http://nginx.org/en/linux_packages.html#Ubuntu

``` shell
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:nginx/stable 
sudo apt-get update
sudo apt-get install nginx
```

安装完成后，检查Nginx服务的状态`sudo systemctl status nginx`  和 版本`nginx -V`

访问：http://localhost

![](https://cdn.devopsing.site/2020/20210112000843.png)

启动时候若显示端口80被占用： `Starting nginx: [emerg]: bind() to 0.0.0.0:80 failed (98: Address already in use)，`
修改文件：/etc/nginx/sites-available/default,把 listen 后面的 80 端口号改为自己的端口，访问是需要添加端口号。
安装完后如出现403错误，那可能是nginx配置文件里的网站路径不正确

### 卸载Nginx

``` shell
sudo apt-get remove nginx nginx-common # 卸载删除除了配置文件以外的所有文件。
sudo apt-get purge nginx nginx-common # 卸载所有东东，包括删除配置文件。
sudo apt-get autoremove # 在上面命令结束后执行，主要是卸载删除Nginx的不再被使用的依赖包。
sudo apt-get remove nginx-full nginx-common #卸载删除两个主要的包。
```

## Nginx 命令

```shell
- sudo nginx #打开 nginx
- nginx -s reload|reopen|stop|quit #重新加载配置|重启|停止|退出 nginx
- nginx -t #测试配置是否有语法错误

nginx [-?hvVtq] [-s signal] [-c filename] [-p prefix] [-g directives]

-?,-h : 打开帮助信息
-v : 显示版本信息并退出
-V : 显示版本和配置选项信息，然后退出
-t : 检测配置文件是否有语法错误，然后退出
-q : 在检测配置文件期间屏蔽非错误信息
-s signal : 给一个 nginx 主进程发送信号：stop（停止）, quit（退出）, reopen（重启）, reload（重新加载配置文件）
-p prefix : 设置前缀路径（默认是：/usr/local/Cellar/nginx/1.2.6/）
-c filename : 设置配置文件（默认是：/usr/local/etc/nginx/nginx.conf）
-g directives : 设置配置文件外的全局指令
```

验证配置是否正确: nginx -t
配置文件修改重装载命令：nginx -s reload

停止nginx: `sudo systemctl stop nginx`

启动nginx: `sudo systemctl start nginx`

默认，nginx是随着系统启动的时候自动运行，`sudo systemctl disable nginx`可以禁止nginx开机启动.

重新配置nginx开机自动启动: `sudo systemctl enable nginx`

重启nginx: `sudo systemctl restart nginx` 

平滑加载配置(不会断开用户访问）：`sudo systemctl reload nginx`

- reload，重新加载的意思，reload会重新加载配置文件，nginx服务不会中断，而且reload时会测试conf语法等，如果出错会rollback用上一次正确配置文件保持正常运行。
- restart，重启，会重启nginx服务。这个重启会造成服务一瞬间的中断，当然如果配置文件出错会导致服务启动失败，那就是更长时间的服务中断了。

## Nginx 目录结构

网站文件位置

- /var/www/html: 网站文件存放的地方, 默认只有我们上面看到nginx页面，可以通过改变nginx配置文件的方式来修改这个位置。

服务器配置

- /etc/nginx: nginx配置文件目录。所有的nginx配置文件都在这里。
- /etc/nginx/nginx.conf: Nginx的主配置文件. 可以修改他来改变nginx的全局配置。
- /etc/nginx/sites-available/: 这个目录存储每一个网站的"server blocks"。nginx通常不会使用这些配置，除非它们陪连接到  sites-enabled 目录 (see below)。一般所有的server block 配置都在这个目录中设置，然后软连接到别的目录 。
- /etc/nginx/sites-enabled/: 这个目录存储生效的 "server blocks" 配置. 通常,这个配置都是链接到 sites-available目录中的配置文件
- /etc/nginx/snippets: 这个目录主要可以包含在其它nginx配置文件中的配置片段。重复的配置都可以重构为配置片段。

日志文件

- /var/log/nginx/access.log: 每一个访问请求都会记录在这个文件中，除非你做了其它设置
- /var/log/nginx/error.log: 任何Nginx的错误信息都会记录到这个文件中

## Nginx热部署

所谓热部署，就是配置文件nginx.conf修改后，不需要stop Nginx，不需要中断请求，就能让配置文件生效！（nginx -s reload 重新加载/nginx -t检查配置/nginx -s stop）

通过上文我们已经知道worker进程负责处理具体的请求，那么如果想达到热部署的效果，可以想象：

**方案一：** 修改配置文件nginx.conf后，主进程master负责推送给woker进程更新配置信息，woker进程收到信息后，更新进程内部的线程信息。（有点valatile的味道）

**方案二：** 修改配置文件nginx.conf后，重新生成新的worker进程，当然会以新的配置进行处理请求，而且新的请求必须都交给新的worker进程，至于老的worker进程，等把那些以前的请求处理完毕后，kill掉即可。

Nginx采用的就是方案二来达到热部署的！

## Nginx 运行原理
### Master-Worker模式

![](https://gitee.com/owen2016/pic-hub/raw/master/1610378134_20200624162443069_232260949.png)

启动Nginx后，其实就是在80端口启动了Socket服务进行监听，如图所示，Nginx涉及Master进程和Worker进程

![](https://gitee.com/owen2016/pic-hub/raw/master/1610378134_20200624162509036_171276403.png)

Master进程的作用是？

- 读取并验证配置文件nginx.conf；管理worker进程；

Worker进程的作用是？

- 每一个Worker进程都维护一个线程（避免线程切换），处理连接和请求；注意Worker进程的个数由配置文件决定，一般和CPU个数相关（有利于进程切换），配置几个就有几个Worker进程。

首先，Nginx在启动时，会解析配置文件，得到需要监听的端口与IP地址，然后在Nginx的master进程里面，先初始化好这个监控的socket(创建socket，设置addrreuse等选项，绑定到指定的IP地址端口，再listen)，然后再fork(一个现有进程可以调用fork函数创建一个新进程。由fork创建的新进程被称为子进程 )出多个子进程出来，然后子进程会竞争accept新的连接。

此时，客户端就可以向Nginx发起连接了。当客户端与Nginx进行三次握手，与Nginx建立好一个连接后，某一个子进程会accept成功，得到这个建立好的连接的socket，然后创建Nginx对连接的封装，即ngx_connection_t结构体。

接着，设置读写事件处理函数并添加读写事件来与客户端进行数据的交换。最后，Nginx或客户端来主动关掉连接

### Nginx如何做到高并发下的高效处理？

上文已经提及Nginx的worker进程个数与CPU绑定、worker进程内部包含一个线程高效回环处理请求，这的确有助于效率，但这是不够的。

作为专业的程序员，我们可以开一下脑洞：BIO/NIO/AIO、异步/同步、阻塞/非阻塞...

要同时处理那么多的请求，要知道，有的请求需要发生IO，可能需要很长时间，如果等着它，就会拖慢worker的处理速度。

Nginx采用了Linux的**epoll模型**，epoll模型基于事件驱动机制，它可以监控多个事件是否准备完毕，如果OK，那么放入epoll队列中，这个过程是异步的。worker只需要从epoll队列循环处理即可。

## Nginx 高可用

Nginx既然作为入口网关，很重要，如果出现单点问题，显然是不可接受的。

答案是：**Keepalived+Nginx**实现高可用。

Keepalived是一个高可用解决方案，主要是用来防止服务器单点发生故障，可以通过和Nginx配合来实现Web服务的高可用。（其实，Keepalived不仅仅可以和Nginx配合，还可以和很多其他服务配合）

Keepalived+Nginx实现高可用的思路：
第一：请求不要直接打到Nginx上，应该先通过Keepalived（这就是所谓虚拟IP，VIP）
第二：Keepalived应该能监控Nginx的生命状态（提供一个用户自定义的脚本，定期检查Nginx进程状态，进行权重变化,，从而实现Nginx故障切换）

![](https://gitee.com/owen2016/pic-hub/raw/master/1610378135_20200624172822781_380420450.png)