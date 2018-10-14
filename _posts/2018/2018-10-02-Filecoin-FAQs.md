#Filecoin官方FAQ缩编和解读

10月2日协议实验室官方发布了FAQ。这是今年继多篇存储证明（Proof of Replication）论文（参考公司星际比特的发问：[深度剖析复制证明论文](https://mp.weixin.qq.com/s/c6yyt9_-btRl8muxlZW0qw)），Q1，Q2 Update（参见笔者文章：[是戏法是真货？深度解读Filecoin Q1&Q2 Update](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483884&idx=1&sn=beb97d485de90dedbbf742903c53d36a&scene=21#wechat_redirect)）之后第三篇长文，笔者读后觉得信息量很大。下文节选了笔者感兴趣的新增内容并标出了重点，与诸君分享。原文地址：[https://filecoin.io/faqs](https://filecoin.io/faqs)，全文翻译见公司公众号IPFS星际比特文章：[IPFS/Filecoin发布官方FAQs](https://mp.weixin.qq.com/s/dHBaV82o0ZPKf1nIsbPw7Q)。

*注：下文以半瓦开头的内容是笔者所加，其余为官方内容。*

## 什么是Filecoin和IPFS
FAQ从IPFS和Filecoin是什么开始，着重回答了两个问题：
*  “When should I choose to use Filecoin and when should I choose IPFS?）”（“什么情况下选择Filecoin，什么情况下选择IPFS？”）：使用IPFS，意味着需要自己管理存储节点，每个节点都需要主动存储数据，IPFS层的每个节点并不会保证数据不会丢失。Filecoin通过激励机制解决了上述问题。
* Filecoin和中心化存储（google cloud，apple cloud，百度网盘）的区别。

## 挖矿
**Storage miners 得到块奖励（block reward）和交易费用（transaction fees）是和矿工对网络贡献的存储能力成正比的，和hash算力无关。**
**Retrieval miners想获得对于特定文件的出价和交易费用，需要看带宽，出价或对于交易的初始相应时间（时延，与客户的距离）。retrieval miner能支持的最大交易量由最大带宽决定。**

矿机的形态和NAS类似，具体的CPU和内存要求还没有确定。值得注意的是，早起矿工需要做为全节点（Full node）接入Filecoin网络。

由于Filecoin使用的Proof-of-Replication and Proof-of-Spacetime并不是（类似于比特币的）计算hash的PoW。虽然Filecoin的proof需要硬件的辅助，但是由于ASIC（专用集成电路）随机访问大内存成本比较高，所以**ASIC用场不大**。协议实验室认为商业硬盘在产生和验证证明都能做到有竞争力的速度。

存储节点会存储两部分内容，一个是sealed数据（也就是用户要实际存储的数据，seal目的见文末名次解释），另一部分是Filecoin区块链本身的数据。用户数据本身并不包括在Filecoin链上数据中。Filecoin区块链的数据会远远小于用户数据的数量。

Retrieval miners允许自己存储数据，但是这并不意味着Retrieval miners成为Storage miners。Filecoin鼓励更多的Storage miners，它们可以质押存储，担保和通过Proof-of-Spacetime证明存储的连续性。

我们预计Retrieval miners同时会成为Storage miners或者从Storage miners得到他们认为的热点文件。Retrieval miners并不一定从Filecoin得到数据，也可以从IPFS网络（免费）得到。

**在存储市场，矿工通过一直存储具体特定的文件获得奖励，同时存储市场的矿工有机会得到出块奖励以及记录在该块的所有交易的费用（和其它加密货币类似）。在索引市场，矿工通过更快为off-chain（链下）提供文件得到奖励。**

## 客户
在解释为什么要使用Filecoin而不是已有token或直接使用美元时，协议实验室强调“Payment and rewards in filecoin power the incentive structure to guarantee a fair, permissionless, robust, and decentralized storage network.”，Filecoin的token FIL用于提供一个公平，permissionless，鲁棒和去中心化的存储网络。
半瓦注：permissionless networks相对于permissioned network，前者例如比特币，以太坊等公链，任何人都可以参与的网络。

**在Filecoin得到数据是否是付费的？有些情况是，有些情况不是。** Filecoin中最基本的情况是，客户为得到数据付费。当然这个情况不能满足当前互联网的所有情况。例如可能有公司或组织通过优惠券的方式（免费）为最终客户提供数据服务，例如网站的运营者为网站付费，Filecoin的最终客户可以免费访问这个网站。（单纯的）IPFS节点和网络仍然是免费的。Filecoin上线后，IPFS节点可以收费或免费提供数据。此外，我们相信，会有非政府组织或政府赞助访问科学或文化数据（最终客户可以免费）。**半瓦：看起来协议实验室官方认为会有很多Filecoin的运营商**

没人能保证数据一定不会丢失，但是Filecoin网络会尽力保证数据尽可能可靠的做了副本。如果某个Filecoin节点数据丢失，它会损失它的质押的FIL。这里如果节点短时不在线，不会损失质押，长时间不在线才会。Filecoin网络会（通过存储市场？）自动找到另一个节点存储数据。

**Filecoin市场有个默认的副本数量，客户可以根据需要调整副本数量。**

如何保证hash碰撞？Filecoin选择了当前供认的不容易碰撞的hash算法。同时Filecoin使用CID保证未来平滑升级到其它（更好）的hash算法。**半瓦：目前IPFS社区正在致力于从CIDv0升级到CIDv1**。

但是hash很难记忆怎么办？Filecoin社区计划解决这个问题。

## Filecoin进阶
在去中心化这节，Filecoin列出了很多点，下面这些点看起来是说明Filecoin开源和建立基金会的信心，**（半瓦：但是如何在初期保证社区不会分裂呢？）** 任何人，无需任何许可可以：
* Audit and verify the codebase
* Improve the protocol by proposing and implementing improvements
* Fork the codebase
* Fork the blockchain

## 社区
再次强调Filecoin在中国没有官方社区。

提到了Filecoin meetup。

### 社区研究奖励
目前有效的有两个，都是关于CRDT的，最高能有20万美元的奖励：
* [ Data laced with permissions: Decentralised Access Control in CRDTs ](https://github.com/protocol/research-RFPs/blob/master/RFPs/rfp-4-CRDT-ACL.md)
* [ Optimize storage and convergence time in causal CmRDTs ](https://github.com/protocol/research-RFPs/blob/master/RFPs/rfp-5-optimized-CmRDT.md)

### 名词解释

Seal操作的目的是：

强制保存多个不同副本时每个副本都是有差异的；

保证PoRep的Setup时间比Challenge时间长。这就是保证了存储矿工不可能在Verifier检查文件是否存在时临时生成指定的副本。

# 你可能感兴趣的文章

半瓦平时有随手记笔记的习惯，公众号原创文章只分享自己有体会的信息，希望能促进价值信息流动。任何建议欢迎给我留言或添加我的微信（公众号《敏达生活》后台回复“微信”，可以看到半瓦的微信）。

* [区块链与数据存储周报（2018年9月17日-2018年9月23日）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483897&idx=1&sn=19453afa202772521a7b57f052072184&chksm=ec6cb7d5db1b3ec3abb7e61e3483b11661267e9c22a35174a0b4fb2516e1deceda6fb8a00c7d&token=1343963564&lang=zh_CN#rd)
* [IPFS+Filecoin北京meetup by 董天一（2018年9月15日）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483890&idx=1&sn=d1d6bb3a86f5fdaab5495f9024df13de&scene=21#wechat_redirect)
* [是戏法是真货？深度解读Filecoin Q1&Q2 Update](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483884&idx=1&sn=beb97d485de90dedbbf742903c53d36a&scene=21#wechat_redirect)
* [“黎曼猜想”推翻区块链加密算法？（](https://mp.weixin.qq.com/s?__biz=MzU4NDQ5NzE3NQ==&mid=2247484130&idx=1&sn=8d1ce1399e8f5c015fd48e5cf58ee5cb&scene=21#wechat_redirect)原创：IPFS星际比特）
* [《理解孩子的画》——与孩子一起成长](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483918&idx=1&sn=fa9b33bb5b34604895dd24f6a8ea3183&chksm=ec6cb422db1b3d343413dc73c4a6ba1bdd6aa7ef6910c1f1c80a94ae4daa51c9ed9cedbc6697&token=1343963564&lang=zh_CN#rd)



本文首发笔者公众号[敏达生活](https://mp.weixin.qq.com/s/9Dbq6H9amoHR15RicO1MFA)，欢迎大家勾搭，拍砖。
