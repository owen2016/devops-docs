# docsify

- <https://docsify.js.org/#/zh-cn/>

docsify 是一个动态生成文档网站的工具, 与GitBook，Hexo不同，它不会生成静态html文件, 所有转换工作都是在运行时进行, 它巧妙地加载和解析您的Markdown文件并将其显示为网站。你需要做的就是创建一个index.html以在GitHub页面上启动和部署它，

## 快速开始

### 安装

安装docsify-cli工具, 命令行执行：

`npm i docsify-cli -g`

### 初始化文档结构

使用init命令初始化。如果要在./docs子目录中编写文档，则可使用下面命令：

`docsify init ./docs`

该命令会生成如下文件

- .nojekyll：让gitHub不忽略掉以 _ 打头的文件
- index.html：整个网站的核心文件
- README.md：默认页面- 做为主页内容渲染

### 本地预览网站

运行一个本地服务器通过 docsify serve 可以方便的预览效果，而且提供 LiveReload 功能，可以让实时的预览。默认访问http://localhost:3000/#/。

`docsify serve docs`

## 定制化

### 全局配置

- 配置 index.html

## 侧边栏 -目录结构

- 添加_sidebar.md文件来配置侧边栏

### 导航栏

- 添加_navbar.md文件来配置顶部导航栏

### 封面

### 主题

### 插件

官方还提供了非常多实用的插件，比如说全文搜索、解析emoji表情、一键复制代码等等，完整版请参考官方插件列表。

- https://docsify.js.org/#/zh-cn/plugins

## 部署

## github pages

GitHub Pages 支持从三个地方读取文件

- docs/ 目录
- master 分支
- gh-pages 分支

上传文件至Github仓库 官方推荐直接将文档放在 docs/ 目录下，在设置页面开启 GitHub Pages 功能并选择 master branch /docs folder 选项。

## 阿里云

//TODO