# Harbor 安装/配置

[TOC]

## 安装

[Installation and Configuration Guide](https://goharbor.io/docs/2.1.0/)

### 1. 下载离线安装包

- Harbor以容器的形式进行部署, 因此可以被部署到任何支持Docker的Linux发行版, 要使用Harbor，需要安装docker和docker-compose编排工具
- 访问[harbor release page](https://github.com/goharbor/harbor/releases)，下载Harbor软件tgz压缩包
- 或执行如下命令 `wget https://storage.googleapis.com/harbor-releases/release-2.0.0/harbor-offline-installer-latest.tgz`

- 解压tgz压缩包
  
    `tar xvf harbor-offline-installer-<version>.tgz`

### 2. 配置 harbor.cfg （harbor.yml）

注： 新版本是.yaml文件，之前版本是.conf 或者 .cfg文件

- 解压后文件在当前目录下的`harbor/`目录下

    ``` shell
    cd harbor/
    vim harbor.cfg
    harbor_admin_password = Harbor12345
    ```

### 3. 启动 Harbor

- 配置完后，执行安装脚本 `./install.sh`

    ``` shell
    #会拉取好几个镜像下来，及检查环境
    Note: docker version: 1.12.5
    Note: docker-compose version: 1.9.0

    [Step 0]: checking installation environment ...
    ....
    [Step 1]: loading Harbor images ...
    ....
    [Step 2]: preparing environment ...
    ....
    [Step 3]: checking existing instance of Harbor ...
    ....
    [Step 4]: starting Harbor ...
    ✔ ----Harbor has been installed and started successfully.----
    ...
    For more details, please visit https://github.com/vmware/harbor .
    ```

    安装完成后，会发现解压目录harbor下面多了一个docker-compose.yml文件，里面包含了harbor依赖的镜像和对应容器创建的信息

- 执行 docker-compose ps (执行docker-compose需在包含docker-compose.yml的目录) , 确保 container 的状态都是up (healthy).

- 如果安装一切顺利，通过之前在harbor.cfg配置的hostname即可以访问到前端了.

## 安装配置问题

Harbor安装 之后，需要用`docker-compose ps` 命令去查看状态，保证所有docker 容器都是 healthy, 否则 很可能login harbor 失败

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201215230145.png)

如果那个service 启动不正常，就去查看/var/log/harbor/ 下对应的log

``` shell
owen@swarm-node-107:/disk/harbor_v2.0.0$ ls /var/log/harbor/ -lht
总用量 22M
-rw-r--r-- 1 10000 10000 3.5M 12月 15 23:03 registryctl.log
-rw-r--r-- 1 10000 10000 5.4M 12月 15 23:02 core.log
-rw-r--r-- 1 10000 10000 4.4M 12月 15 23:02 portal.log
-rw-r--r-- 1 10000 10000 4.9M 12月 15 23:02 registry.log
-rw-r--r-- 1 10000 10000 1.2M 12月 15 23:02 proxy.log
-rw-r--r-- 1 10000 10000 392K 12月 15 23:00 redis.log
-rw-r--r-- 1 10000 10000 1.6M 12月 15 23:00 jobservice.log
-rw-r--r-- 1 10000 10000  53K 12月 14 21:42 postgresql.log
-rw-r--r-- 1 10000 10000  65K 7月   7 23:35 clair.log
-rw-r--r-- 1 10000 10000 1.2K 7月   5 11:43 clair-adapter.log
-rw-r--r-- 1 10000 10000 1.4K 7月   5 11:38 chartmuseum.log
```

修改harbor的运行配置，需要如下步骤：

``` shell
# 停止 harbor
 docker-compose down -v
# 修改配置
 vim harbor.cfg
# 执行./prepare已更新配置到docker-compose.yml文件
 ./prepare
# 启动 harbor
 docker-compose up -d
```

### 问题-1 服务启动异常

ubuntu@172-20-16-51:/opt/harbor$ docker login 192.20.16.51
Username: admin
Password:
Error response from daemon: login attempt to <http://192.20.16.51/v2/> failed with status: 502 Bad Gateway

Harbor-db  service 不能正常启动，最后查看postgresql.log 发现下面 message.

```text
 | initdb: directory "/var/lib/postgresql/data" exists but is not empty
 | If you want to create a new database system, either remove or empty
 | the directory "/var/lib/postgresql/data" or run initdb
 | with an argument other than "/var/lib/postgresql/data".
```

因为当时/data/datebase  目录下，确实不是empty, 手动改了docker-compose.yml ，然后 `docker-compose up -d` 重新启动容器，服务正常

```yaml
  postgresql:
    image: goharbor/harbor-db:v2.0.0
    container_name: harbor-db
    restart: always
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
    volumes:
      - /data/database:/var/lib/postgresql/data:z
```

### 问题-2- dial tcp xxx.xxx.xxx.xxx:443: connect: connection refused

```shell
# docker login 192.20.16.51:80
Username: admin
Password:
Error response from daemon: Get https://192.20.16.51:80/v2/: http: server gave HTTP response to HTTPS client
或者
Error response from daemon: Get https://192.168.31.107/v2/: dial tcp 192.168.31.107:443: connect: connection refused
```

docker1.3.2版本开始默认docker registry使用的是https，·Harbor默认安装使用的是HTTP协议·，所以当执行用docker login、pull、push等命令操作`非https的docker regsitry`的时就会报错。

临时解决办法：需要在每一台harbor客户端机器都要设置"insecure-registries" (**彻底解决需要启动Harbor HTTPS证书**)

- 如果系统是MacOS，则可以点击“Preference”里面的“Advanced”在“Insecure Registry”里加上hostname (e.g. docker.bksx.com)，重启Docker客户端就可以了。

- 如果系统是`Ubuntu`，则修改配置文件`/lib/systemd/system/docker.service`，修改[Service]下ExecStart参数，增加`–insecure-registry hostname` (e.g. docker.bksx.com)

- 如果系统是`Centos`，可以修改配置`/etc/sysconfig/docker`，将OPTIONS增加 `–insecure-registry hostname` (e.g. docker.bksx.com)

如果是新版本的docker在/etc/sysconfig/ 没有docker这个配置文件的情况下。

```shell
#在daemon.json中添加以下参数
[root@localhost harbor]# cat /etc/docker/daemon.json
{
  "insecure-registries": [
    "hostname"
  ]
}
```

注意：该文件必须符合 json 规范，否则 Docker 将不能启动。另外hostname 必须与harbor.cfg 里的hostname 一致。

添加完了后重新启动 docker：`systemctl daemon-reload && systemctl enable docker && systemctl restart docker`

登录后，账号信息都保存到本机的`~/.docker/config.json`

``` shell
owen@swarm-manager-105:~/gitee/vnote_notebooks$ docker login 192.168.31.107
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /home/owen/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
owen@swarm-manager-105:~/gitee/vnote_notebooks$ cat ~/.docker/config.json 
{
	"auths": {
		"192.168.31.107": {
			"auth": "YWRtaW46SGFyYm9yMTIzNDU="
		}
	},
	"HttpHeaders": {
		"User-Agent": "Docker-Client/19.03.14 (linux)"
	}

```

### 问题-3 防止容器进程没有权限读取生成的配置

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201215232916.png)