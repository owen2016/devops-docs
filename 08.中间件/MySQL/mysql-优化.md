# mysql-优化

### 分表
数据库分表能够解决单表数据量很大的时候数据查询的效率问题，但是无法给数据库的并发操作带来效率上的提高，因为分表的实质还是在一个数据库上进行的操作，很容易受数据库IO性能的限制。

### 分库
如何将数据库IO性能的问题平均分配出来，很显然将数据进行分库操作可以很好地解决单台数据库的性能问题。


[单KEY业务，数据库水平切分架构实践 | 架构师之路](https://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651960212&idx=1&sn=ab4c52ab0309f7380f7e0207fa357128&chksm=bd2d06488a5a8f5e3b7c9de0cc5936818bd9a6ed4058679ae8d819175e0693c6fbd9cdea0c87&mpshare=1&scene=24&srcid=0903t4lvUDhWto8H2e87XwaV#rd "单KEY业务，数据库水平切分架构实践 | 架构师之路")


[多key业务，数据库水平切分架构一次搞定](https://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651960373&idx=1&sn=abf7d36840c4d3d556b17a8776ee536c&chksm=bd2d01e98a5a88ff0cbf615cb3444668ccdfca58d5dca2da00ed0cc8948585b7509adf648db0&scene=0#rd "多key业务，数据库水平切分架构一次搞定")