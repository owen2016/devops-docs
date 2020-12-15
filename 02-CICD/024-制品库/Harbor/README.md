# Harbor

[TOC]

Docker容器应用的开发和运行离不开可靠的镜像管理，虽然Docker官方也提供了公共的镜像仓库，但是从安全和效率等方面考虑，部署私有环境内的Registry也是非常必要的。[Harbor](https://goharbor.io/) 是由VMware公司开源的企业级的Docker Registry管理项目，它包括权限管理(RBAC)、LDAP、日志审核、管理界面、自我注册、镜像复制和中文支持等功能。

注： 由于 Harbor 是基于 Docker Registry V2 版本，所以 docker 版本必须 > = 1.10.0 docker-compose >= 1.6.0

Harbor的目标是帮助用户迅速搭建一个企业级的Docker registry服务。它`以Docker公司开源的registry为基础`，额外提供了如下功能:

- 基于角色的访问控制(Role Based Access Control)
- 基于策略的镜像复制(Policy based image replication)
- 镜像的漏洞扫描(Vulnerability Scanning)
- AD/LDAP集成(LDAP/AD support)
- 镜像的删除和空间清理(Image deletion & garbage collection)
- 友好的管理UI(Graphical user portal)
- 审计日志(Audit logging)
- RESTful API
- 部署简单(Easy deployment)

## 架构图

- https://github.com/goharbor/harbor

Harbor的每个组件都是以Docker容器的形式构建的，可以使用Docker Compose来进行部署。如果环境中使用了kubernetes，Harbor也提供了kubernetes的配置文件。

Harbor大概需要以下几个容器组成：ui(Harbor的核心服务)、log(运行着rsyslog的容器，进行日志收集)、mysql(由官方mysql镜像构成的数据库容器)、Nginx(使用Nginx做反向代理)、registry(官方的Docker registry)、adminserver(Harbor的配置数据管理器)、jobservice(Harbor的任务管理服务)、redis(用于存储session)。

Harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，整体架构还是很清晰的。下面借用了网上的架构图:

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201215235908.png)

### Harbor依赖的外部组件

- -> Nginx(即Proxy代理层): Nginx前端代理，主要用于分发前端页面ui访问和镜像上传和下载流量; Harbor的registry,UI,token等服务，通过一个前置的反向代理统一接收浏览器、Docker客户端的请求，并将请求转发给后端不同的服务。

- -> Registry v2: 镜像仓库，负责存储镜像文件; Docker官方镜像仓库, 负责储存Docker镜像，并处理docker push/pull命令。由于我们要对用户进行访问控制，即不同用户对Docker image有不同的读写权限，Registry会指向一个token服务，强制用户的每次docker pull/push请求都要携带一个合法的token, Registry会通过公钥对token进行解密验证。

- -> Database(MySQL或Postgresql)：为core services提供数据库服务，负责储存用户权限、审计日志、Docker image分组信息等数据。

### Harbor自有组件

- -> Core services(Admin Server): 这是Harbor的核心功能，主要提供以下服务：
  - -> UI：提供图形化界面，帮助用户管理registry上的镜像（image）, 并对用户进行授权。
  - -> webhook：为了及时获取registry 上image状态变化的情况， 在Registry上配置webhook，把状态变化传递给UI模块。
  - -> Auth服务：负责根据用户权限给每个docker push/pull命令签发token. Docker 客户端向Regiøstry服务发起的请求,如果不包含token，会被重定向到这里，获得token后再重新向Registry进行请求。
  - -> API: 提供Harbor RESTful API
- -> Replication Job Service：提供多个 Harbor 实例之间的镜像同步功能。
- -> Log collector：为了帮助监控Harbor运行，负责收集其他组件的log，供日后进行分析。

## 核心组件

- Proxy：一个nginx的前端代理，代理Harbor的registry,UI, token等服务。-通过深蓝色先标识
- db：负责储存用户权限、审计日志、Dockerimage分组信息等数据。
- UI：提供图形化界面，帮助用户管理registry上的镜像, 并对用户进行授权。
- jobsevice：jobsevice是负责镜像复制工作的，他和registry通信，从一个registry pull镜像然后push到另一个registry，并记录job_log。通过紫色线标识
- Adminserver：是系统的配置管理中心附带检查存储用量，ui和jobserver启动时候回需要加载adminserver的配置。通过灰色线标识；
- Registry：镜像仓库，负责存储镜像文件。当镜像上传完毕后通过hook通知ui创建repository，上图通过红色线标识，当然registry的token认证也是通过ui组件完成。通过红色线标识
- Log：为了帮助监控Harbor运行，负责收集其他组件的log，供日后进行分析。过docker的log-driver把日志汇总到一起，通过浅蓝色线条标识

    ![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201215235702.png)
