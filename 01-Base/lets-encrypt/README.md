# Let’s Encrypt

[TOC]

- https://letsencrypt.org/zh-cn/docs/

Let’s Encrypt是一个由非营利性组织互联网安全研究小组（ISRG）提供的免费、自动化和开放的证书颁发机构（CA）。
简单的说，借助Let’s Encrypt颁发的证书可以为我们的网站免费启用HTTPS(SSL/TLS)

## 客户端

Let’s Encrypt 使用 ACME 协议来验证您对给定域名的控制权并向您颁发证书。要获得 Let’s Encrypt 证书，您需要选择一个要使用的 ACME 客户端软件。Let’s Encrypt 不控制或审查第三方客户端，也不能保证其安全性或可靠性。

官方提供了几种证书的申请方式方法

- https://letsencrypt.org/zh-cn/docs/client-options/

### certbot

它既可以仅为您获取证书，也可以帮助您安装证书（如果您需要的话）。它易于使用，适用于许多操作系统，并且具有出色的文档。

https://certbot.eff.org/

### acme.sh

目前 Let's Encrypt 免费证书客户端最简单、最智能的 shell 脚本，可以自动发布和续订 Let's Encrypt 中的免费证书

- https://github.com/acmesh-official/acme.sh

## 安装acme.sh

1. 手动安装

    ``` shell
    git clone https://github.com/acmesh-official/acme.sh.git
    cd ./acme.sh
    ./acme.sh --install

    #默认安装在 ~/.acme.sh/ 目录下，按照域名为文件夹存放。

    # 测试收否安装成功
    user@owen-ubuntu:~$ acme.sh --version
    https://github.com/acmesh-official/acme.sh
    v2.8.8

    #创建指令： alias acme.sh=~/.acme.sh/acme.sh
    ```

    ![acme-install](./images/acme-install.png)

2. 创建cronjob，检测证书过期

``` shell
#每天 0:00 点自动检测所有的证书, 如果快过期了, 需要更新, 则会自动更新证书
0 0 * * * /root/.acme.sh/acme.sh --cron --home /root/.acme.sh > /dev/null
```

## 使用acme.sh生成证书

### HTTP 方式

http 方式需要在你的网站根目录下放置一个文件, 以此来验证你的域名所有权,完成验证，只需要指定域名, 并指定域名所在的网站根目录，acme.sh 会全自动的生成验证文件, 并放到网站的根目录, 然后自动完成验证，该方式较适合独立域名的站点使用，比如博客站点等

``` shell
./acme.sh  --issue  -d mydomain.com -d www.mydomain.com  --webroot  /home/wwwroot/mydomain.com/

- issue是acme.sh脚本用来颁发证书的指令；
- d是–domain的简称，其后面须填写已备案的域名；
- w是–webroot的简称，其后面须填写网站的根目录。
```

**示例：**

``` shell
./acme.sh  --issue  -d devopsing.site -d www.devopsing.site  --webroot  /var/www/html/blog/

#执行成功，默认为生成如下证书：
root@ecs-ubuntu18:/etc/nginx/sites-available# ls ~/.acme.sh/devopsing.site/ -l
total 28
-rw-r--r-- 1 root root 1587 Dec 16 12:34 ca.cer
-rw-r--r-- 1 root root 1866 Dec 16 12:34 devopsing.site.cer
-rw-r--r-- 1 root root  642 Dec 16 12:34 devopsing.site.conf
-rw-r--r-- 1 root root 1001 Dec 16 12:33 devopsing.site.csr
-rw-r--r-- 1 root root  232 Dec 16 12:33 devopsing.site.csr.conf
-rw-r--r-- 1 root root 1679 Dec 16 12:33 devopsing.site.key
-rw-r--r-- 1 root root 3453 Dec 16 12:34 fullchain.cer
```

如果用的apache/nginx服务器, acme.sh 还可以智能的从 nginx的配置中自动完成验证, 不需要指定网站根目录:

`acme.sh --issue  -d mydomain.com   --apache`

`acme.sh --issue  -d mydomain.com   --nginx`

查看安装证书

``` shell
root@ecs-ubuntu18:/home/user/acme.sh# ./acme.sh list
Main_Domain     KeyLength  SAN_Domains         CA               Created                       Renew
devopsing.site  ""         www.devopsing.site  LetsEncrypt.org  Wed Dec 16 04:34:15 UTC 2020  Sun Feb 14 04:34:15 UTC 2021
```

### DNS 方式

适合用于生成范解析证书

优势：不需要任何服务器, 不需要任何公网 ip, 只需要 dns 的解析记录即可完成验证
劣势：如果不同时配置 Automatic DNS API，使用这种方式 acme.sh 将无法自动更新证书，每次都需要手动再次重新解析验证域名所有权

1. 生成证书记录

注意，第一次执行时使用 --issue，-d 指定需要生成证书的域名

`./acme.sh --issue -d *.example.com  --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please`

`./acme.sh --issue -d *.devopsing.site  --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please`

2. 在域名解析中添加TXT记录

3. 重新生成证书

注意，这里第二次执行是用的是 --renew

`./acme.sh --renew -d *.example.com  --yes-I-know-dns-manual-mode-enough-go-ahead-please`

`./acme.sh --renew  --force  -d *.example.com  --yes-I-know-dns-manual-mode-enough-go-ahead-please`

### 使用dns api的模式进行证书申请

获取AccessKey ID和AccessKey Secret

``` shell
export Ali_Key="key值"
export Ali_Secret="key Secret"

# 下次就不用再次执行这个命令了
acme.sh --issue --dns dns_ali -d *.example.com --force
```

``` shell
root@ecs-ubuntu18:/var/log/nginx# ls ~/.acme.sh/\*.devopsing.site/ -l
total 28
-rw-r--r-- 1 root root 1587 Dec 16 16:09  ca.cer
-rw-r--r-- 1 root root 1846 Dec 16 16:09 '*.devopsing.site.cer'
-rw-r--r-- 1 root root  613 Dec 16 16:09 '*.devopsing.site.conf'
-rw-r--r-- 1 root root  980 Dec 16 16:09 '*.devopsing.site.csr'
-rw-r--r-- 1 root root  211 Dec 16 16:09 '*.devopsing.site.csr.conf'
-rw-r--r-- 1 root root 1679 Dec 16 16:04 '*.devopsing.site.key'
-rw-r--r-- 1 root root 3433 Dec 16 16:09  fullchain.cer
```

## 使用acme.sh安装证书

### Nginx 配置

``` shell
acme.sh --installcert -d <domain>.com \
--key-file /etc/nginx/ssl/<domain>.key \
--fullchain-file /etc/nginx/ssl/fullchain.cer \
--reloadcmd "service nginx force-reload"
```

``` shell
acme.sh --installcert -d *.devopsing.site \
--key-file /etc/nginx/ssl/*.devopsing.site.key \
--fullchain-file /etc/nginx/ssl/fullchain.cer \
--reloadcmd "service nginx force-reload"
```

通过 installcert 来完成安装，此处我们需要把*.key,fullchain.cer 文件拷贝到指定位置。最后通过reload命令让Nginx重载

Nginx 的配置 ssl_certificate 使用 /etc/nginx/ssl/fullchain.cer ，而非 /etc/nginx/ssl/<domain>.cer ，否则 SSL Labs 的测试会报 Chain issues Incomplete 错误

``` conf
server {
        listen 443 ssl;
        server_name demo.com;
        
        ssl on;
        ssl_certificate      /etc/nginx/ssl/fullchain.cer;
        ssl_certificate_key  /etc/nginx/ssl/<domain>.key;
```

## acme.sh的更新维护

acme 协议和 letsencrypt CA 都在频繁的更新, 因此 acme.sh 也经常更新以保持同步。

手动更新： acme.sh --upgrade

自动更新：acme.sh --upgrade --auto-upgrade

取消自动更新： acme.sh --upgrade --auto-upgrade 0