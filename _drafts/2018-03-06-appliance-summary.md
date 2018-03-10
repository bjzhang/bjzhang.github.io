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
/Users/bamvor/works/source/bjzhang.github.io/public/images/appliance/applicace_comparision.png

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


漫谈操作系统镜像打包方式之二
====
复习一下上次的内容： 预先安装需要制作一个磁盘镜像，一键部署时选择指定的磁盘直接写入并设置bootloader之后即可使用。有suse的kiwi，redhat的virt-builder和terraform. 其中只有kiwi支持从物理机，虚拟机到云化场景的镜像构建和部署。terraform支持跨操作系统的虚拟机，但是不支持物理机，尤其适合个人用户。 网上中文材料基本说的都是kiwi不是最新的kiwi-ng，而且缺乏定制化细节。

kiwi超快上手
--------------
wget Vagrantfile
mkdir vagrant_kiwi
cd vagrant_kiwi
vagrant up

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

vagrant跨平台部署
-----------------
buildroot/docs/manual/getting.txt
buildroot/support/misc/Vagrantfile


vagrant up
```
192:vagrant_kiwi bamvor$ vagrant up
Bringing machine 'opensuse42.3' up with 'virtualbox' provider...
==> opensuse42.3: Importing base box 'opensuse/openSUSE-42.3-x86_64'...
==> opensuse42.3: Matching MAC address for NAT networking...
==> opensuse42.3: Checking if box 'opensuse/openSUSE-42.3-x86_64' is up to date...
==> opensuse42.3: Setting the name of the VM: vagrant_kiwi_opensuse423_1520604280467_51794
==> opensuse42.3: Clearing any previously set network interfaces...
==> opensuse42.3: Available bridged network interfaces:
1) en0: Wi-Fi (AirPort)
2) p2p0
3) awdl0
4) en2: 雷雳 1
5) en1: 雷雳 2
6) bridge0
==> opensuse42.3: When choosing an interface, it is usually the one that is
==> opensuse42.3: being used to connect to the internet.
    opensuse42.3: Which interface should the network bridge to? 0
    opensuse42.3: Which interface should the network bridge to? 1
==> opensuse42.3: Preparing network interfaces based on configuration...
    opensuse42.3: Adapter 1: nat
    opensuse42.3: Adapter 2: bridged
==> opensuse42.3: Forwarding ports...
    opensuse42.3: 22 (guest) => 2222 (host) (adapter 1)
==> opensuse42.3: Booting VM...
==> opensuse42.3: Waiting for machine to boot. This may take a few minutes...
    opensuse42.3: SSH address: 127.0.0.1:2222
    opensuse42.3: SSH username: vagrant
    opensuse42.3: SSH auth method: private key
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3: Warning: Remote connection disconnect. Retrying...
    opensuse42.3: Warning: Connection reset. Retrying...
    opensuse42.3:
    opensuse42.3: Vagrant insecure key detected. Vagrant will automatically replace
    opensuse42.3: this with a newly generated keypair for better security.
    opensuse42.3:
    opensuse42.3: Inserting generated public key within guest...
    opensuse42.3: Removing insecure key from the guest if it's present...
    opensuse42.3: Key inserted! Disconnecting and reconnecting using new SSH key...
==> opensuse42.3: Machine booted and ready!
==> opensuse42.3: Checking for guest additions in VM...
    opensuse42.3: The guest additions on this VM do not match the installed version of
    opensuse42.3: VirtualBox! In most cases this is fine, but in rare cases it can
    opensuse42.3: prevent things such as shared folders from working properly. If you see
    opensuse42.3: shared folder errors, please make sure the guest additions within the
    opensuse42.3: virtual machine match the version of VirtualBox you have installed on
    opensuse42.3: your host and reload your VM.
    opensuse42.3:
    opensuse42.3: Guest Additions Version: 5.1.30
    opensuse42.3: VirtualBox Version: 5.2
==> opensuse42.3: Setting hostname...
==> opensuse42.3: Configuring and enabling network interfaces...
==> opensuse42.3: Mounting shared folders...
    opensuse42.3: /vagrant => /Users/bamvor/works/source/bjzhang.github.io/public/sources/vagrant_kiwi
```
```
192:vagrant_kiwi bamvor$ vagrant ssh
Last failed login: Tue Nov 28 18:08:50 CET 2017 from 10.0.2.2 on ssh:notty
There were 7 failed login attempts since the last successful login.
Have a lot of fun...
vagrant@os74:~>
```
```
192:appliance_helper bamvor$ vagrant global-status --prune
id       name         provider   state   directory
------------------------------------------------------------------------------------------------------------------
b41836b  opensuse42.3 virtualbox running /Users/bamvor/works/source/bjzhang.github.io/public/sources/vagrant_kiwi

The above shows information about all known Vagrant environments
on this machine. This data is cached and may not be completely
up-to-date. To interact with any of the machines, you can go to
that directory and run Vagrant, or you can use the ID directly
with Vagrant commands from any directory. For example:
"vagrant destroy 1a2b3c4d"
192:appliance_helper bamvor$ vagrant ssh b41836b
Last login: Fri Mar  9 15:06:34 2018 from 10.0.2.2
Have a lot of fun...
vagrant@os74:~>
```


