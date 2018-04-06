---
layout: post
title: 比较操作系统镜像制作方式
categories: [Software]
tags: [Linux, kiwi]
---

打包或制作镜像是个很广的话题，为了能够高效的快速的把业务系统运行起来，从部署整个操作系统的ghost镜像，到轻量级的虚拟化（容器）再到更轻的unikernel等应用打包方式有很多选择。最近重度使用了操作系统的一些镜像制作方式，可以在物理机，虚拟机和容器（系统容器）中使用。
我的需求是在特定环境部署物理机或虚拟机，系统在一键部署后直接可用。想达到这个目的，我看到三个思路
1.  定制镜像，部署时直接把镜像写到硬盘，系统启动后直接可以使用；
2.  通过配置文件，把原本需要手工干预的操作系统安装过程自动完成；
3.  基于一个已部署的默认系统，使用自动化部署工具配置环境。

方法1（下文称为定制镜像）和2（下文称为自动安装）可以和方法3联合使用。设想一下，如果多个业务系统需要统一的定制的操作系统，但是这个操作系统不同于默认安装，有些配置需要修改，有些软件需要安装。我们可以通过前两个方法安装后，使用方法3部署特定的业务系统。当然也有人[比较这两个思路的优劣](https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c)[1]，文中提到了[Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)[2]，分析思路值得看看，作者推荐的terraform是方法1和3的结合，这是本文重点比较的方法之一。

方法3的自动化部署工具很多，例如Ansible, Chef, Fabric，Puppe, SaltStack。。。有些很轻，适合部署几台机器；有些需要在目标机器安装daemon，即使网络暂时中断也不影响部署。这也是比较广的话题，笔者最近在学习Fabric和Ansible，将来有机会会分享这方面的话题。本系列文章聚焦在定制镜像，计划专门分享下我自己用过的几个镜像打包工具，并做出比较，方便小伙伴们选择。系列分三部分：
*   介绍和比较各种镜像打包工具，并举例说明如何使用制作的镜像（本文）；
*   介绍SUSE的KIWI，功能强大，极为推荐；
*   介绍其它镜像打包方式：包括terraform和vagrant，virt-builder等。

具体说来，定制镜像和自动安装在各发行版的部署方式里面都有介绍，关系如下图：
<img alt="applicace_comparision.png" src="{{site.url}}/public/images/appliance/applicace_comparision.png" width="100%" align="center" style="margin: 0px 15px">

定制镜像常通过一个配置文件，配置bootloader，安装源（光盘，网络repo均可）和要安装哪些包，制作镜像时需要从安装源下载软件并安装到磁盘镜像中，使用时通过系统支持的引导方式（pxe，光盘启动）启动后部署或直接写入硬盘的方式写入目标机器（物理机，虚拟机或容器）。可以看出这个过程只有制作镜像时的软件包下载和安装是软件包管理方式相关，并不绑体发行版，所以这类工具通常很容易支持多种发行版。相比之下，自动安装需要干预安装过程，每个发行版有自己的安装生序，上面列出的autoyast和kiwistart都只支持特定的发行版。自动安装通常的场景是有几台机器需要选择相同的安装选项，软件包，配置文件，或安装后简单的自定义设置。管理员先手工安装第一台机器，安装后目标机器会带有autoyast或kickstart的配置文件（默认在root目录下: suse/opensuse "/root/\*.xml", redhat: "/root/anaconda-ks.cfg"），管理员调整这个配置文件后，使用这个配置文件安装其余几台机器。SUSE的autoyast使用方法可以参考[SUSE Linux Enterprise Server 11 SP4 AutoYaST](https://www.suse.com/documentation/sles11/singlehtml/book_autoyast/book_autoyast.html)，[openSUSE Leap 42.3 AutoYaST](https://doc.opensuse.org/projects/autoyast/)。Redhat kickstart可以参考[CHAPTER 31. KICKSTART INSTALLATIONS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/installation_guide/ch-kickstart2)

综述结束，下面具体比较三种定制镜像的方法：KIWI，virt-builder和terraform。对于这三种方法来说，一句话选型建议是：
*   如果需要支持物理机部署，只能选择kiwi；
*   如果部署镜像时需要额外定制，只能选择terraform。
*   如果单纯在虚拟化环境使用，希望一个stardalone快速构建虚拟机镜像的方式，可以选择virt-builder。

可以在哪些平台上build
---------------------
Terraform支持的平台是最多的，如果有在windows或os x上build image的需求，只有选择terraform。

supported host | kiwi | virt-builder |  terraform
---------------|------|--------------|-----------
sle            | Yes  |    Yes       |     Yes[3]
opensuse       | Yes  |    Yes       |     Yes[3]
rhel           | No   |    Yes       |     Yes[3]
centos         | No   |    Yes       |     Yes[3]
fedora         | Yes  |    Yes       |     Yes[3]
debian         | No   |    ?         |     Yes[3]
os x           | No   |    No        |     Yes
windows        | No   |    No        |     Yes

注：
1.  sle: SUSE Liux Enterprise
2.  rhel: Redhat Enterprise Linux
3.  Terraform针对Linux系统发布静态二进制包，与发行版无关，道理上讲对内核版本（主要是系统调用）有依赖，不过从terraform功能上看，只会用比较常见的系统调用，估计目前发行版提供的内核都可以。Terraform还支持FreeBSD, OpenBSD和Solaris。

Build的image可以用于哪些平台
----------------------------
这个回合kiwi胜出，如果希望image在物理机和虚拟机都可以部署，只能选择kiwi。本文最后有KIWI的使用方法简介，供参考。这尤其适合笔者开发或简单测试在虚拟机中测试，产品测试和实际部署需要在物理机的情况。

Supported target | kiwi | virt-builder |  terraform
-----------------|------|--------------|------------
Physical machine |  Yes |   No         |     No
Virtual machine  |  Yes |   Yes        |     Yes
Docker           |  Yes |   Yes        |     Yes

注：Terraform文档中提到可以支持部署到物理机，但是根据[github上的官方回复](https://github.com/hashicorp/terraform/issues/50)，目前并不支持。笔者也没看到支持的计划。

支持哪些hypervisor
------------------
Terraform构建的镜像可以通过vagrant这个命令行工具下载和管理虚拟机。kiwi和vagrant同时支持Virtualbox，相比之下vagrant有镜像启动时的配置文件可以在启动虚拟机时在做一些定制，灵活灵更强，多说一句其实os x现在可以支持kvm了<https://github.com/kholia/OSX-KVM>，所以道理上讲kvm的镜像也可以用在os x上，如果是这样的话，virt-builder构建出的镜像也可以用于os x。但os x kvm毕竟不是默认可用的，暂时不考虑。

Supported hypervior | kiwi | virt-builder |  vagrant
--------------------|------|--------------|----------
KVM                 |  Yes |   Yes        |     Yes
Xen                 |  Yes |   Yes        |     Yes
VirtualBox          |  Yes |   No         |     Yes

build出的镜像可以用于哪些发行版
--------------
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
例如上图，选择了openSUSE42.3 virtualbox镜像，镜像名称是"openSUSE-Leap-42.3-JeOS-for-VirtualBox"。单击"Create appliance"按钮会，会自动建立出名为: https://build.opensuse.org/project/show/home:USERNAME:branches:openSUSE:Templates:Images:42.3 的分支，如下图：
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
    6.  这个镜像打开了firstboot。可以删除如下内容关闭。TODO构建镜像失败，本地搭建环境构建。可以在下面[链接](https://build.opensuse.org/package/rdiff/home:bjzhang:branches:openSUSE:Templates:Images:42.3/openSUSE-Leap-42.3-JeOS-for-VirtualBox?linkrev=base&rev=2)[5]查看如何关闭firstboot，修改"openSUSE-Leap-42.3-JeOS-for-VirtualBox.kiwi"：
	```
	@@ -74,7 +74,6 @@
			 <package name="fipscheck"/>
			 <package name="grub2-branding-openSUSE" bootinclude="true"/>
			 <package name="iputils"/>
	-        <package name="jeos-firstboot"/>
			 <package name="vim"/>
			 <package name="gettext-runtime"/>
			 <package name="shim" arch="x86_64"/>
	```

链接
---
1.  Why we use Terraform and not Chef, Puppet, Ansible, SaltStack, or CloudFormation: https://blog.gruntwork.io/why-we-use-terraform-and-not-chef-puppet-ansible-saltstack-or-cloudformation-7989dad2865c
2.  Infrastructure as Code: https://en.wikipedia.org/wiki/Infrastructure_as_Code
3.  SUSE studio express: https://studioexpress.opensuse.org/
4.  KIWI template: https://build.opensuse.org/image_templates
5.	关闭firstboot: https://build.opensuse.org/package/rdiff/home:bjzhang:branches:openSUSE:Templates:Images:42.3/openSUSE-Leap-42.3-JeOS-for-VirtualBox?linkrev=base&rev=2

