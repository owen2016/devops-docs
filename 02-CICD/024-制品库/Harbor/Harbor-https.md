# HTTPS配置

如果使用自签名的https证书，仍然会提示证书不受信任的问题。需要将自签名的ca证书发送到所有的docker客户端的指定目录。
关于使用自签名证书配置harbor的具体过程可以参考: https://github.com/goharbor/harbor/blob/master/docs/configure_https.md

https://www.cnblogs.com/pangguoping/p/7650014.html
https://github.com/goharbor/harbor/blob/master/docs/configure_https.md

１. 生成自签名证书key文件

    ```shell
    # mkdir /etc/certs
    # openssl genrsa -out /etc/certs/ca.key 2048 
    Generating RSA private key, 2048 bit long modulus
    ....+++
    ..................................................+++
    e is 65537 (0x10001)
    ```

２．创建自签名证书crt文件
    # openssl req -x509 -new -nodes -key /etc/certs/ca.key -subj "/CN=mc.harbor.com" -days 5000 -out /etc/certs/ca.crt

３．修改Harbor配置文件harbor.cfg
    hostname = mc.harbor.com
    ui_url_protocol = https
    ssl_cert = /etc/certs/ca.crt
    ssl_cert_key = /etc/certs/ca.key

４．开始安装Harbor

    ``` shell
    # ./install.sh
    ✔ ----Harbor has been installed and started successfully.----
    Now you should be able to visit the admin portal at https://mc.harbor.com. 
    For more details, please visit https://github.com/goharbor/harbor .
    ```