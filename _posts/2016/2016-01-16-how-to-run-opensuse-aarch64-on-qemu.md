---
layout: post
title: How to run opensuse for aarch64 on qemu(使用qemu运行opensuse aarch64)
categories: [Virtualization]
tags: [qemu, opensuse, arm64, aarch64]
---

Install the lastest qemu-system-aarch64.
----------------------------------------

qemu-system-aarch64 exist in qemu-arm package. It is highly recommneded that use the lastet version(2.5 for now).

```
sudo zypper ar -c -f -r http://download.opensuse.org/repositories/Virtualization/openSUSE_Leap_42.1/Virtualization.repo
sudo zypper refresh
sudo zypper in "qemu-arm>=2.5"
```

Download opensuse aarch64 images
--------------------------------

<http://download.opensuse.org/ports/aarch64/factory/images/*JeOS-efi*.raw>
Assume that openSUSE-Tumbleweed-ARM-JeOS-efi.aarch64-1.12.1-Build296.1.raw is the image you downlaod.

Run opensuse images
-------------------

    You could run it with efi which load kernel exist in the image you download reference <https://en.opensuse.org/openSUSE:AArch64>. But if you want to build your own kernel in x86 and run it in qemu, you probably need the direct boot:

    ```
    qemu-system-aarch64 -m 2048 -cpu cortex-a57 -smp 2 -M virt --kernel /path/to/Image --append "console=ttyAMA0 root=/dev/vda2 rw" -device virtio-net-device,vlan=0,id=net0,mac=52:54:00:09:a4:37 -net user,vlan=0,name=hostnet0,hostfwd=tcp::2222-:22 -drive if=none,file=/path/to/openSUSE-Tumbleweed-ARM-JeOS-efi.aarch64-1.12.1-Build296.1.raw,id=hd0 -device virtio-blk-device,drive=hd0 -s
    ```
    It will pop up a x windows. If you do not want X, add "-nographic" which will be the following command:
    ```
    qemu-system-aarch64 -m 2048 -cpu cortex-a57 -smp 2 -M virt --kernel /path/to/Image --append "console=ttyAMA0 root=/dev/vda2 rw" -device virtio-net-device,vlan=0,id=net0,mac=52:54:00:09:a4:37 -net user,vlan=0,name=hostnet0,hostfwd=tcp::2222-:22 -drive if=none,file=/path/to/openSUSE-Tumbleweed-ARM-JeOS-efi.aarch64-1.12.1-Build296.1.raw,id=hd0 -device virtio-blk-device,drive=hd0 -s --nographic
    ```
    You could find my kernel Image [here]({{site.url}}/public/binaries/Image_aarch64_for_qemu_system_aarch64).

Others: how to install packages in opensuse
------------------------------------
<http://opensuse-guide.org/installpackage.php>

