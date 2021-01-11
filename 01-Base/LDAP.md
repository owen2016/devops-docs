# LDAP

LDAP是轻量目录访问协议(Lightweight Directory Access Protocol)的缩写；LDAP标准实际上是在X.500标准基础上产生的一个简化版本。LDAP是一种开放Internet标准，LDAP协议是跨平台的 的Interent协议， 它是基于X.500标准的， 与X.500不同，LDAP支持TCP/IP(即可以分布式部署)

## 目录服务

目录服务就是按照树状存储信息的模式

目录服务的特点？ 目录服务与关系型数据库不同？
- 目录服务的数据类型主要是字符型, 而不是关系数据库提供的整数、浮点数、日期、货币等类型；为了检索的需要添加了BIN（二进制数据）、CIS（忽略大小写）、CES（大小写敏感）、TEL（电话型）等语法（Syntax）
- 同样也不提供象关系数据库中普遍包含的大量的函数
- 目录有很强的查询（读）功能，适合于进行大量数据的检索；但目录一般只执行简单的更新（写）操作，不支持批量更新所需要的事务处理功能
- 它主要面向数据的查询服务（查询和修改操作比一般是大于10:1），不提供事务的回滚（rollback）机制.
- 目录具有广泛复制信息的能力，适合于多个目录服务器同步/更新

常见的目录服务软件
- X.500
- LDAP
- Actrive Directory，Microsoft公司
- NIS

## LDAP
 LDAP是轻量目录访问协议(Lightweight Directory Access Protocol)的缩写；LDAP标准实际上是在X.500标准基础上产生的一个简化版本。LDAP是一种开放Internet标准，LDAP协议是跨平台的 的Interent协议， 它是基于X.500标准的， 与X.500不同，LDAP支持TCP/IP(即可以分布式部署) 

庸俗的讲，可以理解为数据库，因为他是存储数据的东西。但又不能说他是数据库，因为它的功能远远要比数据库简单，它只是一个目录。它具有很强大的查询（读）的功能，适合进行大量数据的检索。它可以快速的查询结果，不过在写方面，就慢的多，所以说适合读不适合写

**LDAP的优势：**
LDAP协议是跨平台的和标准的协议，因此应用程序就不用为LDAP目录放在什么样的服务器上操心了。
LDAP服务器可以用“推”或“拉”的方法复制部分或全部数据，例如：可以把数据“推”到远程的办公室，以增加数据的安全性。复制技术是内置在LDAP服务器中的而且很容易配置。

- LDAP同步配置

```
# Where to store the replica logs for database #1
#replogfile     /var/lib/ldap/master-slapd.replog
 
replogfile /var/lib/ldap/master-slapd.replog
replica         host=192.168.7.108:389
                binddn="cn=admin,dc=ldap,dc=monkey,dc=com,dc=de"
                bindmethod=simple credentials='password'
```

### LDAP 目录结构
在LDAP中目录是按照树型结构组织——目录信息树（DIT）；DIT是一个主要进行读操作的数据库

**DN**
DIT由条目（Entry）组成，条目相当于关系数据库中表的记录；
条目是具有分辨名DN（Distinguished Name）的属性-值对（Attribute-value,简称AV）的集合，DN是该条目在整个树中的唯一名称标识，相当于关系数据库表中的关键字（Primary  Key）；

常见的两种DN设置：
- 基于cn（姓名）
cn=Fran Smith,ou=employees,dc=foobar,dc=com 
最常见的CN是/etc/group转来的条目

- 基于uid（User ID）
uid=fsmith,ou=employees,dc=foobar,dc=com
最常见的UID是/etc/passwd和/etc/shadow转来的条目

***Base DN**
就是"dc=,dc= "; LDAP目录树的最顶部就是根，也就是所谓的“Base DN"。


user和group在ldap中的不同
- 从属ou不同
user属于ou=People
group属于ou=Group

- dn表示方式不同
user的dn用uid打头:uid=news,ou=People,dc=otas,dc=cn
group的dn用cn打头：cn=news,ou=Group,dc=otas,dc=cn

LDAP连接服务器的连接字串格式为：ldap://servername/DN   

其中DN有三个属性，分别是CN,OU,DC   
在 LDAP 目录中，
- DC (Domain Component)
- OU (Organizational Unit)
- CN (Common Name)

![](https://gitee.com/owen2016/pic-hub/raw/master/1604675569_20200731163104418_1107908820.png)

```
ldap目录的根      dc=ldap,dc=monkey,dc=com,dc=de  (基准DN)
                 /       \
ou                       users          groups
                /\      /   \
ou                    user1  user2    it      other
                       /\   /  \
user                             admin bird  goog   qqq


dc=ldap,dc=monkey, dc=com,dc=de
    ou=groups
        ou=it
        ou=purchase
        ou=administration
    ou=customer
        ou=usa
        ou=asia
        ou=japan
    ou=vendor
       ou=usa
       ou=asia
```

LDAP 目录类似于文件系统目录。 
下列目录： 
- DC=redmond,DC=wa,DC=microsoft,DC=com       

如果我们类比文件系统的话，可被看作如下文件路径:    
- Com/Microsoft/Wa/Redmond   

例如：CN=test,OU=developer,DC=domainname,DC=com 
在上面的代码中 cn=test 可能代表一个用户名，ou=developer 代表一个 active directory 中的组织单位。这句话的含义可能就是说明 test 这个对象处在domainname.com 域的 developer 组织单元中

一个单条LDAP记录就是一个条目,即目录条目.目录条目的组成如下:
```
dn: uid=goog,ou=Users,dc=ldap,dc=monkey,dc=com,dc=de (条目名)
objectClass: top
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
objectClass: sambaSamAccount
cn: goog
sn: goog
uid: goog
uidNumber: 1027
gidNumber: 513
homeDirectory: /home/goog
loginShell: /bin/nologin
gecos: System User
description: System User
sambaSID: S-1-5-21-2655127250-259968048-1391940258-3054
sambaPrimaryGroupSID: S-1-5-21-2655127250-259968048-1391940258-513
displayName: System User
sambaPwdMustChange: 2147483647
sambaPasswordHistory: 00000000000000000000000000000000000000000000000000000000
 00000000
sambaAcctFlags: [U          ]
sambaLMPassword: 44EFCE164AB921CAAAD3B435B51404EE
sambaNTPassword: 32ED87BDB5FDC5E9CBA88547376818D4
sambaPwdCanChange: 1178523372
sambaPwdLastSet: 1178523372
userPassword:: e1NNRDV9Q3dOM3BEaStHcnVvMUMrUTEzZm1BU1BDRVl3PQ==

```
每个条目都有一个条目名,即DN(Distinguished Name)
条目是具有区别名DN（Distinguished Name）的属性（Attribute）集合，
属性由类型（Type）和多个值（Values）组成，类型规定了属性允许存放的值的约束条件，同时也规定了该类型的数据进行比较时规则，LDAP中是用语法(syntax)这一概念来表式属性的取值约束和比较规则的。常用的LDAP Syntax是字符型，为了检索的需要添加了BIN（二进制数据）、CIS（忽略大小写）、CES（大小写敏感）、TEL（电话型）等语法（Syntax）， 而不是关系数据库提供的整数、浮点数、日期、货币等类型，同样也不提供象关系数据库中普遍包含的大量的函数，它主要面向数据的查询服务（查询和修改操作比一般是大于10:1），

在属性的基础上LDAP还用schema进一步约束目录条目。schema是一种类型定义机制，每种类型定义又成为objectClass，它规定一个该类型的目录条目实例必须的和可选的属性等其它 约束。和面向对象的编程语言相似，objectClass支持继承，并且所有的objectClass都是 top的子类型，因为top定义了必须的属性objectClass，所以所有的目录条目实例都有objectClass这个属性。

```
Example:
objectclass ( 1.3.6.1.4.1.42.2.27.4.2.10
        NAME 'corbaContainer'
        DESC 'Container for a CORBA object'
        SUP top
        STRUCTURAL
        MUST cn )
```
LDAP中条目的组织一般按照地理位置和组织关系进行组织，非常的直观。LDAP把数据存放在文件中，为提高效率可以使用基于索引的文件数据库，而不是关系数据库

**专用名词解释:**
DN=Distinguished Name 一个目录条目的名字
CN=Common Name 为用户名或服务器名，最长可以到80个字符，可以为中文；
OU=Organization Unit为组织单元，最多可以有四级，每级最长32个字符，可以为中文；
O=Organization 为组织名，可以3—64个字符长
C=Country为国家名，可选，为2个字符长
L=Location 地名，通常是城市的名称
ST 州或省的名称
O=Orgnization 组织名称
STREET 街道地址
UID 用户标识


### LDAP客户端/服务器端交互

1. LDAP客户端发起连接请求与LDAP服务器建立会话，LDAP的术语是绑定(binding)。在 建立绑定时客户端通常需要指定访问用户，以便能够访问服务器上的目录信息。
2. LDAP客户端发出目录查询、新建、更新、删除、移动目录条目、比较目录条目等操作
3. LDAP客户端结束与服务器的会话，即解除绑定(unbinding)

### OpenLDAP

- https://www.openldap.org/

OpenLDAP是轻型目录访问协议（Lightweight Directory Access Protocol，LDAP）的自由和开源的实现，在其OpenLDAP许可证下发行，并已经被包含在众多流行的Linux发行版中。

它主要包括下述4个部分：
- slapd - 独立LDAP守护服务 （slapd是openldap的服务端应用程名，通常也是服务启动名）
- slurpd - 独立的LDAP更新复制守护服务
- 实现LDAP协议的库
- 工具软件和示例客户端

### 常用管理命令

查询是LDAP中最复杂的操作，它允许客户端指定查询的起点、查询的深度、属性需要满足的条件以及最终返回的目录条目所包含的属性。

查询的起点是通过base DN来指定的，查询的深度即范围有三种baseObject, singleLevel, wholeSubtree。baseObject只对base DN指定的目录条目进行查询；singleLevel只对base DN的直接子节点进行查询； wholeSubtree对base DN(包括base DN)的所有子节点查询。属性需要满足的条件是用search filter来表达的。此外，还可以指定别名的解析(Aliase Dereferrencing)和查询的结果集大小限定和查询时间限定

- https://www.cnblogs.com/sitoi/p/11819550.html

使用“ldapsearch” 命令可以验证、查询 ldapserver是否连接访问
`ldapsearch -h 172.26.20.151 -p 389 -x -D "cn=admin,dc=xxxx,dc=com,dc=cn" -w 'Tse*63!s_ecO9idw' -b "AugUserId=xxx,cn=employee,dc=xxx,dc=com,dc=cn"`

## UI管理工具
针对OpenLDAP图形界面管理，开源组织也提供了GUI管理OpenLDAP软件，目前开源的产品有phpLDAPadmin、LDAP Account Manager、Apache Directory Studio、LDAP Admin等管理工具


### Apache Directory Studio

- https://www.cnblogs.com/somata/p/apacheDirectoryStudioSimpleUse.html

### LDAP Browser

- http://ldapbrowserwindows.com/

LDAPSoft Ldap browser is only available on ldap admin tool windows Windows Platform. You can download the free ldap browser using the following download link.



## PAM

https://www.ibm.com/developerworks/cn/linux/1406_liulz_pamopenldap/

https://blog.csdn.net/lws123253/article/details/89354606