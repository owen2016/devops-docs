# Yaml

yaml 官方网站：<http://www.yaml.org>

YAML是一个类似 XML、JSON 的标记性语言。YAML 强调以数据为中心，并不是以标识语言为重点。因而 YAML 本身的定义比较简单，号称“一种人性化的数据格式语言”。

> P.S. YAML was originally was side to mean Yet Another Markup Language, referencing its purpose as a markup lanaguage with the yet another construct; but it was then repurposed as YAML Anit Markup Language (仍是标记语言，只是为了强调不同，YAML 是以数据设计为重点，XML以标记为重点), a recursive acronym, to distinguish its purpose as data-orinted, rather than document markup.

## 适应场景

1. 脚本语言：由于实现简单，解析成本很低，YAML 特别适合在脚本语言中使用
2. 序列化： YAML是由宿主语言数据类型直转，的比较适合做序列化。
3. 配置文件：写 YAML 要比写 XML 快得多(无需关注标签或引号)，并且比 INI 文档功能更强。由于兼容性问题，不同语言间的数据流转建议不要用 YAML。

## 语言优点

1. YAML易于人们阅读。
2. YAML数据在编程语言之间是可移植的。
3. YAML匹配敏捷语言的本机数据结构。
4. YAML具有一致的模型来支持通用工具。
5. YAML支持单程处理。
6. YAML具有表现力和可扩展性。
7. YAML易于实现和使用。

## YAML 与 XML、JSON

- YAML 与 XML
  - 具有 XML 同样的优点，但比 XML 更加简单、敏捷等  
- YAML 与 JSON
  - JSON 可以看作是 YAML 的子集，也就是说 JSON 能够做的事情，YAML 也能够做
  - YAML 能表示得比 JSON 更加简单和阅读，例如“字符串不需要引号”。所以 YAML 容易可以写成 JSON 的格式，但并不建议这种做
  - YAML 能够描述比 JSON 更加复杂的结构，例如“关系锚点”可以表示数据引用（如重复数据的引用）。

## YAML 组织结构

YAML 文件可以由一或多个文档组成（也即相对独立的组织结构组成），文档间使用“---”（三个横线）在每文档开始作为分隔符。同时，文档也可以使用“...”（三个点号）作为结束符（可选）。如下图所示：

- 如果只是单个文档，分隔符“---”可省略。
- 每个文档并不需要使用结束符“...”来表示结束，但是对于网络传输或者流来说，作为明确结束的符号，有利于软件处理。（例如不需要知道流关闭就能知道文档结束）

- YAML 认为数据由以下三种结构组成：（每个文档由三种结构混合组成）
  - 标量 （相当于数据类型）
  - 序列 （相当于数组和列表）
  - 键值表（相当于 Map 表）

## YAML 编写规范

1. 使用空格 Space 缩进表示分层，不同层次之间的缩进可以使用不同的空格数目，但是同层元素一定左对齐，即前面空格数目相同（不能使用 Tab，各个系统 Tab对应的 Space 数目可能不同，导致层次混乱）
2. ‘#’表示注释，只能单行注释，从#开始处到行尾
3. 破折号后面跟一个空格（a dash and space）表示列表
4. 用冒号和空格表示键值对 key: value
5. 简单数据（scalars，标量数据）可以不使用引号括起来，包括字符串数据。用单引号或者双引号括起来的被当作字符串数据，在单引号或双引号中使用C风格的转义字符

- Structure 用空格表示
- Sequence里的项用"-"表示
- MAP 里的键值对用 ":"分隔

``` yaml
#John.yaml
name: John Smith
age: 37
spouse:
    name: Jane Smith
    age: 25
children:
    -   name: Jimmy Smith
        age: 15
    -   name: Jenny Smith
        age 12
```
