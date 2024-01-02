# Alertmanager


![](_v_images/20200604151307380_243372992.png =807x)


## 二进制安装

```
cd /usr/local
git clone https://gitlab.com/sunshiwei/alertmanager.git   #基于alertmanager 0.17.0版本
chmod +x alertmanager/alertmanager
注册Alertmanager为系统服务

sudo vim /etc/systemd/system/alertmanager.service
编辑

[Unit]
Description=alertmanager
 
[Service]
User=root
WorkingDirectory=/usr/local/alertmanager/
ExecStart=/usr/local/alertmanager/alertmanager
 
[Install]
WantedBy=default.target
# 启动位置和用户根据实际情况改一下
重新加载systemd
$ sudo systemctl daemon-reload

开机启动
$ sudo systemctl enable alertmanager.service

启动
$ sudo systemctl start alertmanager.service

```

## Docker安装

```
docker run -d \
    --name alertmanager \
    -p 9093:9093 \
    -v /ops/alertmanager/config/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
    prom/alertmanager:latest
```

## 配置AlertManager

```
global:
  resolve_timeout: 5m
  smtp_from: 'xxxxxxxx@qq.com'
  smtp_smarthost: 'smtp.qq.com:465'
  smtp_auth_username: 'xxxxxxxx@qq.com'
  smtp_auth_password: 'xxxxxxxxxxxxxxx'
  smtp_require_tls: false
  smtp_hello: 'qq.com'
route:
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'email'
receivers:
- name: 'email'
  email_configs:
  - to: 'xxxxxxxx@qq.com'
    send_resolved: true
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']

```

global: 全局配置，包括报警解决后的超时时间、SMTP 相关配置、各种渠道通知的 API 地址等等。

```
smtp_smarthost是用于发送邮件的邮箱的SMTP服务器地址+端口
smtp_auth_password是发送邮箱的授权码而不是登录密码
smtp_require_tls不设置的话默认为true，当为true时会有starttls错误，可以用其他办法解决。为了简单这里直接设置为false
templates指出邮件的模板路径
receivers下html指出邮件内容模板名，这里模板名为“alert.html”，在模板路径中的某个文件中定义
headers为邮件标题
```
route: 用来设置报警的分发策略，它是一个树状结构，按照深度优先从左向右的顺序进行匹配。
receivers: 配置告警消息接受者信息，例如常用的 email、wechat、slack、webhook 等消息通知方式。
inhibit_rules: 抑制规则配置，当存在与另一组匹配的警报（源）时，抑制规则将禁用与一组匹配的警报（目标）。

```
level=error ts=2020-06-04T07:46:51.837Z caller=notify.go:372 component=dispatcher msg="Error on notify" err="*smtp.plainAuth auth: unencrypted connection" context_err="context deadline exceeded"
level=error ts=2020-06-04T07:46:51.837Z caller=dispatch.go:301 component=dispatcher msg="Notify for alerts failed" num_alerts=1 err="*smtp.plainAuth auth: unencrypted connection"
```
https://github.com/prometheus/alertmanager/issues/1236
https://godoc.org/net/smtp#PlainAuth
https://stackoverflow.com/questions/11065913/send-email-through-unencrypted-connection
https://www.dazhuanlan.com/2019/12/09/5dedecfe85e5a/


## 配置Prometheus报警规则


## 编写邮件模板

## 启动服务


## alertmanager主要处理流程
（引用：https://www.kancloud.cn/huyipow/prometheus/527563，对alertmanager做了很全面到位的解释）

接收到Alert，根据labels判断属于哪些Route（可存在多个Route，一个Route有多个Group，一个Group有多个Alert）
将Alert分配到Group中，没有则新建Group
新的Group等待group_wait指定的时间（等待时可能收到同一Group的Alert），根据resolve_timeout判断Alert是否解决，然后发送通知
已有的Group等待group_interval指定的时间，判断Alert是否解决，当上次发送通知到现在的间隔大于repeat_interval或者Group有更新时会发送通知


- https://yq.aliyun.com/articles/250063