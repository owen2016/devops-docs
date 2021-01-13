# Jenkins 备份

## Jenkins 目录结构

- Executable-war： `/usr/lib/jenkins/jenkins.war`

- JENKINS_HOME: `/var/lib/jenkins`

即为Jenkins的安装目录,可以在Jenkins页面中得到，Jenkins->系统管理-> 系统设置

``` shell
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

## 

jenkins 主要备份 JENKINS_HOME （/var/lib/jenkins）

   ![thinBackup](./_images/jenkins-thinBackup.png)

采用cron定时备份  - <https://crontab.guru/examples.html>

备份路径: /mnt/jenkins-bak

   ![jenkins-backup](./_images/jenkins-backup.JPG)
