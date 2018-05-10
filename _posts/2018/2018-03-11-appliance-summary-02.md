---
layout: post
title: 来自suse的猕猴桃(KIWI)（Linux自动化部署工具之三）
categories: [Software]
tags: [Linux, appliance, SUSE/openSUSE, KIWI]
---

复习一下上次的内容： 预先安装需要制作一个磁盘镜像，一键部署时选择指定的磁盘直接写入并设置bootloader之后即可使用。有suse的kiwi，redhat的virt-builder和terraform. 其中只有kiwi支持从物理机，虚拟机到云化场景的镜像构建和部署。terraform支持跨操作系统的虚拟机，但是不支持物理机，尤其适合个人用户。 网上中文材料基本说的都是kiwi不是最新的kiwi-ng，而且缺乏定制化细节。

kiwi超快上手
--------------
上次使用openSUSE的build service构建镜像。如果仅仅为了构建镜像，不需要部署buildservice。kiwi-ng有单独的命令行🔧。下文说明如何用kiwi命令行工具构建镜像。

public/sources/vagrant_kiwi/build_kiwi.sh
准备kiwi环境并构建镜像。
脚本为了编译大家粘贴每一行，没有使用任何变量。

kiwi description里面包含不同发行版，例如suse，opensuse都在suse目录，redhat，centos，debian等等，下面命令分别构建了opensuse42.3和centos7的镜像
```
APPLIANCE=suse/x86_64/suse-leap-42.3-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```
```
APPLIANCE=centos/x86_64/centos-07.0-JeOS/
sudo kiwi-ng --debug --color-output --type oem system build --target-dir $HOME/works/software/kiwi --description $APPLIANCE
```

这里提供一个标准源一个国内源的配置文件，大家可以根据自己的网络情况选择。

构建成功之后镜像目录：
```
[ INFO    ]: 04:07:37 | Result files:
[ INFO    ]: 04:07:37 | --> disk_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.raw
[ INFO    ]: 04:07:37 | --> image_packages: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.packages
[ INFO    ]: 04:07:37 | --> image_verified: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.verified
[ INFO    ]: 04:07:37 | --> installation_image: /home/vagrant/works/software/kiwi/LimeJeOS-Leap-42.3.x86_64-1.42.3.install.iso
[ INFO    ]: 04:07:37 | Cleaning up BootImageDracut instance
```
使用方法：
1.  虚拟机
2.  物理机
    TODO截屏。

构建之后要删除构建目录，否则会提示：
```
[ INFO    ]: 03:53:22 | Setup root directory: /home/vagrant/works/software/kiwi/build/image-root
[ ERROR   ]: 03:53:22 | KiwiRootDirExists: Root directory /home/vagrant/works/software/kiwi/build/image-root already exists
[ INFO    ]: 03:53:22 | Cleaning up SystemPrepare instance
vagrant@os74:~/works/source/kiwi-descriptions> sudo rm -rf ~/works/software/kiwi/build/image-root
```

kiwi-ng与kiwi
------------
<https://suse.github.io/kiwi/overview/legacy_kiwi.html>

kiwi定制化
----------
kiwi的方便之处是可以很容易的定义自己的镜像。这里举几个栗子🌰，大家可以参考kiwi_customization分支的例子
1.  修改或增加软件源
    比如公司或学校内网有个镜像，我可以这样修改config.xml
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
	比如我想增加一个源，并且希望这个源在镜像中也有效，例如我希望测试最新社区内核（没有suse补丁）的某个特性，我可以这样修改；
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

2.	增加软件包
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

3.  增加二进制包
    1.  比如我一个第三方下载的软件，没有安装源，只有二进制，例如我要使用分布式数据库TiDB，可以这样修改
    <archive name="binaries.tar.gz"/>

4.  修改系统配置。
    root/etc/sysctl.d/99-tidb.conf

5.  其它定制
    config.sh

kiwi免安装选择
--------------
kiwi安装时需要选择磁盘（如果磁盘有多块），还需要确认格式化，如果我确定这些信息，可以去掉这些选项。

kiwi调试
--------
日志位于: "$HOME/works/software/kiwi/build/image-root.log"
构建镜像生成的根文件系统: "$HOME/works/software/kiwi/build/image-root"

kiwi部署
--------
### 物理机
物理机支持pxe，光盘启动，硬盘直接dd。
### 虚拟机
除了前面的virt-install安装。如果是服务器，不方便安装GUI，还可以通过笔者的脚本/Users/bamvor/works/source/small_tools_collection/appliance_helper/install.sh安装，服务器端有vnc server即可。
### 云
google cloud 感觉没空做。
要不要和suse studio ams镜像结合一起说？

kiwi官方文档
------------
[kiwi quick start](https://suse.github.io/kiwi/quickstart.html)
[google group](https://groups.google.com/forum/#!forum/kiwi-images)
YaST 映像创建程序是 KIWI 映像工具的图形界面
<https://www.suse.com/zh-cn/documentation/sles-12/book_sle_deployment/data/cha_imgcreator.html>

