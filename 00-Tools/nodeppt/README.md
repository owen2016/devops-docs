# nodeppt

## 特点

- 基于GFM的markdown语法编写
- 支持html混排，再复杂的demo也可以做！
- 导出网页或者pdf更容易分享
- 支持20种转场动画，可以设置单页动画
- 支持多个皮肤：colors-moon-blue-dark-green-light
- 支持单页背景图片
- 多种模式：overview模式，双屏模式，socket远程控制，摇一摇换页，使用ipad/iphone控制翻页更酷哦~
- 可以使用画板，双屏同步画板内容！可以使用note做备注
- 支持语法高亮，自由选择highlight样式
- 可以单页ppt内部动画，单步动画
- 支持进入/退出回调，做在线demo很方便
- 支持事件update函数
- zoom.js：alt+click

## 安装

``` shell
npm install -g nodeppt --registry https://registry.npm.taobao.org

```

## 使用

new：使用线上模板创建一个新的 md 文件
serve：启动一个 md 文件的 webpack dev server
build：编译产出一个 md 文件

``` shell
# create a new slide with an official template
$ nodeppt new slide.md

# create a new slide straight from a github template
$ nodeppt new slide.md -t username/repo

# start local sever show slide
$ nodeppt serve slide.md

# to build a slide
$ nodeppt build slide.md
```

## 书写规则

```text
/*

　　　　title: 这是演讲的题目
　　　　speaker: 演讲者名字
　　　　url: 链接
　　　　transition: 转换效果，例如：zoomin/cards/slide
　　　　files: 引入js和css的地址
　　　　*/
```
