# Guacamole

http://guacamole.apache.org/


Apache Guacamole is a clientless remote desktop gateway. It supports standard protocols like VNC, RDP, and SSH.


https://github.com/apache/guacamole-client
https://www.freebytes.net/it/java/guacamole-web.html

## Docker Guacamole

```
docker run \
  -p 8090:8080 \
  -p 5433:5432 \
  -v /var/guacamole/:/config \
  oznu/guacamole
```
 
The default username is guacadmin with password guacadmin.

sudo pkill Xorg


docker run --name jms_guacamole \
  -p 127.0.0.1:8081:8080 \
  -e JUMPSERVER_SERVER=http://172.20.249.51 \
  -e BOOTSTRAP_TOKEN=zxffNymGjP79j6BN \
  -e GUACAMOLE_LOG_LEVEL=ERROR \
  jumpserver/jms_guacamole:1.5.9 




