---
layout: post
title: How to use shadowsocks in PC and chromebook
categories: [Software]
tags: [vpn, shadowsocks, PC, opensuse, chromebook]
---

I am looking for a good vpn in recent two years. Try [YunTi](https://www.ytpub.com/) and other vpn through the pp2p and l2tp protocol. But it is not very stable in my home and too slow. Shadowsocks is better. Its bandwidth is bigger than 1Mbyte/s in my home. It is enough to watch youtube. But the issue is that I could only use internet brower or the application which support socks5 in my laptop. And I could not use it in my chromebook. In this blog, I use privoxy to forward the socks5 to http port in pc and compile the arm specific shadowsocks software in my chromebook

Note that there are varies method to use shadowsocks. You could of course setup your own vpn. I buy an account from <https://shadowsocks.com/>(It is not relative to the open source project).

Enable shadowsocks for all the software in my PC
------------------------------------------------
Takes openSUSE Leap 42.1 as example.

Provixy is a sofware which could forward socks5 for other port to http port. Here, I want to forward socks5 to http 1080.

1.  Install privoxy

    `zypper in privoxy`

2.  Configure privoxy

    Edit the config(/etc/privoxy/config):
    ```
    forward-socks5   /               127.0.0.1:1080 .
    ```

3.  Start privoxy

    ```
    > sudo systemctl enable privoxy.service
    > sudo systemctl status privoxy.service
    privoxy.service - Privoxy Web Proxy With Advanced Filtering Capabilities
       Loaded: loaded (/usr/lib/systemd/system/privoxy.service; enabled)
       Active: inactive (dead)

    > sudo systemctl start privoxy.service
    > sudo systemctl status privoxy.service
    privoxy.service - Privoxy Web Proxy With Advanced Filtering Capabilities
       Loaded: loaded (/usr/lib/systemd/system/privoxy.service; enabled)
       Active: active (running) since Mon 2016-02-29 10:50:32 CST; 1s ago
      Process: 9106 ExecStart=/usr/sbin/privoxy --chroot --pidfile /run/privoxy.pid --user privoxy /etc/config (code=exited, status=0/SUCCESS)
      Process: 9103 ExecStartPre=/usr/bin/cp -upf /lib64/libresolv.so.2 /lib64/libnss_dns.so.2 /var/lib/privoxy/lib64/ (code=exited, status=0/SUCCESS)
      Process: 9101 ExecStartPre=/usr/bin/cp -upf /etc/resolv.conf /etc/host.conf /etc/hosts /etc/localtime /var/lib/privoxy/etc/ (code=exited, status=0/SUCCESS)
     Main PID: 9108 (privoxy)
       CGroup: /system.slice/privoxy.service
	   └─9108 /usr/sbin/privoxy --chroot --pidfile /run/privoxy.pid --user privoxy /etc/config
     ```

Configure shadowsocks for ARM powered chromebook
------------------------------------------------
[Shadowsocks-chromeapp](https://github.com/shadowsocks/shadowsocks-chromeapp) is a application of vpn client for chromebook. It is a nodejs application. If there is a nodejs environment(nodejs, npm, cake and so on, it may varies for different nodejs version)in chromebook, we could build and run it. But by default, there is no such environment in chromebook.

There are lots of articles describing how to use shadowsocks in a chromebook. But all of(most of?) these chromebooks are x86 processor inside. For arm based chromebook, one could not use the prebuilt binaries directly(bacause which depends on the binaries do not exists arm based chromebook). And one could not make use of the link of package in these articles too. So, it take me more time to eventually enable shadowsocks in my ASUS chromebook flip(C100PA-BD02).

For x86 chromebook, [this one](http://www.zhyi828.com/shadowsocks-on-chromebook.html) describe the two methods for enable shadowsocks.
![ss-SwitchyOmega]({{site.url}}/public/images/shadowsocks/ss-SwitchyOmega.png)
![ss-externsion]({{site.url}}/public/images/shadowsocks/ss-extension.png)

I do not plan to repeat the words above. Here is the specific step for what I am doing in my chromebook. What I need to do is setup the nodejs environment. For any distribution, we could install the nodejs and npm packages through the package manager. But for chromebook, we could not. We have to download and copy the library and binary to specific directory by hand. Luckily, the only dependency of nodejs is glibc.

We need to disable os verification and enable write permission. I paste the log of enable write permission.

1.  Check the version of glibc in order to determine which package we should download

    There is a soft link point to the real version ld. In my case, it is glibc 2.19.

    ```
    chronos@localhost / $ ls -l  /lib/ld*.so.*
    lrwxrwxrwx 1 root root 10 Jun 10  2015 /lib/ld-linux-armhf.so.3 -> ld-2.19.so
    ```

    glibc 2.19 is used in opensuse 13.2
    ![ss-prepare-software-check-glibc-version]({{site.url}}/public/images/shadowsocks/ss-prepare-software-check-glibc-version.png)

2.  Download nodejs and its dependency.

    We could find out that there is no more dependence except glibc for nodejs:
    ![ss-prepare-software-nodejs]({{site.url}}/public/images/shadowsocks/ss-prepare-software-nodejs.png)

    ```
    # wget http://download.opensuse.org/ports/update/13.2/armv7hl/nodejs-4.3.1-15.1.armv7hl.rpm
    [...]
    nodejs-3.3.1-15.1.armv7hl.rpm      100%[================================================================>]   5.13M   116KB/s    in 58s
    ```

3.  Convert from rpm package to cpio image format, and extract it

    ```
    # rpm2cpio nodejs-4.3.1-15.1.armv7hl.rpm > nodejs-4.3.1-15.1.armv7hl.cpio
    # mkdir nodejs
    # cd nodejs/
    # cpio -iudm < ../nodejs-4.3.1-15.1.armv7hl.cpio
    xxx blocks
    ```

4.  Enable write permission for filesystem

    Now, we have the nodejs bin and lib, we could copy them to the filesystem and build our application. But we need make fileystem writable before it. Otherwise we will encounter the following error message:
    ```
    chronos@localhost ~/Downloads/nodejs $ cp -va usr/bin/* /usr/bin/
    âusr/bin/nodeâ -> â/usr/bin/nodeâ
    cp: cannot create regular file â/usr/bin/nodeâ: Read-only file system
    âusr/bin/npmâ -> â/usr/bin/npmâ
    cp: cannot create symbolic link â/usr/bin/npmâ: Read-only file system
    ```

    ```
    $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification

      ERROR: YOU ARE TRYING TO MODIFY THE LIVE SYSTEM IMAGE /dev/mmcblk0.

      The system may become unusable after that change, especially when you have
      some auto updates in progress. To make it safer, we suggest you to only
      change the partition you have booted with. To do that, re-execute this command
      as:

        sudo ./make_dev_ssd.sh --remove_rootfs_verification --partitions 2

      If you are sure to modify other partition, please invoke the command again and
      explicitly assign only one target partition for each time  (--partitions N )

    ERROR: IMAGE /dev/mmcblk0 IS NOT MODIFIED.
    $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 2

      ERROR: YOUR FIRMWARE WILL ONLY BOOT SIGNED IMAGES.

      Modifying the kernel or root filesystem will result in an unusable system.  If
      you really want to make this change, allow the firmware to boot self-signed
      images by running:

        sudo crossystem dev_boot_signed_only=0

      before re-executing this command.

    ERROR: IMAGE /dev/mmcblk0 IS NOT MODIFIED.
    $ sudo crossystem dev_boot_signed_only=0
    $ sudo /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --partitions 2
    Kernel A: Disabled rootfs verification.
    Backup of Kernel A is stored in: /mnt/stateful_partition/backups/kernel_A_20160303_114351.bin
    Kernel A: Re-signed with developer keys successfully.
    Successfully re-signed 2 of 1 kernel(s)  on device /dev/mmcblk0.
    $
    ```

5.  Copy the nodejs files into system

    ```
    sudo cp -a ./usr/lib/* /usr/lib/
    sudo cp -a ./usr/lib/* /usr/lib/
    ```

6. Now, we could follow the [this arcicle](https://www.dogfight360.com/blog/?p=250) descrbie how to build shadowsocks-chromeapp. [Here](https://github.com/shadowsocks/shadowsocks-chromeapp) is the shadowsocks application for chromebook. [Node and NPM on Chromebook (Chrome OS)](https://gist.github.co9/kalehv/5105268).

