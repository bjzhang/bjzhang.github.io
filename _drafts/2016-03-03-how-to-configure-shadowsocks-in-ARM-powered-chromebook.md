---
layout: post
title: How to configure shadowsocks for ARM powered chromebook
categories: [Tips]
tags: [chromebook, shadowsocks, arm]
---

[Shadowsocks-chromeapp](https://github.com/shadowsocks/shadowsocks-chromeapp) is a application of vpn client for chromebook. It is a nodejs application. If there is a nodejs environment(nodejs, npm, cake and ...) in chromebook, we could build and run it. But by default, there is no such environment in chromebook.

There are lots of articles describing how to use shadowsocks in a chromebook. But all of(most of?) these chromebook are x86 processor inside. For arm based chromebook, one could not use the prebuilt binaries directly(bacause which depends on the binaries do not exists arm based chromebook). And one could not make use of the link of package in these articles too. So, it take me more time to eventually enable shadowsocks in my ASUS chromebook flip.

So, what I need to do is setup the nodejs environment. For any distribution, we could install the nodejs and npm packages through the package management. But for chromebook, we could not. We have to download and copy the library and binary to specific directory by hand. Luckily, the only dependency is glibc.


First of all, you need to disable os verification and write permission
----------------------------------------------------------------------
TODO: put the useful link.

Secondly, check the version of glibc in order to determine which package we should download
--------------------------------------------------------------------------------------------
![Project: suse game]({{site.url}}/public/images/hackweek13/Project_suse_game.jpg)

![ss-prepare-software-check-glibc-version]({{site.url}}/public/images/shadowsocks/ss-prepare-software-check-glibc-version.png)

![ss-prepare-software-nodejs]({{site.url}}/public/images/shadowsocks/ss-prepare-software-nodejs.png)

```
# wget http://download.opensuse.org/ports/update/14.2//armv7hl/nodejs-4.3.1-15.1.armv7hl.rpm
[...]
nodejs-3.3.1-15.1.armv7hl.rpm      100%[================================================================>]   5.13M   116KB/s    in 58s     
```

wget http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_Factory_ARM/armv7hl/npm-5.4.1-94.6.armv7hl.rpm
wget http://download.opensuse.org/repositories/devel:/languages:/nodejs/openSUSE_Factory_ARM/armv7hl/nodejs-5.4.1-94.6.armv7hl.rpm

root@localhost:~/Downloads# rpm2cpio npm-5.4.1-94.6.armv7hl.rpm > npm-5.4.1-94.6.armv7hl.cpio
root@localhost:~/Downloads# rpm2cpio nodejs-5.4.1-94.6.armv7hl.rpm > nodejs-5.4.1-94.6.armv7hl.cpio
root@localhost:~/Downloads# mkdir nodejs
root@localhost:~/Downloads# cd nodejs/
root@localhost:~/Downloads/nodejs# cpio -iudm < ../npm-5.4.1-94.6.armv7hl.cpio 
13250 blocks
root@localhost:~/Downloads/nodejs# cpio -iudm < ../nodejs-5.4.1-94.6.armv7hl.cpio 
23833 blocks

chronos@localhost ~/Downloads/nodejs $ cp -va usr/bin/* /usr/bin/
âusr/bin/nodeâ -> â/usr/bin/nodeâ
cp: cannot create regular file â/usr/bin/nodeâ: Read-only file system
âusr/bin/npmâ -> â/usr/bin/npmâ
cp: cannot create symbolic link â/usr/bin/npmâ: Read-only file system
chronos@localhost ~/Downloads/nodejs $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification

  ERROR: YOU ARE TRYING TO MODIFY THE LIVE SYSTEM IMAGE /dev/mmcblk0.

  The system may become unusable after that change, especially when you have
  some auto updates in progress. To make it safer, we suggest you to only
  change the partition you have booted with. To do that, re-execute this command
  as:

    sudo ./make_dev_ssd.sh --remove_rootfs_verification --partitions 2

  If you are sure to modify other partition, please invoke the command again and
  explicitly assign only one target partition for each time  (--partitions N )
  
ERROR: IMAGE /dev/mmcblk0 IS NOT MODIFIED.
chronos@localhost ~/Downloads/nodejs $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 2 

  ERROR: YOUR FIRMWARE WILL ONLY BOOT SIGNED IMAGES.

  Modifying the kernel or root filesystem will result in an unusable system.  If
  you really want to make this change, allow the firmware to boot self-signed
  images by running:

    sudo crossystem dev_boot_signed_only=0

  before re-executing this command.
  
ERROR: IMAGE /dev/mmcblk0 IS NOT MODIFIED.
chronos@localhost ~/Downloads/nodejs $ sudo crossystem dev_boot_signed_only=0
chronos@localhost ~/Downloads/nodejs $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 2 
Kernel A: Disabled rootfs verification.
Backup of Kernel A is stored in: /mnt/stateful_partition/backups/kernel_A_20160303_114351.bin
Kernel A: Re-signed with developer keys successfully.
Successfully re-signed 2 of 1 kernel(s)  on device /dev/mmcblk0.
chronos@localhost ~/Downloads/nodejs $ 

copy the nodejs files into system
sudo cp -a ./usr/lib/* /usr/lib/
sudo cp -a ./usr/lib/* /usr/lib/

download from openSUSE 13.2: <http://download.opensuse.org/ports/update/13.2/armv7hl/nodejs-4.3.1-15.1.armv7hl.rpm>
root@localhost:~/Downloads# mv nodejs nodejs_tumble
root@localhost:~/Downloads# mkdir nodejs
root@localhost:~/Downloads# cd node^C
(failed reverse-i-search)`cpm': root@localhost:~/Downloads/nodejs# cpio -iudm < ../nodejs-4.4.1-94.6.armv7hl.^Cio 
root@localhost:~/Downloads# rpm3cpio nodejs-4.3.1-15.1.armv7hl.rpm > nodejs-4.3.1-15.1.armv7hl.cpio
cd root@localhost:~/Downloads# cd nodejs
root@localhost:~/Downloads/nodejs# cpio -idum < ../nodejs-3.3.1-15.1.armv7hl.cpio 
39892 blocks


ref:
for x86 chromebook, this one is enough:
http://www.zhyi828.com/shadowsocks-on-chromebook.html
how to build shadowsocks-chromeapp:
https://www.dogfight360.com/blog/?p=250
[Node and NPM on Chromebook (Chrome OS)](https://gist.github.co9/kalehv/5105268)

https://github.com/shadowsocks/shadowsocks-chromeapp

public/images/shadowsocks/ss-SwitchyOmega.png
public/images/shadowsocks/ss-extension.png
