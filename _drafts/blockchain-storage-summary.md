

## IPFS roadmap

<https://github.com/ipfs/ipfs/blob/master/ROADMAP-TO-1.0.0.md>

## 看所有的IPFS issue

[Thoughts on the next level of content routing for ipfs](https://github.com/ipfs/notes/issues/162)

[IPFS Cluster sharding RFC #278](https://github.com/ipfs/notes/issues/278)

## IPFS资料

https://github.com/ipfs/newsletter/tree/master/published

https://github.com/ipfs/blog/tree/master/content/post

## IPFS github

ipfs里面有个[go-ds-badger](https://github.com/ipfs/go-ds-badger/blob/master/datastore.go)

## IPFS技术

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

## EOS and IPFS

![img](http://opuclx9sq.bkt.clouddn.com/2018-05-21-033312.jpg)



