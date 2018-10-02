---
layout: post
title: IPFS+Filecoin北京meetup by 董天一（2018年9月15日）
categories: [Software]
tags: [Blockchain]
---

今天（2018年9月15日）在北京中关村IC咖啡，董天一老师为大家讲解了Filecoin，IPFS和Libp2p三个项目，笔者之前对ipfs和libp2p有些了解，仅仅记录了之前不知道的信息。供大家参考。![从左至右分别是徐潇，戴嘉乐和董天一](http://opuclx9sq.bkt.clouddn.com/macbook/2018-09-16-060659.jpg)
*从左至右分别是徐潇，戴嘉乐和董天一*

## 热场
* 全球大约2700人的社区，以开发者为主。
* 协议实验室之前没有商务，现在刚有。
* 中国只有志愿者没有官方渠道。

## why filecoin
提到5G有更新的延迟，IPv6对于物联网的价值。强调js ipfs对于接入ipfs的意义。笔者之前写的[Filecoin Q1和Q2 update](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483884&idx=1&sn=beb97d485de90dedbbf742903c53d36a&chksm=ec6cb7c0db1b3ed619e0401cbc607a28f6e305995d420c291bf02350f062cdec6a3c9f082abb&token=735856262&lang=zh_CN#rd "Filecoin Q1&Q2 Update")对此也有涉及。

## libp2p介绍
董天一提到libp2p规划做共识协议。笔者觉得应该是overlay在libp2p之上。google搜了下，只看到[https://github.com/libp2p/go-libp2p-consensus](https://github.com/libp2p/go-libp2p-consensus)，这个项目只在2016年有几个更新，并且github上没有其它项目引用。徐潇说目前代码尚未公开，看来是启动了新的项目。这个倒是比较符合协议实验室的习惯（笑）。

### 网络穿透
不管filecoin还是ipfs都是基于libp2p协议。内网需要NAT做穿透。最新的协议是Interactive Connectivity Establishment (ICE) （[rfc8445（参考链接1）](https://tools.ietf.org/html/rfc8445)）。董天一在寻求ICE go语言版本的合作。目前他不清楚社区是否能在上线前完成。戴嘉乐成立的公司有技术专家在和社区和一起做这个事情。

## IPFS
![IPFS全球节点分布。可以看到欧洲和美国最多](http://opuclx9sq.bkt.clouddn.com/macbook/2018-09-16-061149.jpg)
*IPFS全球节点分布。可以看到欧洲和美国最多*

![awesome.ipfs.io](http://opuclx9sq.bkt.clouddn.com/macbook/2018-09-16-060629.png)
*awesome.ipfs.io*

笔者所在公司星际比特计划从中选择一些有趣的项目介绍，已经完成的文章：
* [ IPFS软件生态系列之淘宝篇 ](https://mp.weixin.qq.com/s/ntEwUxS_hyonQRN83gHXmg)
* [ IPFS软件生态系列之视频篇 ](https://mp.weixin.qq.com/s/xmdoB5sZ0JeZcrHIrXJ9XA)

### ipfs子网
董天一认为ipfs未来会成为互联网的子网。重点讲了浏览器对于ipfs的支持。

## filecoin
### 爱西欧
![Filecoin代币经济体系](http://opuclx9sq.bkt.clouddn.com/macbook/2018-09-16-060534.jpg)
*Filecoin代币经济体系*

* 首先解释了为什么filecoin付费是合理的，世界上没有免费的午餐。
* 提到了后续会成立filecoin基金会。
* filecoin在2017年解决了没有度量网络带宽的问题：retrieval market（流量市场）。
* 通过时空证明分发新币。只和存储矿工有关系。
* 使用micro payment减少双花的概率。Filecoin是谁（矿工）提供数据给谁钱。
* 复制证明的论文提到了形式化证明。
* **seal的sector目前在1M到1T之间**。未来没有确定。很耗费cpu。

### 共识
PoStake -\> PoStorage -\> PoRep -\> PoSt

## 问答
### 问题ipns有没有机会？
没有。另外觉得ipns性能还需要优化。
### Erasure Code
**Filecoin EC默认是5+2** 。
### 第一批矿工的代币从哪里来？
（这个笔者之前没有考虑过）。主网上线前，代币会有发放方法。例如注册早期矿工空投。
### 内网专线。
如果有内网专线，异地走内网（比走公网快）有没有意义？
网络会做自平衡，优先考虑距离近的用户。
离用户距离近，指的是延迟和带宽。
### ipfs目前主要是cdn应用。
### 戴嘉乐成立了公司做ipfs
### ipfs社区
董天一是ipfs大使（中国）

## 参考链接
1. rfc8445(ICE): https://tools.ietf.org/html/rfc8445

