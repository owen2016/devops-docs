# simple.yml

```
global:
  smtp_smarthost: 'smtp.163.com:25'
  smtp_from: 'jugglee@163.com'
  smtp_auth_username: 'jugglee@163.com'
  smtp_auth_password: 'admin123'
  smtp_require_tls: false

templates:
  - '/alertmanager/template/*.tmpl'

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 10m
  receiver: default-receiver

receivers:
- name: 'default-receiver'
  email_configs:
  - to: 'whiiip@163.com'
    html: '{{ template "alert.html" . }}'
    headers: { Subject: "[WARN] 报警邮件test" }

```