# prometheus.yml

## SSL 证书过期时间监测
```
cat << 'EOF' > prometheus.yml
rule_files:
  - ssl_expiry.rules
scrape_configs:
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - example.com  # Target to probe
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115  # Blackbox exporter.
        EOF 
cat << 'EOF' > ssl_expiry.rules 
groups: 
  - name: ssl_expiry.rules 
    rules: 
      - alert: SSLCertExpiringSoon 
        expr: probe_ssl_earliest_cert_expiry{job="blackbox"} - time() < 86400 * 30 
        for: 10m
EOF
```
## HTTP 测试

```
- job_name: 'blackbox_http_2xx'
  scrape_interval: 45s
  metrics_path: /probe
  params:
    module: [http_2xx]  # Look for a HTTP 200 response.
  static_configs:
      - targets:
        - https://www.baidu.com/
        - 172.0.0.1:9090
  relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 10.XXX.XX.XX:9115 

```

## ICMP 测试

```
- job_name: 'blackbox00_ping_idc_ip'
  scrape_interval: 10s
  metrics_path: /probe
  params:
    module: [icmp]  #ping
  static_configs:
      - targets: [ '1x.xx.xx.xx' ]
        labels:
          group: 'xxnginx 虚拟IP'
  relabel_configs:
      - source_labels: [__address__]
        regex: (.*)(:80)?
        target_label: __param_target
        replacement: ${1}
      - source_labels: [__param_target]
        regex: (.*)
        target_label: ping
        replacement: ${1}
      - source_labels: []
        regex: .*
        target_label: __address__
        replacement: 1x.xxx.xx.xx:9115

```

```
  - job_name: 'blackbox_port_status'
    metrics_path: /probe
    params:
      module: [tcp_connect]
    static_configs:
      - targets: ['192.168.4.xxx:8080']
        labels:
          instance: 'port_status'
          group: 'tcp'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 1x.xxx.xx.xx:9115

```

### POST 测试
- 监听业务接口地址，用来判断接口是否在线
- 相关代码块添加到 Prometheus 文件内
- 对应 blackbox.yml文件的 http_post_2xx_query 模块（监听query.action这个接口）

```
- job_name: 'blackbox_http_2xx_post'
  scrape_interval: 10s
  metrics_path: /probe
  params:
    module: [http_post_2xx_query]
  static_configs:
      - targets:
        - https://xx.xxx.com/api/xx/xx/fund/query.action
        labels:
          group: 'Interface monitoring'
  relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 1x.xx.xx.xx:9115  # The blackbox exporter's real hostname:port.

```

### 告警应用测试
icmp、tcp、http、post 监测是否正常可以观察probe_success 这一指标
probe_success == 0 ##联通性异常
probe_success == 1 ##联通性正常
告警也是判断这个指标是否等于0，如等于0 则触发异常报警

```
[sss@prometheus01 prometheus]$ cat rules/blackbox-alert.rules 
groups:
- name: blackbox_network_stats
  rules:
  - alert: blackbox_network_stats
    expr: probe_success == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }}  is down"
      description: "This requires immediate action!"

```



