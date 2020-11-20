# SSH

[TOC]

## SSH 原理

// TODO

## SSH 免密登录

为什么设置免密登录及远程拷贝？

- 方便操作，处理快速；
- 计算机集群中机器之间有频繁的数据交换需求。

设置方法：（假设A、B计算机要进行加密通信）
A计算机root用户的命令行输入ssh-keygen –t rsa，生成密钥对；
若B计算机授权给A免密钥登录B，则将A计算机的公钥放入B计算机的authorized_keys文件中。

通俗理解设置：将计算机的信任关系与人之间的信任关系作类比。张三若信任李四，则表示李四在张三的受信任名单的列表中（类比A计算机的公钥放到B计算机的authorized_keys文件中）。

### 1. 在远程主机安装配置ssh服务

Ubuntu 默认只会安装ssh客户端，不会安装ssh服务器，可通过`sudo dpkg -l | grep ssh` 查看：

#### 安装ssh server

``` shell
sudo apt-get update
sudo apt-get install openssh-server

安装ssh client (若已经安装，可忽略)
sudo apt-get install openssh-client
```

#### 查看ssh service的状态  

`systemctl status ssh`

![Linux-ssh-keygen(免密登录)-7.png](./_images/Linux-ssh-keygen(免密登录)-7.png)

如果不是active(running)的状态，可以通过此命令去启：
`sudo /etc/init.d/ssh start`

查看service进程和监听的端口

`/etc/init.d/ssh status or ps -e | grep ssh`

![Linux-ssh-keygen(免密登录)-8.png](./_images/Linux-ssh-keygen(免密登录)-8.png)

#### 修改sshd_config 配置

`sudo vim /etc/ssh/sshd_config`

修改为如下配置：

![Linux-ssh-keygen(免密登录)-10.png](./_images/Linux-ssh-keygen(免密登录)-10.png)

重启ssh服务

`sudo service ssh restart`

#### 设置远程主机 root密码

ubuntu 默认用户不是root，使用root用户需要先设置root的密码: `sudo passwd root`

此时可以用ssh工具使用密码登录root账号

### 2. 本地机器设置ssh 免密登录远程主机

#### 本地主机生成ssh密钥对

```su root #输入密码登陆
cd ~ #进入到根目录
ssh-keygen -t rsa  
```

一直回车即可

![Linux-ssh-keygen(免密登录)-11.png](./_images/Linux-ssh-keygen(免密登录)-11.png)

#### 复制控制主机SSH密钥到目标主机，开启无密码SSH登录

ssh-copy-id 将本机的公钥复制到远程机器的authorized_keys文件中

`ssh-copy-id  -i ~/.ssh/id_rsa.pub  root@IP`

![Linux-ssh-keygen(免密登录)-1.png](./_images/Linux-ssh-keygen(免密登录)-2.png)  

此时，ssh remote登录到远程机器不用再输入密码

![Linux-ssh-keygen(免密登录)-1.png](./_images/Linux-ssh-keygen(免密登录)-3.png)
