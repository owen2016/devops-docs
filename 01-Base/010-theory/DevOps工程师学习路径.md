## DevOps方法论
:::tips
DevOps方法论的主要来源是Agile, Lean 和TOC, 独创的方法论是持续交付。
:::

DevOps 是一种软件开发方法，涉及持续开发，持续测试，持续集成，部署和监视。这一系列过程跨越了传统上孤立的开发和运营团队，DevOps 试图消除它们之间的障碍。
因此，DevOps 工程师基本上与 Development 和 Operations 团队合作，DevOps 是这两个主要部分之间的链接。
![devopsgroup_blog_pipeline_assessment.jpg](https://cdn.nlark.com/yuque/0/2022/jpeg/5374140/1670039817682-76009071-708b-4197-9ae4-2f916fe4b689.jpeg#averageHue=%23fdfdfa&clientId=u1c975ae5-daeb-4&from=ui&height=268&id=rp9Fk&originHeight=650&originWidth=1340&originalType=binary&ratio=1&rotation=0&showTitle=false&size=72634&status=done&style=none&taskId=uc91a573c-cee2-4670-b7f2-447cb792282&title=&width=553)
## DevOps经典图书

- 《DevOps实践指南》
- 《持续交付：发布可靠软件的系统方法》&《持续交付 2.0》
- 《凤凰项目》
- 《Effective DevOps》

## 必备技能
DevOps 包括诸如构建自动化、CI/CD、基础架构即代码等概念，并且有许多工具可以实现这些概念。由于这些工具数量众多，因此可能会造成混乱和压倒性的结果。
最重要的是要了解概念，并为每个类别的学习找一种特定的工具。例如，当你已经知道什么是 CI/CD 并知道如何使用 Jenkins 时，也将很容易学习同类型的其他替代工具。

接下来让就来看看学习 DevOps 需要掌握哪些技能。
![](https://cdn.nlark.com/yuque/0/2021/png/5374140/1620315836733-72a84025-18f8-4702-919f-53e62f5fea1d.png#averageHue=%23ede8c2&height=1011&id=aAEZA&originHeight=2356&originWidth=1263&originalType=binary&ratio=1&rotation=0&showTitle=false&status=done&style=none&title=&width=542)
### 1）软件开发的概念
作为一名 DevOps 工程师，你不会直接对应用程序进行编程，但是当你与开发团队紧密合作以改善和自动化他们的任务时，你需要了解以下概念：

- 开发人员的工作方式
- 他们正在使用哪个 git 工作流程
- 如何配置应用程序
- 自动化测试
### 2）操作系统
作为 DevOps 工程师，你负责准备在操作系统上部署应用程序的所需要的基础结构环境。并且由于大多数服务器是 Linux 服务器，因此你需要了解 Linux 操作系统，并善于使用命令行，所以你需要知道：

- 基本的 Shell 命令
- Linux 文件系统
- 管理服务器的基础知识
- SSH 密钥管理
- 在服务器上安装不同的工具
### 3）网络与安全
你还需要了解网络和安全性的基础知识才能配置基础架构，例如：

- 配置防火墙以保护应用程序
- 了解 IP 地址，端口和 DNS 的工作方式
- 负载均衡器
- 代理服务器
- HTTP/HTTPS

但是，要在 DevOps 和 IT Operations 之间划清界线，你不是系统管理员。因此，在这里不需要高级知识，理解和了解基本知识就够了。IT 方面是这些 SysAdmins，Networking 或 Security Engineers 人的专长。
### 4）容器化
随着容器成为新标准，你可能会将应用程序作为容器运行，这意味着你需要大致了解：

- 虚拟化的概念
- 容器的概念
- 学习哪个工具？Docker - 当今最受欢迎的容器技术
### 5）持续集成和部署
在 DevOps 中，所有代码更改（例如开发人员的新功能和错误修复）都应集成到现有应用程序中，并以自动化方式连续地部署到最终用户。因此，建立完整的 CI/CD 管道是 DevOps 工程师的主要任务和职责。
在完成功能或错误修正后，应自动触发在 CI 服务器（例如 Jenkins ）上运行的管道，该管道：

- 运行测试
- 打包应用程序
- 构建 Docker 镜像
- 将 Docker Image 推送到工件存储库，最后
- 将新版本部署到服务器（可以是开发，测试或生产服务器）

因此，你需要在此处学习技能：

- 设置 CI/CD 服务器
- 构建工具和程序包管理器工具以执行测试并打包应用程序
- 配置工件存储库（例如 Nexus，Artifactory）

当然，可以集成更多的步骤，但是此流程代表 CI/CD 管道的核心，并且是 DevOps 任务和职责的核心。
学习哪个工具？Jenkins 是最受欢迎的人之一。其他：Bamboo，Gitlab，TeamCity，CircleCI，TravisCI。
### 6）云提供商
如今，许多公司正在使用云上的虚拟基础架构，而不是管理自己的基础架构。这些是基础架构即服务（IaaS）平台，可提供一系列服务，例如备份，安全性，负载平衡等。
因此，你需要学习云平台的服务。例如。对于 AWS，你应该了解以下基本知识：

- IAM 服务-管理用户和权限
- VPC 服务-你的专用网络
- EC2 服务-虚拟服务器
- AWS 提供了更多的服务，但是你只需要了解你实际需要的服务即可。例如，当 K8s 集群在 AWS 上运行时，你还需要学习 EKS 服务。

AWS 是功能最强大，使用最广泛的一种，但也是最困难的一种。
学习哪个工具？AWS 是最受欢迎的一种。其他热门：Azure，Google Cloud，阿里云，腾讯云。
### 7）容器编排
如前所述，容器已被广泛使用，在大公司中，成百上千个容器正在多台服务器上运行，这意味着需要以某种方式管理这些容器。
为此目的，有一些容器编排工具，而最受欢迎的是 Kubernetes。因此，你需要学习：

- Kubernetes 如何工作
- 管理和管理 Kubernetes 集群
- 并在其中部署应用程序

学习哪个工具？Kubernetes - 最受欢迎。
### 8）监视和日志管理
软件投入生产后，对其进行监视以跟踪性能，发现基础结构以及应用程序中的问题非常重要。因此，作为 DevOps 工程师的职责之一是：

- 设置软件监控
- 设置基础架构监控，例如用于你的 Kubernetes 集群和底层服务器。

学习哪个工具？Prometheus, Grafana...
### 9）基础设施即代码
手动创建和维护基础架构非常耗时且容易出错，尤其是当你需要复制基础架构时，例如用于开发，测试和生产环境。
在 DevOps 中，希望尽可能地自动化，那就是将“基础结构即代码（Infrastructure as Configuration）”引入其中。因此使用 IaC ，我们将使用代码来创建和配置基础结构，你需要了解两种 IaC 方式：

- 基础设施配置
- 配置管理

使用这些工具，可以轻松地复制和恢复基础结构。因此，你应该在每个类别中都知道一种工具，以使自己的工作更有效率，并改善与同事的协作。
学习哪个工具？
基础架构设置：Terraform 是最受欢迎的一种。配置管理：Ansible，Puppet，Chef。
### 10）脚本语言
作为 DevOps 工程师就常见的工作就是编写脚本和小型的应用程序以自动化任务。为了能够做到这一点，你需要了解一种脚本或编程语言。
这可能是特定于操作系统的脚本语言，例如 bash 或 Powershell。
还需要掌握一种独立于操作系统的语言，例如 Python 或 Go。这些语言功能更强大，更灵活。如果你善于使用其中之一，它将使你在就业市场上更具价值。
学习哪个工具？Python：目前是最需要的一个，它易于学习，易于阅读并且具有许多可用的库。其他：Go，NodeJS，Ruby。
### 11）版本控制
上述所有这些自动化逻辑都作为代码编写，使用版本控制工具（例如Git）来管理这些代码和配置文件。
学习哪个工具？Git - 最受欢迎和广泛使用。

## 网站和博客

- [DEOS](https://events.itrevolution.com/) ：DevOps 国际峰会，以案例总结著称；
- [DevOpsDays：](https://devopsdays.org/)大名鼎鼎的 DevOpsDays 社区；
- [TheNewStack ：](https://thenewstack.io/)综合性网站，盛产高质量的电子书；
- [DevOps.com](https://devops.com/) ：综合性网站；
- [DZone ：](https://dzone.com/) 综合性网站，盛产高质量的电子书；
- [Azure DevOps：](https://devblogs.microsoft.com/devops/)综合性网站，盛产高质量的电子书；
- [Martin Fowler](https://www.martinfowler.com/bliki/) ：Martin Fowler 的博客；
- [CloudBees Devops](https://www.cloudbees.com/devops) ：Jenkins 背后的公司的博客。

[

](https://mp.weixin.qq.com/s/HTiPTC1UFg-fs2YCPlOKkQ##)


