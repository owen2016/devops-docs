# Nginx 使用示例

## 密码访问nginx

1.安装（http://www.letuknowit.com/post/12.html）
    ubuntu的好处体现出来了，输入htpasswd，系统会提示在哪个包中可以找到，有两个包apache2-utils和mini-httpd都有htpasswd，我们这里选apache2-utils。

    sudo apt-get install apache2-utils

2.使用htpasswd命令创建密码文件htpasswd
    htpasswd -cb /application/nginx/conf/htpasswd <username> <password>

3.配置nginx.conf文件
    添加两行：
        auth_basic "Please input password";
        auth_basic_user_file /usr/local/src/nginx/htpasswd;

4.重启

htpasswd命令选项参数说明

``` shell
-c 创建一个加密文件 
-n 不更新加密文件，只将htpasswd命令加密后的用户名密码显示在屏幕上 
-m 默认htpassswd命令采用MD5算法对密码进行加密 
-d htpassswd命令采用CRYPT算法对密码进行加密 
-p htpassswd命令不对密码进行进行加密，即明文密码 
-s htpassswd命令采用SHA算法对密码进行加密 
-b htpassswd命令行中一并输入用户名和密码而不是根据提示输入密码 
-D 删除指定的用户
```

删除
    htpasswd -D <file> <username>

## 实现文件下载

参考：https://www.cnblogs.com/chenjianxiang/p/8479814.html

nginx配置：
    #资源下载
    location ~*\.(zip|rar) { 
        root /home/upload/sourcefile/; 
    }

重启服务：
    sudo systemctl restart nginx

浏览器下载：
    http://<domain>:<port>/xxx.zip
