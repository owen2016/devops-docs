# linux 后台运行进程：& , nohup

[TOC]

当我们在终端或控制台工作时，可能不希望由于运行一个作业而占住了屏幕，因为可能还有更重要的事情要做，比如阅读电子邮件。对于密集访问磁盘的进程，我们更希望它能够在每天的非负荷高峰时间段运行(例如凌晨)。为了使这些进程能够在后台运行，也就是说不在终端屏幕上运行，有几种选择方法可供使用。

## 后台执行

**比较下 & 与 nohup：**

- & ：后台运行，但用户终端退出时（断连），命令结束
- nohup test.sh & : 后台运行，用户终端退出时（断连）依然保持运行，可使用标准输入输出

### &

当在前台运行某个作业时，终端被该作业占据；可以在命令后面加上& 实现后台运行。e.g. `sh test.sh &`

适合在后台运行的命令有f i n d、费时的排序及一些s h e l l脚本。在后台运行作业时要当心：需要用户交互的命令不要放在后台执行，因为这样你的机器就会在那里傻等。不过，作业在后台运行一样会将结果输出到屏幕上，干扰你的工作。如果放在后台运行的作业会产生大量的输出，最好使用下面的方法把它的输出重定向到某个文件中：

`command > out.file 2>&1 &`
这样，所有的标准输出和错误输出都将被重定向到一个叫做out.file 的文件中。

PS：当你成功地提交进程以后，就会显示出一个进程号，可以用它来监控该进程，或杀死它。(ps -ef | grep 进程号 或者 kill -9 进程号）

### nohup

使用&命令后，作业被提交到后台运行，当前控制台没有被占用，但是一但把当前控制台关掉(退出帐户时)，作业就会停止运行。nohup命令可以在你退出帐户之后继续运行相应的进程。nohup就是不挂起的意思( no hang up / ignoring hangup signals) 即 忽略挂起信号一直在后台执行。

`语法: nohup Command [ Arg … ] [& ]`

`e.g. $nohup python manage.py runserver &`

**使用时注意:**

在当shell中提示了nohup成功后，还需要按终端上键盘任意键退回到shell输入命令窗口，然后通过在shell中输入exit来退出终端；如果在nohup执行成功后直接点关闭程序按钮关闭终端的话，这时候会断掉该命令所对应的session，导致nohup对应的进程被通知需要一起shutdown，起不到关掉终端后调用程序继续后台运行的作用。

`nohup command > myout.file 2>&1 &`

无论是否将 nohup 命令的输出重定向到终端，输出都将附加到当前目录的nohup.out 文件中。如果当前目录的nohup.out文件不可写，输出重定向到$HOME/nohup.out文件中。如果没有文件能创建或打开以用于追加，那么 Command 参数指定的命令不可调用。

**2>&1解析:**

`command >out.file 2>&1 &`

- command>out.file是将command的输出重定向到out.file文件，即输出内容不打印到屏幕上，而是输出到out.file文件中。

- 2>&1 是将标准出错 重定向到标准输出，这里的标准输出已经重定向到了out.file文件，即将标准出错也输出到out.file文件中。最后一个&， 是让该命令在后台执行。

试想2>1代表什么，2与>结合代表错误重定向，而1则代表错误重定向到一个文件1，而不代表标准输出；换成2>&1，&与1结合就代表标准输出了，就变成错误重定向到标准输出.

## 查看后台运行的命令

有两个命令可以来查看，`ps` 和 `jobs`。区别在于 jobs 只能查看当前终端后台执行的任务，换了终端就看不见了。而ps命令适用于查看瞬时进程的动态，可以看到别的终端的任务

### jobs

查看当前有多少在后台运行的命令

![](https://gitee.com/owen2016/pic-hub/raw/master/1603718157_20201026141913132_275681253.png)

jobs -l选项可显示所有任务的PID，jobs的状态可以是running, stopped, Terminated。但是如果任务被终止了（kill），shell 从当前的shell环境已知的列表中删除任务的进程标识。

“+”代表最近的一个任务（当前任务），“-”代表之前的任务。

![](https://gitee.com/owen2016/pic-hub/raw/master/1603718158_20201026143108907_1737208027.png)

只有在当前命令行中使用 nohup和& 时，jobs命令才能将它显示出来。如果将他们写到 .sh 脚本中，然后执行脚本，是显示不出来的

比如执行下面这个脚本后，jobs 显示不出来：

``` shell
#!/bin/bash
nohup java -Dfile.encoding=UTF-8 -Dname=Runtime-Name -server -Xms128M -Xmx512M -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M -XX:+HeapDumpOnOutOfMemoryError -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -jar test.jar $1 $2 $3 &
```

### ps

nohup命令可以在你退出帐户/关闭终端之后继续运行相应的进程。关闭中断后，在另一个终端`jobs`已无法看到后台跑得程序了，此时利用ps（进程查看命令）

`ps -aux | grep "test.sh"  #a:显示所有程序 u:以用户为主的格式来显示 x:显示所有程序，不以终端机来区分`

## 关闭当前后台运行的程序

### kill

1. 通过jobs命令查看job号（假设为num），然后执行kill %num

2. 通过ps命令查看job的进程号（PID，假设为pid），然后执行kill pid

前台进程的终止：ctrl+c

## 前后台进程的切换与控制

### ctrl + z 命令

将一个正在前台执行的命令放到后台，并且处于暂停状态。

### fg 命令

将后台中的命令 `调至 前台继续运行`。如果后台中有多个命令，可以用 `fg %jobnumber`（是命令编号，不是进程号）将选中的命令调出

### bg 命令

将一个在后台暂停的命令，`变成在后台继续执行`。如果后台中有多个命令，可以用`bg %jobnumber`将选中的命令调出。

![](https://gitee.com/owen2016/pic-hub/raw/master/1603718158_20201026142920042_1829517779.png)

## 思考

### 问题1-为什么ssh一关闭，程序就不再运行了

元凶：SIGHUP 信号

让我们来看看为什么关掉窗口/断开连接会使得正在运行的程序死掉。

在Linux/Unix中，有这样几个概念：

-  进程组（process group）：`一个或多个进程的集合`，每一个进程组有唯一一个进程组ID，即进程组长进程的ID。

- 会话期（session）：`一个或多个进程组的集合`，有唯一一个会话期首进程（session leader）。会话期ID为首进程的ID。
会话期可以有一个单独的控制终端（controlling terminal）。与控制终端连接的会话期首进程叫做控制进程（controlling process）。当前与终端交互的进程称为前台进程组。其余进程组称为后台进程组。

根据POSIX.1定义：

- 挂断信号（SIGHUP）默认的动作是终止程序。
- 当终端接口检测到网络连接断开，将挂断信号发送给控制进程（会话期首进程）。
- 如果会话期首进程终止，则该信号发送到该会话期前台进程组。

一个进程退出导致一个孤儿进程组中产生时，如果任意一个孤儿进程组进程处于STOP状态，发送SIGHUP和SIGCONT信号到该进程组中所有进程。（关于孤儿进程参照：http://blog.csdn.net/hmsiwtv/article/details/7901711 ）

结论：因此当网络断开或终端窗口关闭后，也就是SSH断开以后，控制进程收到SIGHUP信号退出，会导致该会话期内其他进程退出。

简而言之：就是ssh 打开以后，bash等都是他的子程序，一旦ssh关闭，系统将所有相关进程杀掉！！ 导致一旦ssh关闭，执行中的任务就取消了

**示例：**

打开两个SSH终端窗口，在其中一个运行top命令。

`owen@swarm-manager-105:~$ top`

在另一个终端窗口，找到top的进程ID为 38779，其父进程ID为38751，即登录shell。

``` shell
owen@swarm-manager-105:~$ ps -ef|grep top
owen      24007  23571  0 16:58 tty2     00:00:01 nautilus-desktop
owen      38779  38751  0 20:22 pts/1    00:00:00 top
```

使用pstree命令可以更清楚地看到这个关系：

``` shell
owen@swarm-manager-105:~$ pstree -H 38779|grep top
        |-sshd-+-sshd---sshd---bash---top
```

使用`ps -xj`命令可以看到，登录shell（PID 38751）和top在同一个会话期，shell为会话期首进程，所在进程组PGID为38751，top所在进程组PGID为38779，为前台进程组。

``` shell
owen@swarm-manager-105:~$ ps -xj|grep 38751
 38750  38751  38751  38751 pts/1     38779 Ss    1000   0:00 -bash
 38751  38779  38779  38751 pts/1     38779 S+    1000   0:03 top
```

关闭第一个SSH窗口，在另一个窗口中可以看到top也被杀掉了。

``` shell
owen@swarm-manager-105:~$ ps -ef|grep 38751
owen      40412  38966  0 20:52 pts/4    00:00:00 grep --color=auto 38751
```

### 问题2- 为什么守护程序就算ssh 打开的，就算关闭ssh也不会影响其运行？

因为他们的程序特殊，比如httpd –k start运行这个以后，他不属于sshd这个进程组  而是单独的进程组，所以就算关闭了ssh，和他也没有任何关系！

``` shell
[owen@centos-1 ~]$ pstree |grep http
        |-httpd---8*[httpd]
```

结论：守护进程的启动命令本身就是特殊的，和一般命令不同的，比如mysqld_safe 这样的命令 一旦使用了  就是守护进程运行。所以想把一般程序改造为守护程序是不可能，
