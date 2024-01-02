# queryset

queryset 完全是为了后面的 serializer，只有我们知道当前数据是什么样的，才能开始将数据进行序列化，最后变成我们想要的数据格式

GenericeVewSet 类中，我们之前已经发现了 get_queryset 函数。

```
def get_queryset(self):
        assert self.queryset is not None, (
            "'%s' should either include a `queryset` attribute, "
            "or override the `get_queryset()` method."
            % self.__class__.__name__
        )

        queryset = self.queryset
        if isinstance(queryset, QuerySet):
            # Ensure queryset is re-evaluated on each request.
            queryset = queryset.all()
        return queryset
```
函数中，去找到 queryset 并返回该 queryset。queryset 就是就获取了 model 层的数据。

