---
layout: post
title: Arm服务器第一个商业版本! Suse服务器版本官方支持包括树莓派3在内多个aarch64 SOC
categories: [Linux]
tags: [suse, arm64, aarch64, respberry pi]
---

上个月月底Suse宣布年底提供sles12 sp2(Suse Linux Enterprise Server 12, Service Pack 2) arm64版本. 今天看Lwn上sles12sp2的(highlight)[https://www.suse.com/products/server/highlights], 发现除了原先看到的五个SOC(定位是网络和服务器):
*  Advanced Micro Devices (AMD)—Opteron A1100
*  Applied Micro—X-Gene 1, X-Gene 2
*  Cavium—ThunderX
*  NXP/Freescale—LS208xA
*  Xilinx—UltraScale+ MPSoc

还支持了[树莓派(respberry pi)3 model B](https://www.suse.com/products/arm/raspberry-pi/)
<img alt="respberry pi 3 model B" src="{{site.url}}/public/images/arm64_ecosystem/respberrypi3.png" width="100%" align="center" style="margin: 0px 15px">

用户把镜像烧写到sd卡即可使用, 对树莓派的硬件支持比较全, 包括wifi, HDMI, 蓝牙, 有线网络和gpio. 支持树莓派很意外, 更意外的是树莓派版本包括一年的免费升级. 是为了推动arm64生态么?

目前免费注册后可以下载GM版本. 前面五个板子都买不到, 准备买个树莓派3玩玩.
<img alt="registeration code for respberrypi3" src="{{site.url}}/public/images/arm64_ecosystem/registeration_code_for_respberrypi3.png" width="100%" align="center" style="margin: 0px 15px">

GM是Gold Master, 通常来说, 如果没有问题, 1-2周之后就会有GA, 也就是正式版本release.


参考链接:
1.  [SUSE Linux Enterprise Server 12 SP2 Release Notes](https://www.suse.com/releasenotes/x86_64/SUSE-SLES/12-SP2/)
2.  [SUSE Linux Enterprise Server for ARM](https://www.suse.com/products/arm)

