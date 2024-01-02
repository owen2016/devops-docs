# Celery

- https://docs.celeryproject.org/en/latest/

celery是一个分布式的任务调度模块，可以支持多台不同的计算机执行不同的任务或者相同的任务。

如果要说celery的分布式应用的话，就要提到celery的消息路由机制，提到AMQP协议。

可以有多个"消息队列"（message Queue），不同的消息可以指定发送给不同的Message Queue，

而这是通过Exchange来实现的，发送消息到"消息队列"中时，可以指定routiing_key，Exchange通过routing_key来吧消息路由（routes）到不同的"消息队列"中去。

![](_v_images/20200521095900960_407167591.png =859x)

exchange 对应 一个消息队列(queue)，即：通过"消息路由"的机制使exchange对应queue，每个queue对应每个worker。

```
vi tasks.py

#!/usr/bin/env python
#-*- coding:utf-8 -*-
from celery import Celery

app = Celery()
app.config_from_object("celeryconfig")  # 指定配置文件

@app.task
def taskA(x,y):
return x + y

@app.task
def taskB(x,y,z):
return x + y + z

@app.task
def add(x,y):
return x + y
```

编写配置文件，配置文件一般单独写在一个文件中。

```

vi celeryconfig.py

#!/usr/bin/env python
#-*- coding:utf-8 -*-

from kombu import Exchange,Queue

BROKER_URL = "redis://47.106.106.220:5000/1" 
CELERY_RESULT_BACKEND = "redis://47.106.106.220:5000/2"

CELERY_QUEUES = (
Queue("default",Exchange("default"),routing_key="default"),
Queue("for_task_A",Exchange("for_task_A"),routing_key="for_task_A"),
Queue("for_task_B",Exchange("for_task_B"),routing_key="for_task_B") 
)
# 路由
CELERY_ROUTES = {
'tasks.taskA':{"queue":"for_task_A","routing_key":"for_task_A"},
'tasks.taskB':{"queue":"for_task_B","routing_key":"for_task_B"}
}
```

远程客户端上编写测试脚本
```
vi test.py

from tasks import *
re1 = taskA.delay(100, 200)
print(re1.result)
re2 = taskB.delay(1, 2, 3)
print(re2.result)
re3 = add.delay(1, 2)
print(re3.status)
```

远程客户端上执行脚本可以看到如下输出：

```
python test.py 
300
6
PENDING
```


celery -A tasks worker -l info -n workerA.%h -Q for_task_A

celery -A tasks worker -l info -n workerB.%h -Q for_task_B

celery -A tasks worker -l info -n worker.%h -Q celery


https://www.cnblogs.com/yangjian319/p/9097171.html

https://www.cnblogs.com/alex3714/p/6351797.html

https://blog.csdn.net/qq_33339479/article/details/80961182