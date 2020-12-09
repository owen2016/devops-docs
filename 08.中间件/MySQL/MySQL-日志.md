# MySQL 日志

## 1、MySQL中主要日志如下：

1. 错误日志(Log Error)
2. 查询日志(Query Log)
3. 二进制日志(Binary Log)

## 2、相关日志的作用；

1. 错误日志(Error Log):记录MySQL服务进程MySQL在启动/关闭或者运行过程中遇到的错误消息.是工作中排查错误的重要工具.

2. 查询日志(Query Log)
  1).普通查询日志(`general query log`):记录客户连接和执行的SQL语句信息.

  2).慢查询日志(`show query log`):记录执行时间超出指定值(long query time)和没有利用索引(log_queries_not_using_indexes)的SQL语句.

  3).二进制日志(Binary Log):记录数据库的修改信息

## 3. 如何查看相关日志:

``` shell
mysql> show variables like 'general_log%';  #普通查询日志,一般不开启,比较占空间,没用.   

+------------------+----------------------------+   
| Variable_name    | Value                      |   
+------------------+----------------------------+   
| general_log      | OFF                        |   
| general_log_file | /var/run/mysqld/mysqld.log |   
+------------------+----------------------------+   
2 rows in set (0.00 sec)
```

``` shell
mysql> show variables like 'slow_%log%'; #数据库优化的一个方向   
+---------------------+---------------------------------+   
| Variable_name       | Value                           |   
+---------------------+---------------------------------+   
| slow_query_log      | OFF                             |   
| slow_query_log_file | /var/run/mysqld/mysqld-slow.log |   
+---------------------+---------------------------------+   

2 rows in set (0.00 sec)
```

``` shell
mysql> show variables like 'log_error'; #排查错误的一个方式   
+---------------+---------------------+   
| Variable_name | Value               |   
+---------------+---------------------+   
| log_error     | /var/log/mysqld.log |   
+---------------+---------------------+   
1 row in set (0.00 sec)
```

```shell
mysql> show variables like 'log_bin';#增量恢复的一个基础   

+---------------+-------+   
| Variable_name | Value |   
+---------------+-------+   
| log_bin       | ON    |   
+---------------+-------+   
1 row in set (0.00 sec)
```