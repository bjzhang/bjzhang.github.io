---
layout: post
title: Linux自动化部署工具综述
categories: [Software]
tags: [Linux, kiwi]
---

打算写一个关于Linux自动化部署工具的系列文章。虽然相关的内容和方法在网上基本都可查询的到，但往往都是较为零散的点，很少有资料能把自动化部署的方式描述全面。结合自己在调研及实际工作中遇到的问题及可能有用的一些经验，初步写作计划如下：
1.  Linux发行版有哪些自动部署方式，笔者为什么选择Linux发行版镜像制作这条路（本文）；
2.  Linux发行版镜像打包部署工具比较和选型建议；
3.  介绍SUSE的KIWI，功能强大，极为推荐；
4.  介绍其它镜像打包方式：terraform和vagrant，virt-builder。

按：本系列只说操作系统层次的部署，不包括是容器（docker，k8s, kata等等），libos/unikernel等方式。我们目前另有项目使用k8s部署和管理组件，将来有机会再分享。

笔者的需求是在特定环境部署物理机或虚拟机，系统在一键部署后直接可用。具体要求包括：
1.  安装业务定制rpm和二进制包；
2.  安装业务部署工具；
3.  可以配置系统引导程序(bios/uefi, grub)和硬盘分区；
4.  有简单的安装部署工具；
5.  部署时不依赖外网；

经过调研，Linux自动化部署有三个方法：
<img alt="applicace_comparision.png" src="{{site.url}}/public/images/appliance/applicace_comparision.png" width="100%" align="center" style="margin: 0px 15px">

回忆一下自己手工安装一个Linux系统，需要选择安装设置和安装后的系统配置，发挥余地很大同时也消耗大量精力，估计你等不到下面的视频看完。。。
<https://v.qq.com/x/page/j1338uprqma.html>
[下载地址]({{site.url}}/public/images/misc/openSUSE_13_1_openQA_KDE_video.mp4) （视频来源：<https://www.youtube.com/watch?v=MBq0emuBuOM>）

如果用户需要在相似的硬件上部署相同的系统，可以采用Linux发行版提供的自动安装方式，一次选择多次安装。由于与安装程序绑定，不同发行版有不同的自动安装方法：SUSE的autoyast使用方法可以参考[SUSE Linux Enterprise Server 12 SP2 AutoYaST](https://www.suse.com/documentation/sles-12/book_autoyast/data/book_autoyast.html)，[openSUSE Leap 42.3 AutoYaST](https://doc.opensuse.org/projects/autoyast/)。Redhat kickstart可以参考[CHAPTER 31. KICKSTART INSTALLATIONS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/ch-kickstart2)。

虽然自动安装不需要人为操作，但是仍然是一步一步安装的（例如安装了500个软件包，每个包都要单独安装，进度条慢慢走。。。慢慢走。。。），安装时间本身并没有显著缩短。如果能够一次把需要安装的软件都安装好，制作成镜像，部署时直接把定制的镜像写入系统硬盘，部署时间会显著缩短。例如KIWI这个镜像制作工具，通过用户给出的镜像描述文件(image description)，从给定的安装源(package source)下载包并安装到目录(unpacked image)，安装完成后，根据用户要求的镜像格式制作生成镜像(packed image)：
<img alt="public/images/appliance/kiwi_image_creation_architecture.png" src="{{site.url}}/public/images/appliance/kiwi_image_creation_architecture.png" width="100%" align="center" style="margin: 0px 15px">

所以制作ghost的方式比较适合我们，现有工具中，只有suse的kiwi支持在物理机部署，所以我们选择了kiwi。下一篇文章会详细比较kiwi, virt-builder和terraform。

安装Ghost镜像之后并不是个幸福的结局，我们的业务软件需要客户配置IP地址，硬盘设备路径等信息后，部署业务。对于这个工作来说，方法3的自动化部署工具很适合。此类自动化部署工具很多，例如Ansible, Chef, Fabric，Puppet, SaltStack。。。有些很轻，适合部署几台机器；有些需要在目标机器安装daemon，即使网络暂时中断也不影响部署。我们业务设计上每个节点是完全相同的，所以C/S架构不适合，使用一个简单的Client-Only的方式比较方便。由于我们之前分布式存储使用了Fabric，本次继续使用Fabric部署。

参考链接
--------
1.  Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation: <https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c>，文中提到了[Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)[2]，分析思路值得看看，作者推荐的terraform是上述方法1和3的结合。
2.  开源的自动化部署工具探索: <https://my.oschina.net/u/1540325/blog/639884>
3.  自动化部署工具——Ansible探索: <http://blog.51cto.com/zyxjohn/1886251>

注：
1.  上面opensuse安装视频并不是“活人”手工装的，是opensuse的openQA测试框架在自动化测试安装，其中使用opencv做图片识别判断场景。
2.  相关的工具还有Canonical的MAAS(Metal as a Service, https://maas.io/, 用于物理机管理), Juju(https://jujucharms.com/docs/2.3/about-juju)则适合在云中使用。笔者没有实际使用过，用过的小伙伴可以给些反馈，帮我完善下文档。

本文首发本人公众号[《敏达生活》](https://mp.weixin.qq.com/s/9SjTy3Zl4Md4-kxBuoU5lw)，欢迎勾搭，拍砖，转发。

