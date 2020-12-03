# Elasticsearch 索引模板

[TOC]

Elasticsearch 不要求你在使用一个索引前创建它。 对于日志记录类应用，依赖于自动创建索引比手动创建要更加方便。

Logstash 使用事件中的时间戳来生成索引名。 默认每天被索引至不同的索引中，因此一个 @timestamp 为 2014-10-01 00:00:01 的事件将被发送至索引 logstash-2014.10.01 中。 如果那个索引不存在，它将被自动创建

通常我们想要控制一些新建索引的设置（settings）和映射（mappings）。也许我们想要限制分片数为 1 ，并且禁用 _all 域。 索引模板可以用于控制何种设置（settings）应当被应用于新创建的索引：

## 模板简述

索引可使用预定义的模板进行创建,这个模板称作`Index templates`。模板设置包括 settings 和 mappings，通过模式匹配的方式使得多个索引重用一个模板。

1. settings主要作用于index的一些相关配置信息，如分片数、副本数，tranlog同步条件、refresh等。

2. mappings主要是一些说明信息，大致又分为_all、_source、prpperties这三部分：

   1. _all：主要指的是AllField字段，我们可以将一个或多个都包含进来，在进行检索时无需指定字段的情况下检索多个字段。设置“_all" : {"enabled" : true}  

   2. _source：主要指的是SourceField字段，Source可以理解为ES除了将数据保存在索引文件中，另外还有一份源数据。_source字段在我们进行检索时相当重要，如果在{"enabled" : false}情况下默认检索只会返回ID， 你需要通过Fields字段去到索引中去取数据，效率不是很高。但是enabled设置为true时，索引会比较大，这时可以通过Compress进行压缩和inclueds、excludes来在字段级别上进行一些限制，自定义哪些字段允许存储。  

   3. properties：这是最重要的步骤，主要针对索引结构和字段级别上的一些设置。

        ``` shell
        PUT /_template/my_logs #创建一个名为 my_logs 的模板
        {
        "template": "logstash-*", #将这个模板应用于所有以 logstash- 为起始的索引
        "order":    1,           #这个模板将会覆盖默认的 logstash 模板，因为默认模板的 order 更低
        "settings": {
            "number_of_shards": 1  #限制主分片数量为 1
        },
        "mappings": {
            "_default_": {
            "_all": {
                "enabled": false  #为所有类型禁用 _all 域
            }
            }
        },
        "aliases": {
            "last_3_months": {} #添加这个索引至 last_3_months 别名中
        }
        }
        ```

3. 通常在elasticsearch中 post mapping信息，每重新创建索引便到设置mapping，分片，副本信息。非常繁琐。强烈建议大家通过设置template方式设置索引信息。设置索引名，通过正则匹配的方式匹配到相应的模板。  

    PS: 直接修改mapping的优先级>索引template。索引匹配了多个template，当属性等配置出现不一致的，以order的最大值为准，order默认值为0

## 模板操作

### 创建模板

``` json
{
  "template": "pmall*",
  "settings": {
    "index.number_of_shards": 1,
    "number_of_replicas": 4,
    "similarity": {
      "IgnoreTFSimilarity": {
        "type": "IgoreTFSimilarity"
      }
    }
  },
  "mappings": {
    "_default_": {
      "_source": {
        "enabled": false
      }
    },
    "commodity": {
      "properties": {
        "sold": {
          "type": "long"
        },
        "online_time": {
          "type": "long"
        },
        "price": {
          "type": "long"
        },
        "publish_time": {
          "type": "long"
        },
        "id": {
          "type": "long"
        },
        "catecode": {
          "type": "integer"
        },
        "title": {
          "search_analyzer": "ikSmart",
          "similarity": "IgnoreTFSimilarity",
          "analyzer": "ik",
          "type": "text"
        },
        "content": {
          "index": false,
          "store": true,
          "type": "keyword"
        },
        "status": {
          "type": "integer"
        }
      }
    }
  }
}
```

### 删除模板

`DELETE /_template/template_1`

### 查看模板

`GET /_template/template_1`

也可以通过模糊匹配得到多个模板信息
`GET /_template/temp*`

可以批量查看模板
`GET /_template/template_1,template_2`

验证模板是否存在：
`HEAD _template/template_1`

### 模板优先级

多个模板同时匹配，以order顺序倒排，order越大，优先级越高

``` shell
PUT /_template/template_1
{
    "template" : "*",
    "order" : 0,
    "settings" : {
        "number_of_shards" : 1
    },
    "mappings" : {
        "type1" : {
            "_source" : { "enabled" : false }
        }
    }
}

PUT /_template/template_2
{
    "template" : "te*",
    "order" : 1,
    "settings" : {
        "number_of_shards" : 1
    },
    "mappings" : {
        "type1" : {
            "_source" : { "enabled" : true }
        }
    }
}
```

### 模板版本号

模板可以选择添加版本号，这可以是任何整数值，以便简化外部系统的模板管理。版本字段是完全可选的，它仅用于模板的外部管理。要取消设置版本，只需替换模板即可

创建模板：

``` shell
PUT /_template/template_1
{
    "template" : "*",
    "order" : 0,
    "settings" : {
        "number_of_shards" : 1
    },
    "version": 123
}
```

查看模板版本号： `GET /_template/template_1?filter_path=*.version`

响应如下：

``` json
{
  "template_1" : {
    "version" : 123
  }
}
```

## 自定义模板示例

``` json
elasticsearch{
　　action => "index"
　　hosts => ["xxx"]
　　index => "http-log-logstash"
　　document_type => "logs"
　　template => "opt/http-logstash.json"
　　template_name => "http-log-logstash"
　　template_overwrite => true
}
```

``` json
{
    "template" : "logstash-*", 　　#-------------> 匹配的索引名字
    "order":1,　　#-------------> 代表权重，如果有多个模板的时候，优先进行匹配，值越大，权重越高
    "settings" : { "index.refresh_interval" : "60s" },
    "mappings" : {
        "_default_" : {
            "_all" : { "enabled" : false }, 　　　　　　　"_source" : { "enabled" : false },　　　　　　  "dynamic": "strict",            "dynamic_templates" : [{ 
              "message_field" : {
                "match" : "message",
                "match_mapping_type" : "string", 
                "mapping" : { "type" : "string", "index" : "not_analyzed" } 
              }
            }, {
              "string_fields" : {
                "match" : "*",
                "match_mapping_type" : "string", 
                "mapping" : { "type" : "string", "index" : "not_analyzed" } 
              }
            }],
            "properties" : {
                "@timestamp" : { "type" : "date"}, 
                "@version" : { "type" : "integer", "index" : "not_analyzed" }, 
                "path" : { "type" : "string", "index" : "not_analyzed" }, 
                "host" : { "type" : "string", "index" : "not_analyzed" },
                "record_time":{"type":"date","format": "yyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"}, 
                "method":{"type":"string","index" : "not_analyzed"},
                "unionid":{"type":"string","index" : "not_analyzed"},
                "user_name":{"type":"string","index" : "not_analyzed"},
                "query":{"type":"string","index" : "not_analyzed"},
                "ip":{ "type" : "ip"},
                "webbrower":{"type":"string","index" : "not_analyzed"},
                "os":{"type":"string","index" : "not_analyzed"},
                "device":{"type":"string","index" : "not_analyzed"},
                "ptype":{"type":"string","index" : "not_analyzed"},
                "serarch_time":{"type":"date","format": "yyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"},
                "have_ok":{"type":"string","index" : "not_analyzed"},
                "legal":{"type":"string","index" : "not_analyzed"}
            }
        }
    }
}
```

### 配置项

- template for index-pattern
  只有匹配 logstash-* 的索引才会应用这个模板。有时候我们会变更 Logstash 的默认索引名称，记住你也得通过 PUT 方法上传可以匹配你自定义索引名的模板。当然，我更建议的做法是，把你自定义的名字放在 "logstash-" 后面，变成 index => "logstash-custom-%{+yyyy.MM.dd}" 这样。

- refresh_interval for indexing
  Elasticsearch 是一个近实时搜索引擎。它实际上是每 1 秒钟刷新一次数据。对于日志分析应用，我们用不着这么实时，所以 logstash 自带的模板修改成了 5 秒钟。你还可以根据需要继续放大这个刷新间隔以提高数据写入性能。

- multi-field with not_analyzed
  Elasticsearch 会自动使用自己的默认分词器(空格，点，斜线等分割)来分析字段。分词器对于搜索和评分是非常重要的，但是大大降低了索引写入和聚合请求的性能。所以 logstash 模板定义了一种叫"多字段"(multi-field)类型的字段。这种类型会自动添加一个 ".raw" 结尾的字段，并给这个字段设置为不启用分词器。简单说，你想获取 url 字段的聚合结果的时候，不要直接用 "url" ，而是用 "url.raw" 作为字段名。

- geo_point
  Elasticsearch 支持 geo_point 类型， geo distance 聚合等等。比如说，你可以请求某个 geo_point 点方圆 10 千米内数据点的总数。在 Kibana 的 bettermap 类型面板里，就会用到这个类型的数据。

- order
  如果你有自己单独定制 template 的想法，很好。这时候有几种选择：

  1. 在 logstash/outputs/elasticsearch 配置中开启 manage_template => false 选项，然后一切自己动手；
  2. 在 logstash/outputs/elasticsearch 配置中开启 template => "/path/to/your/tmpl.json" 选项，让 logstash 来发送你自己写的 template 文件；
  3. 避免变更 logstash 里的配置，而是另外发送一个 template ，利用 elasticsearch 的 templates order 功能。

这个 order 功能，就是 elasticsearch 在创建一个索引的时候，如果发现这个索引同时匹配上了多个 template ，那么就会先应用 order 数值小的 template 设置，然后再应用一遍 order 数值高的作为覆盖，最终达到一个 merge 的效果。

比如，对上面这个模板已经很满意，只想修改一下 refresh_interval ，那么只需要新写一个：

  ``` json
  {
    "order" : 1,
    "template" : "logstash-*",
    "settings" : {
      "index.refresh_interval" : "20s"
    }
  }
```

然后运行以下命令即可：

`curl -XPUT http://localhost:9200/_template/template_newid -d '@/path/to/your/tmpl.json'`

- set _source 设置为 false
  假设你只关心度量结果，不是原始文件内容。比如，你可以把原始的数据存储在 MySQL ,hbase 等其他地方，从 es 中得到 id 后，去相应的数据库中进行取数据。将节省磁盘空间并减少 IO。

  `“_source”:{“enabled”:false}`

- _all 设置为 false

  假设你确切地知道你对哪个 field 做查询操作？能实现性能提升，缩减存储。
  `“_all”:{“enabled”:false }`

- dynamic设置为 strict

  假设你的数据是结构化数据。字段设置严格，避免脏数据注入。

  `“dynamic”:”strict”`