# MySQL 运维

[TOC]

## 备份与恢复

参考：

- https://www.cnblogs.com/Cherie/p/3309456.html

1. 通过mysqldump备份数据
    备份指定库：`mysqldump -uroot -proot --databases test_db > dump.sql`

    备份所有库：`mysqldump -uroot -proot --all-databases > dump.sql`

2. mysqldump 命令备份导出mysql容器中数据

    `mysql -h localhost -P 3306 --protocol=tcp -u root`

    `mysqldump  -h localhost -P 3306 --protocol=tcp -u root -p database > ~/dbbackup.sql`

    `docker exec -it mysql mysqldump -uroot -p123456 paas_portal > /cloud/sql/paas_portal.sql`

3. 数据恢复
   `mysql -uroot -proot < dump.sql`

    或 在进入mysql后执行`mysql> source dump.sql`

   指定db恢复

    ``` shell
    shell> mysqladmin create db1
    shell> mysql db1 < dump.sql
    ```

    或者：

    ``` shell
    mysql> CREATE DATABASE IF NOT EXISTS db1;
    mysql> USE db1;
    mysql> source dump.sql
    ```

## 用户/权限操作

### １．添加新用户

命令: `CREATE USER 'username'@'host' IDENTIFIED BY 'password';`

- host - 指定该用户在哪个主机上可以登陆，此处的"localhost"，是指该用户只能在本地登录，不能在另外一台机器上远程登录，如果想远程登录的话，将"localhost"改为"%"，表示在任何一台电脑上都可以登录;也可以指定某台机器可以远程登录;

- password - 该用户的登陆密码,密码可以为空,如果为空则该用户可以不需要密码登陆服务器。

e.g.

限制本机用户访问：`CREATE USER 'user1'@'localhost' IDENTIFIED BY 'root';`

远程登录访问：`CREATE USER 'user2'@'%' IDENTIFIED BY 'root';`

登录测试: `mysql -h localhost -uuser1 -p` or  `mysql -h 172.20.53.158 -uuser2 -p`

### ２．授权

命令:

``` shell

GRANT ｛privileges｝ ON databasename.tablename TO 'username'@'host'`

privileges - 用户的操作权限,如SELECT , INSERT , UPDATE 等(详细列表见该文最后面).如果要授予所的权限则使用ALL.;databasename - 数据库名,tablename-表名,如果要授予该用户对所有数据库和表的相应操作权限则可用*表示, 如*.*.
```

e.g. `GRANT SELECT, INSERT ON test_db.* TO 'user1'@'localhost';`

### 3. 创建用户同时授权

GRANT SELECT ON *.* TO 'user1'@'localhost' identified by 'root';
或者
GRANT SELECT ON *.* TO 'user1'@'%' identified by 'root';

然后必须执行 `flush privileges;`, 否则登录时提示：ERROR 1045 (28000): Access denied for user 'user'@'localhost' (using password: YES )

### 4.修改用户名

``` shell
mysql> use mysql;  选择数据库
Database changed
mysql> update user set user="dns" where user="root";    将用户名为root的改为dns
mysql> flush privileges;
```

### 5. 修改用户密码

- 用UPDATE直接编辑user表

    ```shell
    mysql> use mysql; 
    mysql> update user set password=password('123') where user='root' and host='localhost'; 
    mysql> flush privileges;
    ```

- 用mysqladmin
    `sudo mysqladmin -uuser3 -p123 password root3`

    注意：前提该用户必须要有权限

### 5. 删除用户

`DROP USER 'username'@'host';`

### 6. 查看用户权限

`show grants for username@localhost;`

### 7. 撤销用户权限

命令: `REVOKE privilege ON databasename.tablename FROM 'username'@'host';`

说明: privilege, databasename, tablename - 同授权部分.

e.g.: `REVOKE SELECT ON mq.* FROM 'user'@'localhost';`

### 8. 查询用户/更新用户登录权限

``` shell
use mysql;
select Host,User from user ;
或 select * from user\G;

update user set Host = '%' where User = 'root';

flush privileges;
```

## 数据找回

https://cloud.tencent.com/developer/article/1339799
https://cloud.tencent.com/developer/article/1023260




