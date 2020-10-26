# Linux 包管理

## Linux软件安装包的类型

https://blog.csdn.net/wuruiaoxue/article/details/49967953
通常Linux应用软件的安装包有三种：
1） tar包，如software-1.2.3-1.tar.gz。他是使用UNIX系统的打包工具tar打包的。
2） rpm包，如software-1.2.3-1.i386.rpm。他是Redhat Linux提供的一种包封装格式（www.rpmfind.net）。
3） dpkg包，如software-1.2.3-1.deb。他是Debain Linux提供的一种包封装格式。
4)    bin包，如RealPlayer11GOLD.bin,它是realplayer的linux文件下的二进制安装格式，它是源程序经过编译后的一种机器语言。
5）脚本安装文件，这一类格式比较多，例如后缀为sh、pl、run的文件都是脚本文件。不过对于普通用户不太常见。安装这类文件要注意的问题是，多数要给文件先增加可执行权限，否则有可能会提示找不到文件。具体方法：终端或控制台下执行 chmod +x ***.*，然后再安装。

## Linux软件安装包的命名规则

大多数Linux应用软件包的命名也有一定的规律，他遵循： 名称-版本-修正版-类型 。例如：
1）software-1.2.3-1.tar.gz 意味着：软件名称：software ｜版本号：1.2.3 ｜修正版本：1 ｜ 类型：tar.gz，说明是个tar包。
2）sfotware-1.2.3-1.i386.rpm 意味着：软件名称：software ｜ 版本号：1.2.3 ｜修正版本：1 ｜可用平台：i386，适用于Intel 80x86平台 ｜ 类型：rpm，说明是个rpm包。

## apt

**Launchpad **是一个提供维护、支持或连络 Ubuntu 开发者的网站平台，由 Ubuntu 的母公司 Canonical 有限公司所架设。
- https://launchpad.net/ubuntu

**PPA**,表示Personal Package Archives,也就是个人软件包集
很多软件包由于各种原因吧，不能进入官方的Ubuntu软件仓库。为了方便Ubuntu用户使用，launchpad.net提供了ppa,允许用户建立自己的软件仓库，自由的上传软件。PPA也被用来对一些打算进入Ubuntu官方仓库的软件，或者某些软件的新版本进行测试

## yum