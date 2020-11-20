# Docker

[TOC]

## 为什么要使用容器

[Docker](https://docs.docker.com/get-started/) 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。

![](https://gitee.com/owen2016/pic-hub/raw/master/pics/20201026231615.png)

1. 传统的应用部署方式是所有应用共享一个底层操作系统，这样做不利于应用的升级更新和回滚，虽然可以通过创建虚拟机来实现隔离，但是虚拟机非常的重，不利于移植

2. 新的部署方式采用容器，每个容器之间互相隔离，每个容器有自己的文件系统，容器之间进程不会相互影响，能区分计算资源。相对于虚拟机，容器能快速部署，由于容器与底层设施、机器文件系统解耦的，所以它能在不同云、不同版本操作系统间进行迁移。

## 知识点

按照以下知识点学习，可快速掌握基本Docker操作

- Docker 核心概念
- Docker 架构
- 容器 VS 虚拟机
- 应用场景
- Docker 安装
- 镜像管理
- 容器管理
- 四种网络模式
- 数据持久化
- Dockerfile 制作镜像
- 企业级 Harbor镜像仓库

## 安装

### 0. Uninstall old versions

Older versions of Docker were called docker or docker-engine. If these are installed, uninstall them:

`sudo apt-get remove docker docker-engine docker.io`

### 1. Set up the repository

```shell
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL hhttp://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

### 2. INSTALL DOCKER CE

``` shell
sudo apt-get update
sudo apt-get install docker-ce
sudo apt-get -y install docker-ce=[VERSION]  # 安装指定版本

```

### 3. Manage Docker as a non-root user

- Create the docker group. `$ sudo groupadd docker`

- Add your user to the docker group. `$ sudo usermod -aG docker $USER`

### 4. 配置镜像加速

<https://cr.console.aliyun.com/>

``` shell
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://qku911ov.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## 安装 docker-compose

[Docker Compose](https://docs.docker.com/compose/overview/)是一个用来定义和运行复杂应用的Docker工具。

- 执行如下命令安装docker-compose

``` bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```
