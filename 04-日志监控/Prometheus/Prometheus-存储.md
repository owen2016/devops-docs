# Prometheus

prometheus将采集到的样本以时间序列的方式保存在内存（TSDB 时序数据库）中，并定时保存到硬盘中。

与zabbix不同，zabbix会保存所有的数据，而`prometheus本地存储会保存15天，超过15天以上的数据将会被删除`，若要永久存储数据，有两种方式，

- 方式一：修改prometheus的配置参数“storage.tsdb.retention.time=10000d”；
- 方式二：将数据引入存储到Influcdb中。为保证数据安全性，
 
本文主要介绍的是promethues本地存储备份数据的方法

https://www.cnblogs.com/zqj-blog/p/12205063.html