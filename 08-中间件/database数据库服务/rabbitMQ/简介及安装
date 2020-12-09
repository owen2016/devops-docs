安装教程：https://www.rabbitmq.com/download.html

docker安装：http://www.mamicode.com/info-detail-2454026.html
    1.获取rabbitmq镜像，注意获取镜像的时候要获取management，不要获取last版本，management版本才是带有管理界面的，
    结果如下
        # docker search rabbitmq:management

    2.将rabbitmq镜像pull到本地
        # docker pull rabbitmq:3.7-management

    3.启动容器，映射端口，设置默认账户密码
        # docker run -d \
            -p 5672:5672 \
            -p 15672:15672 \
            -p 15674:15674 \
            -p 61613:61613 \
            --name rabbit-mq \
            --hostname my-rabbit \
            -v /home/user/operation/rabbitMQ/data:/var/lib/rabbitmq \
            -e RABBITMQ_DEFAULT_USER=admin \
            -e RABBITMQ_DEFAULT_PASS=admin \
            --restart=always \
            rabbitmq:management

    4.创建Dockerfile开启rabbitmq插件，编辑 vim Dockerfile 添加如下内容，保存退出
        FROM rabbitmq:3.7-management
        MAINTAINER eddychen
        RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_federation_management rabbitmq_stomp

    5.通过Dockerfile生成镜像，注：这一步必须在启动容器之后执行
        # docker build -f Dockerfile -t rabbitmq:management .

    6.生成镜像后，通过ip:15672访问web界面，
        http://localhost:15672/#/queues

        username: admin
        password: admin

docker官网：https://hub.docker.com/_/rabbitmq/
    1.Running the daemon
        $ docker run -d --hostname my-rabbit --name some-rabbit rabbitmq:3

        This will start a RabbitMQ container listening on the default port of 5672. If you give that
         a minute, then do docker logs some-rabbit, you'll see in the output a block similar to:
            =INFO REPORT==== 6-Jul-2015::20:47:02 ===
            node           : rabbit@my-rabbit
            home dir       : /var/lib/rabbitmq
            config file(s) : /etc/rabbitmq/rabbitmq.config
            cookie hash    : UoNOcDhfxW9uoZ92wh6BjA==
            log            : tty
            sasl log       : tty
            database dir   : /var/lib/rabbitmq/mnesia/rabbit@my-rabbit（数据目录）

        数据目录会append by　＂node＂，又--hostname设置，所有如果不指定--hostname，每次启动的时候数据目录就会不一样，
        ＊＊＊所以最好指定--hostname＊＊＊

    2.Memory Limits
        指定RABBITMQ_VM_MEMORY_HIGH_WATERMARK参数

        -e RABBITMQ_VM_MEMORY_HIGH_WATERMARK=0.49 | -e RABBITMQ_VM_MEMORY_HIGH_WATERMARK="1024MiB"

    3.Management Plugin
        $ docker run -d --hostname my-rabbit --name some-rabbit rabbitmq:3-management

        tag为3-management的镜像，默认用户名密码为guest,可以用http://container-ip:15672访问管理页面

    4.Enabling Plugins（使用场景？？？？？？？？？？？）
        Creating a Dockerfile will have them enabled at runtime. To see the full list of plugins
         present on the image rabbitmq-plugins list

            FROM rabbitmq:3.7-management
            RUN rabbitmq-plugins enable --offline rabbitmq_mqtt rabbitmq_federation_management rabbitmq_stomp

        你也可以用挂载文件的方式（文件：/etc/rabbitmq/enabled_plugins）
            文件内容：[rabbitmq_federation_management,rabbitmq_management,rabbitmq_mqtt,rabbitmq_stomp].

