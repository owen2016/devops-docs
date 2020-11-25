# 分享

// TODO

## nodeppt

### 书写规则

```text
/*

　　　　title: 这是演讲的题目
　　　　speaker: 演讲者名字
　　　　url: 链接
　　　　transition: 转换效果，例如：zoomin/cards/slide
　　　　files: 引入js和css的地址
　　　　*/
```

### 命令行

``` shell
npm install -g nodeppt --registry https://registry.npm.taobao.org

# create a new slide with an official template
$ nodeppt new slide.md

# create a new slide straight from a github template
$ nodeppt new slide.md -t username/repo

# start local sever show slide
$ nodeppt serve slide.md

# to build a slide
$ nodeppt build slide.md

```
