# sudo

 sudo是linux下常用的允许普通用户使用超级用户权限的工具，允许系统管理员让普通用户执行一些或者全部的root命令，如halt，reboot，su等等。这样不仅减少了root用户的登陆和管理时间，同样也提高了安全性。Sudo不是对shell的一个代替，它是面向每个命令的。
   它的特性主要有这样几点：
       1、sudo能够限制用户只在某台主机上运行某些命令。
       2、sudo提供了丰富的日志，详细地记录了每个用户干了什么。它能够将日志传到中心主机或者日志服务器。
       3、sudo使用时间戳文件--日志 来执行类似的“检票”系统。当用户调用sudo并且输入它的密码时，用户获得了一张存活期为5分钟的票（这个值可以在编译的时候改变）。
       4、sudo的配置文件是**/etc/sudoers**，属性必须为0440，它允许系统管理员集中的管理用户的使用权限和使用的主机。


## su命令：switch user

用户切换：两种，登录式和非登录式
（1）登录式切换：su - user，su -l user
（2）非登录式切换：su user -c 'COMMAND'

查看帮助文档：man sudo

## sudo命令：类似于以管理员身份运行
以另外一个用户身份执行指定的命令
授权机制：通过sudo的授权文件实现，/etc/sudoers

查看帮助文档：man sudoers

授权文件有两类内容：

别名的定义，即为变量；
授权项，可使用别名进行授权，要先定义别名；
授权项（每一行一个授权项）格式：
who where=(runas) commands
user hosts=(runas) commands

谁 通过哪些主机=（以谁的身份） 运行什么命令

查看帮助文档：man visudo
使用visudo编辑/etc/sudoers文件，直接输入visudo命令

注意：用户通过sudo获得的授权，只能以sudo命令来启动；wheel组拥有管理员权限；

 
### sudo命令用法
```
sudo [ -Vhl LvkKsHPSb ] │ [ -p prompt ] [ -c class│- ] [ -a auth_type ] [-u username│#uid ] command
参数：
-V 显示版本编号
-h 会显示版本编号及指令的使用方式说明
-l 显示出自己（执行 sudo 的使用者）的权限
-v 因为 sudo 在第一次执行时或是在 N 分钟内没有执行（N 预设为五）会问密码，这个参数是重新做一次确认，如果超过 N 分钟，也会问密码
-k 将会强迫使用者在下一次执行 sudo 时问密码（不论有没有超过 N 分钟）
-b 将要执行的指令放在背景执行
-p prompt 可以更改问密码的提示语，其中 %u 会代换为使用者的帐号名称， %h 会显示主机名称
-u username/#uid 不加此参数，代表要以 root 的身份执行指令，而加了此参数，可以以 username 的身份执行指令（#uid 为该 username 的使用者号码）
-s 执行环境变数中的 SHELL 所指定的 shell ，或是 /etc/passwd 里所指定的 shell
-H 将环境变数中的 HOME （家目录）指定为要变更身份的使用者家目录（如不加 -u 参数就是系统管理者 root ）
command 要以系统管理者身份（或以 -u 更改为其他人）执行的指令
```
https://blog.csdn.net/yongchaocsdn/article/details/78680085

https://www.jianshu.com/p/8cbebd4e429a

## Sudo漏洞（CVE-2019-18634）
要确定sudoers配置是否受到影响，可以在Linux或macOS终端上运行“ sudo -l”命令以查看是否已启用“ pwfeedback”选项并在“匹配默认值”中显示该选项。

如果发现已启用，则可以在sudoers配置文件中将“ Defaults pwfeedback”更改为“ Defaults！Pwfeedback”，以禁用那些易受攻击的组件，以防止利用提权漏洞。

## visudo