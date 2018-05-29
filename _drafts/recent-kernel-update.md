

## Live with upstream kernel 
笔者2015年-2016年在华为工作期间负责从3.10到4.1内核迁移，为产品线提供业务（包括内核模块，库函数，应用等方面）迁移建议。当时的体会到及时追踪社区内核有几个好处：

提前了解社区特性，避免重复开发类似功能；

了解社区规划，与社区协作开发；

与社区共用基础代码，减少维护工作量。
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

<https://www.linuxplumbersconf.org/2017/ocw/system/presentations/4759/original/fast_dvfs_scmi.pdf>

<https://www.slideshare.net/linaroorg/las16200-scmi-system-management-and-control-interface>

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
