# Harbor 升级

**注意：** 不同版本之间升级可能步骤有些差异，需要参考官方文档

- 参考： <https://goharbor.io/docs/2.0.0/administration/upgrade/>

升级主要包括 app instance及其harbor.yml配置，数据库可以考虑提前备份（但非必须，参考官方文档）

## 仅适用于 v1.8.0 -> v1.9.3 版本升级

1. 关闭harbor服务：

    ```shell
    在harbor的所有instance上执行：
        $ cd harbor
        $ sudo docker-compose down
    ```

2. 备份数据和配置：

    2.1  在harbor的所有instance上备份配置

    ```shell
    sudo mkdir -p /backups/harbor
    sudo mv harbor /backups/harbor/harbor-v1.8.0
    ```

    2.2 在harbor的store上备份数据

    ```shell
    sudo mkdir -p /backups/harbor
    sudo cp -rp /data /backups/harbor/
    ```

    2.3 在harbor的db上备份数据库

    ```shell
    sudo mkdir -p /backups/harbor
    sudo pg_dumpall -U postgres -h 192.168.4.238 -p 5432 -f /backups/harbor/dump.sql
    ```

3. 下载harbor v1.9.3：

    ```shell
    在harbor的所有instance上执行：
        $ wget https://github.com/goharbor/harbor/releases/download/v1.9.3/harbor-offline-installer-v1.9.3.tgz
        $ tar zxf harbor-offline-installer-v1.9.3.tgz
    ```

4. 下载harbor迁移工具：

    ```shell
    在harbor的所有instance上执行：
    $ docker pull goharbor/harbor-migrator:v1.9.3
    ```

5. 升级harbor配置文件：

    ```shell
    在harbor的所有instance上执行：
    $ cd harbor
    $ sudo docker run -it --rm \
        -v /backups/harbor/harbor-v1.8.0/harbor.yml:/harbor-migration/harbor-cfg/harbor.yml \
        -v /home/user/harbor/harbor.yml:/harbor-migration/harbor-cfg-out/harbor.yml \
        goharbor/harbor-migrator:v1.9.3 \
        --cfg up
    ```

    删除/注释　harbor.yml文件中redis password配置

6. 启动

    6.1 生成配置

    ```shell
    在harbor的所有instance上执行：
    $ sudo ./prepare
    ```

    6.2 启动服务

    ```shell
    在harbor的所有instance上执行：
    $ sudo docker-compose up -d
    ```
