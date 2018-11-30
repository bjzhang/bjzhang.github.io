# 本月IPFS/Libp2p进展
## 开发进展
本月协议实验室连续发布了go-ipfs 0.4.18，js-libp2p 0.24.0和js-ipfs 0.33.0，重要更新如下。
### QUIC
go-ipfs终于合入了原计划Q3完成的QUIC（之前是libp2p已经合入了，卡在go-ipfs自己）。QUIC是一个基于UDP的协议，对于IPFS来说，使用QUIC的好处有：
- 所有QUIC连接可以共享一个file descriptor，这样可以更快的dial。由于节省了资源，也可以同时打开更多连接。
- QUIC支持的fully encrypted, authenticated, and multiplexed connection，理论上可以改善DHT的时延。这对于IPFS访问大量数据时尤其有用。
- QUIC可以更好的支持NAT打洞。

### gossipsub
go-ipfs支持了基于gossip的pubsub（订阅发布）。和之前floodsub相比，gossipsub可以降低对带宽的需要，同时可以fallback回floodsub。
gossipsub 的规范：[https://github.com/libp2p/specs/tree/master/pubsub/gossipsub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)
floodsub在节点连接时会查询对方是否支持floodsub，如果支持会给对方发一个hello message。floodsub会把所有收到的消息都会转给本节点连接的所有节点。这种简单粗暴的方式会造成消息洪水。。gossipsub希望找到一个平衡点：较快的广播metadata的同时通过可控的路由做数据传输。

用户可以用下面命令打开gossipsub ：
`ipfs config Pubsub.Router gossipsub`
代码实现在：[https://github.com/libp2p/go-libp2p-pubsub/blob/master/gossipsub.go](https://github.com/libp2p/go-libp2p-pubsub/blob/master/gossipsub.go)

### WebUI
IPFS官方认为改进后的WebUI比之前好了100倍，下图是笔者在日常开发分支编译的ipfs节点截图。
节点启动五分钟后，可以看到节点数量最做的依次是美国，德国和中国。
![]({{site.url}}/public/images/2018-11-30-ipfs-libp2p-monthly-progress/DraggedImage.png)
在节点页可以看到基于地理位置的分布，主要在北美，亚洲和欧洲：
![]({{site.url}}/public/images/2018-11-30-ipfs-libp2p-monthly-progress/DraggedImage-1.png)
用文件传输功能上传Filecoin白皮书：
![]({{site.url}}/public/images/2018-11-30-ipfs-libp2p-monthly-progress/DraggedImage-2.png)
使用Filecoin的CID（QmRWx2YMoaJvsVu6v3oBvNwF9Pfcx2VdGEpLuWcBnkVwLR）查看
![]({{site.url}}/public/images/2018-11-30-ipfs-libp2p-monthly-progress/DraggedImage-3.png)
Filecoin的白皮书659k，ipfs默认的chunk大小是256k，所以有三个chunk（分别是256k, 256k, 147k），对应上图从root分出的三个点。
![]({{site.url}}/public/images/2018-11-30-ipfs-libp2p-monthly-progress/DraggedImage-4.png)

## js-libp2p进展
- 支持指定路由的内容和节点寻址：这样用户可以更好的控制自己的DHT。例如libp2p-delegated-content-routing包，可以通过DelegatedContentRouing指定路由。
- Relay默认打开。最近libp2p社区边重构边开发，已经合入了auto relay。auto relay可能会被Filecoin和以太坊使用。

## IPLD roadmap
- 2018年Q4的计划
	- 重构全部规范（已完成）
	- unixfs v2的规范操作（正在进行）
	- 完成js-ipld接口的重构。
- 社区在讨论2019年的计划： [ipld/roadmap#2 ](#)(https://github.com/ipld/roadmap/issues/2)[Stebalien](#)(https://github.com/Stebalien) 和 [mikeal](#)(https://github.com/mikeal)  在IPLD能否直接提供加密数据存储能力有些争议。
- 
# IPFS学习资料
- This single-page web app can edit itself [medium.com/textileio/this-single-page-web-app-can-edit-itself-62734dac2700](#)：从如何使用js IPFS api建立IPFS节点开始，使用IPNS查询内容更新并显示在网页上。
- Tutorial: Host your own IPFS node and help the next generation of web 描述了如何搭建ipfs public gateway.
