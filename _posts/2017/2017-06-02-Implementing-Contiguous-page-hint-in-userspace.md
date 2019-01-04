# 使用连续页面hint改善用户空间匿名页的性能

按：笔者在今年在布达佩斯举办的linaro connect上发表演讲。演讲题目是"Implementing contiguous page hint for anonymous pages in user space"。本文根据当时演讲内容整理。

# 系统内存导致的性能瓶颈

导致系统瓶颈的问题有很多。内存性能问题是其中之一，例如内存碎片，或内存的访问延迟。例如说内存的碎片会导致系统连续内存分配困难，造成性能下降。传统的大页（2M或1G）或透明大页（1G）虽然改善了性能但是由于过多的占用连续内存，容易造成内存外碎片。考虑到系统内存很大时，内存成本会更快上升，如果能找个一个适中的大小，兼顾内存分配性能和外碎片，就能在系统不感知情况下提供系统性能。

另一方面，过小的内存页导致较多的缺页异常，同时会占用比较多的tlb项，tlb是系统珍惜资源，tlb频繁替换（tlb抖动）会造成系统性能下降。

# 可能的改善方法之一：增大page size
例如从4k增加到64k，这样同样分配64k内存时，节省15次缺页异常，同时节省15个tlb表项。

但是页面大小增大，可能造成内存浪费，suse虚拟化工程师测试表明，对于一个虚拟机，从4k切换到64k，可能增加数百兆内存，如果系统中有几十个虚拟机，内存消耗至少会增加几个G。

另一方面，存储器件的基本单元大小不同，可能是512字节，4k或更大，对于64k系统，可能会造成io读写放大，影响io性能。

问题就转化为，我们能不能找到一种方法，让匿名页的页面大小增大，降低tlbmiss，同时io不受影响。

# 可能的改善方法之二：利用contiguous page hint
arm和arm64架构支持contiguous page hint，在页表中满足架构要求（地址对齐，页表表项数量）并设置了下面的hint时，（根据cpu实现）有可能把连续若干个entry作为一个tlb entry。这样节省了tlb entry同时由于基础页面大小没有增加，对io没有影响。

以arm64 level3页表为例：
<img alt="arm64 level3 page table" src="{{site.url}}/public/images/pagetable/pagetable_level3.png" width="100%" align="center" style="margin: 0px 15px">

页表的属性集中在upper attributes和lower attributes，其中第52bit，就是我们的contiguous page hint。
<img alt="arm64 page table attr" src="{{site.url}}/public/images/pagetable/pagetable_attr.png" width="100%" align="center" style="margin: 0px 15px">

cont page hint可以在最后一级（也就是上面的level3）和倒数第二级使用，对于4k, 16k和64k可以组合出如下大小的连续区域。
<img alt="cont_page_hint_choices" src="{{site.url}}/public/images/pagetable/cont_page_hint_choices.png" width="100%" align="center" style="margin: 0px 15px">
  
笔者正在做的优化就是在页面大小是4k情况下，通过contiguous page hint使匿名页看起来是64k。通过对比方案和简化方案可以看出本方案的优势，时间关系，下次给出测试方案和数据分析。

本文首发于本人的公众号“敏达生活”，[点此跳转](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483660&idx=1&sn=2f32af38d6af0f52c9a99b22de27f5cc&chksm=ec6cb720db1b3e369bdf1a67479e06096b47fe9990acc46b41f2da4c66c5be5c1fc35328ee4d#rd)，欢迎扫码关注。
