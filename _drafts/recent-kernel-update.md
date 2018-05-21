

## Live with upstream kernel 

2015年到2017年在华为负责内核从3.10到4.1的迁移，支撑产品线内核迁移。需要熟悉3.10到4.1的内核特性和接口变更。当时体会到提前识别内核的变化很重要：

* 提前了解社区内核演进方向有助于避免背道而驰；

Who write kernel?
-----------------

### History
查找内核历史贡献量。

### 4.16统计
 参见<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2018-02-13-kernel-4.16.md>

Meltdown and Spectre
--------------------
### google I/O
<https://mp.weixin.qq.com/s/bUVQVk3W6BM4WNNbFnJ4HQ>

### upstreaming status
x86, arm, arm64, s390.
 参见<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2018-02-13-kernel-4.16.md>
 搜索kernel 4.17

architecture
------------
arm SCMI, 参见<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2018-04-19-kernel-4.17.md>

memory
------
### from a simple flag
MAP_FIXED, MAP_FIXED_NOREPLACE
 参见<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2018-04-19-kernel-4.17.md>

### memory encryption
 参见<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2018-02-13-kernel-4.16.md>

filesystem
----------
TODO

My ILP32 work
-------------
参见：<https://github.com/bjzhang/bjzhang.github.io/blob/master/_drafts/2016/ILP32_syscall_unit_test_linuxcon_europe.md>

其它参考资料
<https://lwn.net/Articles/746129/>
<https://lwn.net/Articles/746791/>
<https://www.phoronix.com/scan.php?page=article&item=linux-416-changes&num=1>
<https://lwn.net/Articles/750928/>
<https://lwn.net/Articles/751482/>
