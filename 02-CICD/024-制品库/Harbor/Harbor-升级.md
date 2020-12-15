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

## 仅适用于 v1.6.0 -> v1.8.0 版本升级

https://stephenzhou.net/2019/06/04/harbor-upgrade/

由于harbor从v1.6.0版本开始，后端数据库由MariaDB改为Postgresql，所以在升级过程中，必须先升级到v1.6.0版本，再升级至v1.8.0

1. 关闭harbor服务：
    cd /home/user/Documents/harbor
    sudo docker-compose down

2. 备份harbor程序以及数据库文件：
    cd ..
    mv harbor harbor.bak.v1.7
    cp -rf /data/database /data/database.bak.v1.7.0

3. 下载harbor v1.8.0：
    wget https://storage.googleapis.com/harbor-releases/release-1.8.0/harbor-offline-installer-v1.8.0.tgz
    tar zxf harbor-offline-installer-v1.8.0.tgz

4. 下载harbor迁移工具：
    `docker pull goharbor/harbor-migrator:v1.8.0`

5. 升级harbor配置文件，也即harbor.cfg到harbor.yml：

    ```shell
    cd harbor
    cp harbor.yml harbor.yml.src
    docker run -it \
    --rm \
    -v /home/user/Documents/harbor.bak.v1.7.0/harbor.cfg:/harbor-migration/harbor-cfg/harbor.cfg \
    -v /home/user/Documents/harbor/harbor.yml:/harbor-migration/harbor-cfg-out/harbor.yml \
    goharbor/harbor-migrator:v1.8.0 \
    --cfg up
    ```

6. 部署harbor应用，启动harbor：

    ```shell
    mkdir cert
    wget ftp://xxx:xxx@x.x.x.x/cert/_.yeshj.com.crt -P /usr/local/src/harbor/cert/
    wget ftp://xxx:xxx@x.x.x.x/cert/_.yeshj.com.key -P /usr/local/src/harbor/cert/
    sudo ./install.sh
    ```