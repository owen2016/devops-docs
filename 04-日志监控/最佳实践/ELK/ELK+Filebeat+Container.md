# ELK + Filebeat 分析容器日志

## Filebeat配置

配置信息如下，filebeat.inputs的containers的path按实际情况修改;output.logstash输出组件hosts按实际情况修改

```conf
filebeat.inputs:
- type: docker
  enabled: true
  containers:
    path: "/data01/docker/containers"
    ids:
      - "*"
  processors:
    - add_docker_metadata: ~
  multiline.pattern: '\d{2}:\d{2}:\d{2}.\d{3}'
  multiline.negate: true
  multiline.match: after
output.logstash:
  hosts: ["172.20.222.179:5044"]
```

## Logstash配置

配置信息如下，filter条件和output条件和elasticsearch hosts具体ip地址按实际情况修改

```conf
input {
    beats {
        port => "5044"
    }
}
filter {
    if ![container][labels][io_kubernetes_container_name] {
        drop { }
    }
}
output {
    if "[env=dev]" in [message] {
        elasticsearch {
            hosts => ["172.20.222.195:9200"]
            index => "logstash-dev-%{+YYYY.MM.dd}"
        }
    }

    if "[env=test]" in [message] {
        elasticsearch {
            hosts => ["172.20.222.195:9200"]
            index => "logstash-test-%{+YYYY.MM.dd}"
        }
    }

    if "[env=stage]" in [message] {
        elasticsearch {
            hosts => ["172.20.222.195:9200"]
            index => "logstash-stage-%{+YYYY.MM.dd}"
        }
    }

    if "[env=prod]" in [message] {
        elasticsearch {
            hosts => ["172.20.222.195:9200"]
            index => "logstash-prod-%{+YYYY.MM.dd}"
        }
    }
}
```