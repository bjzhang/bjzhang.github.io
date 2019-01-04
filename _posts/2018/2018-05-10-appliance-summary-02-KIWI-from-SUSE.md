# 比较操作系统镜像制作方式（Linux自动化部署工具系列之二）

这是《Linux自动化部署工具》系列的第二篇。上一篇《Linux自动化部署工具综述》介绍了三类自动化部署工具：
</Users/bamvor/works/source/bjzhang.github.io/public/images/appliance/applicace_comparision_cover.png>
本文具体比较第一类工具中的三种：KIWI，virt-builder和terraform。最后以KIWI为例说明从镜像构建到部署的基本流程。

类似的部署工具还有Canonical的MAAS和Juju，笔者未使用过，不班门弄斧了此外Openstack的文档提到了包括kiwi和virt-builder在内的多种工具，感兴趣的话可以参考文末的参考链接[1]。

镜像制作和部署工具一句话选型建议
--------------------------------
*   如果需要支持物理机部署，建议选择KIWI；
*   如果部署镜像时需要更灵活通用的虚拟机配置和管理，建议选择Terraform+Vagrant。
*   如果单纯在虚拟化环境使用，可以选择virt-builder。

镜像制作和部署工具详细比较
----------------------
### **支持哪些Host**
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

### **镜像是否支持物理机**
这个回合kiwi胜出，如果希望image在物理机和虚拟机都可以部署，建议选择kiwi。这尤其适合开发或基本测试在虚拟机中测试，产品测试和实际部署需要在物理机的情况。

Supported target | kiwi | virt-builder |  terraform
-----------------|------|--------------|------------
Physical machine |  Yes |   No         |     No
Virtual machine  |  Yes |   Yes        |     Yes
Docker           |  Yes |   Yes        |     Yes

注：Terraform文档中提到可以支持部署到物理机，但是根据[github上的官方回复](https://github.com/hashicorp/terraform/issues/50)，目前并不支持。笔者也没看到支持的计划。

### **支持哪些hypervisor**
KIWI和Terraform同时支持Virtualbox。如果像笔者一样希望在Linux，OS
X(Macbook)和Windows使用同样的开发环境，这两个工具都可以考虑。此外，Terraform构建的镜像可以通过vagrant这个命令行工具下载镜像，配置和管理虚拟机，如果创建虚拟机前需要修改虚拟机配置文件，或启动虚拟机后需要运行自定义脚本，使用terraform和vagrant组合比较方便。

Supported hypervior | kiwi | virt-builder |  vagrant
--------------------|------|--------------|----------
KVM                 |  Yes |   Yes        |     Yes
Xen                 |  Yes |   Yes        |     Yes
VirtualBox          |  Yes |   No         |     Yes

### **镜像支持哪些发行版**
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
1.  [KIWI支持的发行版列表](https://suse.github.io/kiwi/building.html#supported-distributions)
2.  virt-builder支持的具体发行版版本可以通过`virt-builder --list`查看；virt-builder不支持opensuse leap最新的42.3。virt-builder不支持scientificlinux 7。
3.  terraform构建的镜像可以通过vagrant启动。vagrant box目前没有sle最新的12 sp4。
4.  scientificlinux使用yum作为包管理器，kiwi支持yum这种包管理器，道理上可以支持scientificlinux

从镜像构建到使用的基本过程
--------------------------
### **构建镜像**
kiwi本身是个单机工具。考虑到搭建kiwi构建环境对于初学者有些复杂，笔者将在下一篇详述。这里为了简单直接使用opensuse的build service，在云端构建我们所需的镜像。

在[网站](https://build.opensuse.org/image_templates)免费注册登陆，可以看到目前支持最新的openSUSE 42.3和最新企业版SLES12 SP3，构建出的镜像可以使用在AWS, Openstack，Docker，KVM，XEN和VirtualBox等环境（参见下图）： 
<img alt="public/images/cloud/applicance_kiwi__obs__choose_base_template_01.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__choose_base_template_01.png" width="100%" align="center" style="margin: 0px 15px">
<img alt="public/images/cloud/applicance_kiwi__obs__choose_base_template_02.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__choose_base_template_02.png" width="100%" align="center" style="margin: 0px 15px">
上图选择了openSUSE42.3 virtualbox镜像，镜像名称是”openSUSE-Leap-42.3-JeOS-for-VirtualBox”。单击”Create appliance”按钮会自动建立分支"home:USERNAME:branches:openSUSE:Templates:Images:42.3"：
<img alt="public/images/cloud/applicance_kiwi__obs__template_created.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__template_created.png" width="100%" align="center" style="margin: 0px 15px">
上图中的Packages(不论rpm包还是操作系统打包的镜像，对于openSUSE build service来说都是包(package)) “openSUSE-Leap-42.3-JeOS-for-VirtualBox”对应我们刚才自定义的镜像名称。如果我们定义了openSUSE 42.3的多个镜像，每个镜像对应以镜像名称命名package，**镜像名称不能重名**。仍然以我们刚刚建立的镜像为例，点击该package名称，进入详情界面：
<img alt="public/images/cloud/applicance_kiwi__obs__template_created__branch.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__obs__template_created__branch.png" width="100%" align="center" style="margin: 0px 15px">
**如前所述，需要为构建工具编写镜像配置文件，上图中，左侧的\*.kiwi和\*.sh分别是kiwi镜像配置文件和自定义脚本**，下一篇文章会介绍具体细节。上图右侧是镜像构建状态页面。由于我们选择的不是容器镜像，所以”container”的状态是”excluded”表示不会构建。当”images”显示如上图的”succeeded”时（根据服务器负载和镜像复杂程度可能需要10分钟或更长时间）说明镜像构建完成，即可下载。点击”images”文字，会进入下图的下载链接：
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
    4.  创建后可以根据需要调整设置（例如选择不同的网桥，调整cpu个数，内存大小，添加磁盘等等），此处不在赘述。 至此虚拟机创建完成，**可以看到需要用户手工选择一些信息，如果部署的机器多，希望自动完成，可以使用virtualbox自身的工具VBoxManage（详见参考链接[5]），也可以使用virsh(libvirt.org)。在后面的文章中，会介绍用vagrant管理（Terraform构建的）虚拟机。**
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__after_created.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__after_created.png" width="100%" align="center" style="margin: 0px 15px">
    5.  系统第一次启动会有一些检查和磁盘空间调整，速度稍慢一些，第二次启动会很快。Firstboot（首次启动配置）会提示选择语言，键盘布局等，选择默认即可。选择完成即可使用刚刚设置的root密码登陆。
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__booting_grub.png" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__booting_grub.png" width="100%" align="center" style="margin: 0px 15px">
<img alt="public/images/cloud/applicance_kiwi__virtualbox_installation__firstboot.gif" src="{{site.url}}/public/images/cloud/applicance_kiwi__virtualbox_installation__firstboot.gif" width="100%" align="center" style="margin: 0px 15px">

链接
*   openstack tools for image creation: <https://docs.openstack.org/image-guide/create-images-automatically.html>
*   Terraform对于不支持物理机部署的回复：<https://github.com/hashicorp/terraform/issues/50>
*   SUSE studio express: <https://studioexpress.opensuse.org/>
*   KIWI template: <https://build.opensuse.org/image_templates>
*   Virtualbox命令行工具VBoxManage： <https://www.virtualbox.org/manual/ch08.html>
*   kiwi文档
    -   <https://suse.github.io/kiwi/overview.html>
    -   <https://doc.opensuse.org/projects/kiwi/doc/>

你可能感兴趣的文章
------------------
这是本月的第二篇文章。半瓦平时有随手记笔记的习惯，公众号原创文章只分享自己有体会的信息，希望能促进价值信息流动。任何建议欢迎给我留言或添加我的微信（公众号回复“微信”，可以看到半瓦的微信）：
*   [春风吹又生----梳理中国CPU](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483744&idx=1&sn=c1e047036062dd97aae70cd8d6682f41&chksm=ec6cb74cdb1b3e5a9a21be4b24519a125e071461c02fb4e962c839e2647824ffd313d542b9ae&scene=21#wechat_redirect)
*   [Linux自动化部署工具综述](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483755&idx=1&sn=ce1aaa72e0cc2d1933c9ed8002ab96da&chksm=ec6cb747db1b3e51ee9b56f9c8e3fa10f879d97e5a0b17da0dbbb51b48b8fead0adaff64d9a4&scene=21#wechat_redirect)
*   [ARM生态系统的盛会Linaro connect（之一）：arm64 server和端侧AI](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483722&idx=1&sn=6f4ab00336e1beb589388be5fdc8e34c&chksm=ec6cb766db1b3e70995205ec548ed120b7c4fc3d21e513ae744641966341886a77aa7482a6fd&scene=21#wechat_redirect)
*   [ARM生态系统的盛会Linaro connect（之二）：arm64 workstation和低成本调试工具](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483723&idx=1&sn=87296941e308d5d5e427b632483fd45f&chksm=ec6cb767db1b3e711bee73b95078dc1114721cab6112cc0626d6298103e40e3497702164bf2b&scene=21#wechat_redirect)
*   [内核测试小整理](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483731&idx=1&sn=e2bb2be181cf85d219fcedb58d4dafe4&chksm=ec6cb77fdb1b3e696586dc6f9f7d5ff11cc35f989f9630c127800db2eb2ee03e4f29bdc82e2f&scene=21#wechat_redirect)

本文首发本人公众号[《敏达生活》](https://mp.weixin.qq.com/s/HceY0Jp9iB-PVafJMnMjsQ)，欢迎拍砖，勾搭，关注:)

