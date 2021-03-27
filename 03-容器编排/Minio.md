# Mino

[TOC]

**对象存储服务（Object Storage Service，OSS**）是一种海量、安全、低成本、高可靠的云存储服务，适合存放任意类型的文件。容量和处理能力弹性扩展，多种存储类型供选择，全面优化存储成本。

## 对象存储服务

在项目开发过程中，我们会产生大量的对象数据，包括：日志文件，数据库脚本文件、安装包，容器镜像，图像、视频等等，我们不仅仅是需要有一个集中的地方来存储，还需要能基于 Web 的方式来访问它们，以往我们有以下几种方法来解决：

- 阿里云、Azure 等云服务商提供的SaaS 级别的 OSS 服务
- 自己搭建 NAS 网络存储通过 Samba 服务来访问
- 自己搭建 FTP 服务器来存储

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616687824999-55666588-2d09-46e9-bcfb-6de25befec39.png#align=left&display=inline&height=320&margin=%5Bobject%20Object%5D&name=image.png&originHeight=320&originWidth=626&size=91754&status=done&style=none&width=626)

本篇文章主要介绍下其中的Minio方案

## Minio

![](https://cdn.nlark.com/yuque/0/2021/jpeg/5374140/1616841442916-a0aebceb-8506-441f-bc1b-2aa4b6e81318.jpeg#align=left&display=inline&height=128&margin=%5Bobject%20Object%5D&originHeight=400&originWidth=1200&size=0&status=done&style=none&width=385)
Minio是GlusterFS创始人之一Anand Babu Periasamy发布新的开源项目。Minio兼容Amason的S3分布式对象存储项目，采用Golang实现，客户端支持Java,Python,Javacript, Golang语言。

Minio是建立在云原生的基础上；有分布式和共享存储等功能；旨在多租户环境中以可持续的方式进行扩展的对象存储服务。它最适合存储非结构化数据，如：照片、视频、日志文件、容器/虚拟机/映像等，单次存储对象的大小最大可达5TB

### 参考

- [https://min.io/](https://min.io/)
- [http://www.minio.org.cn/](http://www.minio.org.cn/)
- [minio/minio-service: Collection of MinIO server scripts for upstart, systemd, sysvinit, launchd. (github.com)](https://github.com/minio/minio-service)

### Minio 架构

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616687945743-43cf8f65-e12b-427d-85f5-22e731990a65.png#align=left&display=inline&height=452&margin=%5Bobject%20Object%5D&name=image.png&originHeight=452&originWidth=740&size=137885&status=done&style=none&width=740)

**左边是 MINIO 集群的示意图**，整个集群是由多个角色完全相同的节点所组成的。因为没有特殊的节点，所以任何节点宕机都不会影响整个集群节点之间的通信。通过 rest 跟 RPC 去通信的，主要是实现分布式的锁跟文件的一些操作

**右边这张图是单个节点的示意图**，每个节点都单独对外提供兼容 S3 的服务

### 为什么要用 Minio

- 1、Minio      有良好的存储机制
- 2、Minio      有很好纠删码的算法与擦除编码算法
- 3、拥有RS      code 编码数据恢复原理
- 4、公司做强做大时，数据的拥有重要性，对数据治理与大数据分析做准备。
- 5、搭建自己的一套文件系统服务,对文件数据进行安全保护。
- 6、拥有自己的平台，不限于其他方限制。

#### 存储机制

- Minio使用纠删码erasure      code和校验和checksum来保护数据免受硬件故障和无声数据损坏。 即便丢失一半数量（N/2）的硬盘，仍然可以恢复数据。

#### 纠删码

- 纠删码是一种恢复丢失和损坏数据的数学算法，目前，纠删码技术在分布式存储系统中的应用主要有三类，阵列纠删码（Array      Code: RAID5、RAID6 等）、RS(Reed-Solomon)里德-所罗门类纠删码和 LDPC(LowDensity Parity      Check Code)低密度奇偶校验纠删码。Erasure Code 是一种编码技术，它可以将 n 份原始数据，增加 m 份数据，并能通过 n+m      份中的任意 n 份数据，还原为原始数据。即如果有任意小于等于 m 份的数据失效，仍然能通过剩下的数据还原出来

### MinIO概念

如下图，**每一行是一个机器节点**，这里有32个集群，**每个节点里有一个小方块，我们称之为Drive，Drive可简单地理解为磁盘**。一个节点有32个Drive，相当于32个磁盘。

**Set是一组Drive的集合**，所有红色标识的Drive组成了一个Set。

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616688028544-2d4661ff-7d44-427e-a7b2-4e98922fbaec.png#align=left&display=inline&height=298&margin=%5Bobject%20Object%5D&name=image.png&originHeight=298&originWidth=299&size=58821&status=done&style=none&width=299)
一个对象存储在一个Set上; 一个集群划分为多个Set
一个Set包含的Drive数量是固定的, 默认由系统根据集群规模自动计算得出 MINIO_ERASURE_SET_DRIVE_COUNT
一个SET中的Drive尽可能分布在不同的节点上

### 部署

Minio 提供了两种部署方式：单机部署和分布式，两种部署方式都非常简单，其中分布式部署还提供了纠删码功能来降低数据丢失的风险

#### 单机部署：

`wget `[`https://dl.min.io/server/minio/release/linux-amd64/minio`](https://dl.min.io/server/minio/release/linux-amd64/minio)`
chmod +x minio
./minio server /data``  #``若``/data``目录不存在，要新建一个`

#### Docker 部署Minio

``` shell
mkdir /data/minio-data&&mkdir /data/minio-config # 创建一个数据存储目录
docker run -p 9000:9000 --name minio \
-d --restart=always \
-e "MINIO_ACCESS_KEY=admin" \
-e "MINIO_SECRET_KEY=admin123456" \
-v /data/minio-data:/data \
-v /data/minio-config:/root/.minio \
minio/minio server /data
```

[http://localhost:9000/](http://localhost:9000/) 即可登陆Minio 的管理界面

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616688607585-b362ae32-41e7-40b0-a653-391015b514c3.png#align=left&display=inline&height=295&margin=%5Bobject%20Object%5D&name=image.png&originHeight=295&originWidth=1303&size=22817&status=done&style=none&width=1303)

### 分布式Minio

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616688683921-36c53272-58fe-43e1-98ef-060e091fdac2.png#align=left&display=inline&height=557&margin=%5Bobject%20Object%5D&name=image.png&originHeight=557&originWidth=1008&size=135743&status=done&style=none&width=1008)
单机Minio服务存在单点故障，相反，如果是一个有 m 台服务器， n 块硬盘的分布式Minio,只要有 m/2 台服务器或者 m*n/2 及更多硬盘在线，你的数据就是安全的。

例如，一个16节点的Minio集群，每个节点200块硬盘，就算8台服務器宕机，即大概有1600块硬盘，这个集群仍然是可读的，不过你需要9台服務器在线才能写数据。

`export MINIO_ACCESS_KEY=<ACCESS_KEY>`
`export MINIO_SECRET_KEY=<SECRET_KEY>`
`minio server `[`http://host`](http://host)`{1...n}/export{1...m} `[`http://host`](http://host)`{1...o}/export{1...m}`

当然如果我们只有一台机器，但是想用纠删码的功能，也可以直接配置使用多个本地盘
`minio server /data1 /data2 /data3 ... /data8`

### Minio配置

默认的配置目录是 ${HOME}/.minio，你可以使用--config-dir命令行选项重写之。MinIO server在首次启动时会生成一个新的config.json，里面带有自动生成的访问凭据。
`minio server --config-dir /etc/minio /data`

- **证书目录**

TLS证书存在${HOME}/.minio/certs目录下，你需要将证书放在该目录下来启用HTTPS 

- **凭据**

只能通过环境变量MINIO_ROOT_USER 和 MINIO_ROOT_PASSWORD 更改MinIO的admin凭据和root凭据。使用这两个值的组合，MinIO加密存储在后端的配置

`export MINIO_ROOT_USER=minio`
`export MINIO_ROOT_PASSWORD=minio13`
`minio server /data`

### 如何存储和访问对象

将对象数据存储到 Minio 中有以下几种方式：
• 通过 MINIO CLIENT
• 通过 MINIO SDK 目前支持的语言包括：Go，Java，Node.js，Python，.NET
• 通过浏览器访问 Web 管理界面，在管理界面中上传和下载对象
• 如果你有存储目录 minio-data 的账号和访问权限，可以直接使用 SCP 命令将数据写入磁盘

#### MinIO Client (mc)

``` shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
```

MinIO Client (mc)为ls，cat，cp，mirror，diff，find等UNIX命令提供了一种替代方案。它支持文件系统和兼容Amazon S3的云存储服务（AWS Signature v2和v4）。

##### 命令使用

`ls       ``列出文件和文件夹。``
mb       ``创建一个存储桶或一个文件夹。``
cat      ``显示文件和对象内容。``
pipe     ``将一个``STDIN``重定向到一个对象或者文件或者``STDOUT``。``
share    ``生成用于共享的``URL``。``
cp       ``拷贝文件和对象。``
mirror   ``给存储桶和文件夹做镜像。``
find     ``基于参数查找文件。``
diff     ``对两个文件夹或者存储桶比较差异。``
rm       ``删除文件和对象。``
events   ``管理对象通知。``
watch    ``监听文件和对象的事件。``
policy   ``管理访问策略。``
session  ``为``cp``命令管理保存的会话。``
config   ``管理``mc``配置文件。``
update   ``检查软件更新。``
version  ``输出版本信息。`

**列出Mino服务端**

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616840462896-f6c5a2bd-562c-49c9-8d95-bc3f530ae95c.png#align=left&display=inline&height=379&margin=%5Bobject%20Object%5D&name=image.png&originHeight=379&originWidth=493&size=37287&status=done&style=none&width=493)

**命令行创建bucket**

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616840502464-6155acbc-4744-4434-9a62-5ee3a346eeb5.png#align=left&display=inline&height=166&margin=%5Bobject%20Object%5D&name=image.png&originHeight=166&originWidth=477&size=26220&status=done&style=none&width=477)

![image.png](https://cdn.nlark.com/yuque/0/2021/png/5374140/1616840510944-6e6085fd-2253-49bd-ac92-2cf932de3949.png#align=left&display=inline&height=414&margin=%5Bobject%20Object%5D&name=image.png&originHeight=414&originWidth=607&size=32039&status=done&style=none&width=607)

#### 通过代码存储对象

```  shell
// 构造访问对象
var minio = new MinioClient("localhost:9000","accessKey","secretKey");
// 输出所有的 Buckets 
var rs = minio.ListBucketsAsync();
foreach (varbucket in rs.Result.Buckets)
{
    Console.Out.WriteLine(bucket.Name + " " + bucket.CreationDateDateTime);
}
// 存储对象
var bucketName = "logs";
var objectName = "logs.zip";
var filePath = "c:\\logs.zip";
var contentType = "application/zip";
minio.PutObjectAsync(bucketName, objectName, filePath, contentType);
// 获取对象
var find  = minio.GetObjectAsync(bucketName, objectName)
```