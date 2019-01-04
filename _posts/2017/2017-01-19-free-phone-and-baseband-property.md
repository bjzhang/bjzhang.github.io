# Free phone and baseband property


自由软件基金会日前发布了2017年[高优先级自由软件项目](https://www.fsf.org/campaigns/priority-projects/), 其中包括了[自由的手机操作系统（bootloader, baseband可能是property）](
https://www.fsf.org/campaigns/priority-projects/free-phone): 

```
Free phone operating system
----------------------------
by Georgia Young — Published on Jan 13, 2017 03:09 PM
Smart phones are the most widely used form of personal computer today. Thus, the need for a fully free phone operating system is crucial to the proliferation of software freedom.
Replicant is a fully free Android distribution supported by the FSF through its Working Together for Free Software Fund. It is the first mobile operating system (OS) to run without relying on proprietary system code.

https://www.fsf.org/campaigns/priority-projects/hardware-firmware-drivers
```

还包括自由的驱动，固件和硬件设计：

```
Free drivers, firmware, and hardware designs
---------------------------------------------
by Georgia Young — Published on Jan 13, 2017 03:04 PM
Drivers, firmware, and hardware are integral parts of the computers we use and the devices that interact with them -- and when these things are proprietary, they are incompatible with free software.
Therefore, drivers, firmware, and hardware that can be fully used with free software are crucial to the operation of free systems.
In 2015, Richard Stallman discussed the need for free hardware designs. What we want most is for manufacturers to publish designs for hardware under free licenses. But the minimum is to publish key technical specifications sufficient to write free drivers for their hardware. If they won't cooperate at all, then we'll have to reverse engineer the needed support.

Ways to help
Support companies selling hardware that supports free software, who have earned the FSF's Respects Your Freedom certification and apply for certification if you sell hardware that you feel meets the criteria.
If you are a developer with driver hacking experience, here are a few specific needs that may be good starting points for work within this broad category:

- Video processing units (VPUs) are often the last hurdle to a fully free system on a chip (SoC). By replacing these nonfree dependencies, we can make low-power devices that respect users' freedoms. The Coda9 VPU requires proprietary firmware, which is preventing the Freescale iMX6 from coming entirely with free software. For more information about this visit Rhombus Tech's page about the processor.
- The VideoCore IV GPU is used in the Raspberry Pi. While graphics processing and video decoding could be done by the CPU, the same software that runs the GPU is also required for the Raspberry Pi to startup. This computer is currently unable to even boot without nonfree software.
- The GCxxxx line of chipsets provide 3D rendering for mobile devices such as laptops. This includes the GC2000 used in the One Laptop Per Child computer (OLPC). Get involved with Project Etnaviv here.
- You can help the Radeon project develop a replacement for the nonfree firmware in ATI graphics cards.
- You can support Nouveau, a project creating free replacements for proprietary drivers for nVidia cards.
- PowerVR is a popular 3D graphics engine found in phones, netbooks, and laptops, for which we currently have no free software driver capable of doing 3D graphics acceleration. In 2015, Imagination Technologies, who make PowerVR graphics processors, hinted that it was working on a free software driver, but the status of that project is unknown.
```

正好今天看到了联邦贸易委员会对于高通专利授权的[诉讼](http://arstechnica.com/tech-policy/2017/01/feds-sue-qualcomm-for-anti-competitive-patent-licensing/)诉讼高通反竞争专利授权（Feds sue Qualcomm for anti-competitive patent licensing）:

```
The FTC's redacted complaint (PDF), filed today, says that Qualcomm maintains a "no license, no chips" policy that forces cell phone to pay high royalties to Qualcomm.
According to the FTC complaint, Qualcomm won't sell baseband processors unless a customer takes a license to Qualcomm's standard-essential patents, on Qualcomm's terms. And Qualcomm has refused to license its standard-essential patents to competitors, which the FTC says violates Qualcomm's commitment to license on a "fair, reasonable and non-discriminatory" or FRAND basis. Agreeing to FRAND licensing terms is required by the standard-setting organizations to which Qualcomm belongs.
```
fed举例说，高通要求苹果公司在2011年到2016年不能使用其它公司的基带芯片：

```
Qualcomm laid out a condition—that Apple would exclusively use Qualcomm baseband processors in their products from 2011 to 2016. That denied anyone else who made baseband processors the chance to work with Apple, "a particularly important cell phone manufacturer.
```
但是这个起诉在fed内部也有争议，同时高通不认可fed的指控。

```
The FTC wants a court order that would force Qualcomm to stop what it views as anti-competitive conduct. The Commission voted 2-1 to file the complaint, with Commissioner Maureen K. Ohlhausen taking the unusual step of issuing a written statement (PDF) along with her dissent.
"This is an extremely disappointing decision to rush to file a complaint on the eve of Chairwoman Ramirez’s departure and the transition to a new Administration, which reflects a sharp break from FTC practice," said Qualcomm General Counsel Dan Rosenberg. "We look forward to defending our business in federal court, where we are confident we will prevail on the merits."
```
参考：<http://www.cnx-software.com/2016/07/05/allwinner-and-qualcomm-partner-on-android-and-windows-10-lte-tablets/>
