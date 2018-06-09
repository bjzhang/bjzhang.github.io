---
layout: post
title: 2018图灵奖Lecture：计算机体系结构的又一个黄金时代：特定领域的软硬件协同设计，增强安全，开源指令集和芯片的敏捷开发
categories: [Architecture]
tags: [Tech, CPU]
---

按：上周日（6月3日），在加利福尼亚2017年图灵奖获（2018年3月21日公布）得者Hennessy and Patterson做了[图灵奖lecture](http://iscaconf.org/isca2018/turing_lecture.html) ：A New Golden Age for Computer Architecture:
Domain-Specific Hardware/Software Co-Design, Enhanced Security, Open Instruction Sets, and Agile Chip Development。两个人因为在处理器架构的贡献，获得2017年图灵奖[Pioneers of Modern Computer Architecture Receive ACM A.M. Turing Award](https://www.acm.org/media-center/2018/march/turing-award-2017)：“Hennessy和Patterson对于微处理器的基础贡献引领了移动和物联网的发展”：
> Hennessy and Patterson’s Foundational Contributions to Today’s Microprocessors Helped Usher in Mobile and IoT Revolutions  
具体获奖细节请参考：[2017图灵奖揭晓：两位大神携手获奖，Google成最大“赢家”](https://zhuanlan.zhihu.com/p/34804910?utm_source=wechat_session&utm_medium=social&wechatShare=1&from=timeline&isappinstalled=0)。感谢郭雄飞同学帮忙把视频放到了墙内：[《图灵奖演讲2018》](https://v.qq.com/x/page/j06797ka9ul.html)。以下是本人笔记正文。

## CPU指令集的发展
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135711.png)
演讲第一部分首先回顾了中央处理器（CPU）的指令集（ISA）的发展。[指令集(ISA)](https://en.wikipedia.org/wiki/Instruction_set_architecture)是计算机的抽象，大致有三种：
* CISC(Complex Instruction Set Computer，复杂指令集)；
* RISC(Reduced Instruction Set Computer，精简指令集)；
* VLIW(Very Long Instruction Word，超长指令字）。

早期Intel X86是CISC架构，但是从[奔腾Pro](https://stackoverflow.com/questions/5806589/why-does-intel-hide-internal-risc-core-in-their-processors)开始，内部采用RISC核心。自从Intel安腾使用的VLIM失败后，最近15年内都没有新的通用处理器再使用VLIM。市场上99%以上处理器都是RISC（数据来源，演讲24分10秒）。

## 目前处理器面临的挑战
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135713.png)
[Dennard scaling](https://en.m.wikipedia.org/wiki/Dennard_scaling)描述了当晶体管尺寸越来越小的时候，电源密度是不变的，也就是同样尺寸芯片下面可以有更高的性能。由于半导体工艺的限制，随着晶体管尺寸的缩小，电源功耗并不会降低。Dennard scaling已经失效了。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135726.png)
同样的，摩尔定律也由于工艺的限制失效了。处理器性能的年增长已经由最高的52%降到2015年以后的3%。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135724.png)
如果飞机像软件一样，经常出功能异常(malfunction)的话，除了在加利福尼亚的人，没有人能参加今天的会议。

历史上人们想了很多手段去改善系统的安全。最开始我们认为这个应该可以从软件层面完全解决，但是遗憾的是软件层面没有办法解决全部问题（例如今年发现的五个幽灵/熔断漏洞：1，2，3，3a和4）。所以安全需要硬件的参与！

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135811.jpg)
以40年以前开始发展的x86架构为例，当前的安全状况：
* 底层的固件是封闭的。没有百分之百保证安全的办法。
* 不公开的指令集。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135732.png)
第二部分的结论。

## 如何解决上述问题？
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135734.png)
解决问题的思路有三个，软件，硬件，或软件硬件协同。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135823.png)
从上面例子可以看到，与通用的脚本语言python，相比更多的软硬件结合的优化可以做到6万倍的性能提升。

### 特定领域架构与特定领域语言
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135737.png)
上面对特定领域优化的例子，引出DSA（领域特定架构）：
* 这是一种针对特定领域优化的架构，但不是针对某个应用优化的（后者是专用集成电路（Application Specific Integrated Circuit: ASIC）要解决的问题）。
	* 半瓦注：例如国内比特大陆的比特币矿机就是对比特币挖矿这个特定应用优化的ASIC。
* 设计这种处理器需要比通用处理器更多的领域相关知识
* 例子：
	* 用于机器学习的神经网络处理器；
		* 半瓦注：笔者在[2018 GIAC速递之一：区块链](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483785&idx=1&sn=da6619c6bed8b01ad9ee10fc15b994c7&chksm=ec6cb7a5db1b3eb310ac65b36507a45ca853149548a936461425e3da6a6e2616a64bb89bb70a#rd)介绍了一些用AI芯片挖矿的区块链项目，这与使用专门的比特币矿机芯片相比。是从特定应用到特定领域应用的变化。
	* 用于图形和虚拟现实的GPU（俗称显卡）；
	* 可编程的网络设备。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135740.png)
机器学习论文增长的数量和摩尔定律的速度是一样的。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135740.png)
作者认为的方向就是垂直整合。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135747.png)
RISC-V考虑到DSA需求，预留了大量的op code。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135749.png)
另一个例子是英伟达的深度学习加速器。

### 增强安全
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135758.png)
安全要求是无后门，可以从控制整个硬件。RISC-V很可能是第一个进行软硬件协同设计的架构。

### 自由和开放的架构以及开源实现
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135752.png)
* RISC-V像Linux是开源的，更多组织和更多个人可以同时参与到RISC-V的研发；
* RISC-V指令集是组件化和可扩展的；
* 整个软件从下到上都是完全开源的（可以修改的）；
* 指令集从设计上考虑了从物联网到云计算的各种领域的需求；
* 由拥有一百名以上成员的基金会推动，保证可以长期演进。更多公司去做同一个架构的处理器，意味着更激烈的竞争。商业公司可以去卖一个指令集更好的实现。

### 敏捷芯片开发
![](2018-06-09-ACM-turing-lecture-2018/IMG_0083.PNG)
[chisel](https://chisel.eecs.berkeley.edu/)是一个模块化的硬件设计语言，助力硬件的敏捷开发。上图是不同RISC-V处理器的代码复用情况。

# 你可能感兴趣的文章

这是本月的第一篇文章。半瓦平时有随手记笔记的习惯，公众号原创文章只分享自己有体会的信息，希望能促进价值信息流动。任何建议欢迎给我留言或添加我的微信（公众号回复“微信”，可以看到半瓦的微信）：

- [春风吹又生—-梳理中国CPU](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483744&idx=1&sn=c1e047036062dd97aae70cd8d6682f41&chksm=ec6cb74cdb1b3e5a9a21be4b24519a125e071461c02fb4e962c839e2647824ffd313d542b9ae&scene=21#wechat_redirect)
- [Linux自动化部署工具综述（Linux自动化部署工具系列之一）](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483755&idx=1&sn=ce1aaa72e0cc2d1933c9ed8002ab96da&chksm=ec6cb747db1b3e51ee9b56f9c8e3fa10f879d97e5a0b17da0dbbb51b48b8fead0adaff64d9a4&scene=21#wechat_redirect)
- [比较操作系统镜像制作方式（Linux自动化部署工具系列之二）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483757&idx=1&sn=aa7376cf5f752b4d66a93a8d2fc99c20&scene=21#wechat_redirect)
- [来自suse的猕猴桃(KIWI)（Linux自动化部署工具之三）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483760&idx=1&sn=0785ed74878b5ef27943bda7fc6f2c9f&chksm=ec6cb75cdb1b3e4a10a929940ad79c9dee77917730e3d80ef2fd0de48d8e336c397c081037a1&scene=21#wechat_redirect)
- [与社区共舞：如何追踪Linux内核社区最新动向（之一）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483776&idx=1&sn=cfcd68120e95b3189b80e99f766bb6a4&chksm=ec6cb7acdb1b3eba24e78e672fce1ec48fc74fb138cdc4ccd5f8b85359ba61e7083e4581877b#rd)
- [2018 GIAC速递之一：区块链](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483785&idx=1&sn=da6619c6bed8b01ad9ee10fc15b994c7&chksm=ec6cb7a5db1b3eb310ac65b36507a45ca853149548a936461425e3da6a6e2616a64bb89bb70a#rd)

## 参考链接

* 指令集: https://en.wikipedia.org/wiki/Instruction_set_architecture
* 从奔腾Pro开始Intel x86内部开始使用RISC核心：https://stackoverflow.com/questions/5806589/why-does-intel-hide-internal-risc-core-in-their-processors
* 2017年图灵奖（2018年3月21日公布）
	* 英文：https://www.acm.org/media-center/2018/march/turing-award-2017
	* 知乎 量子位的中文文章：https://zhuanlan.zhihu.com/p/34804910?utm_source=wechat_session&utm_medium=social&wechatShare=1&from=timeline&isappinstalled=0

## 其它
* 工艺进步和电源密度的交叉点出现在2008年。
![](2018-06-09-ACM-turing-lecture-2018/IMG_0095.PNG)
* 岁月如梭：两位图灵奖获得者1980年第一次见面到今年已经相识38年。
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135847.png)
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135845.png)
![](http://opuclx9sq.bkt.clouddn.com/2018-06-09-135843.jpg)

