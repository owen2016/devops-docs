# Flyway

## 介绍

支持多种数据库：

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377751_20201231135300659_1838554034.png)

支持多种使用方式：

- 基于命令行模式，用户从官网下载工具包，进行一些必要的配置，就可以通过命令行使用其功能。

- 基于Java API，用户可以将Flyway提供的第三方包加入classpath，通过Flyway提供的API来使用其功能。

- 基于Maven或Gradle，用户可以通过配置插件，运行mvn或gradle命令来使用其功能。

`mvn flyway:migrate`

- 与spring-boot集成

## 工作原理

Flyway可以对数据库进行升级，从任意一个版本升级到最新的版本。但是升级的依据是用户自己编写的sql脚本，用户自己决定每一个版本的升级内容。

Flyway不限定脚本里面的内容，但是对脚本文件的名称有一定的要求：

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377752_20201231135459107_121668887.png)

版本号可以使用小版本，如V1.1。

具体要求：

- 版本号和版本描述之间，使用两个下划线分隔。
- 版本描述之间，使用一个下划线分隔单词。
- 版本号唯一：不允许多个脚本文件有相同的版本号。


lyway 需要在 DB 中先创建一个 metdata 表 (缺省表名为 flyway_schema_history), 在该表中保存着每次 migration 的记录, 记录包含 migration 脚本的版本号和 SQL 脚本的 checksum 值. 当一个新的 SQL 脚本被扫描到后, Flyway 解析该 SQL 脚本的版本号, 并和 metadata 表已 apply 的的 migration 对比, 如果该 SQL 脚本版本更新的话, 将在指定的 DB 上执行该 SQL 文件, 否则跳过该 SQL 文件.

两个 flyway 版本号的比较, 采用左对齐原则, 缺位用 0 代替. 举例如下:
1.2.9.4 比 1.2.9 版本高.
1.2.10 比 1.2.9.4 版本高.
1.2.10 和 1.2.010 版本号一样高, 每个版本号部分的前导 0 会被忽略.


Flyway SQL 文件可以分为两类: Versioned 和 Repeatable.
Versioned migration 用于版本升级, 每个版本有唯一的版本号并只能 apply 一次.
Repeatable migration 是指可重复加载的 migration, 一旦 SQL 脚本的 checksum 有变动, flyway 就会重新应用该脚本. 它并不用于版本更新, 这类的 migration 总是在 versioned migration 执行之后才被执行.

默认情况下, Migration SQL的命名规则如下图:
![](https://gitee.com/owen2016/pic-hub/raw/master/1610377753_20210104093342660_374645789.png)
其中的文件名由以下部分组成，除了使用默认配置外，某些部分还可自定义规则.

prefix: 可配置，前缀标识，默认值 V 表示 Versioned, R 表示 Repeatable
version: 标识版本号, 由一个或多个数字构成, 数字之间的分隔符可用点.或下划线_
separator: 可配置, 用于分隔版本标识与描述信息, 默认为两个下划线__
description: 描述信息, 文字之间可以用下划线或空格分隔
suffix: 可配置, 后续标识, 默认为.sql

```
CREATE TABLE  flyway_schema_history
    (
        installed_rank INT NOT NULL,
        version VARCHAR(50),
        description VARCHAR(200) NOT NULL,
        type VARCHAR(20) NOT NULL,
        script VARCHAR(1000) NOT NULL,
        checksum INT,
        installed_by VARCHAR(100) NOT NULL,
        installed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        execution_time INT NOT NULL,
        success TINYINT(1) NOT NULL,
        PRIMARY KEY (installed_rank),
        INDEX flyway_schema_history_s_idx (success)
    )
    ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

使用Flyway升级，flyway会自动创建一张历史记录表：flyway_schema_history。

这张表记录了每一次升级的记录，包括已经执行了哪些脚本，脚本的文件名，内容校验和，执行的时间和结果：

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377752_20201231135552854_742681493.png)


flyway在升级数据库的时候，会检查已经执行过的版本对应的脚本是否发生变化，包括脚本文件名，以及脚本内容。如果flyway检测到发生了变化，则抛出错误，并终止升级。

如果已经执行过的脚本没有发生变化，flyway会跳过这些脚本，依次执行后续版本的脚本，并在记录表中插入对应的升级记录。

所以，flyway总是幂等的，而且可以支持跨版本的升级。

如果你好奇，flyway如何检查脚本文件的内容是否有修改。你可以注意以下记录表中有一个字段checksum，它记录了脚本文件的校验和。flyway通过比对文件的校验和来检测文件的内容是否变更。

使用上面的方式，升级一个空的数据库，或者在一直使用flyway升级方案的数据库上进行升级，都不会又问题。但是，如果在已有的数据库引入flyway，就需要一些额外的工作。

flyway检测数据库中是否有历史记录表，没有则代表是第一次升级。此时，flyway要求数据库是空的，并拒绝对数据库进行升级。

你可以设置baseline-on-migrate参数为true，flyway会自动将当前的数据库记录为V1版本，然后执行升级脚本。这也表示用户所准备的脚本中，V1版本的脚本会被跳过，只有V1之后的版本才会被执行。


## 命令行使用
flyway 提供命令行工具, 常用的命令包括:
Clean: 删除所有创建的数据库对象, 包括用户、表、视图等. 注意不要在生产库上执行 clean 操作.
Migrate: 对数据库依次应用版本更改.
Info: 获取目前数据库的状态. 那些迁移已经完成, 那些迁移待完成. 所有迁移的执行时间以及结果.
Validate: 验证已 Apply 的脚本是否有变更, Flyway 的 Migration 默认先做 Validate.
Baseline: 根据现有的数据库结构生成一个基准迁移脚本.
Repair: 修复命令尽量不要使用, 修复场景有: 1. 移除失败的 migration 记录. 2.已经应用的 SQL 脚本被修改, 我们想重新应用该 SQL 脚本.


##  与SpringBoot集成

对于 SpringBoot 项目开发, 其实不需要专门安装 flyway 命令行工具和 maven 插件, SpringBoot 启动就会自动执行 DB migrate 操作

![](https://gitee.com/owen2016/pic-hub/raw/master/1610377750_20201231135243551_613722733.png)

## Jenkins集成 

```
stage('Apply DB changes') {

    agent {
        docker {
            image 'boxfuse/flyway:5.2.4'
            args '-v ./db/migration:/flyway/sql --entrypoint=\'\''
        }
    }

    steps {
        sh "/flyway/flyway -url=jdbc:mariadb://mariadb_service -schemas=${MYSQL_DATABASE} -table=schema_version -connectRetries=60 info"
    }

}
```

## flyway 最佳实践


1. SQL 的文件名
开发环境和生产环境的 migration SQL 不共用. 开发过程往往是多人协作开发, DB migration 也相对比较频繁, 所以 SQL 脚本会很多. 而生产环境 DB migration 往往由 DBA 完成, 每次升级通常需要提交一个 SQL 脚本.

(1). 开发环境 SQL 文件建议采用时间戳作为版本号.
开发环境 SQL 文件建议采用时间戳作为版本号, 多人一起开发不会导致版本号争用, 同时再加上生产环境的版本号, 这样的话, 将来手工 merge 成生产环境 V1.2d migration 脚本也比较方便, SQL 文件示例:
V20180317.10.59__V1.2_Unique_User_Names.sql
V20180317.14.59__V1.2_Add_SomeTables.sql

(2). 生产环境 SQL 文件, 应该是手动 merge 开发环境的 SQL 脚本, 版本号按照正常的版本, 比如 V2.1.5_001__Unique_User_Names.sql

2. migration 后的SQL 脚本不应该再被修改.

3. spring.flyway.outOfOrder 取值 true /false
对于开发环境, 可能是多人协作开发, 很可能先 apply 了自己本地的最新 SQL 代码, 然后发现其他同事早先时候提交的 SQL 代码还没有 apply, 所以 开发环境应该设置 spring.flyway.outOfOrder=true, 这样 flyway 将能加载漏掉的老版本 SQL 文件; 而生产环境应该设置 spring.flyway.outOfOrder=false

4. 多个系统公用要 DB schema
很多时候多个系统公用一个 DB schema , 这时候使用 spring.flyway.table 为不同的系统设置不同的 metadata 表, 缺省为 flyway_schema_history

## 参考

https://blog.waterstrong.me/flyway-in-practice/
http://www.huangbowen.net/blog/2015/04/08/introduction-of-flyway/
http://dbabullet.com/index.php/2018/03/29/best-practices-using-flyway-for-database-migrations/
https://woodylic.github.io/2017/03/23/manage-database-migration-using-maven-and-flyway/
http://blog.didispace.com/spring-boot-flyway-db-version/
http://coyee.com/article/12092-database-versioning-with-flyway-and-java


