# Prometheus配置

## 自动发现

自动发现机制方便我们在监控系统中动态的添加或者删除资源。比如zabbix可以自动发现监控主机以及监控资源。而prometheus作为一个可以与zabbix旗鼓相当的监控系统，自然也有它的自动发现机制。file_sd_configs可以用来动态的添加和删除target。

Prometheus 也提供了多种服务发现方式。

- azure_sd_configs
- consul_sd_configs
- dns_sd_configs
- ec2_sd_configs
- openstack_sd_configs
- file_sd_configs
- kubernetes_sd_configs
- marathon_sd_configs
- nerve_sd_configs
- serverset_sd_configs
- triton_sd_configs

### 基于文件发现配置

修改prometheus的配置文件
在scrape_configs下面添加如下配置

```
  - job_name: 'test_server'
    file_sd_configs:
      - files:
        - /app/hananmin/prometheus/file_sd/test_server.json
        refresh_interval: 10s 
```
files表示文件的路径，文件的内容格式是yaml或者json格式,可以用通配符比如*.json。prometheus或定期扫描这些文件，并加载新配置。refresh_interval定义扫描的时间间隔。

创建被扫描的文件test_server.json
```
[
  {
    "targets":  ["10.161.4.63:9091","10.161.4.61:9100"]
  }
]
```
重新加载prometheus的配置
如果间隔时间短的话应该能立刻发现你新加的target

target资源如果变化大的话可以把间隔时间调小点，如果比较稳定的话可以吧间隔时间调大点