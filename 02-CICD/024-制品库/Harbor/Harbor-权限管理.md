# Harbor 权限管理

Harbor通过“project” docker镜像.用户可以被赋予不同的角色，并被添加到“project”里

## 用户

Harbor 提供不同的认证方式

- Database(db_auth)

- LDAP/Active Directory (ldap_auth)  @AugOpsTeam 使用LDAP

- OIDC Provider (oidc_auth)

<https://github.com/goharbor/harbor/blob/master/docs/user_guide.md#managing-authentication>

## 角色

### 1. 项目级别的角色

| 角色 | 权限说明 |
| ------ | ------ |
| Guset | 对于指定项目拥有只读权限 |
| Developer | 对于指定项目拥有读写权限 |
| ProjectMaintenance | 除了读写权限，同时拥有管理项目镜像和标签权限 |
| ProjectAdmin | 除了读写权限，同时拥有项目管理权限 |

### 2. 系统级别角色

| 角色 | 权限说明 |
| ------ | ------ |
| SysAdmin | 具有最多的权限，除了以上提及的权限，可以跨项目操作，查询所有项目，设定某个用户作为管理员以及扫描策略等 |
| Anonymous | 没有登录的用户被视作匿名用户。匿名用户对private的项目不具访问权限，对public的项目具有只读权限 |

See detailed permissions matrix listed here:

- <https://github.com/goharbor/harbor/blob/master/docs/permissions.md>

## 用户授权

1. 创建用户 (LDAP无需提前创建)

2. @AugOpsTeam 成员默认都是SysAdmin, 可根据实际需求，进行用户权限

### 1. 系统级别授权

在用户管理，勾选需要授权的用户，点击“设置为管理员”

![添加系统级别权限](./images/Harbor_授权系统权限.png)

### 2. 项目级别授权

在对应项目管理页面，点击“成员”，勾选需要授权的用户，点击“其他操作”设置对应角色

![添加项目级别权限](./images/Harbor-授权项目组权限.png)

- 如果两种权限都设置了，系统级别优先级更高

## 项目创建

基于pipeline需要 为@DevTeam 创建Harbor项目

- 尽量取有意义的，简短的名称作为 project name

- 强制规定 “访问级别” 为`私有`

    ![创建对应项目](./images/Harbor-创建项目.png)

## 授权

@DevTeam 提供成员名单，根据名单@AugOpsTeam 对项目成员进行授权

一般情况，我们授予 @DevTeam leader 为项目管理员，这样leader将有权限授予 剩余成员权限

1. 在项目中找到对应项目，点击进入项目管理页面

2. 点击“成员”

3. 点击“+ 用户”，输入用户名，选择角色“项目管理员”，点击确定

    ![项目组Leader用户权限](./images/Harbor-用户授权.png)

