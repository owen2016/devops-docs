# GenericAPIView

https://www.cnblogs.com/weihengblog/p/9206353.html
一、GenericAPIView
GenericAPIView扩展了APIView，为标准列表和详细视图添加了常见的行为。

提供的每个具体通用视图都是一个GenericAPIView或多个mixin类组合在一起而构建的。

例如：

BookView视图类继承自：

ListModelMixin：用于显示所有图书

CreateModelMixin：添加一本书

GenricAPIView：继承自APIView，提供as_view()等，获取当前视图类中queryset和serializer_class ，用于给ListModelMixin和CreateModelMixin使用。

```
class BookView(mixins.ListModelMixin,
               mixins.CreateModelMixin,
               generics.GenericAPIView):

    queryset = models.Book.objects.all()
    serializer_class = BookModelSerializer

    def get(self,request, *args, **kwargs):
        return self.list(request, *args, **kwargs)

    def post(self,request,*args,**kwargs):
       return self.create(request,*args,**kwargs)

.......
```

二、GenericAPIView做了哪些事
1.获取queryset数据，用于所有后续的操作

复制代码
def get_queryset(self):
    # 断言,满足我的条件参会向下执行,否则不执行
    # 所以必须视图类必须提供一个queryset，例如BookView视图类中第一行
    assert self.queryset is not None, (
            "'%s' should either include a `queryset` attribute, "
            "or override the `get_queryset()` method."
            % self.__class__.__name__
    )
    # 获取当前类中的queryset
    queryset = self.queryset
    if isinstance(queryset, QuerySet):
        queryset = queryset.all()
    return queryset
复制代码
2. 获取当前类serializer_class  ： 该用于验证和反序列化输入以及序列化输出的序列化程序类

复制代码
def get_serializer_class(self):
    #断言：必须满足条件才行
    assert self.serializer_class is not None, (
        "'%s' should either include a `serializer_class` attribute, "
        "or override the `get_serializer_class()` method."
        % self.__class__.__name__
    )
    #返回当前实例对象的serializer_class
    return self.serializer_class
复制代码
3. lookup_field ：用于执行各个模型实例的对象查找的模型字段。默认是'pk'。

需要注意，使用超链接的API时，您需要确保双方的API意见和串行类设置查找字段

url(r'books/(?P<pk>\d+)/$',views.BookDetailView.as_view({'get': 'retrieve','put':'update','delete':'destroy'})),
4. 分页

与列表视图一起使用时，以下属性用于控制分页。

pagination_class ：分页列表结果时应使用的分页类。默认值与DEFAULT_PAGINATION_CLASS设置值相同，即'rest_framework.pagination.PageNumberPagination'。设置pagination_class=None将禁用此视图的分页。

5.过滤

filter_backends - 应该用于过滤查询集的过滤后端类列表。默认值与DEFAULT_FILTER_BACKENDS设置相同。