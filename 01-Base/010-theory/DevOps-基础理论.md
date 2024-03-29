
## 美好的DevOps实践

想象有这样的一个世界：产品经理、开发人员、QA人员、IT运维人员和信息安全人员互相帮助，齐心协力，整个公司的业绩蒸蒸日上。

他们朝着一个共同的目标努力奋斗，建立出从产品计划直至功能上线的端到端的快速服务交付流水线（例如每天执行几十次、数百次甚至上千次代码部署），在系统稳定性、可靠性、可用性和安全性方面均达到了世界一流的水平。在那里，跨职能团队严谨地验证他们的假设：哪些功能最能取悦用户并能促进企业目标的实现。他们不仅关心用户特性的实现，而且还积极地保障交付能够顺畅、频繁地通过整个交付价值链，同时，IT运维部门、其他内部或者外部客户的系统都不会出现任何混乱及中断。 在那里，QA人员、IT运维人员和信息安全人员也会共同投身于团队文化建设，致力于创造能使开发人员效率更高、产能更大的工作环境。通过将QA、IT运维和信息安全等方面的专业人员共同融入交付团队，来构建自动化的自助工具和平台，所有团队在日常工作中就能够随时利用他人的专业技能，而不用再依赖或等待其他团队。 在那里，小团队能够快速独立地开 

## 现实中的DevOps


## DevOps理论基础

DevOps 基于精益、约束理论、丰田生产系统、柔性工程、学习型组织、安全文化、人员优化因素等知识体系，并参考了高信任管理文化、服务型领导、组织变动管理等方法论。把所有这些最可信的原则综合地应用到 IT 价值流中，就产生出 DevOps 这样的成果。 

**精益**的两个主要原则包括：

- 坚信前置时间（把原材料转换为成品所需的时间）是提升质量、客户满意度和员工幸福感的最佳度量指标之一；
- 小批量任务的交付是缩短前置时间的一个关键因素。 
 
**敏捷宣言**是在 2001 年由软件领域的 17 位顶尖大师共同提出的。他们希望用一套轻量级的价值观和原则体系，来优化那些沉重的软件开发流程（如传统的瀑布式开发模型）和方法论（如统一软件开发过程） 

- 在敏捷宣言中，一个重要的原则是**“频繁地交付可工作的软件，交付周期可以是数星期也可以是数月，推荐更短的周期”**，并强调使用小批量任务进行增量发布，而非大规模的作业和瀑布流程的发布。同时，强调建立自组织的小团队，让成员在高度信任的环境中愉悦地工作。 

在持续交付中，“部署流水线”确保代码和基础设施始终处于可部署状态，所有提交到主干的代码都可以安全地部署到生产环境 

在“基础设施即代码”这种实践中，运维工作被最大程度地自动化，并确保任何对基础设施的操作都通过代码来实现，从而将现代软件的开发实践应用到了整个产品交付中，其特性包括**持续集成**（由 Grady Booch 提出，是极限编程的 12 个实践之一）、**持续交付**（由 Jez Humble 和 David Farley 提出）和**持续部署**（由 Etsy、Wealthfront 和 Eric Ries 在 IMVU 的工作中提出）


## 价值流分析


第 1 章　敏捷、持续交付和三步法

1.1　制造业价值流

1.2　技术价值流

1.2.1　聚焦于部署前置时间

1.2.2　关注返工指标——%C/A

1.3　三步工作法：DevOps的基础原则

1.4　小结

价值流定义为“一个组织基于客户的需求所执行的一系列有序的交付活动”，或者是“为了给客户设计、生产和提供产品或服务所需从事的一系列活动，它包含了信息流和物料流的双重价值”。 

为了缩短和预测价值流中的前置时间，通常需要持续地关注如何建立一套流畅的工作流程，包括减小批量尺寸、减少在制品（Work in Process，WIP）数量、避免返工等，同时还需要确保不会将次品传递到下游的工作中心，并持续不断地基于全局目标来优化整个系统。  

在DevOps中，我们通常将技术价值流定义为“把业务构想转化为向客户交付价值的、由技术驱动的服务所需要的流程”。 


价值流始于工程师1（包括开发、QA、IT运维和信息安全人员）向版本控制系统中提交了一个变更，止于变更成功地在生产环境中运行，为客户提供价值，并生成有效的反馈和监控信息。 

 聚焦于部署前置时间 

 前置时间与处理时间（有时候也被称为接触时间或者任务时间）3是度量价值流性能的两个常用指标。 前置时间在工单创建后开始计时，到工作完成时结束；处理时间则从实际开始处理这个工作时才开始计时，它不包含这个工作在队列中排队等待的时间 
 

前置时间是客户能够体验到的时间，所以我们把重点放在缩短前置时间而不是处理时间上。不过，处理时间与前置时间的比率是十分重要的效率指标，为了实现快速的流动并缩短前置时间，必须缩短工作在队列中的等待时间。 

 在DevOps的理想情况下，开发人员能快速、持续地获得工作反馈，能快速和独立地开发、集成和验证代码，并能将代码部署到生产环境中（自己部署或者他人部署）。 我们可以通过如下方式达到这个目标：向版本控制系统中持续不断地提交小批量的代码变更，并对代码做自动化测试和探索测试，然后再将它部署到生产环境中。这样，我们就能对代码变更在生产环境中的成功运行保持高度自信，同时还能快速地发现并修复可能出现的问题。 为了更容易地实现上述目标，还需要通过模块化、高内聚、低耦合的方式优化架构设计，帮助小型团队自治地工作。 

 第一步，实现开发到运维的工作快速地从左向右流动。为了最大程度地优化工作流，需要将工作可视化，减小每批次大小和等待间隔，通过内建质量杜绝向下游传递缺陷，并持续地优化全局目标。 通过加快技术价值流的流速，缩短满足内部或者外部客户需求所需的前置时间，尤其是缩短代码部署到生产环境所需的时间，可以有效地提高工作质量和产量，并使企业具有更强的外部竞争力。 相关的实践包括持续构建、集成、测试和部署，按需进行环境搭建，限制在制品数量，构建能够安全地实施变更的系统和组织。 

 第二步，在从右向左的每个阶段中，应用持续、快速的工作反馈机制。该方法通过放大反馈环防止问题复发，并能缩短问题检测周期，实现快速修复。通过这种方式，我们能从源头控制质量，并在流程中嵌入相关的知识。这样不仅能创造出更安全的工作系统，还可以在灾难性事故发生前就检测到并解决它。 

 第三步，建立具有创意和高可信度的企业文化，支持动态的、严格的、科学的实验。通过主动地承担风险，不但能从成功中学习，也能从失败中学习。通过持续地缩短和放大反馈环，不仅能创造更安全的工作系统，也能承担更多的风险，并进行试验帮助自己比竞争对手改进得更快，从而在市场竞争中战胜他们。 


## DevOps误区

### 误区1：DevOps只适用于创业公司  

他们所遇到的问题和传统企业相比并无二致：软件的高风险代码容易导致灾难性故障，无法快速发布新功能来击败竞争对手，存在安全合规性问题，服务无法扩容，开发和运维彼此高度不信任等。 

**这里补充下：可能DevOps 在创业公司或者小团队更好推广而已**

### 误区2：DevOps将取代敏捷

敏捷通常是DevOps效率的保障，因为它专注于让小团队向客户持续交付高品质的代码。 

迭代的目标不限于“潜在可交付的代码”，而是扩展到让代码始终处于可发布状态，让开发人员每天都把代码提交到主干，并在类生产环境中做功能演示

**没有敏捷，就无法拆分需求，最终无法度量交付，DevOps根本无法推广**

### 误区3：DevOps与ITIL不兼容

为了支持DevOps所追求的更短的发布周期和更频繁的部署，ITIL流程的许多方面需要完全自动化，以解决配置和发布管理流程相关的许多问题，例如保持配置管理数据库和最终软件库是最新的

### 误区4：DevOps与信息安全及合规活动不兼容

它并不一定体现在项目结束时的安全和合规性活动中，而是集成到了软件开发生命周期的每一项日常工作中，因此会得到更好的质量、安全性和合规性

### 误区5：DevOps意味着消除IT运维，即“NoOps”

 IT运维团队要在软件生命周期的早期就与开发团队开展合作。在代码部署到生产环境中后，开发团队也要继续与运维团队合作。

 IT运维不只是工单驱动的手动操作，而是能够通过自助服务平台和API来提升开发人员的生产效率，让他们能自助地创建开发环境、测试和部署代码、监控和显示业务运行的状态等


### 误区6：DevOps只是“基础设施即代码”或自动化

DevOps还需要文化规范和架构，以便在IT价值流中实现共同的目标。而这远远超越了自动化的范畴 

DevOps不仅是自动化，就像天文学不只是望远镜一样。

### 误区7：DevOps仅适用于开源软件

开发、测试和部署代码，并且可以快速、安全、可靠地向客户交付价值。同时，公司能够有效地提高开发人员的生产力，建立学习型公司，提高员工满意度，并在市场竞争中取胜。 这就是DevOps产生的效果

