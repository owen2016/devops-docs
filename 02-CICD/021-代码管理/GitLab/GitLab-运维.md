# Gitlab 运维

## 目录结构

GitLab 根据安装方式不同（源码/包），配置文件存放位置以及结构也有所不同

### 源码编译安装

配置文件在 /home/git/gitlab/config/*

- gitlab.yml - GitLab 配置。
- unicorn.rb - Unicorn web 服务器设置。
- database.yml - 数据库连接设置。
- gitaly.yml - Gitaly 配置.
- gitlab-shell 的配置文件在 /home/git/gitlab-shell/config.yml。

### apt包安装 （ubuntu）

- 主配置文件: /etc/gitlab/gitlab.rb
- GitLab 文档根目录: /opt/gitlab
- 默认存储库位置: /var/opt/gitlab/git-data/repositories
- GitLab Nginx 配置文件路径:  /var/opt/gitlab/nginx/conf/gitlab-http.conf
- Postgresql 数据目录: /var/opt/gitlab/postgresql/data

## 服务管理

gitlab-ctl status

gitlab-ctl start #启动全部服务
gitlab-ctl stop #停止全部服务
gitlab-ctl restart #重启全部服务

重启所有 gitlab gitlab-workhorse 组件：
gitlab-ctl restart  gitlab-workhorse

停止所有 gitlab postgresql 组件：
gitlab-ctl stop postgresql

停止相关数据连接服务
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

gitlab-ctl restart nginx #重启单个服务
gitlab-ctl status #查看全部组件的状态
gitlab-ctl show-config #验证配置文件
gitlab-ctl uninstall #删除gitlab(保留数据）
gitlab-ctl cleanse #删除所有数据，重新开始

gitlab-ctl reconfigure #重新加载配置，每次修改/etc/gitlab/gitlab.rb文件之后执行
gitlab-rails console production #进入控制台 ，可以修改root 的密码

## 备份和还原

如果想备份一台Gitlab的数据，然后还原到另外一台Gitlab，需要保证2台Gitlab的docker镜像版本一致。
如果想安装指定版本的镜像，把latest替换成对应版本镜像的tag。
[Gitlab镜像列表](https://hub.docker.com/r/gitlab/gitlab-ce "Gitlab镜像列表")

- https://docs.gitlab.com/ce/raketasks/backup_restore.html

### 1. 备份Gitlab数据

```shell
# backup
# 备份文件默认放在/data/gitlab/data/backups目录下
docker exec -it gitlab gitlab-rake gitlab:backup:create
```

### 2. 还原Gitlab数据

``` shell
# restore
# 备份文件的名称格式类似 1548058266_2019_01_21_11.4.0_gitlab_backup.tar
# 备份文件编号: 1548058266_2019_01_21_11.4.0
# 如果是在另外一台Gitlab上还原数据，把备份文件拷贝到另外一台Gitlab的/data/gitlab/data/backups目录下

docker exec -it gitlab gitlab-rake gitlab:backup:restore BACKUP=备份文件编号
```

------------

## Gitlab mirror

https://www.jianshu.com/p/70b138f88514
https://github.com/samrocketman/gitlab-mirrors

------------

## 重置Gitlab密码

[如何重置root用户密码](https://docs.gitlab.com/ce/security/reset_root_password.html "如何重置root用户密码")

