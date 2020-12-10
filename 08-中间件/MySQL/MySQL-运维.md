# MySQL 运维

## 备份与恢复

https://www.cnblogs.com/Cherie/p/3309456.html

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
