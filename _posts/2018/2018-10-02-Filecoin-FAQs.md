---
layout: post
title: Filecoin FAQs解读版
categories: [Software]
tags: [Blockchain]
---

原文地址：[https://filecoin.io/faqs](https://filecoin.io/faqs)

## 什么是Filecoin和IPFS
FAQ从IPFS和Filecoin是什么开始，着重回答了两个问题：
*  “When should I choose to use Filecoin and when should I choose IPFS?）”（“什么情况下选择Filecoin，什么情况下选择IPFS？”）：使用IPFS，意味着需要自己管理存储节点，每个节点都需要主动存储数据，IPFS层的每个节点并不会保证数据不会丢失。Filecoin通过激励机制解决了上述问题。
* Filecoin和中心化存储（google cloud，apple cloud，百度网盘）的区别。

## 挖矿
**Storage miners 得到块奖励（block reward）和交易费用（transaction fees）是和矿工对网络贡献的存储能力成正比的，和hash算力无关。**
**Retrieval miners想获得对于特定文件的出价和交易费用，需要看带宽，出价或对于交易的初始相应时间（时延，与客户的距离）。retrieval miner的能支持的最大交易量由最大带宽决定。**

矿机的形态和NAS类似，具体的CPU和内存要求还没有确定。值得注意的是，早起矿工需要做为全节点（Full node）接入Filecoin网络。

由于Filecoin使用的Proof-of-Replication and Proof-of-Spacetime并不是（类似于比特币）的计算hash的PoW。虽然Filecoin的proof需要硬件的辅助，但是由于ASIC（专用集成电路）随机访问大内存成本比较高，所以**ASIC用场不大**。协议实验室认为商业硬盘在产生和验证证明都能得到由竞争力的速度。

存储节点会存储两部分内容，一个是sealed数据（也就是用户要实际存储的数据），一部分是Filecoin区块链本身的数据。用户数据本身并不包括在Filecoin链上数据中。Filecoin区块链的数据会远远小于用户数据的数量。

Retrieval miners允许自己存储数据，但是这并不意味着Retrieval miners成为Storage miners。Filecoin鼓励更多的Storage miners，它们可以质押存储，担保和通过Proof-of-Spacetime证明存储的连续性。

我们预计Retrieval miners同时会成为Storage miners或者从Storage miners得到他们认为的热点文件。Retrieval miners并不一定从Filecoin得到数据，也可以从IPFS网络（免费）得到。

“How can a blockchain-based protocol handle fast retrieval of files?”（基于区块链技术的协议如何保证快速得到一个文件？）：retrieval market是链下市场。

**在存储市场，矿工通过一直存储具体特定的文件获得奖励，同时存储市场的矿工有机会得到出块奖励以及记录在该块的所有交易的费用（和其它加密货币类似）。在索引市场，矿工通过更快为off-chain（链下）提供文件得到奖励。**

## 客户
在为什么要使用Filecoin而不是已有token或直接使用美元时，协议实验室强调“Payment and rewards in filecoin power the incentive structure to guarantee a fair, permissionless, robust, and decentralized storage network.”，Filecoin的token FIL用于提供一个公平，permissionless（公链？），鲁棒和去中心化的存储网络。
permissionless networks相对于permissioned network，前者是类似于比特币，以太坊，任何人都可以参与的网络。

**在Filecoin得到数据是否是付费的？有些情况是，有些情况不是。** Filecoin中最基本的情况是，客户为得到数据付费。当然这个情况不能满足当前互联网的所有情况。例如可能有公司或组织通过优惠券的方式（免费）为最终客户提供数据服务，例如网站的运营者为网站付费，Filecoin的最终客户可以免费访问这个网站。（单纯的）IPFS节点和网络仍然是免费的。Filecoin上线后，IPFS节点可以收费或免费提供数据。此外，我们相信，会有非政府组织或政府赞助（是最终客户可以免费）访问科学或文化数据。**看起来协议实验室官方认为会有很多Filecoin的运营商**

没人能保证数据一定不会丢失，但是Filecoin网络会尽力保证数据尽可能可靠的做了副本。如果某个Filecoin节点数据丢失，它会损失它的质押的FIL。这里如果节点短时不在线，不会损失质押，长时间不在线才会。Filecoin网络会（通过存储市场？）自动找到另一个节点存储数据。

**Filecoin市场有个默认的副本数量，客户可以根据需要调整副本数量。**

如何保证hash碰撞？Filecoin选择了当前供认的不容易碰撞的hash算法。同时Filecoin使用CID保证未来平滑升级到其它（更好）的hash算法。**目前IPFS社区正在致力于从CIDv0升级到CIDv1**。

但是hash很难记忆怎么办？Filecoin社区计划解决这个问题。

## Filecoin进阶
在去中心化这节，Filecoin列出了很多点，下面这些点看起来是说明Filecoin开源和建立基金会的信心，**但是如何在初期保证社区不会分裂呢？** 任何人，无需任何许可可以：
* Audit and verify the codebase
* Improve the protocol by proposing and implementing improvements
* Fork the codebase
* Fork the blockchain

## 社区
再次强调Filecoin在中国没有官方社区。

**提到了Filecoin meetup。可以发邮件到team@filecoin.io申请（描述name, background, experience, and location）。我们要不要占这个坑？**

### 社区研究奖励
目前有效的有两个，都是关于CRDT的，最高能有20万美元的奖励：
* [ Data laced with permissions: Decentralised Access Control in CRDTs ](https://github.com/protocol/research-RFPs/blob/master/RFPs/rfp-4-CRDT-ACL.md)
* [ Optimize storage and convergence time in causal CmRDTs ](https://github.com/protocol/research-RFPs/blob/master/RFPs/rfp-5-optimized-CmRDT.md)

