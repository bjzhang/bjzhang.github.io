---
layout: post
title: 假装在现场--2018年第一场linaro connect
categories: [Linux]
tags: [Linux, arm]
---

上一篇关于connect的文章还是：<2017-06-02-Implementing-Contiguous-page-hint-in-userspace.md>


arm64越来越丰富的硬件
---------------------



arm64调测
---------

### openocd
[HKG18-403 – Introducing OpenOCD: Status of OpenOCD on AArch64](http://connect.linaro.org/resource/hkg18/hkg18-403/)
2010年的时候openocd用的是ahb-ap读取的系统信息，没有走apb-ap，所以有cache问题。
但是openocd需要自己根据soc写配置文件。你得学一下。
用现成的armv7之后的soc修改就可以。它里面有继承关系，cpu肯定都支持了。只是需要根据soc适配下。
jlink我没看过。openocd其实只是个通道，下面是个usb转sw debug协议的东西。具体发什么信号都是上面pc端控制的。所以理论上，openocd可以支持所有jtag和sw协议的硬件。但是实际中sw协议不开放。所以2010年的时候openocd只能用jtag协议连接armv7的cpu。

用法参考：<https://www.96boards.org/documentation/consumer/hikey/guides/jtag/>，现在已经合入主线了，可以去官网下载<https://sourceforge.net/p/openocd/code/ci/master/tree/>：`git clone https://git.code.sf.net/p/openocd/code openocd-code`

配置文件："openocd-code/tcl/target/hi6220.cfg"

