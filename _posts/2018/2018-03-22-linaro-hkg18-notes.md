---
layout: post
title: ARM生态系统的盛会：端侧AI和ARM64 PC
categories: [Linux]
tags: [Linux, arm]
---

Linaro作为推进arm生态的组织，在从uefi到kernel到cloud，在众多开源项目中都有不少贡献。从最新release的linux [4.15内核统计](https://lwn.net/Articles/742672/)看，不仅Linaro自己贡献了3.4%的补丁名列公司排名第五，Linaro的三个core member中有两个都进入了前15，ARM和海思（华为芯片部门）分别贡献了2.2%和1.8%，三者加一起是7.4%，已经超过了第三名红帽的6.7%贡献。

Linaro Connect是个沟通的平台，每年在美国和美国以外的地区各办一次，包括公开演讲和各种闭门会议。任何人都可以提交演讲，也可以利用connect的机会组织讨论。我曾经参加过4次connect，面对面讨论对自己和工作都帮助不小。上次参加Linaro connect还是在2017年的布达佩斯(BUD17)，当时还分享了arm64上一个页表优化的工作（[公众号链接](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483660&idx=1&sn=2f32af38d6af0f52c9a99b22de27f5cc&chksm=ec6cb720db1b3e369bdf1a67479e06096b47fe9990acc46b41f2da4c66c5be5c1fc35328ee4d#rd)，[博客链接](http://aarch64.me/2017/06/Implementing-Contiguous-page-hint-in-userspace/)）。目前这个工作由Linaro kernel working group的AKASHI Takahiro继续在做。上周在香港举办了今年第一场Connect，实话讲离真正被x86开发者接受还有距离，只是觉得这些年看着arm生态越来越完善， 一直坚信arm能做更多的事情，不禁和想和大家分享下，文章分为两部分：
1.  arm64 server和端侧AI；
2.  arm64 workstation和低成本调试工具；

Linaro全部精彩内容可以从[官方公众号](http://weixin.bes.ren/index.php?g=Wap&m=Index&a=content&token=mygoqu1459476246&classid=28&id=708&from=groupmessage)（貌似必须在手机微信客户端才能访问），全部日程在这里：<http://connect.linaro.org/hkg18/resources/>。也可以在youtube和slideside搜索Linaro on air得到历届Connect视频和slide。

arm的生态越来越好
-----------------
从1983年第一款Acorn RISC Machine产品算起。作为产品的arm CPU/SOC已经有35年的历史了。直到前几年arm几乎都用于嵌入式领域。随着[2010年linaro](https://www.linaro.org/about/)的成立，很多公司一起改进arm的生态。有些基础规范，软件，单独某个公司难以推动；为了便于协同开发，社区也需要符合统一规范的硬件。经过几年的努力，Linaro建立的96boards规范已经有三大类(CE消费电子，EE企业级，IE物联网)，几十种开发版，可以用于开发和产品原型。得益于这些努力，最近几年arm产品越来越多样，不仅仅是传统的嵌入式市场，在服务器和桌面电脑（为啥笔者不说是pc，下文分解）也有不少值得评估的产品。

Linaro定位在消费电子的96boards CE板子，只有信用卡的大小，有arm，arm64多种SOC可供选择，由于统一接口和软件，日常开发，评估不同单板都很方便。CE板子小巧使用方便，由于毕竟是给移动端设计的，强调低功耗，性能和桌面电脑略有差距，所以Linaro一直积极在做EE板子，这次linaro connect重磅介绍来自日本公司Socionext的arm64 workstation，很多新闻称其为PC，详见下文"arm64 workstation"。

作为嵌入式产品和通用产品，会有一些差别。比如嵌入式产品，系统软件与硬件绑定，使用devicetree区分不同硬件就很方便。但是对于通用产品，用户会安装不同的操作系统，无法接受需要为不同芯片准备不同的镜像（例如不同的Linux kernel）。在x86领域，得益于EFI和ACPI等规范，软硬件可以很好的解耦。Linaro的LEG(Linaro Enterprise Group)一直在推动arm64 server的各种标准，例如uefi, ACPI for ARM64, Server Base System Architecture (SBSA)和Server Base Boot Requirements (SBBR)。 其中来自华为的技术专家郭寒军是ACPI for arm64规范和Kernel代码的最主要贡献者。有了EFI和ACPI，就可以像x86一样，通过光盘，网络等方式安装操作系统。

自己说自己符合标准等于自说自话，这次有个keynote是来自微软Azure的Leendert van Doorn（杜麟达）： [HKG18-300K1 – Keynote: Leendert van Doorn “Microsoft Azure: Operating at Hyper-Scale”](https://www.youtube.com/watch?v=uF1B5FfFLSA)

演讲的开始，Leendert首先介绍了微软之前5代数据中心的特点，可以看到PUE([Power usage effectiveness，数据中心整体能耗除以用于IT设备的能耗](https://en.wikipedia.org/wiki/Power_usage_effectiveness))在逐步下降。
<img alt="public/images/cloud/linaro_hkg18__microsoft__datacenter_evolution.png" src="{{site.url}}/public/images/cloud/linaro_hkg18__microsoft__datacenter_evolution.png" width="100%" align="center" style="margin: 0px 15px">

微软有选择arm64 server最重要的原因貌似是多供应商策略，Leendert同时强调Intel还是Microsoft最大的合作伙伴，双方合作的很好:)
Leendert提到arm64 server有几个机会点：提高数据中心容量，高性能存储等：
<img alt="public/images/cloud/linaro_hkg18__microsoft__arm64_opportunities__small.png" src="{{site.url}}/public/images/cloud/linaro_hkg18__microsoft__arm64_opportunities__small.png" width="100%" align="center" style="margin: 0px 15px">

目前市场上arm server大致有两个思路，一个是通过低功耗和高集成度，实现大规模并行计算，适合于hadoop等对于cpu要求不高但需要大容量存储的场景。另一个思路是提供可以与x86相比较的单核性能和更好的集成度，把原本运行在x86的软件，不做太大调整的拿到arm64上面运行。显然，微软Azure以及Windows等产品是在x86上成熟闭源产品，同时对单核性能要求高。所以微软只会使用标准化高性能的arm产品，不会使用cortex-A53等低功耗cpu。

Leendert最后总结道，对于Azure来说arm64 server的Windows 已经成熟了。虽然还有商业上的其它因素，暂时只是把arm server作为内部使用，但是下一步会把arm server放到Azure里面。
<img alt="public/images/cloud/linaro_hkg18__microsoft__arm64_server_summary__small.jpg" src="{{site.url}}/public/images/cloud/linaro_hkg18__microsoft__arm64_server_summary__small.jpg" width="100%" align="center" style="margin: 0px 15px">

演讲中，还提到由于arm64 server普遍cpu核数比较多，对于动辄200多核的arm64 server来说，操作系统怎么感知到这个拓扑结构并合理利用很重要。微软注意到社区正在合入ACPI PPTT补丁，这对于arm64和x86都很有帮助，参考：[ACPI 6.2规范](http://uefi.org/sites/default/files/resources/ACPI_6_2.pdf)和[Support PPTT for ARM64 v7补丁](https://lwn.net/Articles/748300/)

96Boards.ai
-----------
让我们暂时回到CE板子。在AI火的一塌糊涂的今天，端侧（例如手机，各种消费电子产品等要权衡性能和功耗的场景）中如何使用AI呢？本次connect宣布了<https://www.96boards.ai/>，网站上有Ultra96, Rock960和Hikey970三款板子，加上计划加入的DragonBoard 820c，概括如下：

Board    |  Ultra96   | Rock960    |  Hikey970    |   DragonBoard 820c
---------|------------|------------|--------------|-------------------
SIZE     |  CE        |  CE        |  CE extended |     CE extended
SOC      |Xilinx Zynq UltraScale+ MPSoC| Rockchip RK3399 | Hisilicon Kirin970 | Qualcomm Snapdragon 820E
CPU      |4xCA53@1.5GHz| 2xCA72@1.8GHz + 4xCA53@1.4GHz|4xCA73@2.36GHz + 4xCA53@1.8GHz| 4xKryo CPU@2.35GHz
Memory   |  2G        |  2G/4G     |     6G       |     3G
GPU      |Mali-400 Mp2|Mali-T860MP4| Mali-G72MP12 | Adreno-530
AI       |  FPGA      | NPU        |    NPU       |        ?


注：
1.  CE Extended尺寸是100 x 85mm；
2.  [Ultra96](https://www.96boards.ai/documentation/ultra96/)及其使用的SOC: [Zynq UltraScale+ MPSoC Product Tables and Product Selection Guide](https://www.xilinx.com/support/documentation/selection-guides/zynq-ultrascale-plus-product-selection-guide.pdf)。该系列SOC，Cortex-A53最大频率是1.5G，不清楚这款96boards CPU的具体频率。
3.  [rock960](https://www.96rocks.com/)
4.  [Kirin 970 - HiSilicon](https://en.wikichip.org/wiki/hisilicon/kirin/970)
5.  [DragonBoard 820c](https://www.96boards.org/product/dragonboard820c/)

Linaro CEO George Grey在Keynote（链接见文末）现场演示了通过Ultra96的FPGA使用[Tiny YOLO](https://pjreddie.com/darknet/yolo/)识别人物。Tiny YOLO(You only look once)使用神经网络识别图中的物体，下图中展示了在人们移动过程中的识别结果：
<img alt="public/images/arm64_ecosystem/linaro_connect_hkg18__Ultra96_AI__tiny_YOLO.png" src="{{site.url}}/public/images/arm64_ecosystem/linaro_connect_hkg18__Ultra96_AI__tiny_YOLO.png" width="100%" align="center" style="margin: 0px 15px">

上面的例子是在FPGA上运行的，另一个思路是使用专门的npu芯片，这次华为推出的第三代Hikey（Hikey970）的Kirin970芯片包含了NPU：
<img alt="public/images/arm64_ecosystem/hikey-970.jpg" src="{{site.url}}/public/images/arm64_ecosystem/hikey-970.jpg" width="100%" align="center" style="margin: 0px 15px">

从上述表格可以看到，麒麟(Kirin)970的性能是最好的。实际上，作为华为旗舰芯片，麒麟970不仅用在去年10月发货的Mate 10，去年11月发货的荣耀v10，也会用于下周（2018年3月27日）发布的p20。Kirin970 NPU具体资料很少，HiAI也暂时需要申请才能查看，下面笔者搜集的部分资料：

名称        |        -                | 备注
------------|-------------------------|-------
晶体管数量  | 150万                   | 注1，不到麒麟970全部晶体管的3%
Performance | 1.92 TFLOPs (HP 16-bit)；相当于25倍cpu的性能 | 注1，注3
支持的框架  | TensorFlow, Caffe       | 注2
功耗        | CPU的1/50               | 注3
用途        | 推理（inference）       | 深度学习有两个阶段：训练（training）和推理（inference）

注：
1.  [What is the Kirin 970’s NPU? – Gary explains](https://www.androidauthority.com/what-is-the-kirin-970s-npu-gary-explains-824423/)
2.  [HiAI移动计算平台业务介绍](http://developer.huawei.com/consumer/cn/devservice/doc/31401)
3.  [How Fast Is The Huawei Kirin 970 NPU?](https://www.techarp.com/articles/huawei-kirin-970-npu-speed/)
    ```
    The Kirin 970 NPU offers 25X the AI processing performance of the CPU, at half the size. More importantly, it only consumers 1/50 the power of the CPU. It allows the Kirin 970 to recognise about 2005 images per minute, or about 33 per second. That is more than twice as fast as the new Apple iPhone 8 Plus, and 21X faster than the Samsung Galaxy S8.
    ```

笔者曾经参加过Hikey项目，很高兴看到Hikey家族越来越壮大，上面的Hikey970是Hikey家族的第三代，前两代分别是Hikey和Hikey960。Hikey不仅是最早的[96board](https://www.96boards.org/)，更重要的是Hikey系列一直是google aosp(Android Open Source Project)官方开发平台，所以很多开发者使用Hikey开发。这次connect，Victor Chong以Hikey为例，介绍如何在android中使用op tee，并举例说明如何添加自己的CA和TA：[HKG18-119 – Overview of integrating OP-TEE into HiKey620 AOSP](http://connect.linaro.org/resource/hkg18/hkg18-119/)。 从这里也可以看出迭代的重要性，能够持续迭代的产品，用户投入不会打水飘，也更有可能发挥出产品的特点。

### 其它参考资料
1.  [NVIDIA趣味解读：深度学习训练和推理有何不同？](https://www.jiqizhixin.com/articles/2016-08-26-3)
2.  [开发者福利来袭！华为发布人工智能开发平台HiKey 970，助力端侧AI应用创新](https://mp.weixin.qq.com/s/8-o8h4Z1-mj5iE3aFUuyFg)

ARM64 workstation
-----------------
Linaro 96boards致力于Enterprise领域的板子至少有两年了，开始的进展并不顺利，最早的EE板子是[Cello](http://www.96boards.org/product/cello/)和[Husky Board](http://www.96boards.org/product/huskyboard/)（链接均已失效），下图是笔者在2016年曼谷connect拍摄的Cello样板：
<img alt="public/images/arm64_ecosystem/linaro_connect_bkk16__lemaker_cello__96boards_EE__AMD__small.jpg" src="{{site.url}}/public/images/arm64_ecosystem/linaro_connect_bkk16__lemaker_cello__96boards_EE__AMD__small.jpg" width="100%" align="center" style="margin: 0px 15px">

一年前布达佩斯connect，Socionext第一次展示了24核以及1536核的集群。下图手持的是24核Cortex-A53单板，下面那张纸是8个单板互联板的照片，插满8个板子是192核的集群：
<img alt="public/images/arm64_ecosystem/linaro_connect_bud17__socionext_SC2A11_stacks__small.jpg" src="{{site.url}}/public/images/arm64_ecosystem/linaro_connect_bud17__socionext_SC2A11_stacks__small.jpg" width="100%" align="center" style="margin: 0px 15px">
每个192核的集群可以再次互联，最多可以组成8 x 192 = 1536核的集群，下图是演示运行集群监控软件[ZABBIX](https://www.zabbix.com/)的截图：
<img alt="public/images/arm64_ecosystem/linaro_connect_bud17__socionext_SC2A11_stacks__hadoop__small.jpg" src="{{site.url}}/public/images/arm64_ecosystem/linaro_connect_bud17__socionext_SC2A11_stacks__hadoop__small.jpg" width="100%" align="center" style="margin: 0px 15px">

今年，Socionext正式介绍了arm64 workstation: [Edge Server SynQuacer E-Series 24-Core Arm PC is Now Available for $1,250 with 4GB RAM, 1TB HDD, Geforce GT 710 Video Card](https://www.cnx-software.com/2018/03/21/edge-server-synquacer-e-series-24-core-arm-pc-is-now-available-for-1250-with-4gb-ram-1tb-hdd-geforce-gt-710-video-card/)
从上面的新闻可以看出该workstation有几个特点，一个是内存，显卡，硬盘都可以插拔，可以按需配置，从形态上更接近与x86的pc。二是很适合开发：虽然暂时只能运行Linux，对于最终用户并不方便，但是对于开发者来说，直接在arm64的机器上开发arm64的各种软件，比传统通过交叉编译方便很多。第三，24核Cortex-A53整体可以提供比较好的性能。
<img alt="public/images/arm64_ecosystem/linaro_connect_hkg18__socionext_workstation.jpg" src="{{site.url}}/public/images/arm64_ecosystem/linaro_connect_hkg18__socionext_workstation.jpg" width="100%" align="center" style="margin: 0px 15px">

其实不光是Socionext，老牌网络芯片公司Cavium，现在也全面转向arm架构，也有workstation和server产品，与这次Linaro connect同时在OCP([Open Compute Project](http://www.opencompute.org/ocp-u.s.-summit-2018/))峰会发布了thunderXStation(thunderX2)：
<img alt="public/images/arm64_ecosystem/thunderXstation.jpg" src="{{site.url}}/public/images/arm64_ecosystem/thunderXstation.jpg" width="100%" align="center" style="margin: 0px 15px">

1.  thunderX workstation：[Avantek 32 core Cavium ThunderX ARM Desktop](https://www.avantek.co.uk/store/avantek-32-core-cavium-thunderx-arm-desktop.html)
2.  thunderXStation(thunderX2)：
    1.  [2018 OCP Summit - Cavium公司主要发布及展示](https://mp.weixin.qq.com/s/JviDO_UGctia3MjBrptZrg)
    2.  [GIGABYTE Announces ThunderXStation: Industry's first Armv8 Workstation based on Cavium's ThunderX2 Processor](https://www.prnewswire.com/news-releases/gigabyte-announces-thunderxstation-industrys-first-armv8-workstation-based-on-caviums-thunderx2-processor-300616517.html)

目前在售的workstation比较

Name                |   OverDrive 1000 | SynQuacer™ 96Boards Box       | ThunderX ARM Desktop | thunderXStation(thunderX2)
--------------------|------------------|-------------------------------|----------------------|----------------------------
Chip                |    AMD A1120     | Socionext SynQuacer SC2A11    | Cavium® ThunderX™ CN8890_CP | ThunderX2 CN99XX
CPU                 |   4xCA57@1.7GHz  | 24xCA53@1GHz                  | 32xARMv8@1.8GHz      |  32core per sockets\*; 4 thread per core
L1 Cache            |    ?             |  32KB/32KB I/D                |       ?              |           ?
L2 Cache            |   2M             |    256 KB                     |       ?              |           ?
L3 Cache            |   8M             |    4MB                        |       ?              |           ?
Memory              |up to 64GB(2xDDR4)|up to 4x16GB DDR4-2133 with ECC| 8 x DDR4 with ECC    |16 DDR4 Channels (8 per cpu)
PCIe x16            |   None           | 1x PCIe x16 slot (limited to 4-lanes) for graphics card | PCIe x16 (Gen3 x8 bus) | 6x PCIe Gen 3.0 x16 slots (3 slots per CPU, which can be configured as 1x 16 lane + 1x 8 lane OR 3x 8 lanes).
PCIe x8             |   None           |    None                       |  PCIe x8 (Gen3 x8 bus)| 见上
PCIe x1             |   None           |  2x PCIe x1 slots             |  None                | None
Network             |   通过usb转接    |   1Gbps                       |       ?              | 1GbE(PCIe) option Dual 1/10GbE 10BASE-T RJ45 QLogic OCP NIC
Graphics            |  None            | ASUS Geforce GT 710 | ? | Nvidia GeForce® GT710 with dual monitor support
Storage             | 2xSATA 3.0| 32GB eMMC 5.1 flash + 2x SATA interfaces | ? | 4x NVMe PCIe Gen 3.0x4 + 2x 2.5” U.2/SATA-3  combo bay, option 4x 3.5"
USB                 | 2x USB 3.0| 4x USB 3.0 | ? | ?
BMC                 |  None | None | None | ASPEED AST2500 with IPMI management
os                  | opensuse|debian, ubuntu, fedora | ? | centos7.4, ubuntu, opensuse
support device tree | | Yes | ? | ?
support acpi        | | Yes | Yes | Yes
price               | 580$ | 1250$ | 1349英镑 | 无


注
1.  [OverDrive 1000](https://softiron.com/development-tools/overdrive-1000/)
2.  Linaro提供的Socionext arm workstation文档：<https://github.com/96boards/documentation/wiki/Developerbox-Getting-Started>
3.  SynQuacer™ 96Boards Box功耗，SOC功耗5W TDP；系统功耗：30 Watts at idle, and during the person detection demo at Linaro Connect with Gyrfalcon mPCIe it went up to 40 Watts.
4.  SynQuacer™ 96Boards Box是符合Linaro 96boards EE规范的板子和上一个胎死腹中的EE板子相比改进了很多，总体性能提升（虽然单核性能差了），有了显卡。
5.  ThunderX2 CN99X有不同的配置，公开资料较少。这里列出的似乎是最低的配置。
6.  ThunderX2支持OCP: PCIe: 1x OCP PCIe Gen 3.0 x16 slot per CPU
7.  大家不约而同用了nv家的显卡。早期arm64 pcie设计和规范有一点点差异，当时对于接不同厂商的pcie有一点点困难。不知道目前情况如何。


回到刚才说的EE板子，其实还有个EE板值得关注。rock960的哥哥rock960 EE（下图上面是rock960 EE，下面是rock960。插的卡是pcie转m.2）：
<img alt="public/images/arm64_ecosystem/rock960_CE_and_EE.png" src="{{site.url}}/public/images/arm64_ecosystem/rock960_CE_and_EE.png" width="100%" align="center" style="margin: 0px 15px">

接口如下：

CPU    | 2xCA72, 4xARM Cortex-A53                 |  A72属于arm高性能cpu，但是SOC是低功耗芯片。
-------|------------------------------------------|----------------------------------------------------------
GPU    | Mali-T860MP4 with 2.4 TOPS capable NPU   |  Mali T系列属于Mali性能较好的GPU系列
Memory | up to 4GB RAM                            |  可惜内存不能插拔。主要原因可能是原本SOC定位也不是Enterprise
Display| HDMI 2.0/eDP up to 4K @ 60 Hz            |  4k显示
Camera | Dual MIPI CSI camera interfaces          |  双摄像头可以做3D用。
PCIe   | PCIe 2.1 x16 slot                        |  实际是x4的能力做成了X16的接口，主要为了接硬件方便
Storage| Dual SATA 3.0 port with RAID 0/1 support |  使用mirror可以满足基本的数据安全
Network| Gigabit Ethernet, 802.11ac WiFi          |  网络理论参数不错
USB    | 3x USB 3.0, 5x USB 2.0

可以看到这个板子的优点是接口丰富，价格可爱（1GB-4GB从99$到149$），做IOT网关，家庭nas都挺好的。短板是
1.  CPU性能稍差：RK3399 SOC最初定位是移动场景，使用了低功耗工艺制造，单核性能会比上面的workstation中OverDrive 1000, ThunderX ARM Desktop和thunderXStation(thunderX2)的差一些。
2.  内存不能插拔
3.  显卡是内置的。由于RK3399设计限制PCIe接口最大只能共享32m内存，所以外接显卡意义不大。

这个板子是Tom Cubieo同学做的。该同学之前做了cubieboard, cubietruck等多个allwinner（全志）芯片的开发板。那时候合入社区比较好的就是全志了（虽然不是全志自己推的）。得益于全志自己设计的类似device tree的配置方式，我当初买了一个全志的平板，刷入sd卡，替换配置文件后直接可以启动ubuntu界面。当时cubie系列开发板社区很受原因，笔者当初在[虚拟化平台xen上支持Cortex-A7](https://wiki.xen.org/wiki/Xen_ARM_with_Virtualization_Extensions/Allwinner)，就是基于他们赠送的Cubietruck做的。那时候arm cpu只有Cortex-A15和Cortex-A7支持虚拟化，CA15的板子太贵。Cubietruck是难得学习虚拟化的平台。

RK960 EE详细介绍参考下面的Youtube视频：[$99 Rock960 Enterprise Edition “Ficus”, Rock960 Pro with RK3399Pro with NPU for AI](http://armdevices.net/2018/03/22/99-rock960-enterprise-edition-ficus-rock960-pro-with-rk3399pro-with-npu-for-ai/)，RK3399的资料在这里：<http://www.t-firefly.com/doc/product/info/id/102.html>

arm64上低成本的调试手段
-----------------------
对于bootloader，kernel等底层开发者，有时候还是需要硬件调试器，专业调试器一直都比较贵。于是社区一直在推动低成本的调试器，OpenOCD就是其中之一。OpenOCD的特点是可以通过usb转jtag芯片(FT2232)直接从pc控制具体调试信号，这样OpenOCD其实只是个通道，所以理论上，OpenOCD可以支持所有jtag协议的硬件。

<img alt="public/images/arm64_ecosystem/OpenOCD_Architecture.png" src="{{site.url}}/public/images/arm64_ecosystem/OpenOCD_Architecture.png" width="100%" align="center" style="margin: 0px 15px">

当年从arm7到arm11使用OpenOCD都很方便。到了armv7 Cortex-A时代，arm引入了新的调试框架Coresight，虽然外部提供jtag和sw(serial wired)两种接口，但是arm官方调试器使用的却是sw。之前OpenOCD对于armv7, armv8的支持一直不太好。在包括Linaro在内的社区的共同努力下，目前OpenOCD对于armv7, armv8支持的已经比较好了，我与下文的作者Omair Javaid专门确认了下，虽然使用gdb连接OpenOCD有些corner case，但是对于通常的使用来说足够了("work just fine")：
[HKG18-403 – Introducing OpenOCD: Status of OpenOCD on AArch64](http://connect.linaro.org/resource/hkg18/hkg18-403/)，slide在这里：<http://aarch64.me/public/documents/cpu/arm/HKG18_403__OpenOCD_support_for_AArch64_targets.pdf>

2010年，笔者在中星微使用OpenOCD时，当时OpenOCD用的是ahb-ap读取的系统信息，没有走apb-ap没法直接看到cpu角度的数据，所以有cache一致性问题。现在这些问题已经解决了。OpenOCD的使用可以参考<https://www.96boards.org/documentation/consumer/hikey/guides/jtag/>，文中涉及的代码已经合入主线了，可以去[官网](https://sourceforge.net/p/openocd/code/ci/master/tree/)下载：

`git clone https://git.code.sf.net/p/openocd/code openocd-code`

下载后可以参考hikey的配置文件"openocd-code/tcl/target/hi6220.cfg"，根据自己的soc的配置调整。有任何问题欢迎直接反馈给Linaro，笔者可以帮忙联系Omair或Linaro中国区的兄弟。

其它有意思的东西
----------------
1.  几乎都是（除了五个二进制）go重写的类似busybox的文件系统：<https://github.com/u-root/u-root> <http://u-root.tk/>
2.  华为的keynote：[HKG18-400K1 – Keynote: Kenneth Lee – “To define the rule — why you should go open source”](https://www.youtube.com/watch?v=HdcC6IzLUtc)
3.  很多人尝试FPGA用于加速，这里是xilinx的分享： [HKG18-300K2 – Keynote: Tomas Evensen – All Programmable SoCs? – Platforms to enable the future of Embedded Machine Learning](https://www.youtube.com/watch?v=hhXGnCX06ao)
4.  arm公司为了推动arm server所做的努力： [HKG18-317 – Arm Server Ready Program](http://connect.linaro.org/resource/hkg18/hkg18-317/)
5.  George的keynote的最后还介绍了Linaro在automotive的计划，感兴趣的小伙伴可以从[George Grey: Opening Keynote - HKG18-100K1](https://www.youtube.com/watch?v=NXpC9Ln2-bA)的1小时13分26秒开始看。
6.  [HKG18-206 – CSI-based storage orchestration system on AArch64](http://connect.linaro.org/resource/hkg18/hkg18-206/)

相关链接
--------
1.  使用连续页面hint改善用户空间匿名页的性能
    1.  [敏达生活公众号](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483660&idx=1&sn=2f32af38d6af0f52c9a99b22de27f5cc&chksm=ec6cb720db1b3e369bdf1a67479e06096b47fe9990acc46b41f2da4c66c5be5c1fc35328ee4d#rd)
    2.  [博客](http://aarch64.me/2017/06/Implementing-Contiguous-page-hint-in-userspace/)
2.  ARM服务器第一个商业版本! Suse服务器版本官方支持包括树莓派3在内多个SOC
    1.  [敏达生活公众号](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483651&idx=1&sn=9eb471492caaac8ea3147c55f5a742b1&chksm=ec6cb72fdb1b3e390e7f9d8df138181bd90ec7e1577b887cc9051efa85a5d0a1ade5e0c077e2#rd)
    2.  [博客](http://aarch64.me/2016/11/suse-release-12-sp2-including-aarch64-support/)

本文首发本人[公众号敏达生活](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483722&idx=1&sn=6f4ab00336e1beb589388be5fdc8e34c&chksm=ec6cb766db1b3e70995205ec548ed120b7c4fc3d21e513ae744641966341886a77aa7482a6fd#rd)，欢迎关注。
