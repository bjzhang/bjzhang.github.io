---
layout: post
title: How to find out a definition of a syscall or libc function
categories: [Linux]
tags: [kernel, glibc, syscall]
---

This is a quick guide for finding out the definition of library function, syscall wrapper and definition. Wrote for my colleague who ask me the definition of sched_yield in glibc. I will also mention how to find out the definition of readdir(library function).

Check manpage to know it is a syscall or library function
---------------------------------------------------------
According to `man 1 man`, 2 is syscall, so `sched_yield` is only a syscall(There are lots of name share between library function and syscall).

```
    2   System calls (functions provided by the kernel)
    3   Library calls (functions within program libraries)
```

```
> man sched_yield
Man: find all matching manual pages (set MAN_POSIXLY_CORRECT to avoid this)
 * sched_yield (2)
   sched_yield (3p)
Man: What manual page do you want?
Man:
```

Manpage will also show the section number in the beginning of it. E.g. "GETDENTS(2)" means it is a syscall. We could see "Glibc does not provide a wrapper for these system calls" which is not shown in the manpage of sched_yield. It means that getdents is a syscall which is not wrapped by glibc. `sched_yield` is a syscall which is wrapped by glibc.

```
> man getdents
GETDENTS(2)                                                                                Linux Programmer's Manual                                                                               GETDENTS(2)

NOTES
       Glibc does not provide a wrapper for these system calls; call them using syscall(2).  You will need to define the linux_dirent or linux_dirent64 structure yourself.  However, you probably want to use
       readdir(3) instead.

       These calls supersede readdir(2).
```

Find the definition of syscall in  glibc
----------------------------------------
There are different ways to know where glibc implements a syscall. E.g. we could grep the source code, find the syscall named source code or find the dependency file in the build directory of glibc.

It is easy to know definition from the dependency file when there is the coresponding compiler:

```
> find . -name sched_yield.o.d
./posix/sched_yield.o.d
```

Usually, the second line of dependency show the definition. In sched_yield.o, we see headers instead of c source code. It means that sched_yield is wrapped by the assembly language.
```
> head -n 2 posix/sched_yield.o
$(common-objpfx)posix/sched_yield.o: \
  ../include/stdc-predef.h ../include/libc-symbols.h \
```

We could confirm it in sysd-syscalls in build directory. All the syscalls found in this file(exclude comments) is wrapped by assembly language and controlled by several macros:

```
#### CALL=sched_yield NUMBER=(124) ARGS=i: SOURCE=-
ifeq (,$(filter sched_yield,$(unix-syscalls)))
unix-syscalls += sched_yield
$(foreach p,$(sysd-rules-targets),$(foreach o,$(object-suffixes),$(objpfx)$(patsubst %,$p,sched_yield)$o)): \
                $(..)sysdeps/unix/make-syscalls.sh
        $(make-target-directory)
        (echo '#define SYSCALL_NAME sched_yield'; \
         echo '#define SYSCALL_NARGS 0'; \
         echo '#define SYSCALL_SYMBOL __sched_yield'; \
         echo '#include <syscall-template.S>'; \
         echo 'weak_alias (__sched_yield, sched_yield)'; \
         echo 'libc_hidden_weak (sched_yield)'; \
        ) | $(compile-syscall) $(foreach p,$(patsubst %sched_yield,%,$(basename $(@F))),$($(p)CPPFLAGS))
endif
```

The above macro show that the name, number of args and symbol of sched_yield syscall. There are also another two useful macros:

*   `#define SYSCALL_NOERRNO 1` means no error number will set after this syscall.
*   `#define SYSCALL_CANCELLABLE 1` means it is cancellable where pthread_cancel might happen. Reference "Cancellation points" in `man 7 pthreads` for further information.

Find the definition in kernel
-----------------------------
Most of the architecture make use of the `include/uapi/asm-generic/unistd.h` with their own options in unistd.h in "arch/<arch name>/include". We could saw the file name of a syscall in this file. For example, the following result show that `sched_yield()` is defined in "kernel/sched/core.c".

```
> grep "\(\/\*.*\*\/\)\|\(sched_yield\)" include/uapi/asm-generic/unistd.h | grep sched_yield -B 1
/* kernel/sched/core.c */
#define __NR_sched_yield 124
__SYSCALL(__NR_sched_yield, sys_sched_yield)
```

Searching "SYS.*sched_yield" in "kernel/sched/core.c" will find the location of definition.

Find the definition of glibc(for library function)
--------------------------------------------------
As we mentioned, `getdents()` is not wrapped by glibc. `readdir()` is the recommandation library function to use it. We could find the definition of `readdir()` is "sysdeps/posix/readdir.c" with above method:

```
> head -n 2 `find . -name readdir.o.d`
$(common-objpfx)dirent/readdir.o: \
 ../sysdeps/posix/readdir.c ../include/stdc-predef.h \
```

When we search in source code, we could know the name of function by searching alias like this:

```
> grep alias sysdeps/posix/readdir.c | grep -w readdir
weak_alias (__readdir, readdir)
```

And we could find that __readdir call getdents/getdents64 through __getdents in above file.

Q & A
-----
Q:  Why we do not search the syscall named file in glibc source code directly?

A:

*   Reason one: if the syscall is wrapped by assembly. There is no source code named by such syscall. In fact, sysd-syscalls is generated by sysdeps/unix/make-syscalls.sh based on the priority defined by Implies. The Implies file should read from the abi root directory. E.g. "sysdeps/unix/sysv/linux/aarch64/Implies" for aarch64 LP64.
*   Reason two: There might be several files, we could find the correct one by the Implies file. Note that function in "xxx/syscall_name.c" is usually a stub function(E.g. "dirent/readdir.c").

    *   For readdir:

        ```
        > find . -name readdir.c
        ./dirent/readdir.c
        ./sysdeps/posix/readdir.c
        ./sysdeps/mach/hurd/readdir.c
        ./sysdeps/unix/sysv/linux/wordsize-64/readdir.c
        ```
    *   For backtrace:

        ```
        > find . -name backtrace.c
        ./debug/backtrace.c
        ./sysdeps/microblaze/backtrace.c
        ./sysdeps/tile/backtrace.c
        ./sysdeps/sparc/backtrace.c
        ./sysdeps/mips/backtrace.c
        ./sysdeps/arm/backtrace.c
        ./sysdeps/alpha/backtrace.c
        ./sysdeps/ia64/backtrace.c
        ./sysdeps/powerpc/powerpc64/backtrace.c
        ./sysdeps/powerpc/powerpc32/backtrace.c
        ./sysdeps/aarch64/backtrace.c
        ./sysdeps/i386/backtrace.c
        ./sysdeps/m68k/backtrace.c
        ./sysdeps/s390/s390-64/backtrace.c
        ./sysdeps/s390/s390-32/backtrace.c
        ./sysdeps/x86_64/backtrace.c
        ./sysdeps/sh/backtrace.c
        ```


