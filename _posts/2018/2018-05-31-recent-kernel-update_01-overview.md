# 与社区共舞：如何追踪Linux内核社区最新动向（之一）

按：不出意外的话，4.17（或5.0）将于下周release。这里笔者以4.16和4.17内核变动为线索，介绍了追踪linux内核最新特性的方法。以体系结构和内存的特性为实例，介绍了作为一个内核开发者或者关心内核开发的底层开发者，如何有效的关注内核最新进展。
整体来说这是一条线就是从社区到产品的过程。对于重度使用开源软件的产品来说，这是个很重要一条线。

本内容基于笔者上周（5月23日）在优麒麟北京产品发布派对内容整理。

## Live with upstream kernel
2015年到2017年笔者在华为负责内核从2.6.32/3.10到4.1的迁移，支撑产品线内核迁移。需要熟悉2.6.32/3.10到4.1的内核特性和接口变更。当时有两方面的体会：
1. 提前了解社区的发展趋势，可以从特性到代码实现各个层次降低专有代码量工作量，降低内核升级工作量：
	* 当时某产品线内核有类似社区pstore的特性，但由于长期独立演进二者差异大，无法合并。如果能提早识别产品的需求，尽早识别社区变化，就有可能避免这一问题。
	* 在具体代码层次：当时产品线使用了社区已在使用的printk “Pointers”格式化参数（%p+格式字符），造成产品内核升级后打印格式变化。发现问题后，笔者把内核社区文档加入产品内核接口变更说明中，避免再次出现同类问题。printk具体格式可以参考社区文档：<[How to get printk format specifiers right — The Linux Kernel  documentation](https://www.kernel.org/doc/html/latest/core-api/printk-formats.html)>
2. 更重要的是可以把自身的需求放入到社区的路线图中，提高社区影响力。
	* 例如，当时部门通过投入一个技术专家到linaro社区的方式，作为该特性的实际贡献者推动了arm64 acpi特性地开发与合入，有效支撑了华为自身的arm芯片和产品计划。只是受到arm公司想主导arm内核社区的想法的影响，寒军只成为arm64 acpi排名第二个的maintainer：
![arm64 acpi maintainer](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145317.png)

相关slide如下，后续以实例说明。
![Live with upstream kernel 01](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145323.jpg)
![Live with upstream kernel 02](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145326.jpg)
![Live with upstream kernel 03](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145330.jpg)


## Who write kernel?
![Who write kernel](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145332.jpg)

### History
这里给大家提了一个问题，就是内核历史贡献量是哪一个公司或者组织最多。活动中我给了大家几个选项，最终大家没有猜对。
![Who write kernel: history](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145335.jpg)
从上图可以看到，内核历史第一贡献公司/组织是爱好者，第四名是没有说明公司或组织的个人，这两者加在一起，一共有20%的贡献量，所以这里希望大家能明白一个道理，真正活跃的，健壮的开源社区，它的贡献是非常多元的，开源社区所倡导的集市的开发模式，贡献者会非常分散，并不会被公司把持。

### 4.16统计
![Who write kernel: 4.16](http://opuclx9sq.bkt.clouddn.com/2018-05-31-145340.jpg)
随后笔者分享了4.16内核的贡献统计，可以看到这前20名厂商里面大概分为三类，第一类是芯片公司，例如intel，amd，瑞萨，arm，broadcom；第二类是软件公司，例如Linux发行版的两家公司：redhat和suse；第三类是软硬件都做的公司，例如oracle和华为。最近几个版本，华为作为唯一的中国公司稳稳的站在内核贡献前20名。这和华为拥有从嵌入式到手机再到云计算产品丰富的产品线，所需要的完整的公共内核的研发能力有关。

后续文章中笔者将从体系结构和内存两个子系统，分享一下从Linux merge window到具体代码，追踪内核特性开发的过程。

本文首发本人公众号[敏达生活](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483776&idx=1&sn=cfcd68120e95b3189b80e99f766bb6a4&chksm=ec6cb7acdb1b3eba24e78e672fce1ec48fc74fb138cdc4ccd5f8b85359ba61e7083e4581877b#rd)，欢迎关注，勾搭，转发。
