

各种镜像打包方式总结

实际工作中可能涉及到在特定环境部署物理机或虚拟机，可能希望系统一键部署后直接可用。一般有两类思路，一个是做一个ghost镜像，直接写入目标系统，系统启动后直接可以使用。第二个是启动或安装一个默认系统，使用自动化部署工具配置环境。更复杂的情况是两者的结合。

第二种方法包括ansible, fabric等方法。本文只讨论第一种方法。第二类方法后续。

Linux发行版一键安装方式有很多种，可以分为预先安装和预先写好配置文件一键安装两种方式。

通过配置文件一键安装通常和发行版联系比较紧密，例如suse有autoyast，redhat有kickstart。todo链接。这类方法以一个管理员手工安装的脚本为基础，进一步修改做成。由于每次重新安装时间较长。适合于需要给少量几台机器部署。

前一种方法和在云化场景中选择自定义镜像类似。实际应用中，不管物理机还是虚拟机还是云化场景的镜像定制，都适合。

预先安装需要制作一个磁盘镜像，一键部署时选择指定的磁盘直接写入并设置bootloader之后即可使用。有suse的kiwi，redhat的virt-builder, virt-p2v里面用的那个, terraform.

其中只有kiwi支持从物理机，虚拟机到云化场景的镜像构建和部署。terraform支持跨操作系统的虚拟机，但是不支持物理机，尤其适合个人用户。

网上中文材料基本说的都是kiwi不是最新的kiwi-ng，而且缺乏定制化细节。


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
以libvirt为例。
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


