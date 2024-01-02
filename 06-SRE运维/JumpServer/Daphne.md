# Daphne
- Daphne is a pure-Python ASGI server for UNIX, maintained by members of the Django project. It acts as the reference server for ASGI.

基本用法:daphne -b 0.0.0.0 -p 8001 django_project.asgi:channel_layer
或者绑定UNIX sockets daphne -u /tmp/daphne.sock django_project.asgi:channel_layer
    -b 指定IP
    -p 指定端口
对于Django项目，django_project.asgi:channel_layer配置文件，需要手动创建asgi文件
例如:

import os
import django
import channels.routing

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "project.settings")
django.setup()
application = channels.routing.get_default_application()
最后执行： daphne -b 0.0.0.0 -p 8001 django_project.asgi:application ，这里需要自行指定p和b参数

作者：小蜗牛的成长
链接：https://www.jianshu.com/p/b17debfecce9
来源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。