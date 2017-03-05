---
layout: post
title: Implement contiguous page hint for anonymous page in user space
categories: [kernel]
tags: [kernel, arm, arm64, memory, pagetable]
---

The bottleneck of memory
-------------------------
There are lots of performance issues of memory for application.
1.  latency:
    We hope the low latency when we allocate the memory. Such as lower the times of page fault, cache the data and pagetable in the cache/tlb. We could use the bigger page to archive this.
2.  Fragmenation:
    At the same time, high order free pages is important for system. The more we allocated the bigger pages, the less we have the high order pages. Which lead to the performance downgrade of memory allocation. So, we need a good balence of cross difference page size. The Linux kernel already make use of hugepage for specific application. And use THP for transparent senario.
    But there is a big gup between 4k and 2M in 4k system. And we could not replace 2M with small size.

Q: When I think about in details, I do not know how the fully describe the bottleneck of memory.

Increasing the page size?
-------------------------
1.  So, how about increase the size of base page to improve the performance?
    We will waste more memory when we use 64k instead of 4k especially when we run lots of vm in host. (I suppose it is 100-200M per vm, but I do not have specific data in my hand). And there is side effect of IO which decrease the increase of performance. For example, we will operation 64k in kernel even if we only want to update one block in devices.

2.  Page size performance measurements
    There is no overall improvement for filesystem. We compare the performance of filesytem. TODO: introduce the item we tested. confirm with pingbo wen. Add thanks to pingbo wen in speaker's notes.

Evaluate the application performance through specint
----------------------------------------------------
*   Why?
    Care about system benchmark other than micro benchmark: we also do the micro benchmark. in order to evaluate the real application performance. We use specint of speccpu 2006.
    not overly affected by wasted memory or I/O performance: specint is a set of real application, which include the memory intensive, cpu bound algarithem(TODO: fix the typo) and so on.
    sensitive to TLB misses: why?

*   Result
    There is no overall improvement when we change the page size from 4k to 64k
    Some of test cases downgrade: hmmer, xalancbmk.

Compare the performance between 4k and 64k
-------------------------------------------
explain the typical difference testcase I am focused. mcf. hmmer, xalancbmk, libquantum, astar.

Contiguous page hint
--------------------
Paste the page page attribute here.


Contiguous page hint: configuration
-----------------------------------
TODO: this table is not clear. use the table from Ard? Reserve this table at the end of slide.

The relationship between performance and tlb miss
-------------------------------------------------
I forget the reason why I introduce this slide: Compare with 4k with THP and 4k with THP and hugetlb(64k)? TODO make sure.

In order evaluate the performance before coding we use 64k hugetlb on 4k system.

Our idea
--------
I should use more time to do it.
mention I will preserve a pointer in mm struct.


Patches of cont page hint
----------------
    1.  For contiguous mapping. Used by kernel segment(text, data...), memblock(What it is?) and efi runtime. Contribute by (Jeremy Linton <jeremy.linton@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>)
        ```
        0bfc445 arm64: mm: set the contiguous bit for kernel mappings where appropriate
        667c275 Revert "arm64: Mark kernel page ranges contiguous"
        348a65c arm64: Mark kernel page ranges contiguous
        202e41a arm64: Make the kernel page dump utility aware of the CONT bit
        06f90d2 arm64: Default kernel pages should be contiguous
        93ef666 arm64: Macros to check/set/unset the contiguous bit
        ecf35a2 arm64: PTE/PMD contiguous bit definition
        2ff4439 arm64: Add contiguous page flag shifts and constants
        ```
        1.  Could it become a problem if we change the mapping in running for some reason? (I do not know if we need do it).
        2.  Is there performance downgrade if the kernel run in the virtualization senario?

    2.  enable for hugetlb contribute by David Woods <dwoods@ezchip.com>
        "66b3923" arm64: hugetlb: add support for PTE contiguous bit)

    3.  filesystem

1.  does our smmu suppport cont page hint?
    1.  if so, I could add the support for it.

1.  start to write the notes or make sure I could talk more than 20 minutes.
2.  add performance number.
    1.  in order to compare the tlb miss and L2 cache, I need to know the latency of tlb miss and L2 d$ load.
3.  draw a picture of current design.


