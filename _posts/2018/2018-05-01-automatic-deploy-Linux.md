---
layout: post
title: Linux自动化部署工具综述
categories: [Software]
tags: [Linux, kiwi]
---

TODO: 测试gibhub pages如何展示draft文稿。以后公众号未发表的不再放到post里面。

生产环境中通常用自动部署的方式代替手工安装Linux的过程。笔者前段时间正好有封闭场景自动化部署的需求，调研发现有多种方式可供选择，但很少有文章把自动部署的方式都说全，并给出选型建议。选型后，实际使用中，发现这些工具英文文档和论坛比较丰富，中文资料大多只是分散的入门文档。故写文章分享调研过程和实际踩坑体会，写作计划：
1.  Linux发行版有哪些自动部署方式，我为什么选择Linux发行版镜像制作这条路（本文）；
2.  Linux发行版镜像打包部署工具分类，比较其中的三种并给出选型建议；
3.  介绍SUSE的KIWI，功能强大，极为推荐；
4.  介绍其它镜像打包方式：terraform和vagrant，virt-builder。
注：原本1和2是一篇文章，有兄弟看了觉得没重点，自己也觉得问题1没说清楚。索性单独写一篇。

首先本系列只说Linux发行版层次的部署，所以不管是容器（docker，kata等等），还是unikernel都**不**包括在内。我亲爱的帅哥同事李昂写过k8s的文章，欢迎灌水，拍砖。另外工作基于选定的发行版做定制，不是lfs(Linux From Scratch)等自己从头构建Linux的思路。

笔者的需求是在特定环境部署物理机或虚拟机，系统在一键部署后直接可用。想达到这个目的，经过调研看到三个思路：
1.  定制镜像，部署时直接把镜像写到硬盘，系统启动后直接可以使用；
2.  通过配置文件，把原本需要手工干预的Linux发行版安装过程自动完成；
3.  基于一个已部署的默认系统，使用自动化部署工具配置环境。

这里面要考虑的点包括
1.  是否有外网；
2.  重在把Linux系统升级到指定状态还是重新部署整个Linux；
3.  是否Client/Server架构还是Client-Only架构。

方法1（下文称为定制镜像）和2（下文称为自动安装）可以和方法3联合使用。设想一下，如果多个业务系统需要统一的定制的Linux发行版，但是这个Linux发行版不同于默认安装，有些配置需要修改，有些软件需要安装。我们可以通过前两个方法安装后，使用方法3部署特定的业务系统。当然也有人[比较这两个思路的优劣](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)[1]，文中提到了[Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)[2]，分析思路值得看看，作者推荐的terraform是方法1和3的结合，这是本文重点比较的方法之一。

方法3的自动化部署工具很多，例如Ansible, Chef, Fabric，Puppet, SaltStack。。。有些很轻，适合部署几台机器；有些需要在目标机器安装daemon，即使网络暂时中断也不影响部署。这也是比较广的话题，笔者最近在学习Fabric和Ansible，将来有机会会分享这方面的话题。

具体说来，定制镜像和自动安装在各发行版的部署方式里面都有介绍，关系如下图：
<img alt="applicace_comparision.png" src="{{site.url}}/public/images/appliance/applicace_comparision.png" width="100%" align="center" style="margin: 0px 15px">

回忆一下自己手工安装一个Linux系统，需要选择安装设置和安装后的系统配置，发挥余地很大同时也消耗大量精力：
<img alt="public/images/appliance/Linux_distribution_installation.png" src="{{site.url}}/public/images/appliance/Linux_distribution_installation.png" width="100%" align="center" style="margin: 0px 15px">

如果用户需要在相似的硬件上部署相同的系统，可以采用Linux发行版提供的自动安装方式，一次选择多次安装。由于与安装程序绑定，不同发行版有不同的自动安装方法：SUSE的autoyast使用方法可以参考[SUSE Linux Enterprise Server 12 SP2 AutoYaST](https://www.suse.com/documentation/sles-12/book_autoyast/data/book_autoyast.html)，[openSUSE Leap 42.3 AutoYaST](https://doc.opensuse.org/projects/autoyast/)。Redhat kickstart可以参考[CHAPTER 31. KICKSTART INSTALLATIONS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/ch-kickstart2)。

虽然自动安装不需要人为操作，但是仍然是一步一步安装的（例如安装了500个软件包，每个包都要单独安装，看着进度条慢慢走。。。），安装时间本身并没有显著缩短。如果能够一次把需要安装的软件都安装好，制作成镜像，部署时直接把定制的好镜像写入系统硬盘。例如KIWI这个镜像制作工具，通过用户给出的镜像描述文件(image description)，从给定的安装源(package source)下载包并安装到目录(unpacked image)，安装完成后，根据用户要求的镜像格式制作生成镜像(packed image)：
<img alt="public/images/appliance/kiwi_image_creation_architecture.png" src="{{site.url}}/public/images/appliance/kiwi_image_creation_architecture.png" width="100%" align="center" style="margin: 0px 15px">

制作好的镜像可以快速的部署到目标环境中。

链接
[Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)
[开源的自动化部署工具探索](https://my.oschina.net/u/1540325/blog/639884)
[自动化部署工具——Ansible探索](http://blog.51cto.com/zyxjohn/1886251)


非本文
------
生产环境中通常用自动部署的方式代替手工安装Linux的过程。笔者前段时间正好有在封闭场景自动化部署的需求，调研发现有多种方式可供选择，但很少有文章把自动部署的方式都说全，并给出选型建议。选型后，实际使用中，发现这次工具英文文档和论文比较丰富，中文资料却很简单。故写文章分享调研过程和实际踩坑体会，计划专门分享下我自己用过的几个镜像打包工具，并做出比较。方便小伙伴们选择。系列分为：
*   介绍自动部署的三种方式，具体介绍和比较其中的镜像打包工具（本文）；
*   介绍SUSE的KIWI，功能强大，极为推荐；
*   介绍其它镜像打包方式：terraform和vagrant，virt-builder。

镜像制作和部署工具选型建议
--------------------------
本文具体比较三种定制镜像工具：KIWI，virt-builder和terraform，一句话选型建议：
*   如果需要支持物理机部署，只能选择KIWI；
*   如果部署镜像时需要额外定制，只能选择terraform。
*   如果单纯在虚拟化环境使用，希望一个stardalone的环境快速构建虚拟机镜像的方式，可以选择virt-builder。

