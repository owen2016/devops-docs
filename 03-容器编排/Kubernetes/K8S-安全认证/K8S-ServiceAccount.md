# ServiceAccount

Service account是`为了方便Pod里面的进程调用Kubernetes API或其他外部服务而设计的,可以简单的理解为服务账户`，一般RBAC的最普遍的使用都是使用serviceaccount，因为k8s默认的user资源是不在集群管理内的，而且使用方式过于繁琐。serviceaccount可以简单方便的实现认证和授权