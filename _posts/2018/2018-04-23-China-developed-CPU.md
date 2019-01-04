# 春风吹又生----梳理中国CPU

（为了照顾微信公众号无法跳转非微信链接的限制，所有链接都统一放到最后）

《[一段关于国产芯片和操作系统的往事](https://mp.weixin.qq.com/s/w63uRu-yT12Pmt9GYiNDvQ)》写到国产方舟CPU和国产软件的故事。 笔者不禁想起，十五年前在大学时，一个视频点播机房曾经全部部署过方舟CPU的瘦客户端。过了两年，都换成普通PC了，当时的瓶颈似乎是集群带宽不够。我觉得领先两步是烈士，当年我们各个方面差距非常大，这些年我们虽然高端制造还有极大差距，但是很多东西还是追了上来。如果没有方舟们之前的工作，没有当时方舟们的成功流片，就没有后来我们对体系结构这么深的理解，也没有君正，申威，国防科大，展讯等很多公司现在能够继续在自研CPU上继续往下走。

一直觉得专业的人做专业的事情。经济，贸易这些笔者也不太懂。恰好本人是芯片专业，后来一直做操作系统相关的工作，这些年对于国内CPU，SOC比较关注。正好借这个机会梳理下中国CPU。本文没有借东风，火烧赤壁的精彩。分析且仅仅往下分析一层，希望比各种吐槽提供更多价值信息。

首先需要说明的是，国内CPU公司的设计不一定都在国内。技术发展水平，美国出口限制（并不是专门针对大陆）等原因导致很多国内公司CPU的一部分设计在国外。本人也不太喜欢国产CPU这种提法，看看具体能做什么有意义的技术，把技术水平提高，比单纯强调国产有意义。

本文思路
--------
CPU其实有不同的场景，也有不同的需求。做东西还是为了满足诉求，不是为了做而做。比如国家安全，比如针对自己场景做特定的优化。总体来说，超算领域，我们有申威CPU；手机芯片有展讯的SC9850KH；低功耗服务器、个人计算机、工业控制、网络安全方面我们有龙芯；低功耗嵌入式CPU有君正。

本文内容包括：
1.  本文说什么，不说什么；
2.  介绍国内公司研发的CPU现状；
3.  上述CPU背后的关系。

### 本文涉及
1.  CPU与SOC的区别；
2.  CPU与GPU，DSP，MPU，NPU的区别；
3.  我国参与的CPU涉及的架构和专利。

### 本文不说
1.  CPU和操作系统及其生态：网上不少人说到CPU和操作系统就说生态，就好像我去爬山你非要和我讨论环境保护。生态重要，但是和CPU和操作系统的研发和应用并不是同一个话题。
2.  抽象的计算机体系架构：简单说只说CPU涉及到的工程实现，不说学术。计算机体系结构可以参考学术论文，例如isca。
3.  不发散计算要怎么做：CPU是用于计算的，除了XXU之外，还有DNA计算，量子计算。
4.  CPU是否重要。
5.  芯片设计软件（EDA工具）：CPU工程设计属于芯片设计，芯片设计需要与芯片生产工艺相关的芯片设计软件。
6.  Foundry，即芯片制造商，国内最大的制造商是中芯国际，大中华区最大的是台积电，全球最大的是英特尔。投资周期长，投资以10亿美元为单位。
7.  芯片生产设备（即芯片制造设备）属于高端制造的一部分。全球芯片生产设备集中在美国日本荷兰。这个笔者也不太了解，而且还涉及到禁运。
8.  芯片设计和制造流程：二者极为都极为复杂，而且与CPU设计生产没有直接关系，超过了笔者只想多分析一层的计划，本文完全不打算涉及。
9.  各种爆料和猜测。听起来有趣或激动人心。实际试图去了解它们背后的逻辑更为重要。

中国研究机构或公司研发的CPU
---------------------------
### CPU和芯片是什么关系？
CPU是计算机系统中用于计算和控制的芯片，是计算机系统的核心。中学学的半导体二极管，三极管等器件，大家还记得吧。芯片是把很多，甚至千万、上亿个半导体器件放到一块二氧化硅（沙子的主要成分）上。经常有个说法是中国无芯，很有意思的是，结束中国无芯历史也被宣布好几次了，这是为什么呢？因为芯片种类繁多，例如计算和控制相关的有CPU，GPU，MPU，NPU等等，还有存储的芯片，各种通信芯片等等。如果我们把Macbook pro拆开，下图的“胡子”叫主板，主板中红色框框就是英特尔的CPU，如果我们把芯片拆下来，正面和反面如图所示：
<img alt="public/images/misc/intel-i7-6700hq.gif" src="{{site.url}}/public/images/misc/intel-i7-6700hq.gif" width="100%" align="center" style="margin: 0px 15px">
图片来源： <http://www.hardwareluxx.ru/index.php/fotostrecken/artikel-galerien/intel-skylake-core-i7-6700hq-im-test/intel-skylake-h-3-white-fronta767fce.html>，<https://zh.ifixit.com/Guide/%E9%85%8D%E5%A4%87Touch+Bar%E7%9A%8415%E8%8B%B1%E5%AF%B8MacBook+Pro%E6%8B%86%E8%A7%A3/73395>

上图中
*   红色部分是英特尔CPU：酷睿(Core) i7 6700HQ 四核处理器 2.6GHz主频 (最大睿频 3.5GHz)
*   黄色部分是AMD的显卡：AMD Radeon Pro 450 独立显卡

如果把上述主板中的多个芯片集成到一个芯片中，称为SOC（System On a Chip，片上系统）。SOC通常包括CPU，显卡，内存控制器，硬盘控制器等模块。例如下图是华为最新旗舰手机的核心SOC麒麟970（下图CPU是华为购买的ARM CPU；GPU即显卡，功能和上图苹果macbook的AMD显卡一样；DDR指内存控制器）：
<img alt="public/images/arm64_ecosystem/Huawei_kirin970__internal.png" src="{{site.url}}/public/images/arm64_ecosystem/Huawei_kirin970__internal.png" width="100%" align="center" style="margin: 0px 15px">
图片来源: 华为mate10拆解: <http://www.techinsights.com/about-techinsights/overview/blog/huawei-mate-10-teardown/>

在我们的PC和服务器领域，通常CPU是个单独的芯片，例如英特尔，龙芯的服务器芯片。但是在手机中一般设计成SOC以提高系统可靠性，降低功耗，例如高通，华为，联发科，展讯等公司的手机芯片。笔记本中也经常有CPU和GPU在一个芯片的情况（即APU）。

如果仔细看全球自研CPU的发展，尤其是自研ARM CPU的发展，能看到明显思路是先购买包括CPU在内的各个模块自己设计SOC，逐步到SOC级别的优化，优化和设计模块，甚至自行设计CPU。例如苹果手机芯片从最开始的ARM11，到2009年iPhone 3GS的Cortex-A8再到后来的自研CPU，苹果公司通过软硬件极好的配合，用相对较低的CPU和内存配置做到了比Android更流畅的体验。CPU作为SOC中最复杂的模块之一，要想保持竞争力，有断裂点，自己做是个很自然的选择。除了军工或国家安全的需要，自己做CPU的好处还有：微架构的设计可以更符合场景需要，例如更好的性能功耗比等等；在体系结构允许范围内做优化或加自己的扩展。

本文不说SOC设计公司，只说CPU设计公司。每家CPU的介绍思路是
1.  发展历史；
2.  最新处理器的架构和生态。

### 申威
申威处理器又称"SW处理器"，具体负责研发的单位是江南计算机所属于军方研究机构(总参56所)。2006年推出第一代处理器，目前共有4代处理器。其中前三代源于DEC Alpha架构。第四代26010架构不详，官方文档明确说不是alpha架构(Shenwei-64  Instruction Set (this is NOT related to the DEC Alpha instruction set))。第四代申威处理器架构设计类似与Power cell架构：每个通用处理核心与64个SIMD向量处理器搭配，每个计算节点共4个通用处理器+256个计算节点（256 CPEs (computing  processing  elements) + 4  MPEs (management processing  elements)）

<img alt="public/images/misc/Shenwei_64__26010__supercomputer.png" src="{{site.url}}/public/images/misc/Shenwei_64__26010__supercomputer.png" width="100%" align="center" style="margin: 0px 15px">
申威太湖之光超级计算机，图片来源：<http://www.netlib.org/utk/people/JackDongarra/PAPERS/sunway-report-2016.pdf>

### 龙芯
龙芯(Loongson)是中科院计算所研发的，属于MIPS兼容架构。2002年推出第一代处理器（32位）。2003年10月17日，龙芯2号首片MZD110流片成功。代号MZD110纪念毛泽东主席诞辰110周年。2009年最新一代龙芯3成功量产。龙芯3A2000出来后，计算所内部把以前的桌面系统都换了。作为一款通用处理器，原有x86软件如何使用是个大问题。技术上讲，对于有源代码的软件，可以通过移植和重新编译解决；对于没有源代码的软件，需要以某种方式在龙芯芯片上模拟运行。龙芯至迟从2004年开始做x86软件运行加速工作，基本有两个思路，一是CPU硬件直接支持部分x86指令；二是软件DBT(Dynamic Binary Translation)优化。DBT是在系统运行时动态把其它架构的软件（例如x86）转化为本芯片支持的软件。当年英特尔在移动市场推广x86手机芯片，同样使用了DBT技术。

<img alt="public/images/misc/loongson_3_front.png" src="{{site.url}}/public/images/misc/loongson_3_front.png" width="100%" align="center" style="margin: 0px 15px">
最新的龙芯3处理器，图片来源：<http://www.loongson.cn/product/cpu/3/3A3000.html>

MIPS是世界上第一个RISC处理器。消费市场上大家知道的CPU，除了英特尔是CISC架构起家，其余各家（Power，ARM，RISC-V）等都是RISC架构。龙芯的Loongson ISA在MIPS上也有扩展，是个消化吸收并针对需求优化的过程。此外，从龙芯2f开始，龙芯已经成为著名发行版Debian的mipsel架构的编译机器。 在2009年，龙芯提交了大量的MIPS代码到内核，作为团体进入前10，获得了kernel开发者峰会提名。

此外，君正公司SOC的自研CPU也是MIPS架构，其核心人员来自前文提到的方舟。君正之前做过MP4芯片，平板芯片，目前主攻智能穿戴。由于MIPS架构的优势和自身技术积累，君正的SOC功耗都很低。

### 展讯
展讯产品线除了ARM架构还有和英特尔合作的X86芯片。这里只说ARM。非技术人第一次听说ARM也许是2016年日本软银孙正义收购ARM公司。ARM不仅在移动端有完善的Android生态；在高性能计算（HPC），云计算方面也有多家公司持续投入。例如老牌网络公司Cavium，占领欧洲的发行版公司SUSE，惠普三家联合在英国上线ARM64 HPC项目。云计算方面，阿里去年上线测试ARM64服务器。这些都是ARM生态的价值。关于ARM生态的一些动态，可以参考笔者前面两篇文章：[ARM生态系统的盛会Linaro connect（之一）：arm64 server和端侧AI](https://mp.weixin.qq.com/s/TrHpq7VXtrsL7D1wT0xcYg)，[ARM生态系统的盛会Linaro connect（之二）：arm64 workstation和低成本调试工具](https://mp.weixin.qq.com/s/omUv7HkGxSatKh6jJyZKVg)

<img alt="public/images/arm64_ecosystem/Spreadtrum__CPU__SOC__SC9850.jpg" src="{{site.url}}/public/images/arm64_ecosystem/Spreadtrum__CPU__SOC__SC9850.jpg" width="100%" align="center" style="margin: 0px 15px">
图片来源：展讯twitter：<https://twitter.com/spreadtrum>

展讯当年因为中国移动运营的TD-SCDMA步调慢，差点死掉。后来凭借TD的订单，一直持续投入做基带芯片，并且逐步开始做手机AP芯片（上述华为麒麟970就是AP芯片），也就是我们说的手机CPU。后来才有了现在说的[自研CPU SC9850KH](https://mp.weixin.qq.com/s/0jH4uoEv0UsMuKOFZiozIQ)。从文章看，主打性能功耗比。据知情人透露，SC9850KH是大小核架构，其中大核是两个支持了SMT（硬件多线程）的自研CPU，小核是Cortex-A53。操作系统看到的是6个核（一种配置是2 x 2 SMT@1.5G + 2 x CA53@1.5G，具体频率会因产品有所不同)。ARM架构硬件多线程是趋势，不过手机里面用的好很少（或没有？）。这里也能看出展讯CPU团队的技术积累。

背后的故事
-----------
### 架构之争
[从Intel和ARM争霸战，看看做芯片有多难](https://mp.weixin.qq.com/s/gpfMOW7gzVa2HhYOlDy2nQ)介绍了X86和ARM架构的历史，并建议用中间件屏蔽CPU和操作系统的差异。这部分留给软件的专家和吃瓜群众讨论就好了。咱们还是聚焦到CPU。

到底选择什么样的架构？要不要做一个全新架构？个人觉得消费市场来说，机会点不多。不过这两年有个开源的CPU架构RISC-V(BSD License)，发展很快。与其完全自己做，不如参与开源社区，构筑开源社区的影响力，长期看对于生态更好。

咱们还是聊一聊MIPS和ARM的小关系。清华紫光集团联席总裁，前展讯CEO的李力游最近去了全球三大GPU厂家之一Imagination。过去几年苹果手机一直使用Imagination的GPU（俗称显卡）。2012年MIPS公司被Imagiation和AST(Allied Security Trust)收购。简单说前者买了MIPS公司的实体和MIPS专利中与MIPS CPU直接相关的专利。后者AST是20多家公司的合资公司。在MIPS被收购中，AST花了$350M(约21亿人民币)买了498项通用CPU专利。其中ARM公司出资大约是一半。为什么ARM公司要出这么多钱？ ARM CEO Warren East当时说：
>   "Litigation is expensive and time-consuming and, in this case, a collective approach with other major industry players was the best way to remove that risk."

翻译过来就是，ARM不买这些专利，就是等着别人诉讼，花钱只会更多。不过话说回来，做x86的intel, AMD和做power的IBM也有很多通用的CPU专利，只是暂时风平浪静。技术角度讲，64位ARM处理器与32位ARM处理器是不同的设计，前者和MIPS有大量类似之处，有人说是"70-80%的相似度"，笔者没有考证过。ARM公司尚且如此，国内公司如果完全做一个新的64位架构，专利风险有多大，不言而喻。所以笔者认为，对于商业产品来说，龙芯，飞腾，展讯等公司合法购买已有体系结构的授权是很合理的选择。

抛开技术上MIPS和ARM的纠葛，只是看人的流向也有意思。当年方舟同时做自研架构和MIPS架构，给后来的君正和做ARM CPU的公司培养了人才。做龙芯Linux内核移植的专家去了国内手机公司，带领Linux内核团队做了很多事情。体系结构其实有万千，但是万变不离其宗，其实我们国家做不管是MIPS还是ARM都属于对总体来说都属于RISC架构。在扩大些说，不管是RISC还是CISC，其实从技术特性的比较，比如说性能功耗比，它主要取决于微架构设计，而微架构其实在体系结构之间，哪怕是CISC和RICS间都是高度共通的，所以这种CPU微架构的设计，其实不管做什么体系结构，都会有积累。就像英特尔当年想做嵌入式，选择32位ARM架构，和ADI联合研发MSA架构，并设计了XScale系列CPU及其SOC。后来xScale卖给了marvell。直到现在marvell仍然是沿着XScale架构的路线持续演进。

### 杂七杂八
国内明确做cpu的其实还有两家，一个是国防科大的飞腾，一个是兆芯。国防科大飞腾从原来的sparcv8架构转到ARM架构。前年飞腾ARM 64位芯片出来时争议很大，从芯片spec看只能用在服务器领域。兆芯的x86授权2018年到期，据说只是不能用2018年之后的指令集，原来指令集授权仍然可用。这两家公司笔者暂时了解不到具体情况，欢迎大家合法爆料多给些输入。

### 华为？
另外一个值得说一说的公司是华为，华为的海思，从20多年以前开始做芯片，目前的芯片已经广泛用到华为各个产品线中，华为的手机也从最开始的k3(SOC)的祖传暖手宝，到现在的麒麟970，性能逐渐改善进入全球手机芯片第一梯队。麒麟芯片目前用在华为所有的中高端手机中，年出货量超过千万。按照前面展讯SOC的研发过程华为有没有做CPU呢？2016年的时候，曾经有文章说华为的自研泰山CPU的SOC Hi1612流片，但是随后被华为辟谣，我们不去讨论华为目前有没有自研CPU。但是如前所述，从做SOC到做CPU是一个逐步深入的过程，因此不管华为有没有做自己的CPU，华为做SOC所培养的技术人才，对于我们做CPU来说都是非常重要的积累。
顺便八卦一下，华为芯片一直以山命名，k3是喀喇昆仑山的第三高峰-布洛德峰。这个比很多SOC公司单纯数字编号相比，从K3到泰山的命名更说明了华为心中的志向。再比如华为2012年建立了2012实验室，喜欢以科学家名字命名，例如图灵，欧拉，高斯，这里就不展开了，可以参考[真正的出路：重读任正非2012实验室讲话](https://mp.weixin.qq.com/s/IMUfA-SEcqra_8RIa7AY0g)

参考链接
--------
1.  CPU
    1.  申威
        1.  <http://www.netlib.org/utk/people/JackDongarra/PAPERS/sunway-report-2016.pdf>
        2.  <https://zh.wikipedia.org/wiki/%E7%94%B3%E5%A8%81%E5%A4%84%E7%90%86%E5%99%A8>
        3.  <http://www.eefocus.com/mcu-dsp/370966/r0>
    2.  龙芯
        1.  <https://zh.wikipedia.org/wiki/%E9%BE%99%E8%8A%AF>
        2.  DBT: <https://lt.cjdby.net/thread-526768-1-1.html> 
        3.  关于龙芯的更多信息：《如何看待国产龙芯处理器？》：<https://www.zhihu.com/question/19612562/answer/364963263>
    3.  展讯
        1.  <https://mp.weixin.qq.com/s/0jH4uoEv0UsMuKOFZiozIQ>
        2.  首款国产 自主手机CPU，紫光展锐SC9850KH正式亮相: <http://t.cj.sina.com.cn/articles/view/5772303575/1580e5cd7001004pvx?cre=tianyi&mod=pcpager_fintoutiao&loc=13&r=9&doct=0&rfunc=100&tj=none&tr=9>
    4.  MIPS被收购
        1.  MIPS公司被Imagination和AST两家公司拆分收购之后，对国内基于MIPS架构的CPU设计公司有哪些影响？比如龙芯: <https://www.zhihu.com/answer/16061799>
        1.  ARM Holdings licenses big chunk of MIPS patents: <https://www.theregister.co.uk/2012/11/06/mips_sells_itself_to_imagination_arm/>
    5.  学术会议：
        1.  isca: http://iscaconf.org/isca2018/program.html
        2.  hotchips
        3.  asplos
2.  芯片制造厂(foundry)  <https://en.wikipedia.org/wiki/Semiconductor_fabrication_plant>
3.  知乎：“现在有哪些国产 CPU 和操作系统？现状如何？”：<https://www.zhihu.com/question/58816532>
4.  李力游：<http://www.esmchina.com/news/article/201804031625>
5.  华为海思芯片命名，"华为海思K3芯片命名曝光：为喀喇昆仑山峰": <http://info.tele.hc360.com/2009/07/210936144523.shtml>
6.  禁运
    1.  瓦瑟纳尔协议 <https://zh.wikipedia.org/wiki/%E7%93%A6%E8%81%96%E7%B4%8D%E5%8D%94%E5%AE%9A>
    2.  哪些设备技术对中国禁运? <https://www.zhihu.com/question/53217224/answer/151017560>

感谢两位猎头MM及4位架构师帅哥的宝贵建议。本文首发本人公众号[《敏达生活》](https://mp.weixin.qq.com/s/HcLDWQIArUjkCGGc8eOYEg)，欢迎关注。

