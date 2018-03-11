---
layout: post
title: 漫谈操作系统镜像打包方式之一————综述
categories: [Software]
tags: [Linux, kiwi]
---

实际工作或学习中中可能涉及到在特定环境部署物理机或虚拟机，希望系统一键部署后直接可用。一般有两类思路，一个是做一个定制的镜像，不干预直接安装，系统启动后直接可以使用。第二个是启动或安装一个默认系统，使用自动化部署工具配置环境。更复杂的情况是两者结合一起用。自动化部署工具很多，例如Ansible, Chef, Fabric，Puppe, SaltStack。。。有些很轻，适合部署几台机器；有些需要在目标机器安装daemon，即使网络暂时中断也不影响部署。当然也有人[比较这两个思路的优劣](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)，暂时不展开了。这里计划专门分享下我自己用过的几个镜像打包工具，并做出比较，方便小伙伴们选择。计划分三部分写：
第一部分总体介绍各种镜像打包工具。
第二部分介绍suse的kiwi，功能强大，极为推荐。
第三部分介绍其它镜像打包方式。

Linux发行版一键安装方式有很多种，可以分为预先安装和配置文件一键安装两种方式，如下图所示：
<img alt="applicace_comparision.png" src="{{site.url}}/public/images/appliance/applicace_comparision.png" width="100%" align="center" style="margin: 0px 15px">

预先安装的方式通常通过一个配置文件，配置bootloader，安装源（光盘，网络repo均可）和要安装哪些包，build image需要从安装源下载软件并安装到磁盘镜像中，使用时把磁盘镜像通过pxe，光盘启动，或直接写入硬盘的方式写入目标物理机，虚拟机或云中。这类工具通常支持多种发行版。相比之下，后一种方法和具体发行版是绑定的，通常的用法是如果有几台机器需要选择相同的安装选项，管理员先手工安装第一台机器，安装后目标机器会带有autoyst或kickstart的配置文件（默认在root目录下），管理员调整这个个配置文件后，使用这个配置文件安装其余几台机器。
suse的autoyast使用方法可以参考[SUSE Linux Enterprise Server 11 SP4 AutoYaST](https://www.suse.com/documentation/sles11/singlehtml/book_autoyast/book_autoyast.html)，[openSUSE Leap 42.3 AutoYaST](https://doc.opensuse.org/projects/autoyast/)。
redhat kickstart可以参考[CHAPTER 31. KICKSTART INSTALLATIONS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/ch-kickstart2)

下面从几个方面比较kiwi，virt-builder和terraform

可以在哪些平台上build
---------------------
可以看到terraform支持的平台是最多的，如果有在windows或os x上build image的需求，只有选择terraform。
supported host | kiwi | virt-builder |  terraform
-------------------------------------------------
sle            | Yes  |    Yes       |     Yes
opensuse       | Yes  |    Yes       |     Yes
rhel           | No   |    Yes       |     Yes
centos         | No   |    Yes       |     Yes
fedora         | Yes  |    Yes       |     Yes
debian         | No   |    ?         |     Yes
os x           | No   |    No        |     Yes
windows        | No   |    No        |     Yes

注：
1.  sle: SUSE Liux Enterprise
2.  rhel: Redhat Enterprise Linux
3.  terraform还支持FreeBSD, OpenBSD和Solaris。

build的image可以用于哪些平台
----------------------------
这个回合kiwi胜出，如果希望build的image在物理机和虚拟机都可以部署，可以选择kiwi。这尤其适合开发或简单测试在虚拟机中测试，产品测试和实际部署需要在物理机的情况。
supported target | kiwi | virt-builder |  terraform
----------------------------------------------------
Physical machine |  Yes |   No         |     No
Virtual machine  |  Yes |   Yes        |     Yes
Docker           |  Yes |   Yes        |     Yes

注：terraform文档中提到可以支持部署到物理机，但是根据[github上的官方回复](https://github.com/hashicorp/terraform/issues/50)，目前并不支持。笔者也没看到支持的计划。

支持哪些hypervisor
------------------
terraform构建的镜像可以通过vagrant这个命令行工具下载和管理虚拟机。由于支持virtualbox，所以如果希望在os x运行制作的镜像，只能选择terraform/vagrant这个组合。多说一句其实os x现在可以支持kvm了<https://github.com/kholia/OSX-KVM>。
supported hypervior | kiwi | virt-builder |  vagrant
----------------------------------------------------
KVM                 |  Yes |   Yes        |     Yes
Xen                 |  Yes |   Yes        |     Yes
VirtualBox          |  Yes |   No         |     No

支持哪些发行版
--------------
可以看出对于常用发行版kiwi支持的最全。
supported Distribution | kiwi | virt-builder |  vagrant box
----------------------------------------------------
sle            | Yes  |    No        |     Partial\*
opensuse       | Yes  |    Partial\* |     Yes
rhel           | Yes  |    Yes       |     Yes
centos         | Yes  |    Yes       |     Yes
fedora         | Yes  |    Yes       |     Yes
debian         | Yes  |    Yes       |     Yes
mageia         | Yes  |    Yes       |     Yes
ubuntu         | Yes  |    Yes       |     Yes
cirros         | No   |    Yes       |     No
freebsd        | No   |    Yes       |     Yes
scientificlinux| Should\*| Partial\* |     Yes

注：
1.  virt-builder支持的具体发行版版本可以通过`virt-builder --list`查看。
2.  virt-builder不支持opensuse leap最新的42.3。virt-builder不支持scientificlinux 7。
3.  terraform构建的镜像可以通过vagrant启动。vagrant box目前没有sle最新的12 sp4。
4.  scientificlinux使用yum作为包管理器，kiwi支持yum这种包管理器，道理上可以支持scientificlinux

注：
1.  sle: SUSE Liux Enterprise
2.  rhel: Redhat Enterprise Linux

实操：下载并使用kiwi的镜像
--------------------------

实操：下载并使用vagrant镜像
--------------------------

