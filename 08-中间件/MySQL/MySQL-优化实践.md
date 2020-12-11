
# MySQL 优化实践

[TOC]

## 1. 慢查询日志分析

MySQL的慢查询日志是MySQL提供的一种日志记录，它用来记录在MySQL中响应时间超过阀值的语句，具体指运行时间超过long_query_time值的SQL，则会被记录到慢查询日志中。long_query_time的默认值为10，意思是运行10S以上的语句。默认情况下，Mysql数据库并不启动慢查询日志，需要我们手动来设置这个参数，当然，如果不是调优需要的话，一般不建议启动该参数，因为开启慢查询日志会或多或少带来一定的性能影响。慢查询日志支持将日志记录写入文件，也支持将日志记录写入数据库表

### 慢查询日志相关参数

MySQL 慢查询的相关参数解释：slow_query_log ：是否开启慢查询日志，1表示开启，0表示关闭。

``` text
slow_query_log    ：是否开启慢查询日志，1表示开启，0表示关闭。
log-slow-queries  ：旧版（5.6以下版本）MySQL数据库慢查询日志存储路径。可以不设置该参数，系统则会默认给一个缺省的文件- host_name-slow.log
slow-query-log-file：新版（5.6及以上版本）MySQL数据库慢查询日志存储路径。可以不设置该参数，系统则会默认给一个缺省的文件host_name-slow.log
long_query_time ：慢查询阈值，当查询时间多于设定的阈值时，记录日志。
log_queries_not_using_indexes：未使用索引的查询也被记录到慢查询日志中（可选项）
log_output：日志存储方式。log_output='FILE'表示将日志存入文件，默认值是'FILE'。log_output='TABLE'表示将日志存入数据库，这样日志信息就会被写入到mysql.slow_log表中。MySQL数据<br>库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如：log_output='FILE,TABLE'。日志记录到系统的专用日志表中，要比记录到文件耗费更多的系统资源，因此对于需要启用慢查询日志，又需<br>要能够获得更高的系统性能，那么建议优先记录到文件
```

### 慢查询日志配置

默认情况下slow_query_log的值为OFF，表示慢查询日志是禁用的，可以通过设置slow_query_log的值来开启，如下所示：

``` shell
mysql> show variables like '%slow_query_log%';
+---------------------+-------------------------------------+
| Variable_name       | Value                               |
+---------------------+-------------------------------------+
| slow_query_log      | OFF                                 |
| slow_query_log_file | /var/lib/mysql/owen-ubuntu-slow.log |
+---------------------+-------------------------------------+
2 rows in set (0.01 sec)

mysql> set global slow_query_log=1;
Query OK, 0 rows affected (0.00 sec)
##使用set global slow_query_log=1开启了慢查询日志只对当前数据库生效，MySQL重启后则会失效。如果要永久生效，就必须修改配置文件my.cnf（其它系统变量也是如此）

mysql> show variables like '%slow_query_log%';
+---------------------+-------------------------------------+
| Variable_name       | Value                               |
+---------------------+-------------------------------------+
| slow_query_log      | ON                                  |
| slow_query_log_file | /var/lib/mysql/owen-ubuntu-slow.log |
+---------------------+-------------------------------------+
2 rows in set (0.01 sec)
```

那么开启了慢查询日志后，什么样的SQL才会记录到慢查询日志里面呢？ 这个是由参数`long_query_time`控制，默认情况下long_query_time的值为10秒，可以使用命令修改，也可以在my.cnf参数里面修改。

``` shell
mysql> show variables like 'long_query_time';
+-----------------+-----------+
| Variable_name   | Value     |
+-----------------+-----------+
| long_query_time | 10.000000 |
+-----------------+-----------+
1 row in set (0.00 sec)

mysql> set global long_query_time=4;
Query OK, 0 rows affected (0.00 sec)

mysql> show global variables like 'long_query_time';
+-----------------+----------+
| Variable_name   | Value    |
+-----------------+----------+
| long_query_time | 4.000000 |
+-----------------+----------+
1 row in set (0.02 sec)
```

`log_output` 参数是指定日志的存储方式。log_output='FILE'表示将日志存入文件，默认值是'FILE'。log_output='TABLE'表示将日志存入数据库，这样日志信息就会被写入到mysql.slow_log表中。

MySQL数据库支持同时两种日志存储方式，配置的时候以逗号隔开即可，如：log_output='FILE,TABLE'。日志记录到系统的专用日志表中，要比记录到文件耗费更多的系统资源，因此对于需要启用慢查询日志，又需要能够获得更高的系统性能，那么建议优先记录到文件.

系统变量`log-queries-not-using-indexes`：未使用索引的查询也被记录到慢查询日志中（可选项）。如果调优的话，建议开启这个选项。另外，开启了这个参数，其实使用full index scan的sql也会被记录到慢查询日志。

``` shell
mysql> show variables like 'log_queries_not_using_indexes';
+-------------------------------+-------+
| Variable_name                 | Value |
+-------------------------------+-------+
| log_queries_not_using_indexes | OFF   |
+-------------------------------+-------+
1 row in set (0.00 sec)

mysql> set global log_queries_not_using_indexes=1;
Query OK, 0 rows affected (0.00 sec)

mysql> show variables like 'log_queries_not_using_indexes';
+-------------------------------+-------+
| Variable_name                 | Value |
+-------------------------------+-------+
| log_queries_not_using_indexes | ON    |
+-------------------------------+-------+
1 row in set (0.00 sec)
```

系统变量`log_slow_admin_statements`表示是否将慢管理语句例如ANALYZE TABLE和ALTER TABLE等记入慢查询日志

``` shell
mysql> show variables like 'log_slow_admin_statements';
+---------------------------+-------+
| Variable_name             | Value |
+---------------------------+-------+
| log_slow_admin_statements | OFF   |
+---------------------------+-------+
1 row in set (0.00 sec)
```

如果你想查询有多少条慢查询记录，可以使用系统变量`slow_queries`

``` shell
mysql> show global status like '%slow_queries%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Slow_queries  | 0     |
+---------------+-------+
1 row in set (0.00 sec)
```

### 日志分析工具 mysqldumpslow

在实际生产环境中，如果要手工分析日志，查找、分析SQL，显然是个体力活，MySQL提供了日志分析工具mysqldumpslow

``` shell
得到返回记录集最多的10个SQL。
mysqldumpslow -s r -t 10 /database/mysql/mysql06_slow.log
 
得到访问次数最多的10个SQL
mysqldumpslow -s c -t 10 /database/mysql/mysql06_slow.log
 
得到按照时间排序的前10条里面含有左连接的查询语句。
mysqldumpslow -s t -t 10 -g “left join” /database/mysql/mysql06_slow.log
 
另外建议在使用这些命令时结合 | 和more 使用 ，否则有可能出现刷屏的情况。
mysqldumpslow -s r -t 20 /mysqldata/mysql/mysql06-slow.log | more
```

## 2. 索引优化

- https://www.cnblogs.com/lqCnblog/p/6923217.html

``` shell
mysql> show index from user;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| user  |          0 | PRIMARY  |            1 | Host        | A         |           3 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| user  |          0 | PRIMARY  |            2 | User        | A         |          10 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.16 sec)

mysql> show keys from user;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| user  |          0 | PRIMARY  |            1 | Host        | A         |           3 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| user  |          0 | PRIMARY  |            2 | User        | A         |          10 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.00 sec)

```

- Table 表的名称。
- Non_unique 如果索引不能包括重复词，则为0。如果可以，则为1。
- Key_name 索引的名称。
- Seq_in_index 索引中的列序列号，从1开始。
- Column_name 列名称。
- Collation 列以什么方式存储在索引中。在MySQL中，有值‘A'（升序）或NULL（无分类）。
- Cardinality 索引中唯一值的数目的估计值。通过运行ANALYZE TABLE或myisamchk -a可以更新。基数根据被存储为整数的统计数据来计数，所以即使对于小型表，该值也没有必要是精确的。基数越大，当进行联合时，MySQL使用该索引的机会就越大。
- Sub_part 如果列只是被部分地编入索引，则为被编入索引的字符的数目。如果整列被编入索引，则为NULL。
- Packed 指示关键字如何被压缩。如果没有被压缩，则为NULL。
- Null 如果列含有NULL，则含有YES。如果没有，则该列含有NO。
- Index_type 用过的索引方法（BTREE, FULLTEXT, HASH, RTREE）。

## 3．查看正在被锁定的表

``` shell
mysql> show status like 'Table%';
+----------------------------+-------+
| Variable_name              | Value |
+----------------------------+-------+
| Table_locks_immediate      | 12    |
| Table_locks_waited         | 0     |
| Table_open_cache_hits      | 1083  |
| Table_open_cache_misses    | 83    |
| Table_open_cache_overflows | 0     |
+----------------------------+-------+
5 rows in set (0.00 sec)

#查询正在被锁定的表
mysql> show OPEN TABLES where In_use > 0;
Empty set (0.00 sec)
```

## 4. 执行计划分析

- https://www.cnblogs.com/galengao/p/5780958.html
- https://www.cnblogs.com/wangzun/p/7118646.html

## 5. 数据库连接数优化

查看数据库最大的连接数命令：  `show variables like 'max_connections';`

show processlist
    查看连接数，可以发现有很多连接处于sleep状态，这些其实是暂时没有用的，所以可以kill掉

set GLOBAL max_connections=1000;
    修改最大连接数，但是这不是一劳永逸的方法，应该要让它自动杀死那些sleep的进程。

show global variables like 'wait_timeout';
    这个数值指的是mysql在关闭一个非交互的连接之前要等待的秒数，默认是28800s

set global wait_timeout=300;
    修改这个数值，这里可以随意，最好控制在几分钟内

show global variables like 'interactive_timeout';
    修改这个数值，表示mysql在关闭一个连接之前要等待的秒数，至此可以让mysql自动关闭那些没用的连接，但要注意的是，正在使用的连接到了时间也会被关闭，因此这个时间值要合适
    set global interactive_timeout=300;

时间计算是无操作：
    sleep的时间，如果是query，机会在quertt time + sleep time(300s) 后被kill

问题：
１．wait_timeout默认值为28800，大小需要根据项目来定。
２．wait_timeout过大有弊端，其体现就是MySQL里大量的SLEEP进程无法及时释放。
３．过小容易遇到`ERROR : (2006, 'MySQL server has gone away')` ，死锁等待等问题。

https://www.cnblogs.com/fnlingnzb-learner/p/5984795.html




