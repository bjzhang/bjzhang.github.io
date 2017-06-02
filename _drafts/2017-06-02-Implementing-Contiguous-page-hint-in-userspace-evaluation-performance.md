---
layout: post
title: 使用连续页面hint改善用户空间匿名页的性能
categories: [Linux]
tags: [Linux, arm, mobile]
---


按：笔者在今年在布达佩斯举办的linaro connect上发表演讲。演讲题目是"Implementing contiguous page hint for anonymous pages in user space"。本文根据当时演讲内容整理。

# 系统内存导致的性能瓶颈

导致系统瓶颈的问题有很多。内存问题是其中之一，例如内存碎片，或内存的访问延迟。例如说内存的碎片会导致系统连续内存分配困难，造成性能下降。传统的大页（2M或1G）或透明大页（1G）虽然改善了性能但是由于过多的占用连续内存，容易造成内存外碎片。

The bottleneck of memory

There are lots of performance issues of memory for application.

latency: We hope the low latency when we allocate the memory. Such as lower the times of page fault, cache the data and pagetable in the cache/tlb. We could use the bigger page to archive this.

Fragmenation: At the same time, high order free pages is important for system. The more we allocated the bigger pages, the less we have the high order pages. Which lead to the performance downgrade of memory allocation. So, we need a good balence of cross difference page size. The Linux kernel already make use of hugepage for specific application. And use THP for transparent senario. But there is a big gup between 4k and 2M in 4k system. And we could not replace 2M with small size.

Q: When I think about in details, I do not know how the fully describe the bottleneck of memory.

其中一个改善性能的方法就是增大系统base page size。但是页面大小增大，可能会造成io的性能问题。如果我们能找到一种方法，让匿名页的页面大小增大，降低tlbmiss，同时io不受影响。


Increasing the page size?

So, how about increase the size of base page to improve the performance? We will waste more memory when we use 64k instead of 4k especially when we run lots of vm in host. (I suppose it is 100-200M per vm, but I do not have specific data in my hand). And there is side effect of IO which decrease the increase of performance. For example, we will operation 64k in kernel even if we only want to update one block in devices.

Page size performance measurements There is no overall improvement for filesystem. We compare the performance of filesytem. TODO: introduce the item we tested. confirm with pingbo wen. Add thanks to pingbo wen in speaker's notes.

# 通过specint评价性能
我们需要一种评价性能的方法，这种方法不能是micro benchmark。speccpu是一种广泛使用的权威的以实际用例为基础的测试套。

Evaluate the application performance through specint

Why? Care about system benchmark other than micro benchmark: we also do the micro benchmark. in order to evaluate the real application performance. We use specint of speccpu 2006. not overly affected by wasted memory or I/O performance: specint is a set of real application, which include the memory intensive, cpu bound algarithem(TODO: fix the typo) and so on. sensitive to TLB misses: why?

Result There is no overall improvement when we change the page size from 4k to 64k Some of test cases downgrade: hmmer, xalancbmk.

# 比较不同base page size的性能
arm64架构支持三种page大小，4k, 16k和64k。这里通过specint比较4k和64k性能。
最终发现直接切换到64k页没有整体的性能提升.
Compare the performance between 4k and 64k

explain the typical difference testcase I am focused. mcf. hmmer, xalancbmk, libquantum, astar.

Contiguous page hint

Paste the page page attribute here.

Contiguous page hint: configuration

TODO: this table is not clear. use the table from Ard? Reserve this table at the end of slide.

Compare with 4k THP

Could I say that if the dTLB load miss lead to lower L2 access and lower times of exception taken. the performance will improved. But how could I explain the downgrade of omentpp? xalancbmk is easy because d tlb miss is unchanged(really? it seems impossible).

The relationship between performance and tlb miss

I forget the reason why I introduce this slide: Compare with 4k with THP and 4k with THP and hugetlb(64k)? TODO make sure.

In order evaluate the performance before coding we use 64k hugetlb on 4k system.

Our idea

I should use more time to do it. mention I will preserve a pointer in mm struct.

Patches of cont page hint

1. For contiguous mapping. Used by kernel segment(text, data...), memblock(What it is?) and efi runtime. Contribute by (Jeremy Linton <jeremy.linton@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>) ``` 0bfc445 arm64: mm: set the contiguous bit for kernel mappings where appropriate 667c275 Revert "arm64: Mark kernel page ranges contiguous" 348a65c arm64: Mark kernel page ranges contiguous 202e41a arm64: Make the kernel page dump utility aware of the CONT bit 06f90d2 arm64: Default kernel pages should be contiguous 93ef666 arm64: Macros to check/set/unset the contiguous bit ecf35a2 arm64: PTE/PMD contiguous bit definition 2ff4439 arm64: Add contiguous page flag shifts and constants ``` 1. Could it become a problem if we change the mapping in running for some reason? (I do not know if we need do it). 2. Is there performance downgrade if the kernel run in the virtualization senario? 2. enable for hugetlb contribute by David Woods <dwoods@ezchip.com> "66b3923" arm64: hugetlb: add support for PTE contiguous bit) 3. filesystem 

does our smmu suppport cont page hint?

if so, I could add the support for it.

start to write the notes or make sure I could talk more than 20 minutes.

add performance number.

in order to compare the tlb miss and L2 cache, I need to know the latency of tlb miss and L2 d$ load.

draw a picture of current design.

The original data of perf_stat

Specint single core compare with 4k with transhuge: hugetlb_64k hugetlb_2048k Mark 401.bzip2: 2.34% 3.72% + 403.gcc: 0.39% 0.90% 429.mcf: 0.55% 0.89% 445.gobmk: 0.88% 0.88% 456.hmmer: 10.34% 8.97% ++ 458.sjeng: -1.87% 0.93% 462.libquantum: 10.49% 4.32% ++ 471.omnetpp: -0.45% 2.84% 473.astar: 1.30% 2.70% 483.xalancbmk: -1.67% 0.83% 

0x016 , L2D_CACHE, Attributable Level 2 data cache access The counter counts Attributable memory-read or Attributable memory-write operations, that the PE made, that access at least the Level 2 data or unified cache. Each access to a cache line is counted including refills of and write-backs from the Level 1 data, instruction, or unified caches. Each access to other Level 2 data or unified memory structures, such as refill buffers, write buffers, and write-back buffers, is also counted. The counter does not count: Operations made by other PEs that share this cache. Cache maintenance instructions.

astar Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 500,714 338,576 67.62% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 48,243,680,996 47,648,606,289 98.77% 0.00% 0.00% dTLB-load-misses 5,136,361,243 2,936,132,054 57.16% 0.00% 0.00% iTLB-load-misses 29,057,053 24,065,221 82.82% 0.00% 0.00%

bzip Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 523,148 534,306 102.13% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 66,436,631,118 66,651,395,233 100.32% 0.00% 0.00% dTLB-load-misses 13,020,948,496 3,265,206,016 25.08% 0.00% 0.00% iTLB-load-misses 31,563,977 29,026,012 91.96% 0.00% 0.00%

hmmer Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 351,910 333,901 94.88% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 53,013,240,266 36,355,002,181 68.58% 0.00% 0.00% dTLB-load-misses 501,759,126 311,239,631 62.03% 0.00% 0.00% iTLB-load-misses 29,022,779 28,277,805 97.43% 0.00% 0.00%

libquantum Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 478,949 448,466 93.64% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 207,143,982,887 206,778,261,323 99.82% 0.00% 0.00% dTLB-load-misses 684,648,521 407,350,122 59.50% 0.00% 0.00% iTLB-load-misses 23,274,692 24,499,482 105.26% 0.00% 0.00%

omnetpp Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 424,349 398,358 93.88% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 50,442,009,131 51,305,942,600 101.71% 0.00% 0.00% dTLB-load-misses 11,415,593,231 9,565,650,618 83.79% 0.00% 0.00% iTLB-load-misses 176,816,421 123,981,643 70.12% 0.00% 0.00%

sjeng Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 432,275 429,621 99.39% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 21,331,053,942 25,505,365,609 119.57% 0.00% 0.00% dTLB-load-misses 8,739,202,106 2,070,855,972 23.70% 0.00% 0.00% iTLB-load-misses 38,233,018 25,198,254 65.91% 0.00% 0.00%

xalancbmk Diff: result/base testcases base result diff cv(base) cv(result) cv: Coefficient of Variation armv8_pmuv3/exc_taken/ 487,774 375,584 77.00% 0.00% 0.00% armv8_pmuv3/l2d_cache/ 66,795,709,011 68,731,343,842 102.90% 0.00% 0.00% dTLB-load-misses 6,908,854,226 6,908,964,707 100.00% 0.00% 0.00% iTLB-load-misses 597,267,468 51,142,127 8.56% 0.00% 0.00%

Desktop version


