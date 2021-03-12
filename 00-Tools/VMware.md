# VMware



## VMware 三种联网方式

vmware为我们提供了三种网络工作模式，它们分别是：Bridged（桥接模式）、NAT（网络地址转换模式）、Host-Only（仅主机模式）

![](./_images/vm-network.jpg)

安装了VMware虚拟机后，会在网络连接对话框中多出两个虚拟网卡

![](./_images/vm-1.jpg)

- VMware Network AdepterVMnet1：Host用于与Host-Only虚拟网络进行通信的虚拟网卡
- VMware Network Adepter VMnet8：Host用于与NAT虚拟网络进行通信的虚拟网卡

- VMnet0：用于虚拟`桥接网络`下的虚拟交换机
- VMnet1：用于虚拟`Host-Only网络`下的虚拟交换机
- VMnet8：用于虚拟`NAT网络`下的虚拟交换机

VMnet0：这是VMware用于虚拟桥接网络下的虚拟交换机；
VMnet1：这是VMware用于虚拟Host-Only网络下的虚拟交换机；
VMnet8：这是VMware用于虚拟NAT网络下的虚拟交换机；

### 1. Bridged（桥接模式）

在这种模式下，VMware中的虚拟机就像是局域网中的一台独立的主机，它可以访问网内任何一台机器。

桥接网络环境下需要做到：

1. 手动为虚拟机系统配置IP地址、子网掩码。

2. 在桥接的模式下虚拟机必须与物理机处于同一网段，(举个例子,物理机IP:192.168.1.2，虚拟机IP:192.168.1.3)这样虚拟系统才能和真实主机进行通信。

首先在Vmware中设置网络模式选择bridge，VMware--->VM--->Setting--->NetworkAdapter

![](./_images/vm-brige.jpg)

在Vmware中选择桥接网卡：VMware--->Edit--->VirtualNetworkEditor

![](./_images/vm-brige-2.jpg)

查看主机IP和网段，然后修改虚拟机IP配置，如同配置局域网IP一样，保持在一个网段即可

![](./_images/vm-brige-3.jpg)

![](./_images/vm-brige-4.jpg)

当你想利用VMware在局域网内新建一个虚拟服务器，为局域网用户提供网络服务，就应该选择桥接模式。便可将虚拟机模拟接入主机所在的局域网。桥接网络，相当于，虚拟机与主机同接在一台交换机上，同时上网，虚拟机对物理机网络的直接影响较小~

### 2. NAT（网络地址转换模式）

在NAT网络中，会使用到VMnet8虚拟交换机，`物理机上的VMware Network Adapter VMnet8虚拟网卡`将会和`VMnet8交换机`相连接，来实现物理机与虚拟机之间的通信。

**注意：**VMware Network Adapter VMnet8虚拟网卡仅仅是用于和VMnet8网段通信用的，它并不为VMnet8网段提供路由功能，处于虚拟NAT网络下的Guest是使用虚拟的NAT服务器连接的Internet的。

VMware Network Adapter VMnet8虚拟网卡它仅仅是为Host和NAT虚拟网络下的Guest通信提供一个接口，所以，即便去掉这块虚拟网卡，虚拟机仍然是可以上网的，只是物理机将无法再访问VMnet8网段而已。

NAT网络环境下需要做到：

1. 主机需要开启vmdhcp和vmnat服务。（服务的开启，在我的电脑当中右键“管理”可以设置）

2. NAT模式下的虚拟机的TCP/IP配置信息将由VMnet8(NAT)虚拟网络的DHCP服务器自动分配，需要开启DHCP功能。

首先设置选择虚拟机的网络模式为NAT，VMware--->VMàSetting--->NetworkAdapter

![](./_images/vm-nat-1.jpg)

然后设置VMnet8的IP地址及网关VMware--->Edit--->VirtualNetworkEditor

![](./_images/vm-nat-2.jpg)

采用NAT模式最大的优势是虚拟系统接入互联网非常简单，你不需要进行任何其他的配置，只需要宿主机器能访问互联网即可。 

NAT 模式下的网络，相当于说虚拟机是通过接入物理机连接上的网络，等于物理机是个路由器，申请到一个上网名额，带着隐藏在它下面的虚拟机上网。自然所有虚拟机使用的网络总和都限制在实机一个网络通道内。虚拟机会抢占物理机的网络~对物理机上网会有很大的影响！

### 3. Host-Only（仅主机模式）

在Host-Only模式下，虚拟网络是一个全封闭的网络，它唯一能够访问的就是主机。其实Host-Only网络和NAT网络很相似，不同的地方就是 Host-Only网络没有NAT服务，所以虚拟网络不能连接到Internet。主机和虚拟机之间的通信是通过VMwareNetworkAdepterVMnet1虚拟网卡来实现的。此时如果想要虚拟机上外网则需要主机联网并且网络共享。
首先设置选择虚拟机的网络模式为Host-Only，VMware--->VM--->Setting--->NetworkAdapter





## VMware Tools 增强功能

实现VMware中Ubuntu与主机Windows系统之间的相互复制与粘贴，以及窗口的自由伸缩

1. 在虚拟机VMware的菜单栏选择 虚拟机-->安装VMware Tools...

2. 选中“安装VMware Tools...”之后可以下图路径找到。或者在/media/VMware Tools目录中找到安装软件压缩包

3. 把VMwareTools-xxx.0.0-xxx.tar.gz拷贝到/tmp目录下

4. 在进入/tmp目录下解压VMwareTools-xxx.0.0-xxx.tar.gz文件。解压文件时建议tar不要用-v参数，避免显示解压的文件名占屏。
    `tar -xzf  VMwareTools-xxx.0.0-xxx.tar.gz（想敲就复制粘贴吧！注意后面文件名可能不一样）`

5. 在进入vmware-tools-distrib文件夹中执行`./vmware-install.pl`, 一路回车

最后只需重启(reboot)一下系统就可以愉快的复制粘贴了。
