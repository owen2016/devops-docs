# Harbor 使用

## 修改数据存储目录

根据实际修改harbor数据存储目录，文件路径为`${Harbor_Home}/docker-compose.yml`, 修改容器挂载目录

------------

## 上传 docker镜像

1. 使用[`pushImagesToHarbor.py`](http://git.augmentum.com.cn/aug-ops/devops/tree/master/docker")脚本，拷贝到装有docker的机器上。

2. 修改这台机器的hosts，添加

    ```shell
    # <Harbor IP address>是Harbor的IP地址
    # <Harbor Domain>是pushImagesToHarbor.py里的HARBOR_DOMAIN
    <Harbor IP address>   <Harbor Domain>
    ```

3. 修改这台机器的/etc/docker/daemon.json

    ```json
    {
      "registry-mirrors": [
        "https://registry.docker-cn.com"
      ],
      "insecure-registries": [
        "<Harbor Domain>"
      ]
    }
    ```

4. 检查这台机器是否能登陆Harbor

    ```shell
    docker login <HARBOR_DOMAIN>
    ```

5. 执行`pushImagesToHarbor.py`

    ```shell
    python pushImagesToHarbor.py
    ```

------------

## Harbor 磁盘清理

1. 登录到harbor admin管理界面,清除多余镜像tag

2. 登录到harbor服务宿主机器执行命令：

    ```text
    # 垃圾回收
    docker exec -it registry registry garbage-collect  /etc/registry/config.yml
    ```
