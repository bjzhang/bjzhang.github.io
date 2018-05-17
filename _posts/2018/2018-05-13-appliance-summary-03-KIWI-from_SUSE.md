---
layout: post
title: 来自suse的猕猴桃(KIWI)（Linux自动化部署工具之三）
categories: [Software]
tags: [Linux, appliance, SUSE/openSUSE, KIWI]
---

[上回书说到Linux镜像构建和部署工具的选型建议](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483757&idx=1&sn=aa7376cf5f752b4d66a93a8d2fc99c20&chksm=ec6cb741db1b3e57f1100a6670ea3ad4b7557aa5572745a52e128b03aed1893dab980485ac56#rd)：

- 如果需要支持物理机部署，建议选择KIWI；
- 如果部署镜像时需要更灵活通用的虚拟机配置和管理，建议选择Hashicorp家族（Terraform, Packer, Vagrant）。
- 如果单纯在虚拟化环境使用，可以选择virt-builder。

这次我们细说KIWI。半瓦的文字希望大家能读到不同的内容，不希望只是翻译或者简单重复已有资料。笔者先会说下为什么对KIWI情有独钟；再分享下自己学习KIWI的思路；最后切入KIWI使用细节。对前言不感兴趣的小伙伴可以直接拉到第一个标题👇

笔者在suse第一次用kiwi是给opensuse for arm做映像，觉得还是比较灵活易用的。后来去了华为，在arm64 uefi和acpi完善前，os的测试也用kiwi制作镜像。在海航工作期间，也有封闭场景使用过kiwi。这些跳坑经历促成了现在《Linux自动化部署工具》系列文章（[之一](https://mp.weixin.qq.com/s/9SjTy3Zl4Md4-kxBuoU5lw)，[之二](https://mp.weixin.qq.com/s/HceY0Jp9iB-PVafJMnMjsQ)）。

为什么要写KIWI呢？其实KIWI自身有详细的手册和google groups讨论组（见参考资料[1], [2]），但是中文资料比较少，网上中文材料基本说的都是kiwi不是最新的kiwi-ng，而且缺乏具体技巧。另一方面，对于没有操作系统定制经验的人，直接看手册和讨论组可能不得要领，甚至问题不知道怎么问。笔者试图按照自己跳坑经历和大家分享KIWI的使用：

* 上次已经分享了如何使用openSUSE build service构建和使用KIWI镜像。大家能看出来KIWI上手很容易。
* 本文的目标是回到初心：如何构建出自己所需的定制镜像。具体内容包括：如何自己搭建KIWI构建镜像的环境，如何通过修改KIWI配置文件和脚本定制镜像。这个过程忽略了物理机部署可能遇到的bios/uefi的问题，也没有解释KIWI如何调试。原因是物理机部署通常比较顺利；对于简单的镜像定制来说，并不需要更多的调试技巧。
* 如果按照本文的操作，自己觉得可以做出所需的镜像，但是逐渐觉得费时费力，那么就该看下一篇文章了。下一篇文章会介绍定制好的镜像如何部署到物理机。KIWI如何调试。如何提高构建的速度/效率。

本地构建KIWI镜像
--------------
上次使用openSUSE的build service构建镜像。如果仅仅为了构建镜像，不需要build service。kiwi-ng的命令行🔧是一个单机工具。下文说明如何用kiwi命令行工具构建镜像（下文无特殊说明时，kiwi代表kiwi-ng）。

KIWI构建需要安装kiwi命令和kiwi所需的配置文件，具体过程见参考资料[1]。这里分享笔者自己的脚本。该脚本可以通过ssh连接到openSUSE机器并构建KIWI镜像。可以对照官方文档看本脚本。脚本地址：<https://github.com/bjzhang/small_tools_collection/blob/master/appliance_helper/build_kiwi_image_remote.sh>

执行下面的脚本即可构建镜像：

```
build_kiwi_image_remote.sh kiwi_machine --appliance centos/x86_64/centos-07.0-JeOS
```

`build_kiwi_image_remote.sh`通过ssh登陆到`kiwi_machine`，并执行`build_kiwi_image.sh`。其中`kiwi_machine`是opensuse的机器（物理机，虚拟机`build_kiwi_image_remote.sh`不支持容器）。"--appliance"表示具体使用的配置文件，上述参数可以构建centos 7.0的最小系统。`build_kiwi_image.sh`做的工作包括：

1. 安装/更新kiwi命令；
2. 下载KIWI官方配置文件；
3. 构建前置条件检查；
4. 构建指定的镜像。

上述直接执行构建任务的是`kiwi-ng`命令，下文直接使用`kiwi-ng`命令讲解。kiwi description是KIWI构建操作系统的配置文件，包含不同发行版（suse（包含SUSE和openSUSE），redhat，centos，debian）的模版，基于模版修改即可。实际的配置文件一般在第三层，例如"suse/x86_64/suse-leap-42.3-JeOS"表示suse发行版的x86_64架构的leap-42.3这个版本的最小系统（JeOS）。leap-42.3即openSUSE Leap42.3，是opensuse的最新版本。使用kiwi-ng命令指定目录即可构建对应的发行版，例如下面命令分别构建了opensuse42.3和centos7的镜像（由于墙的影响，发行版的测速不准确。故实际使用默认的配置文件时下载包的速度会比较慢，后文会给出国内源的例子）：

```
APPLIANCE=suse/x86_64/suse-leap-42.3-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```

```
APPLIANCE=centos/x86_64/centos-07.0-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```

构建成功后会输出镜像文件：

```
[ INFO    ]: 04:07:37 | Result files:
[ INFO    ]: 04:07:37 | --> disk_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.raw
[ INFO    ]: 04:07:37 | --> image_packages: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.packages
[ INFO    ]: 04:07:37 | --> image_verified: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.verified
[ INFO    ]: 04:07:37 | --> installation_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.install.iso
[ INFO    ]: 04:07:37 | Cleaning up BootImageDracut instance
```

其中*.raw是硬盘文件，可以直接dd到硬盘；install.iso是镜像安装光盘，把这张按照光盘像平时安装Linux一样插入光驱，选择Install再选择硬盘即可完成安装。此外构建之后要删除`—target-dir`，否则会提示：

```
[ INFO    ]: 03:53:22 | Setup root directory: /home/vagrant/works/software/kiwi/build/image-root
[ ERROR   ]: 03:53:22 | KiwiRootDirExists: Root directory /home/vagrant/works/software/kiwi/build/image-root already exists
[ INFO    ]: 03:53:22 | Cleaning up SystemPrepare instance
vagrant@os74:~/works/source/kiwi-descriptions> sudo rm -rf ~/works/software/kiwi/build/image-root
```

### 初识KIWI配置文件

基于上面的本地构建结果，我们可以通过修改KIWI的配置文件定制自己所需要的镜像。先来看看KIWI的配置文件包括哪些：

![kiwi-description-files](http://opuclx9sq.bkt.clouddn.com/2018-05-13-122330.png)

* `Dicefile`: 如果host是openSUSE，可以很容易的用Dicefile通过docker或vagrant构建kiwi镜像。由于笔者用的macbook，就不给大家演示了。感兴趣的小伙伴可以参考：<https://suse.github.io/kiwi/building/build_containerized.html>

* `config.sh`：kiwi定制脚本，在软件包安装后，可以通过config.sh对文件系统进行修改，config.sh后，会生成镜像。回忆下本系列第一篇文章[Linux自动化部署工具综述](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483755&idx=1&sn=ce1aaa72e0cc2d1933c9ed8002ab96da&scene=21#wechat_redirect)提到的镜像构建的过程，config.sh是在步骤1结束前运行的：

   <img src="http://opuclx9sq.bkt.clouddn.com/2018-05-13-123958.png" style="zoom:50%" />

* `leap-42.3-JeOS.kiwi` ，`config.xml`：kiwi的核心描述文件，包括

  * 系统描述
  * 镜像类型配置，镜像类型包括：
    * vmx：固定硬盘大小的镜像，一般部署到云中。
    * OEM expandable disk：首次时可以自动扩容的镜像，一般为了适配不同硬盘大小，制作一个根分区较小的镜像，在系统首次启动时，通过dracut脚本扩展根分区到磁盘的剩余空间。这种类似的格式比较灵活，可以使用卷方式（例如lvm，btrfs volume）建立分区，便于日后在线扩容。
    * live cd：光盘启动直接可用的系统，一般用于demo。
    * pxe：用于pxe启动并部署机器的场景。
    * docker：用于制作系统容器。
  * 软件源配置：可以配置优先级（`priority="1"`）和是否在镜像中包括（`imageinclude="true"`）
  * 软件包配置：软件包配置包括通用的软件包配置和与上述镜像类型特定的软件包配置。需要注意的是软件包的名称在不同发行版可能有差异。跨发行版复制config.xml时，这部分可能需要修改。

例说KIWI定制镜像
----------

前面提到，KIWI定制镜像的核心配置文件是config.xml，官方文档在：<https://suse.github.io/kiwi/development/schema.html>。请大家看了下面的子标题，先去看官方文档，再回来看本文。希望本文看完了，schema也看熟练了。

#### 修改或增加软件源

比如公司或学校内网有个镜像，可以这样修改config.xml

```
commit cafb99c233d958f01845eb8aa54f538783d709dd (HEAD -> kiwi_customization)
Author: Bamvor Zhang <bamv2005@gmail.com>
Date:   Sat Mar 10 10:31:27 2018 +0800

	examples: use tsinghua mirror instead of the default one

	Signed-off-by: Bamvor Zhang <bamv2005@gmail.com>

diff --git a/suse/x86_64/suse-leap-42.3-JeOS/config.xml b/suse/x86_64/suse-leap-42.3-JeOS/config.xml
index 0886cbc..7747b69 100644
--- a/suse/x86_64/suse-leap-42.3-JeOS/config.xml
+++ b/suse/x86_64/suse-leap-42.3-JeOS/config.xml
@@ -42,7 +42,7 @@
		 <source path="obs://Virtualization:Appliances:Builder/openSUSE_Leap_42.3"/>
	 </repository>
	 <repository type="rpm-md" alias="Leap_42_3" imageinclude="true">
-        <source path="obs://openSUSE:Leap:42.3/standard"/>
+        <source path="https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/42.3/repo/oss/"/>
	 </repository>
	 <packages type="image">
		 <package name="checkmedia"/>
```
比如想增加一个源，并且希望这个源在镜像中也有效，例如我希望测试最新社区内核（没有suse补丁）的某个特性，我可以这样修改；
```
commit c4c416c9884081ae5cc50bd8e77df50a60624e50 (HEAD -> kiwi_customization)
Author: Bamvor Zhang <bamv2005@gmail.com>
Date:   Sat Mar 10 10:57:57 2018 +0800

	examples: use lastest uptream kernel for kernel tester and low level user space development

	Signed-off-by: Bamvor Zhang <bamv2005@gmail.com>

diff --git a/suse/x86_64/suse-tumbleweed-JeOS/config.xml b/suse/x86_64/suse-tumbleweed-JeOS/config.xml
index 71c715a..55d7d77 100644
--- a/suse/x86_64/suse-tumbleweed-JeOS/config.xml
+++ b/suse/x86_64/suse-tumbleweed-JeOS/config.xml
@@ -29,6 +29,9 @@
	 <repository type="yast2" alias="Tumbleweed" imageinclude="true">
		 <source path="http://download.opensuse.org/tumbleweed/repo/oss"/>
	 </repository>
+    <repository type="yast2" alias="Kernel HEAD"  priority="2" imageinclude="true">
+        <source path="https://download.opensuse.org/repositories/Kernel:/HEAD/standard/"/>
+    </repository>
	 <packages type="image">
		 <package name="patterns-openSUSE-base"/>
		 <package name="plymouth-branding-openSUSE"/>
@@ -52,7 +55,7 @@
		 <package name="bash-completion"/>
		 <package name="dhcp-client"/>
		 <package name="which"/>
-        <package name="kernel-default"/>
+        <package name="kernel-vanilla"/>
		 <package name="timezone"/>
	 </packages>
	 <packages type="iso">
```

#### 增加软件包

比如我希望在centos7镜像里面加入docker命令，可以这样修改：

```
commit 219124102d731debc0544b4aa1772568104b9e5a (HEAD -> kiwi_customization)
Author: Bamvor Zhang <bamv2005@gmail.com>
Date:   Sat Mar 10 11:10:28 2018 +0800

    examples: add docker command in centos7 image

    Signed-off-by: Bamvor Zhang <bamv2005@gmail.com>

diff --git a/centos/x86_64/centos-07.0-JeOS/config.xml b/centos/x86_64/centos-07.0-JeOS/config.xml
index d1491f8..8df4692 100644
--- a/centos/x86_64/centos-07.0-JeOS/config.xml
+++ b/centos/x86_64/centos-07.0-JeOS/config.xml
@@ -51,6 +51,7 @@
         <package name="grub2"/>
         <package name="kernel"/>
         <package name="plymouth-theme-charge"/>
+        <package name="docker"/>
     </packages>
     <packages type="iso">
         <package name="dracut-kiwi-live"/>
```
### 增加二进制包

比如我一个第三方下载的软件，没有安装源，只有二进制，可以这样修改

```
<archive name="binaries.tar.gz"/>
```

#### 修改系统配置

上文提到kiwi description目录有个root目录，root目录的文件会覆盖步骤1中安装软件包之后的文件，例如我希望修改系统级的sysctl配置，可以增加文件`root/etc/sysctl.d/99-tidb.conf`，添加如下内容：

```
net.core.somaxconn = 32768
vm.swappiness = 0
net.ipv4.tcp_syncookies = 0
fs.file-max = 1000000
```

例如`fs.file-max`表示系统允许最大打开的文件数量是10万。下面我们修改config.sh时，修改的是名为tidb的用户的最大上限是10万。

#### 其它镜像定制要求

下面的config.sh片段是笔者使用kiwi准备TiDB部署环境的例子：

- 修改了tidb这个用户的limits，例如最大打开文件数量时10万个；
- 把TiDB二进制复制到指定目录；
- 创建并修改TiDB所需目录的权限。

```
echo "configure tidb"
deploy_user=tidb
echo "Configuration system and user limitation"
LIMITS_CONF="/etc/security/limits.conf"
echo "$deploy_user        soft        nofile        1000000" >> $LIMITS_CONF
echo "$deploy_user        hard        nofile        1000000" >> $LIMITS_CONF
echo "$deploy_user        soft        core          unlimited" >> $LIMITS_CONF
echo "$deploy_user        soft        stack         10240" >> $LIMITS_CONF
mv /binaries/tidb-v1.0.6-linux-amd64/bin/ /home/tidb/deploy
mkdir -p /home/tidb/deploy/log
chown tidb:tidb /home/tidb/deploy/log -R
mkdir -p /home/tidb/deploy/status
chown tidb:tidb /home/tidb/deploy/status -R
```

注：TiDB时新一代（NewSQL）与MYSQL兼容的分布式数据库，主要贡献公司是国内的创业公司Pincap（<https://www.pingcap.com/>），开发和使用社区都很活跃，github已经超过1万3千星。

KIWI参考资料
------------
1. [kiwi quick start](https://suse.github.io/kiwi/quickstart.html): <https://suse.github.io/kiwi/quickstart.html>
2. [google group](https://groups.google.com/forum/#!forum/kiwi-images): <https://groups.google.com/forum/#!forum/kiwi-images>
3. [YaST 映像创建程序是 KIWI 映像工具的图形界面](https://www.suse.com/zh-cn/documentation/sles-12/book_sle_deployment/data/cha_imgcreator.html): <https://www.suse.com/zh-cn/documentation/sles-12/book_sle_deployment/data/cha_imgcreator.html>
4. [kiwi-ng与legacy kiwi比较](https://suse.github.io/kiwi/overview/legacy_kiwi.html): <https://suse.github.io/kiwi/overview/legacy_kiwi.html>

## 你可能感兴趣的文章

这是本月的第三篇文章。半瓦平时有随手记笔记的习惯，公众号原创文章只分享自己有体会的信息，希望能促进价值信息流动。任何建议欢迎给我留言或添加我的微信（公众号回复“微信”，可以看到半瓦的微信）：

- [春风吹又生—-梳理中国CPU](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483744&idx=1&sn=c1e047036062dd97aae70cd8d6682f41&chksm=ec6cb74cdb1b3e5a9a21be4b24519a125e071461c02fb4e962c839e2647824ffd313d542b9ae&scene=21#wechat_redirect)
- [Linux自动化部署工具综述（Linux自动化部署工具系列之一）](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483755&idx=1&sn=ce1aaa72e0cc2d1933c9ed8002ab96da&chksm=ec6cb747db1b3e51ee9b56f9c8e3fa10f879d97e5a0b17da0dbbb51b48b8fead0adaff64d9a4&scene=21#wechat_redirect)
- [比较操作系统镜像制作方式（Linux自动化部署工具系列之二）](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483757&idx=1&sn=aa7376cf5f752b4d66a93a8d2fc99c20&scene=21#wechat_redirect)
- [ARM生态系统的盛会Linaro connect（之一）：arm64 server和端侧AI](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483722&idx=1&sn=6f4ab00336e1beb589388be5fdc8e34c&chksm=ec6cb766db1b3e70995205ec548ed120b7c4fc3d21e513ae744641966341886a77aa7482a6fd&scene=21#wechat_redirect)
- [ARM生态系统的盛会Linaro connect（之二）：arm64 workstation和低成本调试工具](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483723&idx=1&sn=87296941e308d5d5e427b632483fd45f&chksm=ec6cb767db1b3e711bee73b95078dc1114721cab6112cc0626d6298103e40e3497702164bf2b&scene=21#wechat_redirect)
- [内核测试小整理](http://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483731&idx=1&sn=e2bb2be181cf85d219fcedb58d4dafe4&chksm=ec6cb77fdb1b3e696586dc6f9f7d5ff11cc35f989f9630c127800db2eb2ee03e4f29bdc82e2f&scene=21#wechat_redirect)

本文首发本文公众号[《敏达生活》](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483760&idx=1&sn=0785ed74878b5ef27943bda7fc6f2c9f&chksm=ec6cb75cdb1b3e4a10a929940ad79c9dee77917730e3d80ef2fd0de48d8e336c397c081037a1#rd)，欢迎关注，拍砖，转发。

