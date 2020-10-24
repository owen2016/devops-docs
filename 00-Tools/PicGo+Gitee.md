# PicGo + Gitee 实现 Markdown 图床

## PicGo - 基于 electron-vue 开发的图床工具

PicGo目前支持了微博图床，七牛图床，腾讯云COS v4\v5版本，又拍云，GitHub，SM.MS等，另外通过插件可以支持更多图床包括 gitee

- <https://github.com/Molunerfinn/PicGo>  

![picgo](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916222359.png)

另外还有支持VS code 和 手机操作

- vs-picgo：PicGo 的 VS Code 版。
- flutter-picgo：PicGo 的手机版（支持 Android 和 iOS ）。

[更多PicGo插件](https://github.com/PicGo/Awesome-PicGo)

## Gitee图床+PicGo 配置步骤

最近在研究图床，注册的阿里云域名备案还在审批，所以七牛云图床暂时没用，所以试下用PicGo+ Gitee

### 1. 新建 gitee 空仓库用于 存放图片

![repo](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916230122.png)

### 2. 创建token

![token](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916225748.png)

### 2. 下载PicGo, 安装gitee图床插件

因为官方默认不支持gitee图床，需要单独下载插件

![gitee-plugin](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916223759.png)

### 4. 配置gitee图床

![gitee-bed](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916222359.png)

### 5. 直接粘贴，或者拖拽即可，上传后自动复制URL，直接粘贴在Markdown即可

![push](https://gitee.com/owen2016/pic-hub/raw/master/pics/20200916230156.png)

## 七牛云图床+PicGo 配置步骤

为空间绑定自定义 CDN 加速域名，通过 CDN 边缘节点缓存数据，提高存储空间内的文件访问响应速度

华东 z0, 华北 z1，华南 z2，北美 na0，东南亚 as0
