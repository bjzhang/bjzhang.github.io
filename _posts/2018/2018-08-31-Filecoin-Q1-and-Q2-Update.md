# 是戏法是真货？深度解读Filecoin Q1&Q2 Update

北京时间周二午夜，协议实验室公布了[Filecoin 2018年第一季度和第二季度的进展（参考链接1）](https://filecoin.io/blog/update-2018-q1-q2/ "filecoin 2018 Q1&Q2 Update")，内容包括开发进展，研究进展，路线图，媒体报道和演讲，filecoin与协议实验室两个两个项目IPFS和libp2p的关系等内容。Update描述的Filecoin开发进展比之前详细的多，再结合Q2 Roadmap（参考链接2），心里觉得踏实很多，感觉Filecoin项目还是挺靠谱的。

## 从Filecoin开发进展开Filecoin架构
![图1: Filecoin Development Update]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/Image.jpeg "Filecoin Development Update https://filecoin.io/blog/update-2018-q1-q2/")
上面是Filecoin的开发进展，这是Filecoin项目第一次涉及到和协议实验室的IPFS和libp2p两个项目的关系。原本这篇文章之前，我心里面Filecoin和二者的关系是这样的。
![图2: 我原本想象的Filecoin与IPFS和libp2p]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/DraggedImage.png)
看完这次资料之后，脑补了下面这张图：
![图3: 脑补Filecoin与IPFS，Libp2p关系]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/DraggedImage-1.png "脑补Filecoin与IPFS，Libp2p关系")
上图中数字代表开发进展中的数字编号。上图中IPLD是IPFS中的重要组件（见下图），它用于IPFS数据表示和管理，IPFS中默认使用balanced merkledag存储数据。
![图4: IPFS Stack]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/17D1E28E-E8D1-49AF-8DB1-53875469EA76.jpeg)
下图是协议实验室js-ipfs团队提供的IPFS核心架构图，可以看到DAG向上通过unixfs提供和\*nixz一致的文件和目录管理，对下连接Bitswap（即上图的exchange，节点间数据交换）和blocks service（IPFS节点负责本地存储的接口）。笔者后续可以会写IPFS数据之旅系列文章，心急的小伙伴可以参考
这篇文章：[Understanding the IPFS White Paper part 2 (参考链接3）](https://hackernoon.com/understanding-the-ipfs-white-paper-part-2-df40511addbd)
![图5: ipfs core architecture https://github.com/ipfs/js-ipfs#ipfs-core-architecture]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/ipfs-core.png "ipfs core architecture")
上图没有表示的内容有：

* 第四条“miners can assemble blocks”结合Roadmap的“Miners can assemble transactions into a block (block creation)”，可以知道Filecoin目前已经可以从transactions建立区块（Block）。
* 第五条”the nodes validate blocks & achieve consensus on the heaviest chain”和后面roadmap的“Nodes can choose the heaviest (or highest quality) chain (consensus)”，看起来是防止分叉的事情，具体怎么做的还不清楚。想一想现在的区块链项目很多是基于DAG的账本，Filecoin会不会也是呢？
* 8, 9, 10三条都是Filecoin协议的实现，参见Filecoin白皮书：
![图6: Illustration of the Filecoin Protocol, showing an overview of the Client-Miner interactions. from Filecoin whitepaper]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/DraggedImage-2.png "Illustration of the Filecoin Protocol, showing an overview of the Client-Miner interactions. from Filecoin whitepaper")
参考链接2中的Roadmap还提到了Gas（运行智能合约的费用），下图是以太坊中gas对虚拟机执行智能合约（智能合约概念参见参考链接4）的影响：
![图7: ethereum evm]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/DraggedImage-3.png "https://takenobu-hs.github.io/downloads/ethereum_evm_illustrated.pdf")
有心画成computes.io的样子，还是缺一些信息：
![图8: computes.io architecture]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/F4F03F7F-44D7-404C-89FC-C505FFB785B6.png "computes.io architecture")

## Filecoin研究进展
Filecoin研究一直围绕复制证明（Proof of REPlication）进行。在协议实验题500万美元的资助下，今年上半年也的确有5篇PoREP论文（参见公司公众号的解读：[深度剖析复制证明论文](https://mp.weixin.qq.com/s/c6yyt9_-btRl8muxlZW0qw)），目前这方面研究已经转向PoREP的细分领域。
![]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/DraggedImage-4.png)
进展同时强调，上面对于PoREP的改进和Filecoin的测试网络是并行进行的，这里面的优化是说的性能优化，我认为言外之意是测试网络上线的时候很有可能不会用到这些性能优化，也就是说刚开始测试矿机需要性能比较强。考虑到Filecoin未来的需求，团队也在如下方面有部分投入：

1. fully off-chain market orders;
2. chain compression using proofs;
3. user-defined file contracts;
4. scalable consensus.
这次Update和Roadmap多次提到了On-chain和Off-chain的工作。结合之前Filecoin白皮书的Filecoin客户与矿机之前的交互协议（见前文图6），可以有更准确的理解。

## libp2p与Filecoin
![Other libp2p transports for Filecoin]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/Image-1.jpeg "Other libp2p transports for Filecoin")
Highlight里面重点提到了Transports。

### QUIC
libp2p新增的QUIC准备用在Retrieval Market。QUIC是libp2p的[Transport接口（参考链接5）](https://github.com/libp2p/go-libp2p-transport/blob/master/transport.go#L42 "libp2p Transport Interface")的实现。默认的Transport实现包括TCP，UTP(Micro Transport Protocol)。另一方面，go-ipfs QUIC支持正在合入[ add QUIC support （参考链接6）](https://github.com/ipfs/go-ipfs/pull/5350)。未来可以使用形如下面的multiaddress通过QUIC访问，”/ip4/0.0.0.0/udp/4001/quic/“，此外社区再讨论要不要支持”/ip4/127.0.0.1/udp/0/quic”，0表示由操作系统分配端口。

### Tor
Tor改善了网络通信的匿名和隐私，所以适合用在用在安全和隐私要求比较高的存取文件场景。从2015年开始，社区就开始讨论Tor集成到IPFS，目前有两个思路，一个是OpenBazaar项目的[go-onion-transport（参考链接7）](https://github.com/OpenBazaar/go-onion-transport)，需要在系统或浏览器中集成Tor，并打开Tor control port，[参见：参考链接8](https://github.com/ipfs/notes/issues/37#issuecomment-307966649)。另一种是IPFS中集成Tor。

### 使用libp2p的区块链项目
![libp2p used by many blockchain application]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/Image-2.jpeg "libp2p used by many blockchain application https://filecoin.io/blog/update-2018-q1-q2/")
Libp2p有Polkadot, 以太坊，OpenBazaar（项目介绍参见公司公众号文章 ：[IPFS生态之淘宝篇](https://mp.weixin.qq.com/s/ntEwUxS_hyonQRN83gHXmg)）, Livepeer, Keep Network和Paratii等区块链项目使用。其中Polkadot和以太坊都在最近从以太坊的devp2p迁移到了协议实验室的libp2p，而且Polkadot还是[第一个实际使用rust-libp2p的项目（参考链接8）](https://medium.com/polkadot-network/polkadot-poc-2-is-here-parachains-runtime-upgrades-and-libp2p-networking-7035bb141c25 "polkadot-poc-2-is-here-parachains-runtime-upgrades-and-libp2p-networking")，笔者也很吃惊，要知道libp2p的rust开发时间是最短的，但是Rust在移动设备，嵌入式设备和c语言绑定方面有很大优势。又没有go语言的gc问题。想必对于Polkadot要解决区块链互操作性问题有帮助。

## IPFS与Filecoin
IPFS和Filecoin这部分说明了什么是IPFS，并解释了二者的关系，但是有意思是的，里面没有提到任何IPFS具体技术。似乎说明IPFS基本满足了Filecoin的需要。有意思的是，IPFS和libp2p两部分都强调了二者对浏览器的支持，笔者猜测Filecoin所有的监控运维能力都通过ipfs和libp2p实现，从浏览器直接通过libp2p协议连接到Filecoin网络。
![Some recent IPFS User Highlights]({{site.url}}/public/images/2018-08-31-Filecoin-Q1-and-Q2-Update/Image-3.jpeg "Some recent IPFS User Highlights https://filecoin.io/blog/update-2018-q1-q2/")

## Roadmap / Upcoming Milestones
### go-filecoin collaborator & contributor preview (ETA: 2018 Q4)
在今天第四季度，go-filecoin会引入早起社区贡献者。申请表格有如下信息：
* 提到了go和rust两门语言的要求，意味着Filecoin未来会有go和rust两个版本。
* 两个问题提到关于是否了解开源开放方式。在github上有持续活跃的贡献，对开源社区运作比较了解对申请会有帮助。
* 是否对协议实验室的IPFS和libp2p有贡献。前文已经提到，Filecoin与IPFS和libp2p的关系，对二者有实际贡献有助于更好的参与Filecoin的开发。
* 语言和地区。希望不同地区的人都能参与，并帮助翻译文档。

	## 	ETA: 2018 Q4/2019 Q1 Opening up the go-filecoin codebase; Launching the first public Filecoin testnet
2018年第四季度和2019年第一季度安排了两个事情，go-filecoin项目开源和第一个公共测试网络上线。二者其实并没有依赖关系。早期矿工调查表格包括：矿工的硬盘类型（HDD，SSD和磁带），矿场容量（最大10PB+，10PB+的矿场群将在2019年第一季度测试），带宽等信息。

### go-filecoin v1.0.0 feature freeze (ETA: 2019 Q1/Q2)
2019年第一第二季度go-filecoin v1.0.0版本feature freeze（特性冻结）。此后不能再添加新的特性，在修复所有已知问题之后，会进入Code Freeze（代码冻结）。Code Freeze之后做系统测试，如果没有问题，版本会Release（发布）。

### Security Review & Audit (ETA: 2019 Q1/Q2)
1.0.0 release之后会进行严格的安全review和审计。

### Launching the Filecoin mainnet (ETA: 2019 Q2/Q3)
主网上线之后，会持续改进网络的扩展性，完善网络工具，建立Filecoin基金会。基金会是开源社区的一种运作方式。例如Linux foundation（Linux基金会），多年来不仅仅支持了Linux社区的发展，还支持了Linux社区其它社区的发展，例如联盟链中常用的基础设施Hyperledger就是Linux基金会的项目。

## Filecoin Project Roadmap (2018-Q2)
文中还提到了[Filecoin Project Roadmap (2018-Q2) （参考链接2）](https://docs.google.com/document/d/1cgss-rifFO2iSJgnMmOsD_tPal40MUp1m7crTFQuVYQ)，里面涉及到更多技术细节。文中用绿色表示基本完成，黄色表示正在进行，无颜色是TODO。从中可以看到
* 区块链，网络和存储市场的基本功能已经完成。只有网络部分更好的查找算法还没有做，这部分正是最近社区正在讨论和解决的。
* PoRep已经有了原形，下一步是满足产品级的需求。所以依赖PeRep的Seal操作目前还没有开始，回顾下Filecoin的白皮书，Seal操作的目的是：
	1. 强制保存多个不同	副本时每个副本都是有差异的；
	2. 保证PoRep的Setup时间比Challenge时间长。这就是保证了存储矿工不可能在Verifier检查文件是否存在时临时生成指定的副本。
* 由于Seal还没有做，文件修复（使用纠删码）也没有开始。
* 虚拟机基本功能已经有了，目前在做出错处理，例如gas（用于交易的费用）没有时，虚拟机需要暂停。

## 你可能感兴趣的文章
### 区块链与数据存储周报
* [2018年7月29日——2018年8月4日](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483851&idx=1&sn=31e6b017cf5a7cf34ac89fe7a5204c18&chksm=ec6cb7e7db1b3ef1c8f44a1ab2477bf94c084b79888c970f7e57fdd1be5c7d1418182c64ae54&scene=21#wechat_redirect)
* [2018年8月5日——2018年8月11日](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483865&idx=1&sn=01c8edf1f03df9b991ab9574d8243431&chksm=ec6cb7f5db1b3ee3e7240ca3f2cf5e1096bba42d082ec3a1c176657063c23f695b1c605702ef&token=902989691&lang=zh_CN&scene=21#wechat_redirect)
* [2018年8月12日——2018年8月18日](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483872&idx=1&sn=2b3726657013c60095720e4ada1b1d5b&chksm=ec6cb7ccdb1b3eda61a4f69b9b41065ffec551c406c404807439cba20fa625c730ab90b3b45a&token=1825062655&lang=zh_CN&scene=21#wechat_redirect)
* [2018年8月19日——2018年8月25日](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483879&idx=1&sn=31699f3d0130cb586f04c2ea04601d59&chksm=ec6cb7cbdb1b3edddbdd0ae9fbaf1e1454a6b385dbd5d9e07d8c87dccad563ab6435461b06ce&token=2069466773&lang=zh_CN#rd)

### 原创技术文章
* [2018图灵奖Lecture：计算机体系结构的又一个黄金时代：特定领域的软硬件协同设计，增强安全，开源指令集和芯片的敏捷开发](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483810&idx=1&sn=7da1d609b0d8d3c91a5fee82d2b5551a&chksm=ec6cb78edb1b3e98d5f201457d69c08565e28757be2ff36a97b40e5d1e24d5eeea006812b54a&scene=21#wechat_redirect)
* [春风吹又生—-梳理中国CPU](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483744&idx=1&sn=c1e047036062dd97aae70cd8d6682f41&chksm=ec6cb74cdb1b3e5a9a21be4b24519a125e071461c02fb4e962c839e2647824ffd313d542b9ae&scene=21#wechat_redirect)

## 参考链接
1.  Filecoin 2018 Q1 & Q2 Update: [https://filecoin.io/blog/update-2018-q1-q2/ ](https://filecoin.io/blog/update-2018-q1-q2/)
2. Filecoin Project Roadmap (2018-Q2) : [https://docs.google.com/document/d/1cgss-rifFO2iSJgnMmOsD_tPal40MUp1m7crTFQuVYQ/edit?usp=sharing ](https://docs.google.com/document/d/1cgss-rifFO2iSJgnMmOsD_tPal40MUp1m7crTFQuVYQ/edit?usp=sharing)
3. Understanding the IPFS White Paper part 2: [https://hackernoon.com/understanding-the-ipfs-white-paper-part-2-df40511addbd](https://hackernoon.com/understanding-the-ipfs-white-paper-part-2-df40511addbd)
4. smart contract: [https://blockgeeks.com/guides/smart-contracts/](https://blockgeeks.com/guides/smart-contracts/)
5. Libp2p Transport Interface:[https://github.com/libp2p/go-libp2p-transport/blob/master/transport.go#L42](https://github.com/libp2p/go-libp2p-transport/blob/master/transport.go#L42)
6. add QUIC support: [https://github.com/ipfs/go-ipfs/pull/5350](https://github.com/ipfs/go-ipfs/pull/5350)
7. OpenBazaar/go-onion-transport: [https://github.com/OpenBazaar/go-onion-transport](https://github.com/OpenBazaar/go-onion-transport)
8. Requirement of OpenBazaar Tor:[https://github.com/ipfs/notes/issues/37#issuecomment-307966649](https://github.com/ipfs/notes/issues/37#issuecomment-307966649)
9. Polkadot PoC-2: [https://medium.com/polkadot-network/polkadot-poc-2-is-here-parachains-runtime-upgrades-and-libp2p-networking-7035bb141c25](https://medium.com/polkadot-network/polkadot-poc-2-is-here-parachains-runtime-upgrades-and-libp2p-networking-7035bb141c25)
