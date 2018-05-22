<https://www.youtube.com/watch?v=HUVmypx9HGI>

the future of web

Critical pricinples need for build.



开头讲了ipfs要解决什么问题。

![ipfs_basic](http://opuclx9sq.bkt.clouddn.com/2018-05-14-030313.png)



中心化，去中心化和分布式网络的区别



howto?

![ipfs_talk__how_to_work](http://opuclx9sq.bkt.clouddn.com/2018-05-14-032437.png)



the problem of location addressing

TODO: insert the picture

* only specific host could serve you.
* Lots of bandwidth lost
  * bandwidth is not growed up so fast.
  * bandwidth is descreasing slower than storage.

想google一样的大公司可以在全球建立服务器，个体和小公司呢？这是目前internet的短板

![ipfs_talk__google_provide_server_globally](http://opuclx9sq.bkt.clouddn.com/2018-05-14-033422.png)



即使这样仍然有问题：

![ipfs_talk__bandwithd_problems](http://opuclx9sq.bkt.clouddn.com/2018-05-14-034307.png)

![ipfs_talk__infrastructure_problems](http://opuclx9sq.bkt.clouddn.com/2018-05-14-034310.png)



how do you deal with the website you can no longer talk to?

put the web to distributed system. 



It is your data theoretically, but your data and your information reply on the gatekeeper in the internet. 



#### Security

半瓦：联想最近的twitter和github的bug。



We are armoring the line not the data.

![ipfs_talk__security_issue_of_internet__should_armoring_the_data](http://opuclx9sq.bkt.clouddn.com/2018-05-14-035113.png)



#### performance



IPFS is a protocal which upgrade the web 

The most important one is that make it faster

![ipfs_talk__goals](http://opuclx9sq.bkt.clouddn.com/2018-05-14-035510.png)



immutable link



Fast, privacy



### merkledag is the core

![ipfs_talk__merkledag_is_the_core](http://opuclx9sq.bkt.clouddn.com/2018-05-14-040331.png)

how merkle tree work?

hash

there are difference merkle trees of them



path on the top of the web.



Git have the immutable objects. mutable branch.



### why ipns

我们可以在内容变更时更新dns，但是这样太重了。

### sign

sign by private key and everyone could check by your public key.

![ipfs_talk__ipfs_file_signed_by_keys](http://opuclx9sq.bkt.clouddn.com/2018-05-14-073146.png)

support different crypto systems.

pki chain.

Huge mesh of content.



Generate the data locally and signed it. Do not need to worry about the leak of data.

#### application

![ipfs_talk__application__webapp_data](http://opuclx9sq.bkt.clouddn.com/2018-05-14-074235.png)

![ipfs_talk__application__legal_records](http://opuclx9sq.bkt.clouddn.com/2018-05-14-073832.png)



##### docker image

##### package management





crdt: immutable data structure.

ref <https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type>

> * ideal for optimistic replication.
> * two approaches to CRDTs, both of which can provide [strong](https://en.wikipedia.org/wiki/Strong_consistency) [eventual consistency](https://en.wikipedia.org/wiki/Eventual_consistency): operation-based CRDTs[[9\]](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#cite_note-2010OpBased-9)[[10\]](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#cite_note-:0-10) and state-based CRDTs.[[11\]](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#cite_note-1999StateBased-11)[[12\]](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#cite_note-:1-12)。
>
> Operation-based CRDTs are referred to as **commutative replicated data types**, or **CmRDTs**. 
>
> * [commutative](https://en.wikipedia.org/wiki/Commutative).
> * not [idempotent](https://en.wikipedia.org/wiki/Idempotent). 
>
> State-based CRDTs are called **convergent replicated data types**, or **CvRDTs**.
>
> * CvRDTs send their full local state to other replicas, where the states are merged by a function which must be [commutative](https://en.wikipedia.org/wiki/Commutative), [associative](https://en.wikipedia.org/wiki/Associative), and [idempotent](https://en.wikipedia.org/wiki/Idempotent). 

TODO: <https://medium.com/@istanbul_techie/a-look-at-conflict-free-replicated-data-types-crdt-221a5f629e7e>



[The Decentralized Web, IPFS and Filecoin - Juan Benet](https://www.youtube.com/watch?v=cU-n_m-snxQ)(Recorded at the Silicon Valley Ethereum Meetup - October 22nd, 2016)

比特币提供了去中心化的交易平台。IPFS希望把所有internet上面的东西都去中心化。



web3.0

![ipfs_talk_in_Ethereum_meetup__web30](http://opuclx9sq.bkt.clouddn.com/2018-05-14-085809.png)



[Filecoin | White Paper Breakdown and Token Sale Analysis](https://www.youtube.com/watch?v=e02czCnCuCM)

Shortage of BT

* Slow to connect. Could download to file but too slow to host a website.
* No incentive to a node
* Content addresstion. No permanent links.

