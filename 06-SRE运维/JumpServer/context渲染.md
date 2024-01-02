# django 上下文 context 以及 模板渲染引擎

当reques 到 达视图类的时候，会根据 request 的 method 属性 来调用相应 视图类 的 方法，这是上一篇文章中分析的逻辑，接下来接着分析，视图类 对数据库的操作 以及 返回上下文对象给模板得 这一交互过程，下面贴出 源码。

```
class AssetListView(AdminUserRequiredMixin, TemplateView):
    template_name = 'assets/asset_list.html'
 
    def get_context_data(self, **kwargs):
        Node.root()
        context = {
            'app': _('Assets'),
            'action': _('Asset list'),
            'labels': Label.objects.all().order_by('name'),
            'nodes': Node.objects.all().order_by('-key'),
        }
        kwargs.update(context)
        return super().get_context_data(**kwargs)
```
就像AssetListView, jumpserver 大量运用了  get_context_data 方法，这个get_context_data 是重写了父类 TemplateView 的父类的get_context_data,下面贴出源码。

```
class ContextMixin:
    """
    A default context mixin that passes the keyword arguments received by
    get_context_data() as the template context.
    """
    extra_context = None
 
    def get_context_data(self, **kwargs):
        kwargs.setdefault('view', self)
        if self.extra_context is not None:
            kwargs.update(self.extra_context)
        return kwargs
```
get_context_data 方法 其实就是组件 context 对象， 给 kwargs 增加新的键值对。

然后会调用 TemplateView 的get 方法 时候 会调用 get_context_data 方法 源码中是这样的，在 get 方法中 调用了 get_context_data  方法。

```
class TemplateView(TemplateResponseMixin, ContextMixin, View):
    """
    Render a template. Pass keyword arguments from the URLconf to the context.
    """
    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return self.render_to_response(context)
 
```

然后把 context 对象返回给前端。前端 页面 代码类似于这样。

```
{% for label in labels %}
                          <li><a style="font-weight: bolder">{{ label.name }}:{{ label.value }}</a></li>
                      {% endfor %}
```
接受到了 context 中的 label 数组 。渲染引擎 就会 把 渲染 成页面。
