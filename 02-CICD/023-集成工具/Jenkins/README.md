# Jenkins

[TOC]

[Jenkins](https://jenkins.io/doc/) 是一个独立的开源自动化服务器，可以用来自动化与构建、测试、交付或部署软件相关的所有任务。

## Jenkins 安装

- https://jenkins.io/doc/　－＞　https://jenkins.io/doc/book/installing/

### 环境准备 - JDK 安装

**注意:** 如果将Jenkins作为Docker 容器运行，这不是必需的

Jenkins依赖java环境， 请先确保java环境已安装好， java安装流程如下：

- 下载jdk8 tar.gz包从[jdk download page](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

- 解压tar.gz包

- 配置环境变量`JAVA_HOME`, `JRE_HOME`，`CLASSPATH`， `PATH`

- 检查是否安装成功:  `java & javac`

    ```shell
    sudo wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz

    tar -zxvf ${your_download_path}/jdk-8u191-linux-x64.tar.gz

    mv ${your_download_path}/jdk1.8.0_191 /usr/local/

    ```

    ```bash
    vim /etc/profile
    # 在文件末尾加上下面内容:
    export JAVA_HOME="/usr/local/jdk1.8.0_191"
    export PATH=$PATH:$JAVA_HOME/bin
    ```

- 使环境变量生效:

    ```bash
    source /etc/profile
    ```

### 1. APT 安装

- https://pkg.jenkins.io/debian/

**安装步骤**

``` shell
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

#可选：设置指定版本
sudo apt-get install jenkins=2.138.1

# 修改jenkins配置`/etc/default/jenkins`
vim /etc/default/jenkins

#配置jenkins运行用户以及用户组：
JENKINS_USER=root
JENKINS_GROUP=root

# 重启 jenkins
systemctl restart jenkins
```

### 2. WAR包方式运行

１．安装前准备 Java 8 (either a JRE or Java Development Kit (JDK) is fine)

２．下载：http://mirrors.jenkins.io/war-stable/latest/jenkins.war

３．执行命令  `java -jar jenkins.war --httpPort=8080`

４．浏览器打开http://localhost:8080

### 3.Docker 方式运行

``` shell
sudo docker run \
-u root \
--rm \
-d \
-p 8080:8080 \
-p 50000:50000 \
-v jenkins-data:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
jenkinsci/blueocean
```

初始化密码存储目录  `/var/jenkins_home/secrets/initialAdminPassword`

## Jenkins 目录结构

- Executable-war： `/usr/lib/jenkins/jenkins.war`

- JENKINS_HOME: `/var/lib/jenkins`

即为Jenkins的安装目录,可以在Jenkins页面中得到，Jenkins->系统管理-> 系统设置

``` text
 +- config.xml     (jenkins root configuration)
 +- *.xml          (other site-wide configuration files)
 +- userContent    (files in this directory will be served under your http://server/userContent/) 
 +- fingerprints   (stores fingerprint records)
 +- plugins        (stores plugins)
 +- jobs
     +- [JOBNAME]      (sub directory for each job)
         +- config.xml     (job configuration file)
         +- workspace      (working directory for the version control system)
         +- latest         (symbolic link to the last successful build)
         +- builds
             +- [BUILD_ID]     (for each build)
                 +- build.xml      (build result summary)
                 +- log            (log file)
                 +- changelog.xml  (change log)
```

如果有权限管理，则在HOME目录下还会有users目录。

其中config.xml是Jenkins重要的配置文件。我们都知道Jenkins用于monitor多个build，而jobs这个目录就是存储每个build相关信息的地方。