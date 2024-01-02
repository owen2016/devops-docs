# View - Function Base View

View (视图) 主要根据用户的请求返回数据，用来展示用户可以看到的内容(比如网页，图片)，也可以用来处理用户提交的数据，比如保存到数据库中。**Django的视图(View）通常和URL路由一起工作的**。服务器在收到用户通过浏览器发来的请求后，会根据urls.py里的关系条目，去视图View里查找到与请求对应的处理方法，从而返回给客户端http页面数据。

当用户发来一个请求request时，我们通过HttpResponse打印出Hello， World!

- **views.py**
```
from django.http import HttpResponse
def index(request):
    return HttpResponse("Hello， World!")
```

下面一个新闻博客的例子。/blog/展示所有博客文章列表。/blog/article/<int:id>/展示一篇文章的详细内容

- **blog/urls.py**

```
from django.urls import path
from . import views
urlpatterns = [
    path('blog/', views.index, name='index'),
   path('blog/article/<int:id>/', views.article_detail, name='article_detail'),
]
```

-  **blog/views.py**

```
from django.shortcuts import render, get_object_or_404
from .models import Article

# 展示所有文章
def index(request):
    latest_articles = Article.objects.all().order_by('-pub_date')
    return render(request, 'blog/article_list.html', {"latest_articles": latest_articles})

# 展示所有文章
def article_detail(request, id):
    article = get_object_or_404(Article, pk=id)
    return render(request, 'blog/article_detail.html', {"article": article})

```

模板可以直接调用通过视图传递过来的内容。

- **blog/article_list.html**

```

{% block content %}
{% for article in latest_articles %}
     {{ article.title }}
     {{ article.pub_date }}
{% endfor %}
{% endblock %}

# blog/article_detail.html
{% block content %}
{{ article.title }}
{{ article.pub_date }}
{{ article.body }}
{% endblock %}

```
