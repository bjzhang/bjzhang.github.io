---
layout: post
title: 来自suse的猕猴桃(KIWI)（Linux自动化部署工具之三）
categories: [Software]
tags: [Linux, appliance, SUSE/openSUSE, KIWI]
---

复习一下[上次的选型建议](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483757&idx=1&sn=aa7376cf5f752b4d66a93a8d2fc99c20&chksm=ec6cb741db1b3e57f1100a6670ea3ad4b7557aa5572745a52e128b03aed1893dab980485ac56#rd)：

- 如果需要支持物理机部署，建议选择KIWI；
- 如果部署镜像时需要更灵活通用的虚拟机配置和管理，建议选择Terraform+Vagrant。
- 如果单纯在虚拟化环境使用，可以选择virt-builder。

笔者在suse第一次用kiwi是给opensuse for arm做映像，觉得还是比较灵活易用的。后来去了华为，在arm64 uefi和acpi完善前，os的测试也用kiwi制作镜像。在海航工作期间，也有封闭场景使用过kiwi。KIWI自身有详细的手册和google groups讨论组（链接见参考资料），但是中文资料比较少，网上中文材料基本说的都是kiwi不是最新的kiwi-ng，而且缺乏定制化细节。本文从搭建KIWI环境开始一步一步介绍KIWI使用技巧。

kiwi超快上手
--------------
上次使用openSUSE的build service构建镜像。如果仅仅为了构建镜像，不需要部署buildservice。kiwi-ng有单独的命令行🔧。下文说明如何用kiwi命令行工具构建镜像。

上次文章的末尾在opensuse build service上使用KIWI创建了一个openSUSE镜像，基于这个镜像执行下面的脚本即可构建镜像：

<https://github.com/bjzhang/small_tools_collection/blob/master/appliance_helper/build_kiwi_image_remote.sh>

`build_kiwi_image_remote.sh kiwi_machine --appliance centos/x86_64/centos-07.0-JeOS`

其中`remote_machine`是opensuse的机器，可以是上次构建的，也可以是自己安装的。这个命令可以构建centos 7.0的最小系统。`build_kiwi_image_remote.sh`通过ssh登陆到`kiwi_machine`，并执行`build_kiwi_image.sh`。`build_kiwi_image.sh`会更新kiwi并构建指定的镜像。直接执行构建任务的是`kiwi-ng`命令，下文直接使用`kiwi-ng`命令讲解。感兴趣的小伙伴可以看下`build_kiwi_image.sh`都做了哪些事情。

### 如何用命令行构建镜像

前面的`build_kiwi_image.sh`已经在`kiwi_machine`的`$HOME/works/source/virtualization/kiwi-descriptions`，clone了kiwi-description。kiwi description是KIWI构建操作系统的配置文件，包含不同发行版（suse（包含SUSE和openSUSE），redhat，centos，debian）的模版，基于模版修改即可。实际的配置文件一般在第三层，例如"suse/x86_64/suse-leap-42.3-JeOS"表示suse发行版的x86_64架构的leap-42.3这个版本的最小系统（JeOS）。leap-42.3即openSUSE Leap42.3，是opensuse的最新版本。使用kiwi-ng命令指定目录即可构建对应的发行版，例如下面命令分别构建了opensuse42.3和centos7的镜像（由于墙的影响，发行版的测速不准确。故实际使用默认的配置文件时下载包的速度会比较慢，后文会给出国内源的例子）：

```
APPLIANCE=suse/x86_64/suse-leap-42.3-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```

```
APPLIANCE=centos/x86_64/centos-07.0-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```

构建成功之后镜像目录：

```
[ INFO    ]: 04:07:37 | Result files:
[ INFO    ]: 04:07:37 | --> disk_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.raw
[ INFO    ]: 04:07:37 | --> image_packages: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.packages
[ INFO    ]: 04:07:37 | --> image_verified: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.verified
[ INFO    ]: 04:07:37 | --> installation_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.install.iso
[ INFO    ]: 04:07:37 | Cleaning up BootImageDracut instance
```

构建之后要删除构建目录，否则会提示：

```
[ INFO    ]: 03:53:22 | Setup root directory: /home/vagrant/works/software/kiwi/build/image-root
[ ERROR   ]: 03:53:22 | KiwiRootDirExists: Root directory /home/vagrant/works/software/kiwi/build/image-root already exists
[ INFO    ]: 03:53:22 | Cleaning up SystemPrepare instance
vagrant@os74:~/works/source/kiwi-descriptions> sudo rm -rf ~/works/software/kiwi/build/image-root
```

### 初试KIWI配置文件

上面提到的每个目录下都可以看到类似这样的文件：

![kiwi-description-files](http://opuclx9sq.bkt.clouddn.com/2018-05-13-122330.png)

每个文件的作用如下：

* `Dicefile`: 如果host是opensuse，可以很容易的用Dicefile通过docker或vagrant构建kiwi镜像。由于我使用的macbook，就不给大家演示了。感兴趣的小伙伴可以参考：<https://suse.github.io/kiwi/building/build_containerized.html>

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

kiwi定制化
----------

kiwi的方便之处是可以很容易的定义自己的镜像。这里举几个栗子🌰，大家可以参考kiwi_customization分支的例子。

#### config.sh修改实例

下面的config.sh片段是笔者使用kiwi准备TiDB部署环境的例子：

* 修改了tidb这个用户的limits，例如最大打开文件数量时10万个；
* 把TiDB二进制复制到指定目录；
* 创建并修改TiDB所需目录的权限。

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

比如我一个第三方下载的软件，没有安装源，只有二进制，例如我要使用分布式数据库TiDB，可以这样修改

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

例如`fs.file-max`表示系统允许最大打开的文件数量是10万。前面我们修改config.sh时，修改的是名为tidb的用户的最大上限是10万。



KIWI参考资料
------------
1. [kiwi quick start](https://suse.github.io/kiwi/quickstart.html): <https://suse.github.io/kiwi/quickstart.html>
2. [google group](https://groups.google.com/forum/#!forum/kiwi-images): <https://groups.google.com/forum/#!forum/kiwi-images>
3. [YaST 映像创建程序是 KIWI 映像工具的图形界面](https://www.suse.com/zh-cn/documentation/sles-12/book_sle_deployment/data/cha_imgcreator.html): <https://www.suse.com/zh-cn/documentation/sles-12/book_sle_deployment/data/cha_imgcreator.html>
4. [kiwi-ng与legacy kiwi比较](https://suse.github.io/kiwi/overview/legacy_kiwi.html): <https://suse.github.io/kiwi/overview/legacy_kiwi.html>

