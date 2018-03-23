---
layout: post
title: 假装在现场--2018年第一场linaro connect
categories: [Linux]
tags: [Linux, arm]
---

上次参加linaro connect还是在布达佩斯，当时还分享了arm64上一个页表优化的工作，目前这个工作仍然由Linaro kernel working group的其它小伙伴继续在做（之前公众号链接见文末）。

Linaro作为推进arm生态的组织，在从efi到kernel到cloud，在众多开源项目中都有不少贡献。从最新release的[4.15内核统计](https://lwn.net/Articles/742672/)看，不仅Linaro自己贡献了3.4%的补丁名列公司排名第五，Linaro的三个core member中有两个都进入了前15，arm和海思（华为芯片部门）分别贡献了2.2%和1.8%，三者加一起是7.4%，已经超过了红帽的6.7%贡献。

arm64越来越丰富的硬件
---------------------
从1983年第一个Acorn RISC Machine算起。作为产品的arm cpu已经有2018-1983=35年的历史了。直到前几年arm几乎都用于嵌入式领域。随着xxxx年linaro的成立，很多公司一起改进arm的生态。最近几年arm产品越来越多样。不仅仅是传统的嵌入式市场，在服务器和桌面电脑（为啥笔者不说是pc，下文分解）也有不少值得评估的产品。要想真正有产品，就需要有很方便可以用于开发的设备。

这方面linaro定位在消费电子的96boards CE板子，很适合。信用卡的大小，有arm，arm64，但是统一接口和软件。用起来非常方便。CE板子小巧使用方便，由于毕竟是给移动端设计的，强调低功耗，性能和桌面电脑略有差距，所以linaro一直积极在做EE板子，这次linaro connect重磅介绍来自日本公司socionext。

hikey970
--------
AI.
rockchip960 pro

arm64 workstation
-----------------
最早的EE板子是[Cello](http://www.96boards.org/product/cello/)和[Husky Board](http://www.96boards.org/product/huskyboard/)链接已失效。
TODO 找照片。

[Edge Server SynQuacer E-Series 24-Core Arm PC is Now Available for $1,250 with 4GB RAM, 1TB HDD, Geforce GT 710 Video Card](https://www.cnx-software.com/2018/03/21/edge-server-synquacer-e-series-24-core-arm-pc-is-now-available-for-1250-with-4gb-ram-1tb-hdd-geforce-gt-710-video-card/)

其实不光是socionext，老牌网络芯片公司cavium，现在也全面转向arm架构，也有workstation和server产品，与这次Linaro connect同时在OCP发布了thunderXStation(thunderX2)
这是thunderX, thunderX2的workstation：
[Avantek 32 core Cavium ThunderX ARM Desktop](https://www.avantek.co.uk/store/avantek-32-core-cavium-thunderx-arm-desktop.html)

[2018 OCP Summit - Cavium公司主要发布及展示](https://mp.weixin.qq.com/s/JviDO_UGctia3MjBrptZrg)
[GIGABYTE Announces ThunderXStation: Industry's first Armv8 Workstation based on Cavium's ThunderX2 Processor](https://www.prnewswire.com/news-releases/gigabyte-announces-thunderxstation-industrys-first-armv8-workstation-based-on-caviums-thunderx2-processor-300616517.html)
目前在售的workstation比较

Name                |   OverDrive 1000 | SynQuacer™ 96Boards Box | ThunderX ARM Desktop | thunderXStation(thunderX2)
--------------------|------------------|-------------------------|----------------------|----------------------------
Chip                |    AMD A1120     | Socionext SynQuacer SC2A11| Cavium® ThunderX™ CN8890_CP | ThunderX2 CN99XX
CPU                 |   4xCA57@1.7GHz  | 24xCA53@1GHz            | 32xARMv8@1.8GHz      |  32core per sockets\*; 4 thread per core
L1 Cache            |    ?             |  32KB/32KB I/D          |       ?              |           ?
L2 Cache            |   2M             |    256 KB               |       ?              |           ?
L3 Cache            |   8M             |    4MB                  |       ?              |           ?
Memory              |up to 64GB(2xDDR4)|4x16GB DDR4-2133 with ECC| 8 x DDR4 with ECC    |16 DDR4 Channels (8 per cpu)
PCIe x16            |   None           | 1x PCIe x16 slot (limited to 4-lanes) for graphics card | PCIe x16 (Gen3 x8 bus) | 6x PCIe Gen 3.0 x16 slots (3 slots per CPU, which can be configured as 1x 16 lane + 1x 8 lane OR 3x 8 lanes).
PCIe x8             |   None           |    None                 |  PCIe x8 (Gen3 x8 bus)| 见上
PCIe x1             |   None           | 2x PCIe x1 slots        |  None                | None
Network             |   通过usb转接    | 1Gbps                   |       ?              | 1GbE(PCIe) option Dual 1/10GbE 10BASE-T RJ45 QLogic OCP NIC
Graphics            |  None            | ASUS Geforce GT 710 | ? | Nvidia GeForce® GT710 with dual monitor support
Storage             | 2xSATA 3.0| 32GB eMMC 5.1 flash + 2x SATA interfaces | | 4x NVMe PCIe Gen 3.0x4 + 2x 2.5” U.2/SATA-3  combo bay, option 4x 3.5"
USB                 | 2x USB 3.0| 4x USB 3.0 | ? | ?
BMC                 |  None | None | None | ASPEED AST2500 with IPMI management
os                  | opensuse|debian, ubuntu, fedora | ? | centos7.4, ubuntu, opensuse
support device tree | | Yes | ? | ?
support acpi        | | Yes | ? | ?
price               | 580$ | 1250$ | 1349英镑 | 无

注
1.  ThunderX2 CN99X有不同的配置，公开资料较少。这里列出的似乎是最低的配置。
2.  ThunderX2支持OCP: PCIe: 1x OCP PCIe Gen 3.0 x16 slot per CPU
3.  大家不约而同用了nv家的显卡。早期arm64 pcie设计和规范有一点点差异，当时对于接不同厂商的pcie有一点点困难。不知道目前情况如何。
4.  SynQuacer™ 96Boards Box: 30 Watts at idle, and during the person detection demo at Linaro Connect with Gyrfalcon mPCIe it went up to 40 Watts.
5.  SynQuacer™ 96Boards Box是符合Linaro 96boards EE规范的板子和上一个胎死腹中的EE板子相比改进了很多，总体性能提升（虽然单核性能差了），有了显卡。

linaro的文档。
<https://github.com/96boards/documentation/wiki/Developerbox-Getting-Started>

[OverDrive 1000](https://softiron.com/development-tools/overdrive-1000/)

arm64调测
---------

### openocd
[HKG18-403 – Introducing OpenOCD: Status of OpenOCD on AArch64](http://connect.linaro.org/resource/hkg18/hkg18-403/)
2010年的时候openocd用的是ahb-ap读取的系统信息，没有走apb-ap，所以有cache问题。
但是openocd需要自己根据soc写配置文件。你得学一下。
用现成的armv7之后的soc修改就可以。它里面有继承关系，cpu肯定都支持了。只是需要根据soc适配下。
jlink我没看过。openocd其实只是个通道，下面是个usb转sw debug协议的东西。具体发什么信号都是上面pc端控制的。所以理论上，openocd可以支持所有jtag和sw协议的硬件。但是实际中sw协议不开放。所以2010年的时候openocd只能用jtag协议连接armv7的cpu。

用法参考：<https://www.96boards.org/documentation/consumer/hikey/guides/jtag/>，现在已经合入主线了，可以去官网下载<https://sourceforge.net/p/openocd/code/ci/master/tree/>：`git clone https://git.code.sf.net/p/openocd/code openocd-code`

配置文件："openocd-code/tcl/target/hi6220.cfg"


其它有意思的东西
----------------
几乎都是（除了五个二进制）go重写的类似busybox的文件系统。
<https://github.com/u-root/u-root>
<http://u-root.tk/>


链接
----
1.  使用连续页面hint改善用户空间匿名页的性能
    1.  [敏达生活公众号](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483660&idx=1&sn=2f32af38d6af0f52c9a99b22de27f5cc&chksm=ec6cb720db1b3e369bdf1a67479e06096b47fe9990acc46b41f2da4c66c5be5c1fc35328ee4d#rd)
    2.  [博客](http://aarch64.me/2017/06/Implementing-Contiguous-page-hint-in-userspace/)
2.  ARM服务器第一个商业版本! Suse服务器版本官方支持包括树莓派3在内多个SOC
    1.  [敏达生活公众号](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483651&idx=1&sn=9eb471492caaac8ea3147c55f5a742b1&chksm=ec6cb72fdb1b3e390e7f9d8df138181bd90ec7e1577b887cc9051efa85a5d0a1ade5e0c077e2#rd)
    2.  [博客](http://aarch64.me/2016/11/suse-release-12-sp2-including-aarch64-support/)

