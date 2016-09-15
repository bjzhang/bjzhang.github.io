---
layout: post
title: Split stack support for arm64
categories: [Linux]
tags: [arm64, split-stack, gcc]
---

Today I found that arm64 will support split stack. I feel that it is a cool enhancement after read the comment from Adhemerval and document from Ian.

<img alt="split-stack-patches-from-Adhemerval" src="{{site.url}}/public/images/gcc/split-stack-arm64-from-Adhemerval.png" width="100%" align="center" style="margin: 0px 15px">

[Split Stacks in GCC](https://gcc.gnu.org/wiki/SplitStacks)
```
Ian Lance Taylor

The goal of split stacks is to permit a discontiguous stack which is grown automatically as needed. This means that you can run multiple threads, each starting with a small stack, and have the stack grow and shrink as required by the program. It is then no longer necessary to think about stack requirements when writing a multi-threaded program. The memory usage of a typical multi-threaded program can decrease significantly, as each thread does not require a worst-case stack size. It becomes possible to run millions of threads (either full NPTL threads or co-routines) in a 32-bit address space.

This is currently implemented for 32-bit and 64-bit x86 targets running GNU/Linux in gcc 4.6.0 and later. For full functionality you must be using the gold linker, which you can get by building binutils 2.21 or later with --enable-gold.
```

