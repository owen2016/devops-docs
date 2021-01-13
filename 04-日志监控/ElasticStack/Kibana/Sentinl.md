# sentinl

## 1.安装 sentinl 插件

sentinl是一个开源的插件，它所有的code都在GitHub上，所以首先到它的release页面 [https://github.com/sirensolutions/sentinl/releases](https://github.com/sirensolutions/sentinl/releases) 选择合适的版本，注意下载版本一定要和kibana版本一致

``` shell

> usr/share/kibana/bin/kibana-plugin install https://github.com/sirensolutions/sentinl/releases/download/tag-6.6.0-0/sentinl-v6.6.0.zip

如果网速比较差，也可以先下载安装插件：
> wget -O https://github.com/sirensolutions/sentinl/releases/download/tag-6.6.0-0/sentinl-v6.6.0.zip

然后直接安装：
> usr/share/kibana/bin/kibana-plugin install file:///sentinl-v6.6.0.zip

如果不需要了，也可以卸载此插件：
> user/share/kibana/bin/kibana-plugin remove sentinl
```

## 2. 修改kibana配置文件

``` shell
> vim /etc/kibana/kibana.yml

在最后加上：
sentinl:
  settings:
    email:
      active: true
      user: 'xxx@163.com'
      password: 'XXX'  #此处密码为授权码，不是登录邮箱的账户密码
      host: 'smtp.163.com'
      ssl: true
      port: 465  #若ssl为true，需要加此port，若为false，可不加
    report:
      active: true
```

Note：163的邮箱需要开启POP3/SMTP服务，并且配置授权码，接收邮件的邮箱，比如qq邮箱，也同样需要开启POP3/SMTP服务，否则会收到退信。

## 3. 重启kibana服务

> systemctl restart kibana

然后打开kibana url http://localhost:5601 即可看到一个新的tab叫sentinl:

## 4. 添加Watcher

4.1 创建watcher

在Sentinl页面，选择Watchers tab，然后点右上角的New，选择Watcher Wizard，在如下页面添加title和index：

这个时候，出自动出现Match condintion和Actions区域，在Actions区域，已经自动添加了一个发邮件的action，叫做：
email_html action: email html alarm

当你save watcher的时候，这封邮件里的content会基于Match condintion自动更新。

4.2 配置Match condition

这里我配置一个简单的触发alert的条件： 当nginx access log数量 >=5

4.3 配置Actions

展开email_html action: email html alarm，你可以修改任何field，这里我只填必要的From和To字段：

保存此watcher。

4.4 验证
打开nginx webportal: http://localhost:80 ,刷新个5,6次，这样就可以产生5,6条access log，然后在watcher页面，可以等2分钟或者点执行按钮，立即执行这个watcher，切换到Alarms页面，如果没有error，可到邮箱检查是否收到邮件，若有error，则需要进一步排查问题