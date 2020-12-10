
# MySQL 优化实践

## 慢查询分析

１．选择数据库
    show variables;

２．搜索配置　https://www.cnblogs.com/saneri/p/6656161.html
    slow_query_log ON/NO　是否开启慢查询

    slow_query_log_file 慢查询日志文件路径


    附录：如果想记录所有操作（实时生效）
        https://www.cnblogs.com/sandea/p/6090744.html

        １）
            mysql> show variables where variable_name = "general_log";
            +---------------+-------+
            | Variable_name | Value |
            +---------------+-------+
            | general_log   | OFF   |
            +---------------+-------+

            mysql> set global general_log=on;

        ２）
            mysql> show variables where variable_name = "general_log_file";
            +------------------+----------------------------------+
            | Variable_name    | Value                            |
            +------------------+----------------------------------+
            | general_log_file | /var/lib/mysql/172-20-48-235.log |
            +------------------+----------------------------------+

３．查看表索引　https://www.cnblogs.com/lqCnblog/p/6923217.html
    show index from `dev-lts`.`lts_wjq_devtaskTracker`;

４．执行查询分析
    EXPLAIN select * from `lts`.`lts_wjq_testtaskTracker` where 
job_id = '0A21B4F97CB045F9A72553CD2DD7150D' AND is_running = 0 AND trigger_time = 1556076600000 AND 
gmt_modified = 1556076302221;

    主要看
        possible_keys 可能命中的索引
        keys 实际命中的索引
        rows 查询到目的数据需要扫描的数据条数
        filtered 查询数据和扫描数据比例

    参考：https://www.cnblogs.com/galengao/p/5780958.html
        　https://www.cnblogs.com/wangzun/p/7118646.html

５．MySQL查看正在被锁定的表

    １）show status like 'Table%';

    ２）查询正在被锁定的表
        show OPEN TABLES where In_use > 0;

## 数据库连接数优化

查看数据库最大的连接数命令：
    show variables like 'max_connections';

show processlist;
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
    ３．过小容易遇到MySQL server has gone away ，死锁等待等问题。
        https://www.cnblogs.com/fnlingnzb-learner/p/5984795.html

        有可能是因为某些原因导致超时，比如说程序中获取数据库连接时采用了Singleton的做法，虽然多次连接数据库，但其实使用的
        都是同一个连接，而且程序中某两次操作数据库的间隔时间超过了wait_timeout（SHOW STATUS能看到此设置），那么就可能出
        现问题。最简单的处理方式就是把wait_timeout改大，当然你也可以在程序里时不时顺手mysql_ping()一下，这样MySQL就知
        道它不是一个人在战斗。



