
---
layout: post
title: Understanding process switch in arm64
categories: [Linux]
tags: [kernel, arm64, process, apcs, assembly]
---


Recently, we want to enable a trace hardware(coresight[1]) in context switch and make it as close as the next thread run in order to trace the next thread. But we found that the functionality is not workded as we expected. After read the assembly language and test, we reelize that we should call this function before cpu_switch_to. Here is the root cause analysis and then recall the specific process switch in arm world,  and the whole process switch at the end.


As I said before, we found that the prev and next will changed after cpu_switch_to(). When I read the code in "arch/arm64/kernel/process.c" at first, I think the next and prev is the argument of `__switch_to` which should not be changed during the function call:
```
/*
 * Thread switching.
 */
__notrace_funcgraph struct task_struct *__switch_to(struct task_struct *prev,
                                struct task_struct *next)
{
        struct task_struct *last;

        fpsimd_thread_switch(next);
        tls_thread_switch(next);
        hw_breakpoint_thread_switch(next);
        contextidr_thread_switch(next);
        entry_task_switch(next);
        uao_thread_switch(next);

        /*
         * Complete any pending TLB or cache maintenance on this CPU in case
         * the thread migrates to a different CPU.
         */
        dsb(ish);

        /* the actual thread switch */
        last = cpu_switch_to(prev, next);

        return last;
}
```

But it is actually changed. So I read the assembly in "arch/arm64/kernel/entry.S". The x19 and x20 is switched to the new values!
TODO: explain the assembly here in details.

```
/*
 * Register switch for AArch64. The callee-saved registers need to be saved
 * and restored. On entry:
 *   x0 = previous task_struct (must be preserved across the switch)
 *   x1 = next task_struct
 * Previous and next are guaranteed not to be the same.
 *
 */
ENTRY(cpu_switch_to)
        mov     x10, #THREAD_CPU_CONTEXT
        add     x8, x0, x10
        mov     x9, sp
        stp     x19, x20, [x8], #16             // store callee-saved registers
        stp     x21, x22, [x8], #16
        stp     x23, x24, [x8], #16
        stp     x25, x26, [x8], #16
        stp     x27, x28, [x8], #16
        stp     x29, x9, [x8], #16
        str     lr, [x8]
        add     x8, x1, x10
        ldp     x19, x20, [x8], #16             // restore callee-saved registers
        ldp     x21, x22, [x8], #16
        ldp     x23, x24, [x8], #16
        ldp     x25, x26, [x8], #16
        ldp     x27, x28, [x8], #16
        ldp     x29, x9, [x8], #16
        ldr     lr, [x8]
        mov     sp, x9
        msr     sp_el0, x1
        ret
ENDPROC(cpu_switch_to)
```
So I disassembly the process.o: `aarch64-linux-gnu-objdump -Sx arch/arm64/kernel/process.o > process.S`

x1 and x0 save to x19 and x20.
```
00000000000003f8 <__switch_to>:
/*
 * Thread switching.
 */
__notrace_funcgraph struct task_struct *__switch_to(struct task_struct *prev,
                                struct task_struct *next)
{
 3f8:   a9be7bfd        stp     x29, x30, [sp,#-32]!
 3fc:   910003fd        mov     x29, sp
 400:   a90153f3        stp     x19, x20, [sp,#16]
 404:   aa0103f3        mov     x19, x1
 408:   aa0003f4        mov     x20, x0
        struct task_struct *last;

        fpsimd_thread_switch(next);
 40c:   aa0103e0        mov     x0, x1
 410:   94000000        bl      0 <fpsimd_thread_switch>
```

and x19 and x20 will restore to x1 and x0 when call `cpu_switch_to`. why?
```
        /* the actual thread switch */
        last = cpu_switch_to(prev, next);
 47c:   aa1303e1        mov     x1, x19
 480:   aa1403e0        mov     x0, x20
 484:   94000000        bl      0 <cpu_switch_to>
                        484: R_AARCH64_CALL26   cpu_switch_to
```

After analysis the kernel compiler argument, I found that "-O2" will get this result. here is my test.
TODO: disassemble the main->foo->bar with two arguments.

Think about the reason:
when A call B, if A and B use the same arguemnts. Because x0-x7 is caller saved register. A must save the corresponding register before calling B.
But it still hard to see why x0 and x1 will store to callee saved register. x0 and x1 should store to stack.
The logic could be: if A call B, two functions use the same argument, A will store the argument of A to stack. And during cpu_switch_to, the stack will be swaped through x9. After context switch, the variable in stack will be swtich too.
The question is why x0 and x1 save to x19 and x20? It relative to kernel compiler option.

fpsimd_thread_switch(next);
---------------------------
tls_thread_switch(next);
------------------------
hw_breakpoint_thread_switch(next);
----------------------------------
contextidr_thread_switch(next);
-------------------------------
entry_task_switch(next);
------------------------
uao_thread_switch(next);
------------------------


Notes: this is part of the documents of understanding Linux Kernel with arm architecture.

