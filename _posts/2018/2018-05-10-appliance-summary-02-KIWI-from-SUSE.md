---
layout: post
title: 比较操作系统镜像制作方式（Linux自动化部署工具系列之二）
categories: [Software]
tags: [Linux, kiwi]
---

上回书说到我们选择suse的kiwi作为操作系统镜像制作工具，本文具体比较三种定制镜像工具：KIWI，virt-builder和terraform。并给出简单的kiwi使用例子。

镜像制作和部署工具选型建议
--------------------------
*   如果需要支持物理机部署，只能选择KIWI；
*   如果部署镜像时需要额外定制，只能选择terraform。
*   如果单纯在虚拟化环境使用，希望一个stardalone的环境快速构建虚拟机镜像的方式，可以选择virt-builder。

镜像制作和部署工具详细比较
----------------------
### **可以在哪些平台上build**
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

### **Build的image可以用于哪些平台**
这个回合kiwi胜出，如果希望image在物理机和虚拟机都可以部署，只能选择kiwi。本文最后有KIWI的使用方法简介，供参考。这尤其适合笔者开发或简单测试在虚拟机中测试，产品测试和实际部署需要在物理机的情况。

Supported target | kiwi | virt-builder |  terraform
-----------------|------|--------------|------------
Physical machine |  Yes |   No         |     No
Virtual machine  |  Yes |   Yes        |     Yes
Docker           |  Yes |   Yes        |     Yes

注：Terraform文档中提到可以支持部署到物理机，但是根据[github上的官方回复](https://github.com/hashicorp/terraform/issues/50)，目前并不支持。笔者也没看到支持的计划。

### **支持哪些hypervisor**
KIWI和Terraform同时支持Virtualbox，相比之下Terraform构建的镜像可以通过vagrant这个命令行工具下载，配置和管理虚拟机：

Supported hypervior | kiwi | virt-builder |  vagrant
--------------------|------|--------------|----------
KVM                 |  Yes |   Yes        |     Yes
Xen                 |  Yes |   Yes        |     Yes
VirtualBox          |  Yes |   No         |     Yes

### **build出的镜像可以用于哪些发行版**
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
1.  SUSE studio express: https://studioexpress.opensuse.org/
2.  KIWI template: https://build.opensuse.org/image_templates
3.  kiwi文档
    1.  <https://suse.github.io/kiwi/overview.html>
    2.  <https://doc.opensuse.org/projects/kiwi/doc/>
4.  kiwi上传镜像到google: <https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images>

