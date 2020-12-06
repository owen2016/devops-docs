# Mysql

https://www.cnblogs.com/zxhyJack/p/8596864.html

https://www.cnblogs.com/UniqueColor/p/11150314.html

https://www.cnblogs.com/felordcn/p/12970489.html

https://www.kutu66.com//hulianwang/article_173387

mysql_install_db - 初始化MySQL数据目录

## mysql-卸载
sudo apt-get autoremove --purge mysql-server
sudo apt-get remove mysql-server
sudo apt-get autoremove mysql-server
sudo apt-get remove mysql-common
清理残留数据 dpkg -l |grep mysql|awk '{print $2}' |sudo xargs dpkg -P 


