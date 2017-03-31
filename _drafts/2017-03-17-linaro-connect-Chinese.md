
cont page hint
--------------
    - design discussion
    - guys from Cambrige, UK, hisi. plan to migrate to 16k pages. because ios use 2G with 16k base page. But they could not run the Android right now. They hope they could delivery this feature to mobile this year or next year. But given than the tight of time of schedule of product. I suspect they could not make it this year. Then there is a chance to us to compare the two method.

   - Steve Capper is working on improve the cont page hint in kernel. He is going to send out the patches next week. TODO IN FUTURE: track the patches.
     Steve also suggest that pay attention the alignment of cache when enable hugetlb. it might be unaligned. And the stand deviation is also important for the performance number.
   - Maxim ask how about the behavior of prefetch if cont page hint is set. TODO: ask details with my colleague.
这次cont page hint主要有几方面的反馈：
    - 大家对于对比方案的性能分析和目前的设计方案总体比较认可。
    - 认可:
        * Linaro toolchain group(Maxim Kuvyrkov)对这个方案比较感兴趣，他们希望找到在4k上利用64k页表的优势，这个设计正好能满足他们的需求。
        * Steve Capper在做内核静态映射的cont page hint优化，对我这个方案在用户空间的改进比较感兴趣。建议我考虑对用户空间text, data做cont page hint优化。
    - 竞争方案
        英国研究所的Srinivas Kalaga在考虑在手机上使用16k页表。据他说iphone上使用16k页表（2G内存）性能很好。他们计划在手机上使用16k页表的方案以提高性能。但是他们还没有把系统跑起来，性能评估也没有做。我个人觉得这个是值得关注的方向，但是16k页表不是所有系统都支持，适用范围有限。他们进展并不快，将来估计可以正面比较下两种方案的优劣。

Coresight
---------
talk with Mathieu: Mathieu is appreciated that huawei could provide the real use case for coresight. I think it could be a way to push the development of coresight features for huawei.

Hi, Mathieu, Mike
Here is the notes of coresight we discussed in bud17. please correct me if I am wrong.

1.  Mathieu said that cpu idle(power off) will lost the state of etm. For our senario, we could not avoid this, so we re-setup etm when cpu is online. This is 

2.  cross trigger:
    1.  Mathieu said that qualcomm 8074 board support cti . Mathieu send me the driver. I will read it later.
    2.  Discuss with Mike about how to make use of FULL signal of tmc and cti to do the continuous tracing. Mike wrote a note to me:
        ```
        So the FULL and ACQCOMP signals should be connected to a CTI. This is mentioned in the TMC TRM (Section 2.1.5).
        And each CTI is connected to all other CTIs via the CTM network (this is normal, I hope).
        And then each CTI for a CPU should normally have a trigger output which is connected to an interrupt input on the CPU/GIC. This connection was historically documented in the "processor debug connectivity" document for partners to use when integrating CoreSight, and is much more publicly documented in ARMv8.
        This network allows the usage model described, and allows the interrupt to be routed to a specific CPU (although a GIC can probably do that for you anyway).
        ```
        The thing is when cpu notice this interrupt, the buffer is already overwritten. Do you know if etr could support threshold to send the 'almost full' signal?

3.  timestamp:
    Bamvor ask how to design a proper timestamp. Mathieu suggest that timestamp should be async with cpu if timestamp in cpu domain or design a fast timestamp outside cpu subsystem.
    Mathieu: "HiSilicon was seeing clock jitters when frequency scaling (CPUfreq) was used."

4.  multiple etr support.
    There are 4 ets in D05. Bamvor hope linaro could find to support it. He suppose there is d05 in linaro.

5.  About coresight intergrate with perf.
    In bamvor''s understanding, perf per-thread buffer connect to etr which could not trace multiple thread in the same time. Is it correct? Mathieu mentioned Alex Shishkin from intel. "Alex is working on a feature that allows tracing on a system wide basis".

6.  About unneeded package in Bamvor''s trace:
    Bamvor found the following packages:
    ```
    52: [4904464] I_ASYNC : Alignment Synchronisation.
    65: [4904464] I_TRACE_INFO : Trace Info.; PCTL=0x0
    68: [4904464] I_ADDR_L_64IS0 : Address, Long, 64 bit, IS0.; Addr=0xFFFFFFC00009A880;
    76: [4904464] I_ASYNC : Alignment Synchronisation.
    91: [4904464] I_TRACE_INFO : Trace Info.; PCTL=0x0
    94: [4904464] I_ADDR_L_64IS0 : Address, Long, 64 bit, IS0.; Addr=0xFFFFFFC0008DB9A0;
    ```
    Mike/Mathieu said that it is the part of the alignment package which could not be avoided. Because decoder need the absolute address(the later package only contain the relative address). When Bamvor enable the cpu power up/off, there are lots of these type of packages which lead to more time to decode the package. It would be great to eliminate these set of package. Bamvor thought that ETM should output the package before it really output the first relative address. Mike feel it is hard to do in the hardware.
    Mike:
    ```
    These packets are architecturally defined in the ETMv4 specification and hardware. They cannot be filtered out. They are vital for the correct decode of trace.  It is not possible to determine when trace restarts without these packets.  If they were missing from the stream then decode errors would occur as we cannot tell if packets are dropped when the ETM is powered down.  Furthermore, for systems using timestamps, then the initial timestamp is emitted at this point as well. The ETM cannot delay in emitting these packets as is is designed to output trace as soon as possible to avoid any internal buffers becoming full and causing trace data to be dropped.
    ```

7.  bamvor ask for how to use other resource? sequencer, event(other than viswinst), comparator, viewdata. Mathieu suggest ask arm support.

8.  etr buffer will restart when it start.


10. trsustzone? Ask Joakim Bech, Jens Wiklander about software part.
11. TODO: ask Leo yan or Mathieu about if them use coresight in hikey successful. they will focus on the hikey 960. 

13. Linaro could provide 4 hours debug training. it is free for core and club member.


这次主要是带着项目需求和Linaro的Mathieu Poirier, Mike Leach交流了coresight的用法，总体来说我们对coresight的思考还是比较多的，有比较明确的需求。通过Coresight或其它调测特性的需求交流，可以牵引Linaro改进并用到我们的产品中。具体交流内容如下：（直接贴英语）





-  toolchain and filesystem support for armv8.x(from hanjun)
和arm toolchain组engineering manager Joey(剑桥，下面管四个组，共17人)交流工具链和文件系统v8.1,8.2支持问题：包括v8.1 lse (原子指令)和v8.2 16位浮点。

Lse如果是库函数使用，考虑ifunc方式（见下）。应用可以不用或采用类似ifunc方式。

cavium 在推ifunc方式，目的是支持lse (原子指令)和针对thunder x的memcpy优化，补丁szabolcs.nagy@arm.com review差不多了，需要人收，现在的glibc arm64 maintainer marcus不在toolchain组，去做iot了，joey在想办法能不能把maintainer换成szabolcs.nagy@arm.com。

针对v8.2的16位浮点，joey认为在不支持16位浮点的平台会影响性能，所以原有应用不会用到。新应用直接调用16位浮点接口即可。

- ILP32
    - Upstreaming plan
    - Performance regression analysis.
- OS distribution maintainance
    - How to upgrade to new version: how to build the bootstrap.
    - How to make use of the ring and staging like openSUSE?

- EAS
     discuss with Leo Yan.

Do not wait and see,  you  will behind.

Arm should lead industry. Real time may be the one .

OTrP ?

Chromebook:)

只要10$!

Hawkbit open source  device  management.

Demo: use hikey as gateway.

Blue light mean it is updating/updated over bluetooth ble

Linus: bfq? block-mq.
Arnd: Mike: could you keep an eye on kernelci?
Ashi: kdump. security?(Ask them).
David long: audio for hikey?
Alex: lsk. rt-mutex documentation improvement, plan to talk  to mathiu and david long.
chunyan: the future 96boad from spectrum.
mike leach: openCSD, cti driver(TODO ask about the senario of CTI).
bejan: iommu device.
mathiu:  cfp for what conference?
stephen boyd(qualcomm).

ILP32

Marc:
Fix the glibc and gdb failure .
ilp 32 is the abi for ios(? Todo make sure)。
之前glibc代码质量不太好，合入后引入了regression . 影响合入进度。

0308 5G

ABI of arm


We already know about the potential issue of enum.

Demo friday

Socionext(索尼和富士合资的芯片公司? TODO recheck）发布了一个1536核（24*8*8）的服务器（集群）。它的基本单元是A11，24核Cortex-A53，最大支持64G内存，SOC自身功耗是5w。8个A11可以通过4-lane PCIe连接到一起，组成A20，A20里面有个mcu控制互联，可以提供remote memory，具体什么技术不肯透露。Andew Farber说Suse有个美国芯片公司客户在考虑通过hypervior做类似arm集群的管理。视频中可以看到这个1536核服务器大概和人差不多高。视频演示了在上面运行hadoop的结果。
介绍人：Satoru Okamoto(Unit Leader, SOC solution Engineering Unit).

思考和建议：在arm单核，单芯片能力偏弱，系统互连延迟有难点的情况下，通过软件实现某种集群管理，可能是体现arm优势的一种手段。建议把arm多socket方案，x86小型机方案和本方案比较，如果本方案能发现有价值的应用场景，建议欧拉考虑。2015年（？）arm64双socket性能不好时，hulk也讨论过对策，当时笔者就提出过把hypervior和pmem用起来。个人感觉作为整理方案的一环，会有它的优势。

和欣蔚讨论了下，欣蔚说这是标准的HPC用法。只是互连成了pcie. 看欣蔚的意思，remote memory就是rdma？研究下。
TODO: myrinnet.

arm server内容不要贴网络上！


Hi, Etienne

It is a pity not to discuss with you in Budapest. I read the TEE material recently. The issue is how to identify the fake CA. Could I encrypt the data in an atomic context and use one-time key in REE?

Is there a best practice in your hand?

Thanks

Bamvor

Etienne Carriere
Core Development - Security Working Group  ST
CONTACT DETAILS
* Email: etienne.carriere@linaro.org
* Timezone: LE MANS, FRANCE
MANAGER
Joakim Bech


整理和mathieu，Mike（要注意用全名，除非是像Arnd，Mathieu这样不容易重名的的）对齐的内容，并发邮件。
思考teeos问题：这次错过了看tee的内容。给tee的兄弟发个邮件表示歉意。
回复Andrew邮件，明确v8.x指令支持办法。
TODO 整理名片
TODO去年linuxcon也认识一个socionext的兄弟，给两个人都发个邮件，问问互相是否认识)

计划做但是没做的事情：
找leo yan请教：eas如何针对场景调优。

华为suse sync（lixiaoping，bios，bamvorzhangjian；suse: agraf, andres farber, and ?共三人)：agraf:内核的默认行为是先检查device tree有没有，再用acpi. 所以如果希望用acpi bios就不要传device tree。丁天虹：红帽之前也提了类似需求，当时没理解目的。bios为了能同时支持内部hulk版本和对外的upstream版本，为了内部版本维护方便，二进制归一。但是内部版本维护问题，不应该影响外部用户的体验。
后来华为说到在upstream D05的显示驱动，alex graf建议Bios 给内核传framebuffer就好了。没必要搞内核中复杂的驱动。服务器不需要太复杂的图形，也不需要加速。

问opensuse ring and staging. How to build the bootstrap.
bootstrap could be builded in previous version.
staging for testing.
ring for gcc and glibc changes to make things works. do not break.
rebuild=xxx other than local could also avoid the circle dependency.  TODO check and discuss with Shiyuan HU.

给leo yan发coresight 补丁。DONE. 后来Mathieu和suzhuangluan讨论了下，决定不再在hikey上做，后面在hikey960上做。
整理connect出差目标: ILP32, cont page hint; coresight and trustzone.
ILP32进展。
Ask Yury: who join the manager meeting. And is there any speccfic problem discused?
Wookey在做debian支持，要休假，估计要几周。然后Catalin会请其它maintainer ack. 我个人预计4.13会进。

from qiyao: 0309Toolchain上午的讨论：V8.x glibc ifunc根据hwcap或cpuid等信息挂不同的钩子。

通过辛晓慧问arm 对v8.2,8.1libs 的支持。找到徐拯。
徐拯: Arm有live patching想法。建议问下Joey(arm toolchain enginner manager in Cambrige).后来joey说是linaro 的想法，arm没评估过。
其它人提醒我说live patch会不会影响应用的完整性校验，从而有安全问题。

和arm toolchain组engineering manager Joey(剑桥，下面管四个组，共17人)交流工具链和文件系统v8.1,8.2支持问题：包括v8.1 lse (原子指令)和v8.2 16位浮点。

Lse如果是库函数使用，考虑ifunc方式（见下）。应用可以不用或采用类似ifunc方式。

cavium 在推ifunc方式，目的是支持lse (原子指令)和针对thunder x的memcpy优化，补丁szabolcs.nagy@arm.com review差不多了，需要人收，现在的glibc arm64 maintainer marcus不在toolchain组，去做iot了，joey在想办法能不能把maintainer换成szabolcs.nagy@arm.com。

针对v8.2的16位浮点，joey认为在不支持16位浮点的平台会影响性能，所以原有应用不会用到。新应用就用库函数ifunc就好了。

Glibc补丁review: szabolcs.nagy@arm.com，joey在想办法能不能把maintainer换成szabolcs.nagy@arm.com。合入问题可以找Joey。

Acer rbtchc@gmail.com,  tsc. LITE group member.
