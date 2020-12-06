# Harbor 高可用

## 登录信息

1. admin超级用户: (不依赖于LDAP服务)
    - 用户名：　admin
    - 密码：　　**Harbor12345**

2. 支持LDAP用户登录

## 部署结构

使用 ”多harbor实例共享后端存储“ 方案保证了harbor高可用性

![Harbor](./images/Harbor.png)

### Harbor Instance

- 192.168.4.230 (/home/user/harbor)
- 192.168.4.231 (/home/user/harbor)

两个instance 的harbor目录内容相同

![Harbor](./images/harbor-info.png)

### Harbor postgresql ＆ redis

- 192.168.4.238  (psql -Upostgres # 进入postgresql)

### Harbor storage （NFS服务）

- 192.168.4.239

![Harbor-nfs](./images/harbor-nfs-2.png)

`mount -t nfs 192.168.4.239:/data /data # 在harbor节点上挂载nfs目录`

![Harbor](./_images/harbor-nfs.png)
