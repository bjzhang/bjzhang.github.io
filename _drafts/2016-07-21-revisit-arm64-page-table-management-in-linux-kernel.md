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

attribute
B2.2 Memory type overview
ARMv8 provides the following mutually-exclusive memory types:
Normal This is generally used for bulk memory operations, both read/write and read-only operations.
Device The ARM architecture forbids speculative reads of any type of Device memory. This means Device
memory types are suitable attributes for read-sensitive locations.
Locations of the memory map that are assigned to peripherals are usually assigned the Device
memory attribute.
Device memory has additional attributes that have the following effects:
• They prevent aggregation of reads and writes, maintaining the number and size of the
specified memory accesses. See Gathering on page B2-100.
• They preserve the access order and synchronization requirements, both for accesses to a
single peripheral and where there is a synchronization requirement on the observability of
one or more memory write and read accesses. See Reordering on page B2-101
• They indicate whether a write can be acknowledged other than at the end point. See Early
Write Acknowledgement on page B2-102.
For more information on Normal memory and Device memory, see Memory types and attributes on page B2-93.
Note
Earlier versions of the ARM architecture defined a single Device memory type and a Strongly-ordered memory
type. A Note in Device memory on page B2-98 describes how these memory types map onto the ARMv8 memory
types.

Device-nGnRnE Device non-Gathering, non-Reordering, No Early write acknowledgement.
Equivalent to the Strongly-ordered memory type in earlier versions of the architecture.
Device-nGnRE Device non-Gathering, non-Reordering, Early Write Acknowledgement.
Equivalent to the Device memory type in earlier versions of the architecture.
Device-nGRE Device non-Gathering, Reordering, Early Write Acknowledgement.
ARMv8 adds this memory type to the translation table formats found in earlier versions of
the architecture. The use of barriers is required to order accesses to Device-nGRE memory.
Device-GRE Device Gathering, Reordering, Early Write Acknowledgement.
ARMv8 adds this memory type to the translation table formats found in earlier versions of
the architecture. Device-GRE memory has the fewest constraints. It behaves similar to
Normal memory, with the restriction that speculative accesses to Device-GRE memory is
forbidden

Gathering
In the Device memory attribute:
G Indicates that the location has the Gathering attribute.
nG Indicates that the location does not have the Gathering attribute, meaning it is non-Gathering.
The Gathering attribute determines whether it is permissible for either:
• Multiple memory accesses of the same type, read or write, to the same memory location to be merged into a
single transaction.
• Multiple memory accesses of the same type, read or write, to different memory locations to be merged into
a single memory transaction on an interconnect


Reordering
In the Device memory attribute:
R Indicates that the location has the Reordering attribute. Accesses to the location can be reordered
within the same rules that apply to accesses to Normal Non-cacheable memory. All memory types
with the Reordering attribute have the same ordering rules as accesses to Normal Non-cacheable
memory, see Memory ordering on page B2-83.
nR Indicates that the location does not have the Reordering attribute, meaning it is non-Reordering.
Note
Some interconnect fabrics, such as PCIe, perform very limited re-ordering, which is not important
for the software usage. It is outside the scope of the ARM architecture to prohibit the use of a
Non-reordering memory type with these interconnects.


It is a better way to control the acess
---------------------------------------
The restrictions apply only to subsequent levels of lookup at the same stage of translation, and:
• UXNTable or XNTable restricts the XN control:
— When the value of the XNTable bit is 1, the XN bit is treated as 1 in all subsequent levels of lookup,
regardless of its actual value.
— When the value of the UXNTable bit is 1, the UXN bit is treated as 1 in all subsequent levels of lookup,
regardless of its actual value.
— When the value of a UXNTable or XNTable bit is 0 the bit has no effect.
• For the EL1&0 translation regime, PXNTable restricts the PXN control:
— When PXNTable is set to 1, the PXN bit is treated as 1 in all subsequent levels of lookup, regardless
of the actual value of the bit.
— When PXNTable is set to 0 it has no effect.


tlb
Any translation table entry that does not generate a Translation fault, an Address size fault, or an Access flag
fault and is not from a translation regime for an Exception level that is lower than the current Exception level
might be allocated to an enabled TLB at any time. The only translation table entries guaranteed not to be held
in the TLB are those that generate a Translation fault, an Address size fault, or an Access flag fault.
