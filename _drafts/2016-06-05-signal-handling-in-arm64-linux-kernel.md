---
layout: post
title: signal handling in linux kernel take arm64 as example
categories: [kernel]
tags: [kernel, signal, arm64]
---

Recently, I found a bug in my ILP32 feature and send a patch to LKML.
<http://www.gossamer-threads.com/lists/linux/kernel/2452466#2452466>

I think it it worth to recall the signal handling in linux kernel at this time.

I found an issue of unwind with the following code. The correct backtrace 
should be: 
(gdb) where 
#0 0x004004d0 in my_sig (sig=11) at test_force3.c:16 
#1 <signal handler called> 
#2 func2 (num=0) at test_force3.c:22 
#3 0x00400540 in func1 (num=1) at test_force3.c:28 
#4 0x00400574 in main (argc=1, argv=0xffd7bc04) at test_force3.c:33 

Without my patch, the backtrace is: 
(gdb) where 
#0 0x00400490 in my_sig (sig=11) at test_force3.c:16 
#1 <signal handler called> 
#2 0x004004e4 in main (argc=1, argv=0xffe6f8f4) at test_force3.c:33 

With my patch which fix the wrong frame pointer(setup_return calculate the offset 
of fp through ilp32_sigframe instead of sigfreame), the backtrace is: 
(gdb) where 
#0 0x00400490 in my_sig (sig=11) at test_force3.c:16 
#1 <signal handler called> 
#2 func1 () at test_force3.c:28 
#3 0x004004e4 in main (argc=1, argv=0xffe6f8f4) at test_force3.c:33 

I am not sure there is still some issue in kernel. But it seem that the gdb of ilp32 
does not work correctly when unwind without framepointer. 

The test code is: 

#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <signal.h> 

void my_sig(int sig) 
{ 
printf("sig=%d\n", sig); 
*(int *)0 = 0x0; 
} 


void func2() 
{ 
*(int *)0 = 0x0; 
} 

void func1() 
{ 
func2(); 
} 

int main(int argc, char **argv) 
{ 
signal(11, my_sig); 
func1(); 
return 0; 
} 


The full patch is as follows: 

From 7e364a765097f57aed2d73f94c1688c2e7343e79 Mon Sep 17 00:00:00 2001 
From: Bamvor Jian Zhang <bamvor.zhangjian [at] huawei> 
Date: Sat, 4 Jun 2016 14:30:05 +0800 
Subject: [PATCH] arm64: ilp32: fix for wrong fp offset when calculate the 
new fp 

ILP32 define its own sigframe(ilp32_sigframe) because of the 
difference uc_context. setup_return do not use ilp32 specific 
sigframe to calculate the new offset of fp which lead to wrong 
fp in signal handler. At this circumstance, gdb backtrace will miss 
one item: 
(gdb) where 

It should be: 
(gdb) where 

The test code is as follows: 

void my_sig(int sig) 
{ 
printf("sig=%d\n", sig); 
*(int *)0 = 0x0; 
} 

void func2(int num) 
{ 
printf("%s: %d\n", __FUNCTION__, num); 
*(int *)0 = 0x0; 
func2(num-1); 
} 

void func1(int num) 
{ 
printf("%s\n", __FUNCTION__); 
func2(num - 1); 
} 

int main(int argc, char **argv) 
{ 
signal(11, my_sig); 
func1(argc); 
return 0; 
} 

This patch fix this by passing the correct offset of fp to 
setup_return. 
Test pass on both ILP32 and LP64 in aarch64 EE. 

Signed-off-by: Bamvor Jian Zhang <bamvor.zhangjian [at] huawei> 
--- 
arch/arm64/include/asm/signal_common.h | 3 ++- 
arch/arm64/kernel/signal.c | 9 +++++---- 
arch/arm64/kernel/signal_ilp32.c | 4 ++-- 
3 files changed, 9 insertions(+), 7 deletions(-) 

diff --git a/arch/arm64/include/asm/signal_common.h b/arch/arm64/include/asm/signal_common.h 
index de93c71..a5d7b63 100644 
--- a/arch/arm64/include/asm/signal_common.h 
+++ b/arch/arm64/include/asm/signal_common.h 
@@ -29,6 +29,7 @@ int setup_sigcontex(struct sigcontext __user *uc_mcontext, 
struct pt_regs *regs); 
int restore_sigcontext(struct pt_regs *regs, struct sigcontext __user *sf); 
void setup_return(struct pt_regs *regs, struct k_sigaction *ka, 
- void __user *frame, off_t sigframe_off, int usig); 
+ void __user *frame, off_t sigframe_off, off_t fp_off, 
+ int usig); 

#endif /* __ASM_SIGNAL_COMMON_H */ 
diff --git a/arch/arm64/kernel/signal.c b/arch/arm64/kernel/signal.c 
index 038bebe..e66a6e9 100644 
--- a/arch/arm64/kernel/signal.c 
+++ b/arch/arm64/kernel/signal.c 
@@ -256,14 +256,14 @@ static struct rt_sigframe __user *get_sigframe(struct ksignal *ksig, 
} 

void setup_return(struct pt_regs *regs, struct k_sigaction *ka, 
- void __user *frame, off_t sigframe_off, int usig) 
+ void __user *frame, off_t sigframe_off, off_t fp_off, 
+ int usig) 
{ 
__sigrestore_t sigtramp; 

regs->regs[0] = usig; 
regs->sp = (unsigned long)frame; 
- regs->regs[29] = regs->sp + sigframe_off + 
- offsetof(struct sigframe, fp); 
+ regs->regs[29] = regs->sp + sigframe_off + fp_off; 
regs->pc = (unsigned long)ka->sa.sa_handler; 

if (ka->sa.sa_flags & SA_RESTORER) 
@@ -294,7 +294,8 @@ static int setup_rt_frame(int usig, struct ksignal *ksig, sigset_t *set, 
err |= setup_sigframe(&frame->sig, regs, set); 
if (err == 0) { 
setup_return(regs, &ksig->ka, frame, 
- offsetof(struct rt_sigframe, sig), usig); 
+ offsetof(struct rt_sigframe, sig), 
+ offsetof(struct sigframe, fp), usig); 
if (ksig->ka.sa.sa_flags & SA_SIGINFO) { 
err |= copy_siginfo_to_user(&frame->info, &ksig->info); 
regs->regs[1] = (unsigned long)&frame->info; 
diff --git a/arch/arm64/kernel/signal_ilp32.c b/arch/arm64/kernel/signal_ilp32.c 
index a8ea73e..9030f14 100644 
--- a/arch/arm64/kernel/signal_ilp32.c 
+++ b/arch/arm64/kernel/signal_ilp32.c 
@@ -147,7 +147,6 @@ static struct ilp32_rt_sigframe __user *ilp32_get_sigframe(struct ksignal *ksig, 
struct ilp32_rt_sigframe __user *frame; 

sp = sp_top = sigsp(regs->sp, ksig); 
- 
sp = (sp - sizeof(struct ilp32_rt_sigframe)) & ~15; 
frame = (struct ilp32_rt_sigframe __user *)sp; 

@@ -183,7 +182,8 @@ int ilp32_setup_rt_frame(int usig, struct ksignal *ksig, 
err |= setup_ilp32_sigframe(&frame->sig, regs, set); 
if (err == 0) { 
setup_return(regs, &ksig->ka, frame, 
- offsetof(struct ilp32_rt_sigframe, sig), usig); 
+ offsetof(struct ilp32_rt_sigframe, sig), 
+ offsetof(struct ilp32_sigframe, fp), usig); 
regs->regs[1] = (unsigned long)&frame->info; 
regs->regs[2] = (unsigned long)&frame->sig.uc; 
} 
-- 
1.8.4.5 
