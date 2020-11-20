# 常用shell脚本

## 1、Vim自动添加注释及智能换行

``` shell
# vi ~/.vimrc
set autoindent
set tabstop=4
set shiftwidth=4
function AddTitle()
call setline(1,"#!/bin/bash")
call append(1,"#====================================================")
call append(2,"# Author: libin")
call append(3,"# Create Date: " . strftime("%Y-%m-%d"))
call append(4,"# Description: ")
call append(5,"#====================================================")
endf
map <F4> :call AddTitle()<cr>
```

打开文件后，按F4就会自动添加注释，省了不少时间：

## 2、查找并删除/data这个目录7天前创建的文件

``` shell
# find /data -ctime +7 -exec rm -rf {} \;
# find /data -ctime +7 | xargs rm -rf
```

## 3、tar命令压缩排除某个目录

``` shell
# tar zcvf data.tar.gz /data --exclude=tmp    #--exclude参数为不包含某个目录或文件，后面也可以跟多个
```

## 4、查看tar包存档文件，不解压

``` shell
# tar tf data.tar.gz  #t是列出存档文件目录，f是指定存档文件
```

## 5、使用stat命令查看一个文件的属性

``` shel
访问时间（Access）、修改时间（modify）、状态改变时间（Change）
stat index.php
Access: 2018-05-10 02:37:44.169014602 -0500
Modify: 2018-05-09 10:53:14.395999032 -0400
Change: 2018-05-09 10:53:38.855999002 -0400
```

## 6、批量解压tar.gz

``` shell
方法1：
# find . -name "*.tar.gz" -exec tar zxf {} \;
方法2：
# for tar in *.tar.gz; do tar zxvf $tar; done
方法3：
# ls *.tar.gz | xargs -i tar zxvf {}
```

## 7、筛除出文件中的注释和空格

``` shell
方法1：
# grep -v "^#" httpd.conf |grep -v "^$"

方法2：
# sed -e ‘/^$/d’ -e ‘/^#/d’ httpd.conf > http.conf
或者
# sed -e '/^#/d;/^$/d'     #-e 执行多条sed命令

方法3：
# awk '/^[^#]/|/"^$"' httpd.conf
或者
# awk '!/^#|^$/' httpd.conf
```

## 8、筛选/etc/passwd文件中所有的用户

``` shell
方法1：
# cat /etc/passwd |cut -d: -f1

方法2：
# awk -F ":" '{print $1}' /etc/passwd
```

## 9、iptables网站跳转

``` shell
先开启路由转发：
echo "1" > /proc/sys/net/ipv4/ip_forward  #临时生效

内网访问外网（SNAT）：
iptables –t nat -A POSTROUTING -s [内网IP或网段] -j SNAT --to [公网IP]
#内网服务器要指向防火墙内网IP为网关


公网访问内网（DNAT）：
iptables –t nat -A PREROUTING -d [对外IP] -p tcp --dport [对外端口] -j DNAT --to [内网IP:内网端口]
#内网服务器要配置防火墙内网IP为网关，否则数据包回不来。另外，这里不用配置SNAT，因为系统服务会根据数据包来源再返回去。
```

## 10、iptables将本机80端口转发到本地8080端口

``` shell
# iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
```

## 11、find命令查找文件并复制到/opt目录

``` shell
方法1：
# find /etc -name httpd.conf -exec cp -rf {} /opt/ \;:    #-exec执行后面命令，{}代表前面输出的结果，\;结束命令

方法2：
# find /etc -name httpd.conf |xargs -i cp {} /opt     #-i表示输出的结果由{}代替

```

## 12、查看根目录下大于1G的文件

``` shell
# find / -size +1024M
默认单位是b，可以使用其他单位如，C、K、M
```

## 13、查看服务器IP连接数

``` shell
# netstat -tun | awk '{print $5}' | cut -d: -f1 |sort | uniq -c | sort -n  
-tun：-tu是显示tcp和udp连接，n是以IP地址显示
cut -d：-f1：cut是一个选择性显示一行的内容命令，-d指定：为分隔符，-f1显示分隔符后的第一个字段。
uniq -c：报告或删除文中的重复行，-c在输出行前面加上出现的次数
sort -n：根据不同类型进行排序，默认排序是升序，-r参数改为降序，-n是根据数值的大小进行排序
```

## 14、插入一行到391行，包括特殊符号”/“

``` shell
# sed -i "391 s/^/AddType application\/x-httpd-php .php .html/" httpd.conf
```

## 15、列出nginx日志访问最多的10个IP

```shell
方法1：
# awk '{print $1}' access.log |sort |uniq -c|sort -nr |head -n 10
sort ：排序
uniq -c：合并重复行，并记录重复次数
sort -nr ：按照数字进行降序排序

方法2：
# awk '{a[$1]++}END{for(v in a)print v,a[v] |"sort -k2 -nr |head -10"}' access.log
```

## 16、显示nginx日志一天访问量最多的前10位IP

``` shell
# awk '$4>="[16/May/2017:00:00:01" && $4<="[16/May/2017:23:59:59"' access_test.log |sort |uniq -c |sort-nr |head -n 10
# awk '$4>="[16/Oct/2017:00:00:01" && $4<="[16/Oct/2017:23:59:59"{a[$1]++}END{for(i in a){print a[i],i|"sort -k1 -nr |head -n 10"}}' access.log
```

## 17、获取当前时间前一分钟日志访问量

``` shell
# date=`date +%d/%b/%Y:%H:%M --date="-1 minute"` ; awk -vd=$date '$0~d{c++}END{print c}' access.log
# date=`date +%d/%b/%Y:%H:%M --date="-1 minute"`; awk -vd=$date '$4>="["d":00" && $4<="["d":59"{c++}END{print c}' access.log 
# grep `date +%d/%b/%Y:%H:%M --date="-1 minute"` access.log |awk 'END{print NR}'
# start_time=`date +%d/%b/%Y:%H:%M:%S --date="-5 minute"`;end_time=`date +%d/%b/%Y:%H:%M:%S`;awk -vstart_time="[$start_time" -vend_time="[$end_time" '$4>=start_time && $4<=end_time{count++}END{print count}' access.log

```

## 18、找出1-255之间的整数

```shell
方法1：
# ifconfig |grep -o '[0-9]\+'  #+号匹配前一个字符一次或多次
方法2：
# ifconfig |egrep -o '\<([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>'
```

## 19、找出IP地址

```shell
# ifconfig |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'  #-o只显示匹配字符
```

## 20、给文档增加开头和结尾说明信息

``` shell
# awk ‘BEGIN{print "开头显示信息"}{print $1,$NF} END{print "结尾显示信息"}’/etc/passwd
# awk 'BEGIN{printf "  date      ip\n------------------\n"} {print $3,$4} END{printf "------------------\nend...\n"}' /var/log/messages
  date      ip
------------------
03:13:01 localhost
10:51:45 localhost
------------------
end...
```

## 21、查看网络状态命令

``` shell
# netstat -antp #查看所有网络连接
# netstat -lntp #只查看监听的端口信息
# lsof -p pid #查看进程打开的文件句柄
# lsof -i:80  #查看端口被哪个进程占用
```

## 22、生成8位随机字符串

``` shell
方法1：
# echo $RANDOM |md5sum |cut -c 1-8

方法2：
# openssl rand -base64 4
方法3：

# cat /proc/sys/kernel/random/uuid | cut -c 1-8
```

## 23、while死循环

``` shell
while true; do  #条件精确等于真，也可以直接用条件[ "1" == "1" ]，条件一直为真
     ping -c 2 www.baidu.com
done
```

## 24.awk格式化输出

``` shell
将文本列进行左对齐或右对齐。
左对齐：
# awk '{printf "%-15s %-10s %-20s\n",$1,$2,$3}' test.txt
右对齐：
# awk '{printf "%15s %10s %20s\n",$1,$2,$3}' test.txt
```

## 25.整数运算保留小数点

``` shell
方法1：
# echo 'scale=2; 10/3;'|bc  #scale参数代表取小数点位数
方法2：
# awk BEGIN'{printf "%.2f\n",10/3}'
```

## 26.数字求和

``` shell
# cat a.txt
10
23
53
56
方法1：
#!/bin/bash
while read num;
        do
        sum=`expr $sum + $num`
done < a.txt
        echo $sum
方法2：

# cat a.txt |awk '{sum+=$1}END{print sum}'
```

## 27、判断是否为数字（字符串判断也如此）

``` shell
# [[ $num =~ ^[0-9]+$ ]] && echo yes || echo no    #[[]]比[]更加通用，支持模式匹配=~和字符串比较使用通配符`
^ $：从开始到结束是数字才满足条件
=~：一个操作符，表示左边是否满足右边（作为一个模式）正则表达式
```

## 28、删除换行符并将空格替换别的字符

``` shell
# cat a.txt |xargs echo -n |sed 's/[ ]/|/g'  #-n 不换行
# cat a.txt |tr -d '\n'  #删除换行符
```

## 29、查看文本中20至30行内容（总共100行）

``` shell
方法1：
# awk '{if(NR > 20 && NR < 31) print $0}' test.txt
方法2：
# sed -n '20,30p' test.txt
方法3：
# head -30 test.txt |tail
```

## 30、文本中两列位置替换

``` shell
# cat a.txt
60.35.1.15      www.baidu.com
45.46.26.85     www.sina.com.cn
# awk '{print $2"\t"$1}'  a.txt

```

## 31、监控目录，新创建的文件名追加到日志中

``` shell
#要安装inotify-tools软件包

#!/bin/bash
MON_DIR=/opt
inotifywait -mq --format %f -e create $MON_DIR |\
while read files; do
  echo $files >> test.log
done
```

## 32、find一次查找多个指定文件类型

``` shell
# find ./ -name '*.jpg' -o -name '*.png'

# find ./ -regex ".*\.jpg\|.*\.png"
```

## 33、字符串拆分

``` shell
# echo "hello" |awk -F '' '{for(i=1;i<=NF;i++)print $i}'

# echo "hello" |sed 's/./&\n/g'

# echo "hello" |sed -r 's/(.)/\1\n/g'
```

## 34、实时监控命令运行结果

``` shell
# watch -d -n 1 'ifconfig'
```

## 35、解决邮件乱码问题

``` shell
# echo `echo "content" | iconv -f utf8 -t gbk` | mail -s "`echo "title" | iconv -f utf8 -t gbk`" xxx@163.com

注：通过iconv工具将内容字符集转换
```

## 36、在文本中每隔三行添加一个换行或内容

``` shell
# sed '4~3s/^/\n/' file

# awk '$0;NR%3==0{print "\n"}' file

# awk '{print NR%3?$0:$0 "\n"}' file
```

## 37、删除匹配行及后一行或前一行

``` shell
# sed '/abc/,+1d' file  #删除匹配行及后一行

# sed '/abc/{n;d}' file #删除后一行

# tac file |sed '/abc/,+1d' |tac  #删除前一行
```

## 38、统计总行数

``` shell
效率1 # wc -l file  

效率2 # grep -c . file

效率3 # awk 'END{print NR}' file

效率4 # sed -n '$=' file
```

## 39、去除文本开头和结尾空格

``` shell
# sed -i 's/^[ \t]*//;s/[ \t]*$//' file
```

## 40、给单个IP加单引号

``` shell
# echo '10.10.10.1 10.10.10.2 10.10.10.3' |sed -r 's/[^ ]+/"&"/g'

# echo '10.10.10.1 10.10.10.2 10.10.10.3' |awk '{for(i=1;i<=NF;i++)printf "\047"$i"\047"}'
```

## 41、脚本中打印等待时间

``` shell
wait(){
echo -n "wait 3s"
for ((i=1;i<=3;i++)); do
    echo -n "."
    sleep 1
done
echo 
}
wait
```

## 42、删除指定行

```shell
# awk 'NR==1{next}{print $0}' file #$0可省略

# awk 'NR!=1{print}' file

# awk 'NR!=1{print $0}' 或删除匹配行：awk '!/test/{print $0}'

# sed '1d' file

# sed -n '1!p' file
```

## 43、在指定行前后加一行

``` shell
在第二行前一行加txt：

# awk 'NR==2{sub('/.*/',"txt\n&")}{print}' a.txt 

# sed'2s/.*/txt\n&/' a.txt

在第二行后一行加txt：

# awk 'NR==2{sub('/.*/',"&\ntxt")}{print}' a.txt

# sed'2s/.*/&\ntxt/' a.txt
```

## 44、通过IP获取网卡名

``` shell
# ifconfig |awk -F'[: ]' '/^eth/{nic=$1}/192.168.18.15/{print nic}'
```

## 45、浮点数运算（数字46保留小数点）

``` shell
# awk 'BEGIN{print 46/100}'  
0.46

# echo 46|awk '{print $0/100}'
0.46

# awk 'BEGIN{printf "%.2f\n",46/100}'
0.46

# echo 'scale=2;46/100' |bc|sed 's/^/0/'
0.46

# printf "%.2f\n" $(echo "scale=2;46/100" |bc)
0.46
```

## 46、浮点数比较

``` shell
方法1：
if [ $(echo "4>3"|bc) -eq 1 ]; then
    echo yes
else
    echo no
fi

方法2：
if [ $(awk 'BEGIN{if(4>3)print 1;else print 0}') -eq 1 ]; then
    echo yes
else
    echo no
fi
```

## 47、替换换行符为逗号

``` shell
$ cat a.txt
1:
2
3
替换后：1,2,3

方法1：
$ tr '\n' ',' < a.txt
$ sed ':a;N;s/\n/,/;$!b a' a.txt
$ sed ':a;$!N;s/\n/,/;t a' a.txt  :

方法2：
while read line; do
    a+=($line)
done < a.txt
echo ${a[*]} |sed 's/ /,/g'

方法3：
awk '{s=(s?s","$0:$0)}END{print s}' a.txt

#三目运算符(a?b:c)，第一个s是变量，s?s","$0:$0,第一次处理1时，s变量没有赋值为假，结果打印1，第二次处理2时，s值是1，为真，结果1,2。以此类推，小括号可以不写。
awk '{if($0!=3)printf "%s,",$0;else print $0}' a.txt
```

## 48、windows下文本到linux下隐藏格式去除

``` shell
方法1：打开文件后输入
:set fileformat=unix

方法2：打开文件后输入
:%s/\r*$//  #^M可用\r代替

方法3：
sed -i 's/^M//g' a.txt  #^M的输入方式是ctrl+v,然后ctrl+m

方法4：
dos2unix a.txt
```

## 49、xargs巧用

``` shell
xargs -n1  #将单个字段作为一行
# cat a.txt
1 2 
3 4

# xargs -n1 < a.txt
1
2
3
4
xargs -n2 #将两个字段作为一行
$ cat b.txt
string
number
a
1
b
2
$ xargs -n2 < a.txt
string number
a 1
b 2
```

## 50、统计当前目录中以.html结尾的文件总大小

``` shell
方法1：
# find . -name "*.html" -maxdepth 1 -exec du -b {} \; |awk '{sum+=$1}END{print sum}'

方法2：
for size in $(ls -l *.html |awk '{print $5}'); do
    sum=$(($sum+$size))
done
echo $sum
递归统计：
# find . -name "*.html" -exec du -k {} \; |awk '{sum+=$1}END{print sum}'
```

## 51、清除系统缓存，空出更多内存

``` shell
free && sync && echo 3 > /proc/sys/vm/drop_caches && free
```

## 52、杀掉僵尸进程

``` shell
kill $(ps -A -ostat,ppid | awk '/[zZ]/ && !a[$2]++ {print $2}')
```

## 53、监看本机网卡端口情况

``` shell
tcpdump -n -vv tcp port $1 -i em1  #em1为对应的网卡名称。
```

## 54、检查本机连接数

``` shell
netstat -nat |awk '{print $6}'|sort|uniq -c|sort -nr
```

## 55、查看tomcat日志中的异常

``` shell
tail -F /var/log/tomcat8/catalina.out |grep -E 'Exception|at' |grep -v WARN  #这里tomcat8要对应成你的相应版本
```

## 56、删除5天以前的tomcat日志

``` shell
sudo find /var/lib/tomcat8/logs/ -mtime +5 -exec rm {} \;
```


