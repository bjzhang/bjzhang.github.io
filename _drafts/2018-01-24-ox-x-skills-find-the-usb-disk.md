
---
layout: post
title: macbook技巧：查找优盘，烧写镜像
categories: [Software]
tags: [os x, macbook]
---

插入优盘后，可以用`diskutil list`查看系统所有存储设备：
```
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         251.0 GB   disk0
   1:                        EFI EFI                     314.6 MB   disk0s1
   2:                 Apple_APFS Container disk1         250.7 GB   disk0s2

/dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +250.7 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            231.9 GB   disk1s1
   2:                APFS Volume Preboot                 22.0 MB    disk1s2
   3:                APFS Volume Recovery                506.6 MB   disk1s3
   4:                APFS Volume VM                      5.4 GB     disk1s4

/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.5 GB    disk2
   1:             Windows_FAT_16 boot                    71.3 MB    disk2s1
   2:                      Linux                         2.6 GB     disk2s2
```

插入后，如果有os x可以识别的分区，可以在finder看到这个盘（下面的boot）：
<img alt="see the disks in finder" src="{{site.url}}/public/images/os_x_ios/os_x_detach_disk_from_finder.png" width="100%" align="center" style="margin: 0px 15px">

对于要存储数据的优盘，到了这里已经可以愉快的使用了。如果希望烧写整个盘，按照Linux系统思路应该先卸载（os x中文版翻译为推出）已挂载的分区，然后用dd或其它工具写盘。但是如果点了上面的弹出按钮。这是发现`diskutil list`看不到这个盘了。上网搜索os x关于挂载优盘的信息，找到<https://alvinalexander.com/mac-os-x/mac-osx-single-user-mode-usb-drive>，但是没有解决我的思路。这时换个思路，看看系统的日志，google下，得之系统日志可以用"Console"应用查看。下图是查看设备日志并搜索"USB"，console可以点灰"现在"使日志停止：
<img alt="qemu" src="{{site.url}}/public/images/os_x_ios/os_x_console__search_usb_log.png" width="100%" align="center" style="margin: 0px 15px">

可以看到有两个进程和我有关。一个是icdd一个是kernel。kernel提示的0x1308，正是我在关于本机->系统信息->硬件->USB看到的信息：
<img alt="qemu" src="{{site.url}}/public/images/os_x_ios/os_x_show_usb_device_info.png" width="100%" align="center" style="margin: 0px 15px">
icdd似乎是image capture(com.apple.imagecapture)的守护进程。不理解为什么os x的磁盘挂载要通过icdd管理。

再去google，发现有人用diskutils卸载分区：
```
$ diskutil umountDisk /dev/disk2
Unmount of all volumes on disk2 was successful
```

实验发现这样卸载分区后，diskutils list仍然可以看到这块盘. 参考[Solution: dd too slow on Mac OS X](http://daoyuan.li/solution-dd-too-slow-on-mac-os-x/)知道用rdisk可以直接以块对齐的方式访问disk并且有buffer cache：
```
Since any /dev entry can be treated as a raw disk image, it is worth noting which devices can be accessed when and how.  /dev/rdisk nodes are character-special devices, but are "raw" in
the BSD sense and force block-aligned I/O.  They are closer to the physical disk than the buffer cache.  /dev/disk nodes, on the other hand, are buffered block-special devices and are
used primarily by the kernel's filesystem code.
```
实际测试写入1.5G数据用了108秒，13MB/s，对于usb转接的tf，也可以接受了。
```
$ sudo time dd if=openSUSE-Tumbleweed-ARM-JeOS-cubietruck.armv7l-2018.01.20-Build1.2.raw of=/dev/rdisk2 bs=1m
<Press Ctrl+t to show the progress>
load: 3.61  cmd: dd 54368 uninterruptible 0.00u 0.49s
777+0 records in
776+0 records out
813694976 bytes transferred in 57.867805 secs (14061273 bytes/sec)
1488+0 records in
1488+0 records out
1560281088 bytes transferred in 108.140113 secs (14428329 bytes/sec)
      108.99 real         0.00 user         0.93 sys
```

最后一个问题是启动优盘可能不是os x可以识别的格式，会有如下提示：
<img alt="disk error from unknown partition of os x" src="{{site.url}}/public/images/os_x_ios/os_x_disk_error_after_insert.png" width="100%" align="center" style="margin: 0px 15px">
第一反应是选择忽略，但是有时/dev下面看不到设备节点。如果选择"初始化..."就会弹出磁盘工具：
<img alt="use disk tools show the external disk" src="{{site.url}}/public/images/os_x_ios/os_x_show_external_disk_from_disk_tools.png" width="100%" align="center" style="margin: 0px 15px">
这时`diskutils list`可以看到这个盘：
```
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.5 GB    disk2
   1:                      Linux                         251.7 MB   disk2s1
   2:                      Linux                         1.3 GB     disk2s2
```

