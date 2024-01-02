# celery task


django 框架集成了celery ,初衷就是一下 请求到view 的时候，需要执行一些耗时程序，需要一个异步的东西，来代替执行




@app.task 和 @shared_task的区别？
一般情况使用的是从celeryapp中引入的app作为的装饰器：@app.task
django那种在app中定义的task则需要使用@shared_task