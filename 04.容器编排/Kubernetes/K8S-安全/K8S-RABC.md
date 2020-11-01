# k8s 角色访问控制机制


使用kubeadm搭建的集群会默认开启RABC（角色访问控制机制），所以我们必须要进行额外的设置。关于RABC的概念，网上资料很多，大家务必提前了解。这里简要介绍一下几个重要概念：

RBAC
K8S 1.6引进，是让用户能够访问 k8S API 资源的授权方式【不授权就没有资格访问K8S的资源】

用户
K8S有两种用户：User和Service Account。其中，User给人用，Service Account给进程用，让进程有相关权限。如Dashboard就是一个进程，我们就可以创
建一个Service Account给它

角色
Role是一系列权限的集合，例如一个Role可包含读取和列出 Pod的权限【 ClusterRole 和 Role 类似，其权限范围是整个集群】

角色绑定
RoleBinding把角色映射到用户，从而让这些用户拥有该角色的权限【ClusterRoleBinding 和RoleBinding 类似，可让用户拥有 ClusterRole 的权限】

Secret
Secret是一个包含少量敏感信息如密码，令牌，或秘钥的对象。把这些信息保存在 Secret对象中，可以在这些信息被使用时加以控制，并可以降低信息泄露的风险

