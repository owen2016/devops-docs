# MySQL 运维

## 备份与恢复

１．通过mysqldump备份数据
    备份指定库：mysqldump -uroot -proot --databases test_db > dump.sql

    备份所有库：mysqldump -uroot -proot --all-databases > dump.sql

２．数据恢复
    ２．１）mysql -uroot -proot < dump.sql

    或者：
        在进入mysql后执行
            mysql> source dump.sql

    ２．２）指定db
        shell> mysqladmin create db1
        shell> mysql db1 < dump.sql

        或者：
            mysql> CREATE DATABASE IF NOT EXISTS db1;
            mysql> USE db1;
            mysql> source dump.sql

mysql -h localhost -P 3306 --protocol=tcp -u root

mysqldump  -h localhost -P 3306 --protocol=tcp -u root -p mc > ~/mc-dbbackup/mc.sql

mysqldump  -h localhost -P 3306 --protocol=tcp -u root -p mc-zipkin > ~/mc-dbbackup/mc-zipkin.sql

https://blog.csdn.net/zhou_p/article/details/103177004

https://blog.csdn.net/harris135/article/details/79663901

## 添加新用户，赋予不同权限

１．添加新用户https://www.cnblogs.com/xujishou/p/6306765.html
    １．１）进入mysql

    １．２）添加用户
        限制本机访问用户：mysql> CREATE USER 'user1'@'localhost' IDENTIFIED BY 'root';

        ip访问用户：mysql> CREATE USER 'user2'@'%' IDENTIFIED BY 'root';

    １．３）登录测试
        mysql -h localhost -uuser1 -p

        mysql -h 172.20.53.158 -uuser2 -p

２．权限配置
    ２．１）命令:GRANT ｛privileges｝ ON databasename.tablename TO 'username'@'host'

    ｛privileges｝：SELECT , INSERT , UPDATE

    例子：GRANT SELECT, INSERT ON test_db.* TO 'user1'@'localhost';

    ２．２）创建用户同时授权

        mysql> GRANT SELECT ON *.* TO 'user1'@'localhost' identified by 'root';或者GRANT SELECT ON *.* TO 'user1'@'%' identified by 'root';

        mysql> flush privileges;

## 修改密码

１．）修改用户名
    mysql> use mysql;  选择数据库
    Database changed
    mysql> update user set user="dns" where user="root";    将用户名为root的改为dns
    mysql> flush privileges;

２．）修改密码
    ２．１）用UPDATE直接编辑user表 
        mysql> use mysql; 
        mysql> update user set password=password('123') where user='root' and host='localhost'; 
        mysql> flush privileges; 

    ２．２）用mysqladmin 
        前提该用户必须要有权限

        sudo mysqladmin -uuser3 -p123 password root3

        实时生效

## 数据找回

https://cloud.tencent.com/developer/article/1339799
https://cloud.tencent.com/developer/article/1023260


## 配置某个用户可以使用ip访问

https://jasonshieh.iteye.com/blog/2412210

１．连接到mysql

２．查看用户信息
    select Host,User from user where user='root';

    或
    select * from user\G;

３．更新用户登录权限
    update user set Host = '%' where User = 'root';

    flush privileges;

４．用ip连接
    mysql -h 172.20.53.158 -uroot -p
    Enter password: 
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 21
    Server version: 8.0.16 MySQL Community Server - GPL

    Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.

    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

备注：如果还是不行，去修改配置文件，bind-address = 127.0.0.1　（改为：0.0.0.0）


检查权限是否修改：
    select * from user\G;

    *************************** 9. row ***************************
                      Host: %
                      User: user2
                  Password: *81F5E21E35407D884A6CD4A731AEBFB6AF209E1B
               Select_priv: Y
               Insert_priv: N
               Update_priv: N
               Delete_priv: N
               Create_priv: N
                 Drop_priv: N
               Reload_priv: N
             Shutdown_priv: N
              Process_priv: N
                 File_priv: N
                Grant_priv: N
           References_priv: N
                Index_priv: N
                Alter_priv: N
              Show_db_priv: N
                Super_priv: N
     Create_tmp_table_priv: N
          Lock_tables_priv: N
              Execute_priv: N
           Repl_slave_priv: N
          Repl_client_priv: N
          Create_view_priv: N
            Show_view_priv: N
       Create_routine_priv: N
        Alter_routine_priv: N
          Create_user_priv: N
                Event_priv: N
              Trigger_priv: N
    Create_tablespace_priv: N
                  ssl_type: 
                ssl_cipher: 
               x509_issuer: 
              x509_subject: 
             max_questions: 0
               max_updates: 0
           max_connections: 0
      max_user_connections: 0
                    plugin: 
     authentication_string: NULL

case:
    １）如果想修改用户通过ip访问，可以先添加用户，附上访问权限，再修改ip访问权限