
# MySQL 安装

[TOC]

## Linux安装

https://dev.mysql.com/doc/refman/8.0/en/linux-installation.html

* 使用MySQL APT Repository安装，详细安装步骤参见[官方文档](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/)

* 使用Debian Packages安装[参考](https://dev.mysql.com/doc/refman/8.0/en/linux-installation-debian.html)

* 使用Docker安装，详细安装步骤参见[官方文档](https://dev.mysql.com/doc/refman/5.7/en/linux-installation-docker.html)

### APT Repository 安装

https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#repo-qp-apt-install-from-source

#### 首次安装

1. 添加mysql apt仓库配置

   下载配置deb包
   https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb

2. 执行命令配置

   ``` shell
   sudo dpkg -i mysql-apt-config_0.8.13-1_all.deb
   -> Mysql Server & Cluster
   -> 选择版本
   ->选择OK

   sudo apt-get update
   sudo apt-get install mysql-server

   #查看服务状态：sudo service mysql status
   #停用服务：sudo service mysql stop
   #启用服务：sudo service mysql start
   ```

#### 选择主要发行版本

默认情况下，MySQL服务器和其他必需组件的所有安装和升级都来自于在安装配置包期间选择的主要版本的发行版系列（[请参阅添加MySQL APT存储库](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#apt-repo-setup)）。但是，通过重新配置已安装的配置包，您可以随时切换到另一个受支持的主要发行版系列。使用以下命令：

1. 重新配置 `sudo dpkg-reconfigure mysql-apt-config`

2. 更新apt 仓库  `sudo apt-get update`

3. 升级  `sudo apt-get install mysql-server`

### 使用Debian Packages安装

* 根据MySQL版本和系统信息，下载对应的`DEB Bundle`包。[下载地址](https://downloads.mysql.com/archives/community/)

* 解压`DEB Bundle`包 `tar -xvf mysql-server_MVER-DVER_CPU.deb-bundle.tar`

* 安装必要library

  ```shell
  shell> sudo apt-get install libaio1
  shell> sudo apt-get install libmecab2  # no need if only install client
  ```

* 如果安装MySQL server，按如下顺序安装安装deb包。安装mysql-community-server_*.deb过程中会要提示输入root用户密码

  `sudo dpkg -i mysql-{common,community-client,client,community-server,server}_*.deb`

* 如果只安装MySQL client

  `sudo dpkg -i mysql-{common,community-client,client}_*.deb`

### 配置问题

#### 1. 解决无法使用root本地登录的问题

安装后有可能无法使用root本地登录，进行如下设置

* 添加`skip-grant-tables`到配置文件

  ```shell
  shell> vim /etc/mysql/mysql.conf.d/mysqld.cnf
  # Add skip-grant-tables under [mysqld]
  ```

* 重启MySQL服务 `service mysql restart`

* 此时应该可以本地登录 `mysql -u root -p`

* 重新设置`'root'@'localhost'`密码

  ```mysql
  mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
  mysql> FLUSH PRIVILEGES;
  ```

* 从配置文件里去掉`skip-grant-tables`，然后重启MySQL服务，即可以本地登录。

#### 2. 设置root用户远程登录

* 注释掉配置文件里的`bind-address`

  ```shell
  shell> vim /etc/mysql/mysql.conf.d/mysqld.cnf
  
  #bind-address   = 127.0.0.1 #comment out this line
  ```

* 重启MySQL服务  `service mysql restart`

* 本地登录MySQL，然后添加`'root'@'%'`

    ```mysql
    mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';
    mysql> FLUSH PRIVILEGES;
    ```

* 此时应该能够远程登录 `mysql -h mysql-server-host -u root -p`

### 卸载

  ``` shell
  sudo apt-get autoremove --purge mysql-server
  sudo apt-get remove mysql-server
  sudo apt-get autoremove mysql-server
  sudo apt-get remove mysql-common
  #清理残留数据 dpkg -l |grep mysql|awk '{print $2}' |sudo xargs dpkg -P 
  ```

## Windows安装

图中前者是数据库的，后者是图形化界面的。

百度网盘(MySQL数据库)：http://pan.baidu.com/s/1c2MYA6c 密码：6jb6

**Navicat的安装**

百度网盘(Navicat)：http://pan.baidu.com/s/1slLmmYD 密码：src1

**Workbench**
百度网盘(Workbench)：http://pan.baidu.com/s/1c2ngMIk 密码：6z4e