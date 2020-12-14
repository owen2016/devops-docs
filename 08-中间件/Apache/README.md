# 安装Apache

sudo apt-get install apache2
测试：浏览器访问 http://localhost   //会出现网页。
查看状态： service apache2 status/start/stop/restart

Web目录： /var/www
安装目录： /etc/apache2/
全局配置： /etc/apache2/apache2.conf
监听端口： /etc/apache2/ports.conf
虚拟主机： /etc/apache2/sites-enabled/000-default.conf