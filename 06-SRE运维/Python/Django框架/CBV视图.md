# View - Class Based View
视图是可调用的，它接收请求并返回响应。这可能不仅仅是一个函数，Django提供了一些可用作视图的类的示例。这些允许您通过利用继承和mixin来构建视图并重用代码。

基于类（class-based）的视图提供了另一种方法，将视图实现为Python对象而不是函数。 它们不会替换基于函数（function-based）的视图，但与基于函数的视图相比具有一定的差异和优势：

与特定HTTP方法（GET，POST等）相关的代码组织可以通过单独的方法而不是条件分支来解决。
诸如mixins（多重继承）之类的面向对象技术可用于将代码分解为可重用组件。
————————————————

原文链接：https://blog.csdn.net/qq_19268039/java/article/details/84253199

- Django的视图有两种: 基于函数的视图(Function Base View)和基于类的视图(Class Based View)

## 基于函数的视图(Function Base View)
优点是直接，容易读者理解。缺点是不便于继承和重用。

在实际Web开发过程中，我们对不同的对象总是反复进行以下同样的操作，应该需要简化的。

- 展示对象列表（比如所有用户，所有文章）
- 查看某个对象的详细信息（比如用户资料，比如文章详情)
- 通过表单创建某个对象（比如创建用户，新建文章）
- 通过表单更新某个对象信息（比如修改密码，修改文字内容）
- 用户填写表单提交后转到某个完成页面
- 删除某个对象

## 基于类的视图 (Class Based View)
Django提供了很多通用的基于类的视图(Class Based View)，来帮我们简化视图的编写。这些View与上述操作的对应关系如下:

- 展示对象列表（比如所有用户，所有文章）- ListView
- 展示某个对象的详细信息（比如用户资料，比如文章详情) - DetailView
- 通过表单创建某个对象（比如创建用户，新建文章）- CreateView
- 通过表单更新某个对象信息（比如修改密码，修改文字内容）- UpdateView
- 用户填写表单后转到某个完成页面 - FormView
- 删除某个对象 - DeleteView

上述常用通用视图一共有6个，前2个属于展示类视图(Display view), 后面4个属于编辑类视图(Edit view)。下面我们就来看下这些通用视图是如何工作的，如何简化我们代码的。

重要：如果你要使用Edit view，请务必在模型models里定义get_absolute_url()方法，否则会出现错误。这是因为通用视图在对一个对象完成编辑后，需要一个返回链接。

- https://blog.csdn.net/qixu_yang/article/details/80524575?utm_source=blogxgwz0
### Django通用视图之ListView

ListView用来展示一个对象的列表。它只需要一个参数模型名称即可。比如我们希望展示所有文章列表，我们的views.py可以简化为:

```
from django.views.generic import ListView
from .models import Article

class IndexView(ListView):

    model = Article
```
上述代码等同于:

```
# 展示所有文章
def index(request):
    queryset = Article.objects.all()
    return render(request, 'blog/article_list.html', {"article_list": queryset})
```
尽管我们只写了一行model = Article, ListView实际上在背后做了很多事情：

- 提取了需要显示的对象列表或数据集queryset: Article.objects.all()
- 指定了用来显示对象列表的模板名称(template name): 默认app_name/model_name_list.html, 即blog/article_list.html.
- 指定了内容对象名称(context object name): 默认值object_list


ListView的自定义



你或许已经注意到了2个问题：需要显示的文章对象列表并没有按发布时间逆序排列，内容对象名称object_list也不友好。或许你也不喜欢默认的模板名字，还希望通过这个视图给模板传递额外的内容(比如现在的时间)。你可以轻易地通过重写queryset, template_name和context_object_name来完成ListView的自定义。如果你还需要传递模型以外的内容，比如现在的时间，你还可以通过重写get_context_data方法传递额外的参数或内容。

# Create your views here.
from django.views.generic import ListView
from .models import Article
from django.utils import timezone

class IndexView(ListView):

    queryset = Article.objects.all().order_by("-pub_date")
    template_name = 'blog/article_list.html'
    context_object_name = 'latest_articles'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['now'] = timezone.now()
        return context

如果上述的queryset还不能满足你的要求，比如你希望一个用户只看到自己发表的文章清单，你可以通过更具体的get_queryset()方法来返回一个需要显示的对象列表。
```

# Create your views here.
from django.views.generic import ListView
from .models import Article
from django.utils import timezone

class IndexView(ListView):

    template_name = 'blog/article_list.html'
    context_object_name = 'latest_articles'

    def get_queryset(self):
        return Article.objects.filter(author=self.request.user).order_by('-pub_date')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['now'] = timezone.now()
        return context
```


URL如何指向基于类的视图(View)



目前urls.py里path和re_path都只能指向视图view里的一个函数或方法，而不能指向一个基于类的视图(Class Based View)。Django提供了一个额外as_view()方法，可以将一个类伪装成方法。这点在当你使用Django在带的view类或自定义的类时候非常重要。更多内容见Django基础技术知识(2)URL的设计与配置。



具体使用方式如下:


# blog/urls.py
from django.urls import path, re_path

from . import views

urlpatterns = [
      path('blog/', views.IndexView.as_view(), name='index'),
]


Django通用视图之DetailView

DetailView用来展示一个具体对象的详细信息。它需要URL提供访问某个对象的具体参数（如pk, slug值）。本例中用来展示某篇文章详细内容的view可以简写为:


```
# Create your views here.
from django.views.generic import DetailView
from .models import Article

class ArticleDetailView(DetailView):

    model = Article
```

DetailView默认的模板是app/model_name_detail.html,默认的内容对象名字context_object_name是model_name。本例中默认模板是blog/article_detail.html, 默认对象名字是article, 在模板里可通过 {{ article.title }}获取文章标题。



你同样可以通过重写queryset, template_name和context_object_name来完成DetailView的自定义。你还可以通过重写get_context_data方法传递额外的参数或内容。如果你指定了queryset, 那么返回的object是queryset.get(pk = id), 而不是model.objects.get(pk = id)。

# Create your views here.
from django.views.generic import ListView，DetailView
from .models import Article
from django.utils import timezone

class ArticleDetailView(DetailView):

    queryset = Article.objects.all().order_by("-pub_date") # 一般不写
    template_name = 'blog/article_detail.html'
    context_object_name = 'article'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['now'] = timezone.now()
        return context


Django通用视图之CreateView

CreateView一般通过某个表单创建某个对象，通常完成后会转到对象列表。比如一个最简单的文章创建CreateView可以写成：


from django.views.generic.edit import CreateView
from .models import Article

class ArticleCreateView(CreateView):
    model = Article
    fields = ['title', 'body', 'pub_date']
CreateView默认的模板是model_name_form.html, 即article_form.html。默认的context_object_name是form。模板代码如下图所示:


# blog/article_form.html
<form method="post">{% csrf_token %}
    {{ form.as_p }}
    <input type="submit" value="Save" />
</form>
如果你不想使用默认的模板和默认的表单，你可以通过重写template_name和form_class来完成CreateView的自定义。


本例中默认的模板是article_form.html, 你可以改为article_create_form.html。

虽然form_valid方法不是必需，但很有用。当用户提交的数据是有效的时候，你可以通过定义此方法做些别的事情，比如发送邮件，存取额外的数据。


from django.views.generic.edit import CreateView
from .models import Article
from .forms import ArticleCreateForm

class ArticleCreateView(CreateView):
    model = Article
    template_name = 'blog/article_create_form.html'
    form_class = ArticleCreateForm

    def form_valid(self, form):
       form.do_sth()
       return super(ArticleCreateView, self).form_valid(form)
form_valid方法一个常见用途就是就是将创建对象的用户与model里的user结合。见下面例子。

class ArticleCreateView(CreateView):
    model = Article
    template_name = 'blog/article_create_form.html'
    form_class = ArticelCreateForm

    def form_valid(self, form):
        form.instance.author = self.request.user
        return super().form_valid(form)

Django通用视图之UpdateView

UpdateView一般通过某个表单更新现有对象的信息，更新完成后会转到对象详细信息页面。它需要URL提供访问某个对象的具体参数（如pk, slug值）。比如一个最简单的文章更新的UpdateView如下所示。


from django.views.generic.edit import UpdateView
from .models import Article

class ArticleUpdateView(UpdateView):
    model = Article
    fields = ['title', 'body', 'pub_date']
UpdateView和CreateView很类似，比如默认模板都是model_name_form.html。但是区别有两点: 

CreateView显示的表单是空表单，UpdateView中的表单会显示现有对象的数据。

用户提交表单后，CreateView转向对象列表，UpdateView转向对象详细信息页面。



你可以通过重写template_name和form_class来完成UpdateView的自定义。


本例中默认的模板是article_form.html, 你可以改为article_update_form.html。

虽然form_valid方法不是必需，但很有用。当用户提交的数据是有效的时候，你可以通过定义此方法做些别的事情，比如发送邮件，存取额外的数据。

from django.views.generic.edit import UpdateView
from .models import Article
from .forms import ArticleUpdateForm

class ArticleUpdateView(UpdateView):
    model = Article
    template_name = 'blog/article_update_form.html'
    form_class = ArticleUpdateForm

    def form_valid(self, form):
       form.do_sth()
       return super(ArticleUpdateView, self).form_valid(form)



Django通用视图之FormView

FormView一般用来展示某个表单，而不是某个模型对象。当用户输入信息未通过表单验证，显示错误信息。当用户输入信息通过表单验证提交后，转到其它页面。使用FormView一般需要定义template_name, form_class和success_url.



见下面代码。

# views.py - Use FormView
from myapp.forms import ContactForm
from django.views.generic.edit import FormView

class ContactView(FormView):
    template_name = 'contact.html'
    form_class = ContactForm
    success_url = '/thanks/'

    def form_valid(self, form):
        # This method is called when valid form data has been POSTed.
        # It should return an HttpResponse.
        form.send_email()
        return super().form_valid(form)


Django通用视图之DeleteView

DeleteView一般用来删除某个具体对象。它要求用户点击确认后再删除一个对象。使用这个通用视图，你需要定义模型的名称model和成功删除对象后的返回的URL。默认模板是myapp/model_confirm_delete.html。默认内容对象名字是model_name。本例中为article。



本例使用了默认的模板blog/article_confirm_delete.html，删除文章后通过reverse_lazy方法返回到index页面。
```
from django.urls import reverse_lazy
from django.views.generic.edit import DeleteView
from .models import Article

class ArticleDelete(DeleteView):
    model = Article
    success_url = reverse_lazy('index')
```

模板内容如下:

```
# blog/article_confirm_delete.html
<form method="post">{% csrf_token %}
    <p>Are you sure you want to delete "{{ article }}"?</p>
    <input type="submit" value="Confirm" />
</form>

```





