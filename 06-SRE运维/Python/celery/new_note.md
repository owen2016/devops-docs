# new_note

[celery+rabbitmq+redis]

Pasted from <https://blog.csdn.net/geniusle201/article/details/86135282> 


![](_v_images/20200526181154572_253634179.png)


https://blog.csdn.net/cuomer/article/details/81214438



celery 监控工具 flower

pip install flower

指定broker并启动：

celery flower --broker=amqp://guest:guest@localhost:5672//  或
celery flower --broker=redis://guest:guest@localhost:6379/0
————————————————
原文链接：https://blog.csdn.net/aspnet_lyc/article/details/76926981
