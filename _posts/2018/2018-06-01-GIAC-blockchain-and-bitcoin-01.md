# GIAC全球互联网架构大会第一天议题（上）
> GIAC 是中国互联网技术领域一年一度的行业盛事，组委会从互联网架构最热门系统架构设计、工程效率、机器学习、未来的编程语言、分布式架构等领域甄选前沿的有典型代表的技术创新及研发实践的架构案例，分享他们在本年度最值得的总结、盘点的实践启示，打造一个分享及讨论平台，改变未来一年的互联网构建方式。  

今天（2018年6月1日）全天的前沿技术分会场都围绕区块链及数字货币展开。如果用两个关键字概括今天的内容，就是扩容和落地。本文是上午的内容概要。

# Bytom公链构架实践
演讲者：朱益祺  杭州时戳信息科技有限公司    比原链首席架构师

从作者的思路看，似乎是要做更好的比特币和以太坊。Bytom以UTXO为账户模型，天然支持多资产，支持智能合约。一致性算法方面采用int8的矩阵乘法，目的是与AI算力共享，与AI形成互利关系。（半瓦：看起来就是利用AI的剩余算力，利用剩余算力似乎也是大家关注的方向）。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-01-142754.png)

Bytom UTXO模型不管交易是否成功都会消耗gas。用gas限制ddos攻击。gas在虚拟机层次收取。gas由交易体积和每个vm op消耗决定。

和比特币一样，Bytom同样适用了leveldb存储数据。项目位于[GitHub - Bytom/bytom: Official Go implementation of the Bytom protocol](https://github.com/Bytom/bytom) ，使用golang开发，License是AGPLv3。官方说明是仍然在开发过程中，目前支持：
* Manage key, account as well as asset
* Send transactions, i.e., issue, spend and retire asset

本次演讲提到的跨链，DDOS，智能合约，也是今天后面的重点。

# 基于侧链存储的主链扩容技术方案分享
演讲者：陈有才  公信宝  GXS Labs  Dedictor

公信宝的题目看起来是说区块链存储，但是演讲者并没有区分filecoin和ipfs，给人的感觉是还没有细想。演讲者提到了物流，后续京东的分享详细说了区块链在物流的应用。演讲者提到的侧链和存储后续也有相关分享。看起来存储的确是大家都想要解决的问题。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-01-142802.png)

公信宝使用c++开发，也有github地址，虽然有600多提交，但是commit message写的很随意：[GitHub - gxchain/gxb-core: GXChain code](https://github.com/gxchain/gxb-core)。

# 使用安全分片的可扩展公有链Zilliqa
演讲者：贾瑶琪  Zilliqa Research    技术总监

今天演讲者都喜欢以数字说话，贾瑶琪从以太猫对以太坊访问量最高占用20%tps和推高交易gas到50$开始，引出Zilliqa的改进。

瑶琪是今天第一个强调团队来源的演讲者，他多次强调Zilliqa团队来自新加坡国立大学。后续纸贵科技的团队主要来自IBM。二者分别是从学术和大公司出来的团队。

瑶琪首先比较了现有扩容方案的问题：
* 增加区块大小不是线性可扩展的。
* 链下交易不够透明，不够去中心化。
* 代理人共识同样有中心化的问题。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-01-142808.png)
Zilliqa把POW用在分片而不是挖矿上。系统定时（例如2小时）根据节点的POW结果，对节点进行分片。每片大约600个节点。片内采用pbft，2/3多数投票。如果节点少于2/3，该分片会被废弃。

![](http://opuclx9sq.bkt.clouddn.com/2018-06-01-142818.png)
Zilliqa的另一个特点是使用coq做智能合约的形式化验证避免出错。目前已经开发了coq的智能合约形式化验证工具箱，未来会提供给智能合约开发者使用。

Zilliqa最多在AWS上做了7000个节点的测试。演讲的最后，瑶琪强调，如果节点数量少于1000个，传统分布式技术同样可以解决问题，没必要使用区块链。

Zilliqa同样托管在github上：[Zilliqa/Zilliqa: Zilliqa is the world’s first high-throughput public blockchain platform - designed to scale to thousands ​of transactions per second.](https://github.com/Zilliqa/Zilliqa)。Zilliqa并没有选择已有的License。它不允许修改或发布代码，也不允许用此代码部署自己的私链或公链。Zilliqa使用c++开发。Commit数量比Bytom略多，看起来开发也比较规范。

# 你可能感兴趣的文章
这是本月的第一篇文章。半瓦平时有随手记笔记的习惯，公众号原创文章只分享自己有体会的信息，希望能促进价值信息流动。任何建议欢迎给我留言或添加我的微信（公众号回复“微信”，可以看到半瓦的微信）：

* [春风吹又生—-梳理中国CPU](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483744&idx=1&sn=c1e047036062dd97aae70cd8d6682f41&chksm=ec6cb74cdb1b3e5a9a21be4b24519a125e071461c02fb4e962c839e2647824ffd313d542b9ae&scene=21#wechat_redirect)
* [Linux自动化部署工具综述（Linux自动化部署工具系列之一）](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483755&idx=1&sn=ce1aaa72e0cc2d1933c9ed8002ab96da&chksm=ec6cb747db1b3e51ee9b56f9c8e3fa10f879d97e5a0b17da0dbbb51b48b8fead0adaff64d9a4&scene=21#wechat_redirect)
* [比较操作系统镜像制作方式（Linux自动化部署工具系列之二）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483757&idx=1&sn=aa7376cf5f752b4d66a93a8d2fc99c20&scene=21#wechat_redirect)
* [来自suse的猕猴桃(KIWI)（Linux自动化部署工具之三）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483760&idx=1&sn=0785ed74878b5ef27943bda7fc6f2c9f&chksm=ec6cb75cdb1b3e4a10a929940ad79c9dee77917730e3d80ef2fd0de48d8e336c397c081037a1&scene=21#wechat_redirect)
* [与社区共舞：如何追踪Linux内核社区最新动向（之一）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483776&idx=1&sn=cfcd68120e95b3189b80e99f766bb6a4&chksm=ec6cb7acdb1b3eba24e78e672fce1ec48fc74fb138cdc4ccd5f8b85359ba61e7083e4581877b#rd)

# 参考链接
* Bytom: Official Go implementation of the Bytom protocol: <https://github.com/Bytom/bytom>
* 公信宝：gxchain/gxb-core: GXChain code: <https://github.com/gxchain/gxb-core>
* Zilliqa: Zilliqa is the world’s first high-throughput public blockchain platform - designed to scale to thousands ​of transactions per second.: <https://github.com/Zilliqa/Zilliqa>
