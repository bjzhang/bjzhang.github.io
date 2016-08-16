---
layout: post
title: revisit arm64 page table management in linux kernel
categories: [Linux]
tags: [kernel, arm64, pagetable]
---


Several years ago, I read the ARM ARM carefullly when I want to add Cortex-a8 support for nucleus which supported arm9. At that time, I understand the basic knowledge of memory mapping of arm architecture. I thought it is similar in Linux(In theory, it is. In practice, the memory management is complex than Nucleus).

Recently, when I plan to investigate the contiguous hint bit for arm64("66b3923 arm64: hugetlb: add support for PTE contiguous bit" is a start point). I realise that I need to really understand that.

Back to 2005, there is an article in lwn which mentioned [the four level page table in Linux kernel](https://lwn.net/Articles/117749/).

![Linux kernel pagetable overview]({{site.url}}public/images/pagetable/linux_four_level_pagetables_overview_from_lwn.png).
The PUD only exists on architectures which are using four-level tables, the PMD is absent if the architecture only supports two-level tables.

According to the "Documentation/arm64/memory.txt", If four level pagetable is used in arm64, it looks like:
```
Translation table lookup with 4KB pages:

+--------+--------+--------+--------+--------+--------+--------+--------+
|63    56|55    48|47    40|39    32|31    24|23    16|15     8|7      0|
+--------+--------+--------+--------+--------+--------+--------+--------+
 |                 |         |         |         |         |
 |                 |         |         |         |         v
 |                 |         |         |         |   [11:0]  in-page offset
 |                 |         |         |         +-> [20:12] L3 index
 |                 |         |         +-----------> [29:21] L2 index
 |                 |         +---------------------> [38:30] L1 index
 |                 +-------------------------------> [47:39] L0 index
 +-------------------------------------------------> [63] TTBR0/1
```

In arm64 kernel, ARM64_HW_PGTABLE_LEVEL_SHIFT is introduce to convert between PXD and levelX.

Ok, Let me read the page tables.
show_pte.

## mmap and brk
Userspace malloc the memory through mmap and brk syscall. Modern 64bit kernel define mapp as the wrapper of mmap_pgoff. The latter one is defined in mm/mmap.c
```
SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
                unsigned long, prot, unsigned long, flags,
                unsigned long, fd, unsigned long, pgoff)
{
        if (!(flags & MAP_ANONYMOUS)) {
		//align len if f_op is hugetlbfs_file_operations
		//check if set MAP_HUGETLB and hugetlbfs_file_operations at the same time
        } else if (flags & MAP_HUGETLB) {
		//align len if f_op is hugetlbfs_file_operations
		//register hugetlb file hugetlb_file_setup and set f_op as hugetlbfs_file_operations in it.
	}
	vm_mmap_pgoff()
}
```
hugetlbfs_file_operations
