# View、APIView、GenericAPIView

https://zhuanlan.zhihu.com/p/72527077?utm_source=com.doc360.client


首先讲两个概念，FBV开发模式与CBV开发模式

- FBV指的时Function Base View，基于函数开发视图
   ```
  def index(request):
       return HttpResponse()
  ```
- CBV指的时Class Base View，基于类开发视图

  ```
  from django.views import View

  class Index(View):
      def get(self, request):
         return HttpResponse(）
      def post(self, request):
          return HttpResponse(）
  ```
**CBV相比较FBV有什么好处呢？**
1. 可以用不同的函数针对不同的HTTP方法处理，而不是通过很多if判断，提高代码可读性；
2. python多继承特性，可以使用面向对象的技术，比如Mixin（多继承），提高了代码的复用性。

本文仅讨论CBV模式中，APIView、GenericAPIView、ViewSet的使用与区别，以及部分源代码实现，继承关系

## View
上述例子中可以看到视图类继承了django的View，这就是我们介绍的View，可以看到，**View是django自带的模块**，View内部的as_view方法和dispatch方法，实现了http请求可通过不同的http请求方法走到不同的函数中。

## APIView
**APIView是django rest framework框架中的基类**，使用前需要安装dj_rest_framework。**APIView继承了django中的View，所以也具有View的特性，相比较View进行了封装**，主要内容有：

1. 传入到视图方法中的是REST framework的Request对象，而不是Django的HttpRequeset对象；
2. 视图方法可以返回REST framework的Response对象，视图会为响应数据设置（render）符合前端要求的格式；
3. 任何APIException异常都会被捕获到，并且处理成合适的响应信息；
4. 在进行dispatch()分发前，会对请求进行身份认证、权限检查、流量控制。

**支持定义的属性：**
    - authentication_classes 列表或元祖，身份认证类
    - permissoin_classes 列表或元祖，权限检查类
    - throttle_classes 列表或元祖，流量控制类

在APIView中仍以常规的类视图定义方法来实现get() 、post() 或者其他请求方式的方法。

## GenericAPIView
- 继承自APIVIew，增加了对于列表视图和详情视图可能用到的通用支持方法。通常使用时，可搭配一个或多个Mixin扩展类。

**支持定义的属性：**

1. 列表视图与详情视图通用：

- queryset 列表视图的查询集
- serializer_class 视图使用的序列化器

2. 列表视图使用：
- pagination_class 分页控制类
- filter_backends 过滤控制后端

3. 详情页视图使用：
- lookup_field 查询单一数据库对象时使用的条件字段，默认为'pk'
- lookup_url_kwarg 查询单一数据时URL中的参数关键字名称，默认与look_field相同

**提供的方法：**

1. 列表视图与详情视图通用：

- get_queryset(self)
返回视图使用的查询集，是列表视图与详情视图获取数据的基础，默认返回queryset属性，可以重写，例如：
```
def get_queryset(self):
    user = self.request.user
    return user.accounts.all()
```

- get_serializer_class(self)
返回序列化器类，默认返回serializer_class，可以重写，例如：

```
def get_serializer_class(self):
    if self.request.user.is_staff:
        return FullAccountSerializer
    return BasicAccountSerializer
```

- get_serializer(self, args, *kwargs)
返回序列化器对象，被其他视图或扩展类使用，如果我们在视图中想要获取序列化器对象，可以直接调用此方法。

注意，在提供序列化器对象的时候，REST framework会向对象的context属性补充三个数据：request、format、view，这三个数据对象可以在定义序列化器时使用。

2. 详情视图使用：

- get_object(self) 返回详情视图所需的模型类数据对象，默认使用lookup_field参数来过滤queryset。 在试图中可以调用该方法获取详情信息的模型类对象。

若详情访问的模型类对象不存在，会返回404。该方法会默认使用APIView提供的check_object_permissions方法检查当前对象是否有权限被访问。

*url(r'^books/(?P<pk>\d+)/$', views.BookDetailView.as_view()),*

```
class BookDetailView(GenericAPIView):
    queryset = BookInfo.objects.all()　　　　# BookInfo为自己定义的模型数据类
    serializer_class = BookInfoSerializer    # 自己定义的序列化器

    def get(self, request, pk):
        book = self.get_object()
        serializer = self.get_serializer(book)
        return Response(serializer.data)
```


GenericAPIView更多的是搭配Mixin扩展类来实现部分功能，我们本章不过多介绍Mixin扩展类。queyset和serializer_class 是后续ViewSet视图集中重要的属性，也需要了解详细。

后面会介绍ViewSet和Mixin扩展类，今天先这样吧。总之不管是APIView还是GenericAPIView，都是为了能让开发者更有效、更方便地开发符合REST规范接口。
