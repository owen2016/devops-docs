# Django-View-扩展

https://www.cnblogs.com/one-tom/p/11345446.html

！！！！五个扩展类！！！！
1）ListModelMixin
列表视图扩展类，提供list(request, *args, **kwargs)方法快速实现列表视图，返回200状态码。

该Mixin的list方法会对数据进行过滤和分页。

源代码：

class ListModelMixin(object):
    """
    List a queryset.
    """
    def list(self, request, *args, **kwargs):
        # 过滤
        queryset = self.filter_queryset(self.get_queryset())
        # 分页
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        # 序列化
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
举例：

from rest_framework.mixins import ListModelMixin
 
class BookListView(ListModelMixin, GenericAPIView):
    queryset = BookInfo.objects.all()
    serializer_class = BookInfoSerializer
 
    def get(self, request):
        return self.list(request)
2）CreateModelMixin
创建视图扩展类，提供create(request, *args, **kwargs)方法快速实现创建资源的视图，成功返回201状态码。

如果序列化器对前端发送的数据验证失败，返回400错误。

源代码：

class CreateModelMixin(object):
    """
    Create a model instance.
    """
    def create(self, request, *args, **kwargs):
        # 获取序列化器
        serializer = self.get_serializer(data=request.data)
        # 验证
        serializer.is_valid(raise_exception=True)
        # 保存
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
 
    def perform_create(self, serializer):
        serializer.save()
 
    def get_success_headers(self, data):
        try:
            return {'Location': str(data[api_settings.URL_FIELD_NAME])}
        except (TypeError, KeyError):
            return {}
3） RetrieveModelMixin
详情视图扩展类，提供retrieve(request, *args, **kwargs)方法，可以快速实现返回一个存在的数据对象。

如果存在，返回200， 否则返回404。

源代码：

class RetrieveModelMixin(object):
    """
    Retrieve a model instance.
    """
    def retrieve(self, request, *args, **kwargs):
        # 获取对象，会检查对象的权限
        instance = self.get_object()
        # 序列化
        serializer = self.get_serializer(instance)
        return Response(serializer.data)
举例：

class BookDetailView(RetrieveModelMixin, GenericAPIView):
    queryset = BookInfo.objects.all()
    serializer_class = BookInfoSerializer
 
    def get(self, request, pk):
        return self.retrieve(request)
4）UpdateModelMixin
更新视图扩展类，提供update(request, *args, **kwargs)方法，可以快速实现更新一个存在的数据对象。

同时也提供partial_update(request, *args, **kwargs)方法，可以实现局部更新。

成功返回200，序列化器校验数据失败时，返回400错误。

源代码：

class UpdateModelMixin(object):
    """
    Update a model instance.
    """
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
 
        if getattr(instance, '_prefetched_objects_cache', None):
            # If 'prefetch_related' has been applied to a queryset, we need to
            # forcibly invalidate the prefetch cache on the instance.
            instance._prefetched_objects_cache = {}
 
        return Response(serializer.data)
 
    def perform_update(self, serializer):
        serializer.save()
 
    def partial_update(self, request, *args, **kwargs):
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)
5）DestroyModelMixin
删除视图扩展类，提供destroy(request, *args, **kwargs)方法，可以快速实现删除一个存在的数据对象。

成功返回204，不存在返回404。

源代码：

class DestroyModelMixin(object):
    """
    Destroy a model instance.
    """
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        return Response(status=status.HTTP_204_NO_CONTENT)
 
    def perform_destroy(self, instance):
        instance.delete()
3. 几个可用子类视图
1） CreateAPIView
提供 post 方法

继承自： GenericAPIView、CreateModelMixin

2）ListAPIView
提供 get 方法

继承自：GenericAPIView、ListModelMixin

3）RetireveAPIView
提供 get 方法

继承自: GenericAPIView、RetrieveModelMixin

4）DestoryAPIView
提供 delete 方法

继承自：GenericAPIView、DestoryModelMixin

5）UpdateAPIView
提供 put 和 patch 方法

继承自：GenericAPIView、UpdateModelMixin

6）RetrieveUpdateAPIView
提供 get、put、patch方法

继承自： GenericAPIView、RetrieveModelMixin、UpdateModelMixin

7）RetrieveUpdateDestoryAPIView
提供 get、put、patch、delete方法

继承自：GenericAPIView、RetrieveModelMixin、UpdateModelMixin、DestoryModelMixin

视图集ViewSet
使用视图集ViewSet，可以将一系列逻辑相关的动作放到一个类中：

list() 提供一组数据
retrieve() 提供单个数据
create() 创建数据
update() 保存数据
destory() 删除数据
ViewSet视图集类不再实现get()、post()等方法，而是实现动作 action 如 list() 、create() 等。

视图集只在使用as_view()方法的时候，才会将action动作与具体请求方式对应上。如：

class BookInfoViewSet(viewsets.ViewSet):
 
    def list(self, request):
        ...
 
    def retrieve(self, request, pk=None):
        ...
在设置路由时，我们可以如下操作

urlpatterns = [
    url(r'^books/$', BookInfoViewSet.as_view({'get':'list'}),
    url(r'^books/(?P<pk>\d+)/$', BookInfoViewSet.as_view({'get': 'retrieve'})
]
action属性
在视图集中，我们可以通过action对象属性来获取当前请求视图集时的action动作是哪个。

例如：

def get_serializer_class(self):
    if self.action == 'create':
        return OrderCommitSerializer
    else:
        return OrderDataSerializer

常用视图集父类
1） ViewSet
继承自APIView，作用也与APIView基本类似，提供了身份认证、权限校验、流量管理等。

在ViewSet中，没有提供任何动作action方法，需要我们自己实现action方法。

2）GenericViewSet
继承自GenericAPIView，作用也与GenericAPIVIew类似，提供了get_object、get_queryset等方法便于列表视图与详情信息视图的开发。

3）ModelViewSet
继承自GenericAPIVIew，同时包括了ListModelMixin、RetrieveModelMixin、CreateModelMixin、UpdateModelMixin、DestoryModelMixin。

4）ReadOnlyModelViewSet
继承自GenericAPIVIew，同时包括了ListModelMixin、RetrieveModelMixin。

视图集中定义附加action动作
在视图集中，除了上述默认的方法动作外，还可以添加自定义动作。

添加自定义动作需要使用rest_framework.decorators.action装饰器。

以action装饰器装饰的方法名会作为action动作名，与list、retrieve等同。

action装饰器可以接收两个参数：

methods: 该action支持的请求方式，列表传递
detail: 表示是action中要处理的是否是视图资源的对象（即是否通过url路径获取主键）
True 表示使用通过URL获取的主键对应的数据对象
False 表示不使用URL获取主键
举例：

from rest_framework import mixins
from rest_framework.viewsets import GenericViewSet
from rest_framework.decorators import action
 
class BookInfoViewSet(mixins.ListModelMixin, mixins.RetrieveModelMixin, GenericViewSet):
    queryset = BookInfo.objects.all()
    serializer_class = BookInfoSerializer
 
    # detail为False 表示不需要处理具体的BookInfo对象
    @action(methods=['get'], detail=False)
    def latest(self, request):
        """
        返回最新的图书信息
        """
        book = BookInfo.objects.latest('id')
        serializer = self.get_serializer(book)
        return Response(serializer.data)
 
    # detail为True，表示要处理具体与pk主键对应的BookInfo对象
    @action(methods=['put'], detail=True)
    def read(self, request, pk):
        """
        修改图书的阅读量数据
        """
        book = self.get_object()
        book.bread = request.data.get('read')
        book.save()
        serializer = self.get_serializer(book)
        return Response(serializer.data)
url的定义

urlpatterns = [
    url(r'^books/$', views.BookInfoViewSet.as_view({'get': 'list'})),
    url(r'^books/latest/$', views.BookInfoViewSet.as_view({'get': 'latest'})),
    url(r'^books/(?P<pk>\d+)/$', views.BookInfoViewSet.as_view({'get': 'retrieve'})),
    url(r'^books/(?P<pk>\d+)/read/$', views.BookInfoViewSet.as_view({'put': 'read'})),
    ]

————————————————
版权声明：本文为CSDN博主「Odyssues_lee」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/Odyssues_lee/java/article/details/80895207
