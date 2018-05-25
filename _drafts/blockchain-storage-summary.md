# [协议实验室的项目](https://protocol.ai/projects/)

* filecoin
* ipfs
* ipld
* libp2p
* multiformats



## IPFS roadmap and changeling

<https://github.com/ipfs/ipfs/blob/master/ROADMAP-TO-1.0.0.md>

<https://github.com/ipfs/go-ipfs/blob/master/CHANGELOG.md>

## 看所有的IPFS issue

[Thoughts on the next level of content routing for ipfs](https://github.com/ipfs/notes/issues/162)

[IPFS Cluster sharding RFC #278](https://github.com/ipfs/notes/issues/278)

## IPFS资料

https://github.com/ipfs/newsletter/tree/master/published

https://github.com/ipfs/blog/tree/master/content/post

对于IPFS入门很好的材料：[A Beginner’s Guide to IPFS](https://hackernoon.com/a-beginners-guide-to-ipfs-20673fedd3f)

## IPFS github

ipfs里面有个[go-ds-badger](https://github.com/ipfs/go-ds-badger/blob/master/datastore.go)

## IPFS技术

TODO datastore and blockstore.

### keystore

[spec](https://github.com/ipfs/specs/tree/master/keystore)

[go key-value datastore interfaces](https://github.com/ipfs/go-datastore)

<https://github.com/ipfs/go-ipfs-keystore>

[A datastore implementation using sharded directories and flat files to store data](https://github.com/ipfs/go-ds-flatfs)

>  `go-ds-flatfs` is used by `go-ipfs` to store raw block contents on disk. It supports several sharding functions (prefix, suffix, next-to-last/*).

### DHT

### CRDT

<http://liyu1981.github.io/what-is-CRDT/>

> 简要的总结，它
>
> 1. 定义了CRDT
> 2. 列举了CRDT的两种基本形式，即基于状态的CRDT与基于操作的CRDT。前者存储的是一个个的最终值，类似我们的例子，后者存储的是一个个的操作记录，类似于我们例子里面的推导过程
> 3. 界定了CRDT能满足最终一致性的边界条件。简单说，设计一个CRDT，只需要验证它是否满足这些边界条件，即可知道它是否能保持最终一致
> 4. 界定了两类CRDT在系统中应用时，需要的信息交换的边界条件。即回答怎样叫做“收集到足够多的信息”
> 5. 枚举了当前人类所知的CRDT，包含了计数器(counter)，寄存器(register)，集合(set)和图(graph)等几类
> 6. 在现实中应该如何应用CRDT，尤其是对于存储空间怎样进行回收的问题

### [CID](https://github.com/ipld/cid)

> CID is a self-describing content-addressed identifier. It uses cryptographic hashes to achieve content addressing. It uses several [multiformats](https://github.com/multiformats/multiformats) to achieve flexible self-description, namely [multihash](https://github.com/multiformats/multihash) for hashes, [multicodec](https://github.com/multiformats/multicodec) for data content types, and [multibase](https://github.com/multiformats/multibase)to encode the CID itself into strings.

TODO [Experimental Proposal: CIDv1 -- IPLD, Multicodec-packed, and more](https://github.com/ipfs/specs/issues/130)

### datastore

> Datastore represents storage for any key-value pair.



> The generalized Datastore interface does not impose a value type, allowing various datastore middleware implementations (which do not handle the values directly) to be composed together.

### blockstore

blockstore通过go-datastore/namespace实现了不同数据库的namespace。

TODO: AllKeysChan没看懂。	

bloomcache里面用了go-metrix-interface，后者使用Context。

这块感觉挺重要的，仔细看看。

**看起来blockstore和datastore的区别是BasicBlock中保存了CID**

### blockstore service

是Session实现了Exchange接口.到底是怎么用到 `bitswap`的，感觉还需要看其它部分的代码。

> Session is a helper type to provide higher level access to bitswap sessions

![ipfs_blockstore_service__type_session_interface](http://opuclx9sq.bkt.clouddn.com/2018-05-25-090023.png)

## EOS and IPFS

![img](http://opuclx9sq.bkt.clouddn.com/2018-05-21-033312.jpg)



