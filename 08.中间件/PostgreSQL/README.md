# PostgreSQL

docker-postgreql


https://www.cnblogs.com/mingfan/p/12332506.html




https://www.cnblogs.com/zhoujie/p/pgsql.html

psql -U postgres -W abc123_

sudo vim /etc/postgresql/11/main/pg_hba.conf
- ALTER USER postgres PASSWORD 'newPassword'

[postgresql 忘记 postgres 密码](https://www.cnblogs.com/wuling129/p/4917574.html)


METHOD指定如何处理客户端的认证。常用的有ident，md5，password，trust，reject

ident是Linux下PostgreSQL默认的local认证方式，凡是能正确登录服务器的操作系统用户（注：不是数据库用户）就能使用本用户映射的数据库用户不需密码登录数据库。用户映射文件为pg_ident.conf，这个文件记录着与操作系统用户匹配的数据库用户，如果某操作系统用户在本文件中没有映射用户，则默认的映射数据库用户与操作系统用户同名。比如，服务器上有名为user1的操作系统用户，同时数据库上也有同名的数据库用户，user1登录操作系统后可以直接输入psql，以user1数据库用户身份登录数据库且不需密码。很多初学者都会遇到psql -U username登录数据库却出现“username ident 认证失败”的错误，明明数据库用户已经createuser。原因就在于此，使用了ident认证方式，却没有同名的操作系统用户或没有相应的映射用户。解决方案：1、在pg_ident.conf中添加映射用户；2、改变认证方式。

md5是常用的密码认证方式，如果你不使用ident，最好使用md5。密码是以md5形式传送给数据库，较安全，且不需建立同名的操作系统用户。

password是以明文密码传送给数据库，建议不要在生产环境中使用。

trust是只要知道数据库用户名就不需要密码或ident就能登录，建议不要在生产环境中使用。

reject是拒绝认证。

在文件查找 listen_addresses，他的值说明

如果希望只能从本地计算机访问PostgreSQL数据库，就将该项设置为'localhost'；
如果希望从局域网访问PostgreSQL数据库，就将该项设置为PostgreSQL数据库的局域网IP地址；
如果希望从互联网访问PostgreSQL数据库，就将该项设置为PostgreSQL数据库的互联网IP地址；
如果希望从任何地方都可以访问PostgreSQL数据库，就将该配置项设置为“*”；

https://www.cnblogs.com/yulinlewis/p/9404112.html


- PostgreSQL 查找当前数据库的所有表
实现的功能类似MySQL：

show tables;
在 PostgreSQL 中需要写：

select * from pg_tables where schemaname = 'public';