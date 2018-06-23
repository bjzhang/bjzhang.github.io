---
layout: post
title: 与社区共舞（之二）：例说如何了解Linux内核社区最新动向
categories: [Software]
tags: [Linux]
---

接着分享本人上个月在农大的slides（完整slide见参考资料4），上次方法综述见[与社区共舞：如何追踪Linux内核社区最新动向（之一）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483776&idx=1&sn=cfcd68120e95b3189b80e99f766bb6a4&chksm=ec6cb7acdb1b3eba24e78e672fce1ec48fc74fb138cdc4ccd5f8b85359ba61e7083e4581877b#rd)这次以体系结构，内存为例分享如何了解社区最新动向。

## Meltdown and Spectre
体系结构幽灵/熔断漏洞一共有五个变种（1，2，3，3a，4），这些漏洞的特点是在ISA下面做了侧信道攻击。通常从软件角度看，计算机其实就是ISA。安全也是基于ISA的防御。但是这五个漏洞说明，由于处理器性能的优化，是有可能通过微架构的弱点，完成攻击的，漏洞具体情况可以参考如下材料：
* ARM内核专家修志龙从[Spectre/Meltdown演义 — 引子](https://mp.weixin.qq.com/s/CQC5uQrlluEpY36OV5-Mkw)，[通俗篇](https://mp.weixin.qq.com/s/ZTsCUHINDN1oGSg1u8QswQ)，[专业篇（1）](https://mp.weixin.qq.com/s/Iv4X4ZFeeM3nupx3BgseqA)，[专业篇（2）](https://mp.weixin.qq.com/s/VZrIBDbf9XqnEVTdV_AzOA)和[专业篇（3）](https://mp.weixin.qq.com/s/GsaVarmBca0qjFGAVQl_TA)介绍了这些漏洞（持续更新中）
* Canonical内核专家Gavin Guo前段时间视频分享了 [深入 Spectre V2 - VM 如何攻擊 Host](https://v.qq.com/x/page/a0691lzsc04.html)，slide在[这里](https://schd.ws/hosted_files/lc32018/da/Spectre%28v1%20v2%20v4%29%20V.S.%20Meltdown%28v3%29.pdf)。

这里以幽灵v1为例，说明如何从lwn merge window找到具体的代码。

内核的开发流程分成merge window和 release candidate(rc)。
* merge windows固定是两个。一周一个。大特性必须通过merge window合入主线。
* rc一般是7-8个。主要是bugfix和小特性的合入。

所以通常来说一个内核版本的开发周期是10周左右。可以在kernel.org看到最新的版本。例如下图是2018年6月23日的截图，可以看到当前最新版本是4.18 rc1。4.18的两个merge window已经结束。如果想了解4.18内核重大更新，可以参考LWN的merge window文章（参考链接1，参考链接3）。
![kernel.org](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142052.png)

[Linux 4.16 merge window part2](https://lwn.net/Articles/746791/)（参考链接1）的Security-related部分提到：
> Initial mitigations for Spectre variant 1 (bounds-check bypass) have been merged; see this article for details. The core of this support is a new array_index_nospec() macro that prevents speculation that might cause a bounds check to be circumvented.  
> The arm64 architecture has gained another set of Meltdown/Spectre mitigations. The array_index_nospec() operator is supported natively, and it has been applied in a few places in the kernel. Branch-predictor hardening has been improved as well.  
> S390 has also gained an implementation of array_index_nospec(), support for some new instructions to control branch prediction, and a variant on the retpoline concept called an "expoline".  

咱们来看看到底x86和arm64架构下，到底上面提到的`array_index_nospec()`是怎么写的。`git log --oneline --grep array_index_nospec`可以看到一些补丁：
![git_log_array_index_nospec](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142201.png)

但是这里面没有上文提到的arm64和s390补丁。很奇怪，对吧。先看看最新的两个补丁：

* `f84a56f73ddd Documentation: Document array_index_nospec`是文档，小伙伴可以自己看下。文档中说明了为什么类似下面的条件判断，即使攻击者传入非法的index，也有机会获得用户数据。
  ![spectre_v1_doc](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142603.jpg)
* `f3804203306e array_index_nospec: Sanitize speculative array de-references`是与体系结构无关的实现。`git show f3804203306e`可以看到具体的修改。可以看到这个补丁新增了`include/linux/nospec.h`文件，并且`array_index_nospec`使用了`array_index_mask_nospec`实现：![array_index_mask_nospec](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142535.png)

可以想象，体系结构相关的优化可能在`array_index_mask_nospec`，所以我们用如下git命令同时搜索上述两个字符串：
`git log --oneline --grep "\(array_index_nospec\)\|\(array_index_mask_nospec\)”`，这次能看到arm64和s390相关的补丁了。
![](recent-kernel-update/8339E377-D82C-4BDD-AFDA-FF3C7C646766.png)

让我们来详细看下x86和arm64补丁都做了什么：
* x86
  ![spectre_v1_x86](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142500.jpg)

* arm64
  ![spectre_v1_arm64_01](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142344.jpg)![spectre_v1_arm64_02](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142355.jpg)



这次Meltdown and Spectre对业界有很大震动，最近的google I/O和2018年图灵奖演讲都提到了这个漏洞。图灵奖演讲具体内容可以参考笔者的笔记：[2018图灵奖Lecture：计算机体系结构的又一个黄金时代：特定领域的软硬件协同设计，增强安全，开源指令集和芯片的敏捷开发](https://mp.weixin.qq.com/s/D52QGaBlE6sRglP1Rt9KcA)

## memory子系统引入了新的flag: MAP_FIXED_NOREPLACE
4.17内核引入了一个新的flag：MAP_FIXED_NOREPLACE。之前笔者有遇到产品使用MAP_FIXED，但是和系统map冲突，由于没有提示或失败，系统会出奇怪的问题。
```
The mmap() system call supports a new MAP_FIXED_NOREPLACE option. Like MAP_FIXED, it tries to place the new memory region at a user-supplied address.  Unlike MAP_FIXED, though, it will not replace an existing mapping at that address; instead, it will fail with EEXIST if such a mapping exists. This is the change that was discussed last year as MAP_FIXED_SAFE; it seems that the battle over the proper name for the feature has finally been resolved.
```

```
The way that system calls are invoked on the x86-64 architecture has been reworked to make it more uniform and flexible. The new scheme has also been designed to prevent unused (but caller-controlled) data from getting onto the call stack — where it could perhaps be used in a speculative-execution attack.
```

![map_fixed_noreplace](http://opuclx9sq.bkt.clouddn.com/2018-06-23-142257.jpg)

## 参考链接
1. Linux 4.16 merge window
	1. part1: <https://lwn.net/Articles/746129/>
	2. part2: <https://lwn.net/Articles/746791/>
2. Linux 4.16 Changes：<https://www.phoronix.com/scan.php?page=article&item=linux-416-changes&num=1>
3. Linux 4.17 merge window
	1. Part1: <https://lwn.net/Articles/750928/>
	2. Part2: <https://lwn.net/Articles/751482/>
4. 笔者的完整slide：<aarch64.me/public/documents/bamvor_slides/Recent_Linux_kernel.pdf>
