---
layout: post
title: Running SLES and openSUSE on OverDrive1000
categories: [Linux]
tags: [ecosystem, arm, development board]
---

Eventually, I received by overdrive 1000 which I order in last June. Here is the open box for it. I will first introduce my box then compare with others arm64 board, and run suse enterprise and community Linux distribution on it.

Recently, there are lots of arm powered development board announced. A clearly differnce is lots of arm powered board support pcie and G ethernet Which is usually used in enterprise class senaro.

I would like compare the existing/announced board and buy some of them to try to understand this trend. I only compare the buyable board exclude the system which is not opened to real end user.

Distribution support. Because of the differences of arm SOC, a commercial support could not cover all the baord. Take Suse Linux Enterprise Server as example, Suse support 5 enterprise class board and one low-end board. And the SOC powered by AMD is supported by SUSE.


Board/System Name   Cello
SOC                 AMD A1120
CPU                 4xcortex-A57@1.7GHz
Cache               L2 2M L3 8M
Memory              2 DDR3 Slot
Hard disk           Not preinstalled
Ethernet            1xGb
Pcie                x16
Usb
Sata                2
OS supporx
Debug               Jtag
Other               Linaro 96Boards Expansion slot
Consumption
Dimension           160mmx120mm
Weight              500g(?)
Price               299$ without memory and hd

Board Name      |SOC       | CPU                |Cache       | Memory      |Harddisk|sata|usb|os|price
----------------|----------|--------------------|------------|-------------|--------|----|---|--|------
OverDrive 1000  |AMD A1120 | 4xcortex-a57@1.7GHz| L2 2M L3 8M| 8G removable|1T hdd| 1,0,2x3.0|2x3.0| opensuse leap, sles12 sp2| 599$
OverDrive 3000  |AMD A1100 | 8xcortex-a57@2GHz(or 1.7)| L2 4M L3 8M| 16G removable| dual x4 or single x8|?|14x3.0| opensuse leap, sles12 sp2| 2495$

[Cello](http://www.96boards.org/product/cello/)
[Husky Board](http://www.96boards.org/product/huskyboard/)
[96 boards Specification](https://www.96boards.org/specifications/)
[Overdrive 1000](https://shop.softiron.co.uk/product/overdrive-1000/)

Dimensions 315mm x 222mm x 76mm
Weight 3.65kg

There was an announce of EE board of 96boards, But there is no progress in the whole year: <http://www.cnx-software.com/2016/03/07/lemaker-cello-96boards-ee-board-powered-by-amd-opteron-a1120-processor-targets-server-applications/>
[OverDrive 3000](https://shop.softiron.co.uk/product/overdrive-3000/)

Dimensions 356mm x 426mm x 43mm
Weight 5.2kg

[Firefly-rk3399](https://www.kickstarter.com/projects/1771382379/firefly-rk3399-six-core-64-bit-high-performance-pl), [official website(Chinese)]9http://www.t-firefly.com/zh/firenow/Firefly-rk3399/)
Each board also has ARM Mali-T860 MP4 graphics, a microSD card slot and M.2 slot for storage for additional storage, HDMI 2.0, DisplayPort 1.2, 3.5mm audio, and S/PDIF ports, an Ethernet jack, 802.11ac WiFI, Bluetooth 4.0, and USB 3.0, USB 2.0, and USB 3.0 Type-C ports.

[RK3399 Q7](https://www.theobroma-systems.com/rk3399-q7/overview), [Dev Kit for Q7](https://www.theobroma-systems.com/hainan-q7-dev-kit/overview)

GENERAL
Form factor Qseven
Processor   Rockchip RK3399 Hexa-Core
2x ARM Cortex-A72
4x ARM Cortex-A53
2x 80kB + 4x 64kB L1 cache and 1MB + 512kB L2 cache
ARMv8 Cryptography Extensions
2x ARM Cortex-M0 coprocessors
GPU ARM Mali T864MP4 GPU
RGA2 2D Graphics Engine
VPU Video decoder: H.265, H.264, VP9 up to 4K @ 60fps
Video encoder: H.264 up to FullHD @ 30fps
Memory  DDR3, up to 4GB on-module
STORAGE
NOR Flash   Up to 16MB SPI NOR flash on-module
eMMC Flash  Up to 128GB eMMC on-module
CONNECTIVITY
Ethernet    10/100/1000 Mbps (with an on-module triple-speed GbE PHY)
USB 2x USB 3.0 (1x dual-role)
2x USB 2.0 (host)
Display HDMI 2.0, up to 4K @ 60fps
MIPI DSI, up to 2560x1600 @ 60fps
eDP, up to 4 lanes with 2.7 Gb/s each
Camera  2x MIPI-CSI, 2x 4 lanes with up to 1.5Gb/s each
PCIe    4-lane PCIe 2.1, up to 5 GT/s
CAN On-module communication offload controller for CAN
Additional Interfaces   UART, 8x GPIO, I2S, I2C, SMBus, SPI, FAN
Security Module Global Platform 2.2.1 compliant JavaCard environment
On-module state-of-the-art, EAL4-certified smartcard controller
Note: Custom board variants may exclude the security-module option.
SOFTWARE SUPPORT
Operating Systems   Linux
Android
POWER
Power Management    Dynamic frequency and voltage scaling for thermal and power management
Power Supply    Operates directly from a single 5V supply
Consumption < 15W
ENVIRONMENTAL
Operating environment   Commercial 0ºC to 85ºC
Extended temperature ranges are available on request.
Dimensions  70mm x 70mm

[Check the FAQs section for supported device]<https://www.suse.com/products/arm)
*  Advanced Micro Devices (AMD) Opteron A1100
*  Applied Micro X-Gene 1, X-Gene 2
*  Cavium ThunderX
*  NXP/Freescale LS208xA
*  Xilinx UltraScale+ MPSoc

[(respberry pi)3 model B](https://www.suse.com/products/arm/raspberry-pi/)
