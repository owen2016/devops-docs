# Harbor 维护

## 修改数据存储目录

根据实际修改harbor数据存储目录，文件路径为`${Harbor_Home}/docker-compose.yml`, 修改容器挂载目录

## Harbor 磁盘清理

1. 登录到harbor admin管理界面,清除多余镜像tag

2. 登录到harbor服务宿主机器执行命令：

    ```text
    # 垃圾回收
    docker exec -it registry registry garbage-collect  /etc/registry/config.yml
    ```

## 访问Harbor数据库

https://blog.csdn.net/qq_41980563/article/details/90633742

１．进入容器

２．连接数据库
        # psql -U postgres -h postgresql -p 5432

３．选择数据库
        # \c registry

4. 查看数据
        # select * from harbor_user;

        # select * from role;

５．其他
        退出：　\q
        列出所有数据库：　\l