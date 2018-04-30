---
layout: post
title: 比较操作系统镜像制作方式
categories: [Software]
tags: [Linux, kiwi]
---

手工安装Linux很繁琐，生产环境通常会自动完成这一步骤。笔者前段时间正好有在封闭场景自动化部署的需求，调研发现有多种自动化方式可供选择，但很少有文章把Linux自动安装的方式都说全，给出选型建议。使用KIWI实际制作镜像并部署时，发现KIWI英文文档和论文比较丰富，中文资料却很简单。故写文章分享调研过程和实际踩坑体会，计划专门分享下我自己用过的几个镜像打包工具，并做出比较。方便小伙伴们选择。系列分三部分：
*   介绍和比较各种镜像打包工具，并举例说明如何构建和使用镜像（本文）；
*   介绍SUSE的KIWI，功能强大，极为推荐；
*   介绍其它镜像打包方式：包括terraform和vagrant，virt-builder等。

一键部署有哪些方法
------------------
暂时回到一个更原始的问题，和操作系统定制镜像类似的还有什么方法？

“不要只想着造一个更快的马车”。

笔者的需求是在特定环境部署物理机或虚拟机，系统在一键部署后直接可用。想达到这个目的，经过调研看到三个思路：
1.  定制镜像，部署时直接把镜像写到硬盘，系统启动后直接可以使用；
2.  通过配置文件，把原本需要手工干预的操作系统安装过程自动完成；
3.  基于一个已部署的默认系统，使用自动化部署工具配置环境。

方法1（下文称为定制镜像）和2（下文称为自动安装）可以和方法3联合使用。设想一下，如果多个业务系统需要统一的定制的操作系统，但是这个操作系统不同于默认安装，有些配置需要修改，有些软件需要安装。我们可以通过前两个方法安装后，使用方法3部署特定的业务系统。当然也有人[比较这两个思路的优劣](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)[1]，文中提到了[Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)[2]，分析思路值得看看，作者推荐的terraform是方法1和3的结合，这是本文重点比较的方法之一。

方法3的自动化部署工具很多，例如Ansible, Chef, Fabric，Puppe, SaltStack。。。有些很轻，适合部署几台机器；有些需要在目标机器安装daemon，即使网络暂时中断也不影响部署。这也是比较广的话题，笔者最近在学习Fabric和Ansible，将来有机会会分享这方面的话题。

具体说来，定制镜像和自动安装在各发行版的部署方式里面都有介绍，关系如下图：
<img alt="applicace_comparision.png" src="{{site.url}}/public/images/appliance/applicace_comparision.png" width="100%" align="center" style="margin: 0px 15px">

回忆一下自己手工安装一个Linux系统，需要选择安装设置和安装后的系统配置，发挥余地很大同时也消耗大量精力：
<img alt="public/images/appliance/Linux_distribution_installation.png" src="{{site.url}}/public/images/appliance/Linux_distribution_installation.png" width="100%" align="center" style="margin: 0px 15px">

如果用户需要在相似的硬件上部署相同的系统，可以采用操作系统提供的自动安装方式，一次选择多次安装。由于与安装程序绑定，不同发行版有不同的自动安装方法：SUSE的autoyast使用方法可以参考[SUSE Linux Enterprise Server 12 SP2 AutoYaST](https://www.suse.com/documentation/sles-12/book_autoyast/data/book_autoyast.html)，[openSUSE Leap 42.3 AutoYaST](https://doc.opensuse.org/projects/autoyast/)。Redhat kickstart可以参考[CHAPTER 31. KICKSTART INSTALLATIONS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/ch-kickstart2)。

虽然自动安装不需要人为操作，但是仍然是一步一步安装的（例如安装了500个软件包，每个包都要单独安装，看着进度条慢慢走。。。），安装时间本身并没有显著缩短。如果能够一次把需要安装的软件都安装好，制作成镜像，部署时直接把定制的好镜像写入系统硬盘。例如KIWI这个镜像制作工具，通过用户给出的镜像描述文件(image description)，从给定的安装源(package source)下载包并安装到目录(unpacked image)，安装完成后，根据用户要求的镜像格式制作生成镜像(packed image)：
<img alt="public/images/appliance/kiwi_image_creation_architecture.png" src="{{site.url}}/public/images/appliance/kiwi_image_creation_architecture.png" width="100%" align="center" style="margin: 0px 15px">

制作好的镜像可以快速的部署到目标环境中。

镜像制作和部署工具选型建议
--------------------------
本文具体比较三种定制镜像工具：KIWI，virt-builder和terraform，一句话选型建议：
*   如果需要支持物理机部署，只能选择KIWI；
*   如果部署镜像时需要额外定制，只能选择terraform。
*   如果单纯在虚拟化环境使用，希望一个stardalone的环境快速构建虚拟机镜像的方式，可以选择virt-builder。

镜像制作和部署工具详细比较
----------------------
### 可以在哪些平台上build
Terraform支持的平台是最多的，如果有在Windows或macOS上build image的需求，只有选择terraform。

supported host | kiwi | virt-builder |  terraform
---------------|------|--------------|-----------
SLE            | Yes  |    Yes       |     Yes[3]
openSUSE       | Yes  |    Yes       |     Yes[3]
RHEL           | No   |    Yes       |     Yes[3]
Centos         | No   |    Yes       |     Yes[3]
Fedora         | Yes  |    Yes       |     Yes[3]
Debian         | No   |    ?         |     Yes[3]
macOS          | No   |    No        |     Yes
Windows        | No   |    No        |     Yes

注：
1.  SLE: SUSE Liux Enterprise
2.  RHEL: Redhat Enterprise Linux
3.  Terraform针对Linux系统发布静态二进制包，与发行版无关，道理上讲对内核版本（主要是系统调用）有依赖，不过从terraform功能上看，只会用比较常见的系统调用，估计目前发行版提供的内核都可以。Terraform还支持FreeBSD, OpenBSD和Solaris。

### Build的image可以用于哪些平台
这个回合kiwi胜出，如果希望image在物理机和虚拟机都可以部署，只能选择kiwi。本文最后有KIWI的使用方法简介，供参考。这尤其适合笔者开发或简单测试在虚拟机中测试，产品测试和实际部署需要在物理机的情况。

Supported target | kiwi | virt-builder |  terraform
-----------------|------|--------------|------------
Physical machine |  Yes |   No         |     No
Virtual machine  |  Yes |   Yes        |     Yes
Docker           |  Yes |   Yes        |     Yes

注：Terraform文档中提到可以支持部署到物理机，但是根据[github上的官方回复](https://github.com/hashicorp/terraform/issues/50)，目前并不支持。笔者也没看到支持的计划。

### 支持哪些hypervisor
KIWI和Terraform同时支持Virtualbox，相比之下Terraform构建的镜像可以通过vagrant这个命令行工具下载，配置和管理虚拟机：

Supported hypervior | kiwi | virt-builder |  vagrant
--------------------|------|--------------|----------
KVM                 |  Yes |   Yes        |     Yes
Xen                 |  Yes |   Yes        |     Yes
VirtualBox          |  Yes |   No         |     Yes

### build出的镜像可以用于哪些发行版
可以看出对于常用发行版kiwi支持的最全。

Supported Distribution | kiwi | virt-builder |  vagrant box
---------------|------|--------------|--------------
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
1.  KIWI支持的发行版，详见: <https://suse.github.io/kiwi/building.html#supported-distributions>
2.  virt-builder支持的具体发行版版本可以通过`virt-builder --list`查看；virt-builder不支持opensuse leap最新的42.3。virt-builder不支持scientificlinux 7。
3.  terraform构建的镜像可以通过vagrant启动。vagrant box目前没有sle最新的12 sp4。
4.  scientificlinux使用yum作为包管理器，kiwi支持yum这种包管理器，道理上可以支持scientificlinux

KIWI镜像快速使用：openSUSE 42.3 VirtualBox
------------------------------------------
### **build(构建)镜像**
可以从[suse studio express](https://studioexpress.opensuse.org/)找到目前支持的[模板](https://build.opensuse.org/image_templates)选择并下载。从下面两张图可以看到目前支持最新的openSUSE 42.3和最新企业版SLES12 SP3，构建出的镜像可以使用在AWS, Openstack，Docker，KVM，XEN和VirtualBox等环境。
<img alt="public/images/cloud/applicance_kiwi__obs__choose_base_template_01.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__choose_base_template_01.png" width="100%" align="center" style="margin: 0px 15px">
<img alt="public/images/cloud/applicance_kiwi__obs__choose_base_template_02.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__choose_base_template_02.png" width="100%" align="center" style="margin: 0px 15px">
例如上图，选择了openSUSE42.3 virtualbox镜像，镜像名称是"openSUSE-Leap-42.3-JeOS-for-VirtualBox"。单击"Create appliance"按钮会自动建立分支[home:USERNAME:branches:openSUSE:Templates:Images:42.3](https://build.opensuse.org/project/show/home:USERNAME:branches:openSUSE:Templates:Images:42.3)：
<img alt="public/images/cloud/applicance_kiwi__obs__template_created.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__template_created.png" width="100%" align="center" style="margin: 0px 15px">
上图中的Packages(不论rpm包还是操作系统打包的镜像，对于openSUSE build service来说都是包(package)) "openSUSE-Leap-42.3-JeOS-for-VirtualBox"对应我们刚才自定义的镜像名称。如果我们定义了openSUSE 42.3的多个镜像，每个镜像对应以镜像名称命名package，所以镜像名称不能重名。仍然以我们刚刚建立的镜像为例，点击该package名称，进入详情界面：
<img alt="public/images/cloud/applicance_kiwi__obs__template_created__branch.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__template_created__branch.png" width="100%" align="center" style="margin: 0px 15px">
上图中，左侧是源代码（对于kiwi就是kiwi的配置文件和自定义脚本）。镜像的定制通过这些文件完成，篇幅所限不在赘述。在下一篇文章中，会介绍如何添加软件源，添加自己的软件包，修改系统配置文件等具体定制方法。右侧是镜像构建状态页面。由于我们选择的不是容器镜像，所以"container"的状态是"excluded"表示不会构建。当"images"显示如上图的"succeeded"时（根据服务器负载和镜像复杂程度可能需要10分钟或更长时间）说明镜像构建完成，即可下载。点击"images"文字，会进入下图的下载链接：
<img alt="public/images/cloud/applicance_kiwi__obs__template_download_site.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__template_download_site.png" width="100%" align="center" style="margin: 0px 15px">
下载图中""openSUSE-Leap-42.3-JeOS-for-VirtualBox.x86_64-1.1.1-Build1.1.vmdk""（virtualbox的磁盘镜像），并使用"openSUSE-Leap-42.3-JeOS-for-VirtualBox.x86_64-1.1.1-Build1.1.vmdk.sha256"校验。

### 启动VirtualBox虚拟机
这里以Macbook的VirtualBox为例，Windows和Linux操作类似。

1.  单击下图中蓝色的新建按钮
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__create.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__create.png" width="100%" align="center" style="margin: 0px 15px">
2.  选择我们刚刚在build service上构建出的镜像
    1.  选择"使用已有的虚拟硬盘文件"，并单击右下角的文件夹图标：
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__import_existed_disk.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__import_existed_disk.png" width="100%" align="center" style="margin: 0px 15px">
    2.  选择我们刚刚下载的文件。
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__select_disk.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__select_disk.png" width="100%" align="center" style="margin: 0px 15px">
    3.  自定义虚拟机名称，选择发行版为openSUSE 64bit，设置内存大小。单击创建即可创建虚拟机：
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__set_name_and_so_on__click_create.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__set_name_and_so_on__click_create.png" width="100%" align="center" style="margin: 0px 15px">
    4.  创建后可以根据需要调整设置（例如选择不同的网桥，调整cpu个数，内存大小，添加磁盘等等），此处不在赘述。
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__after_created.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__after_created.png" width="100%" align="center" style="margin: 0px 15px">
    5.  系统第一次启动会有一些检查和磁盘空间调整，速度稍慢一些，第二次启动会很快。Firstboot（首次启动配置）会提示选择语言，键盘布局等，选择默认即可。选择完成即可使用刚刚设置的root密码登陆。
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__booting_grub.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__booting_grub.png" width="100%" align="center" style="margin: 0px 15px">
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__firstboot.gif" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__firstboot.gif" width="100%" align="center" style="margin: 0px 15px">

链接
---
1.  Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation: https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
2.  Infrastructure as Code: https://en.wikipedia.org/wiki/Infrastructure_as_Code
3.  SUSE studio express: https://studioexpress.opensuse.org/
4.  KIWI template: https://build.opensuse.org/image_templates
5.  kiwi文档
    1.  <https://suse.github.io/kiwi/overview.html>
    2.  <https://doc.opensuse.org/projects/kiwi/doc/>

