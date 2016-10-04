
class: center, middle

#An efficient unit test and fuzz tools for kernel/libc porting

Bamvor Jian Zhang

Huawei

.date[Oct, 6, 2016]

???
cmd: markdown-to-slides --style remark-template.css --l template.html -d ILP32_syscall_unit_test_linuxcon_europe.md -o ILP32_syscall_unit_test_linuxcon_europe.html

The idea is:
1.  Share the experience of development of ILP32 which show the lack of syscall unit test
2.  Compare the exist testsuite for kernel and glibc. The shortage
3.  Introduce our syscall unit test which based on trinity

## Self introduction
*   Kernel developer from Huawei
*   Linaro kernel working group assignee
*   Focus on migration of 32-bit application
*   Interested in memory management

???
Migrate from ARM 32-bit hardware to 64-bit hardware which include the features, interfaces and kabi.
Mentioned the THP code?

## Contents
*   What is aarch64 ILP32?
*   Why we need more test for ILP32?
*   What's missing in the existing test tools?
*   Introduce our test tools.

# aarch64 ILP32 overview

???
ILP32 is one of three ABIs existing on ARM64. Which provide a software migration path from ARM 32-bit hardware to 64-bit hardware

## What is ILP32?
### ARM architecture
![ARM architechture](../../public/images/syscall_unit_test/arm_architecture.jpg)
.footnote[.red[*] This [picture](http://www.arm.com/zh/assets/images/roadmap/V5_to_V8_Architecture.jpg) is belong to the ARM company]

???
aarch32 is almost compatable with ARMv7. If your application is compiled as ARMv6 or previous architectures, there is some instruction emulation. performance degrade.
What if aarch32 is not supported by hardware? Cortex-A35 do not support aarch64.

### Data model
![data model](../../public/images/syscall_unit_test/data_model.png)

???
mentioned the difference ILP32. Version B of ILP32 is align with x32.

### Migrate 32-bit application to 64-bit hardware
![migrate](../../public/images/syscall_unit_test/migrate_32bit_app_to_64bit_hardware.svg)

???
ILP32 could choise which type of syscall, compat, or normal?
I will mention the difference design of it.

### ILP32 enablement
![enablement](../../public/images/syscall_unit_test/aarch64_ilp32_architecture.png)

???
Technology details of ILP32.

## Why we need unit test for ILP32?
### Lots of choices to be made for a new API
*   The definition of basic type in userspace(NOT the kernel part!)
*   Argument passing: one 64-bit register or two 32-bit registers
*   Sanitize register contents

???
Such as time_t, off_t(file relative types) and so on

### The definition of basic type in userspace
```c
#define __DEV_T_TYPE            __UQUAD_TYPE
#define __UID_T_TYPE            __U32_TYPE
#define __GID_T_TYPE            __U32_TYPE
#define __INO_T_TYPE            __UQUAD_TYPE
#define __INO64_T_TYPE          __UQUAD_TYPE
#define __MODE_T_TYPE           __U32_TYPE
#define __NLINK_T_TYPE          __U32_TYPE
#define __OFF_T_TYPE            __SQUAD_TYPE
#define __OFF64_T_TYPE          __SQUAD_TYPE
#define __PID_T_TYPE            __S32_TYPE
#define __RLIM_T_TYPE           __UQUAD_TYPE
#define __RLIM64_T_TYPE         __UQUAD_TYPE
#define __BLKCNT_T_TYPE         __SQUAD_TYPE
#define __BLKCNT64_T_TYPE       __SQUAD_TYPE
#define __FSBLKCNT_T_TYPE       __UQUAD_TYPE
#define __FSBLKCNT64_T_TYPE     __UQUAD_TYPE
#define __FSFILCNT_T_TYPE       __UQUAD_TYPE
#define __FSFILCNT64_T_TYPE     __UQUAD_TYPE
```

### The definition of basic type in userspace(Cont.)
```c
#define __FSWORD_T_TYPE         __SWORD_TYPE
#define __ID_T_TYPE             __U32_TYPE
#define __CLOCK_T_TYPE          __SLONGWORD_TYPE
#define __TIME_T_TYPE           __SLONGWORD_TYPE
#define __USECONDS_T_TYPE       __U32_TYPE
#define __SUSECONDS_T_TYPE      __SLONGWORD_TYPE
#define __DADDR_T_TYPE          __S32_TYPE
#define __KEY_T_TYPE            __S32_TYPE
#define __CLOCKID_T_TYPE        __S32_TYPE
#define __TIMER_T_TYPE          void *
#define __BLKSIZE_T_TYPE        __S32_TYPE
#define __FSID_T_TYPE           struct { int __val[2]; }
/* ssize_t is always singed long in both ABIs. */
#define __SSIZE_T_TYPE          __SLONGWORD_TYPE
#define __SYSCALL_SLONG_TYPE    __SLONGWORD_TYPE
#define __SYSCALL_ULONG_TYPE    __ULONGWORD_TYPE
#define __CPU_MASK_TYPE         __ULONGWORD_TYPE
```

## Four big changes in 3 years

### Version A
*   Most of syscalls are compat syscalls
*   time_t and off_t are 32-bit

### Version B
Similar to x32(x86 ILP32)
*   Most of syscalls are 64-bit syscalls
*   time_t and off_t are 64-bit
*   Incompatible with ARM32 compat-ioctl
???
Glibc community think that time_t must be 32-bit. 32-bit time_t lead to incompatible with ARM32 compat-ioctl

### Version C
Come back to version A
*   Most of syscalls are compat syscalls
*   time_t and off_t are 32-bit
*   Pass 64-bit variable through one 64-bit reg
*   Do the sign/zero extension when entering kernel
???
TODO: need more picture to illustate why it is not a clear design.
It is hard to maintain the code of glibc because of the arguments passing and delouse

/*
#### Pass 64-bit variable through one 64-bit reg
*   Kernel
    *   More than 10 syscalls is differenct from ARM
*   Glibc
    *   Could not inherit the ARM design. Need to handle by hand.

#### Sign/zero extension in kernel
*   Easy to handle if all the variable is 32-bit in userspace
*   Need handle by hand if mix 32-bit and 64-bit variable
*/

### Version D
*   More compat syscalls compare with version C
*   Pass 64-bit variable through two 32-bit regs
*   Clear the top-halves of of all the 64-bit regs of a syscall when entering kernel
*   time_t is 32-bit and **off_t is 64-bit**
???
Current version. Glibc community is re-organzie the code for a generic new API
We hope ILP32 could be upstreamed soon. This is part of reason we want to add this unit test.

## How many issues found by trinity when LTP syscall fails are < 20?

## 0

# Compare existing kernel/glibc test tools
---
*   Whether easy to reproduce a failure
*   Whether support coverage
*   Whether support libc test
*   Whether generate full random data to basic data type

## LTP and glibc testsuite
*   The Classic testsuite for kernel and glibc
*   Cons
    *   No fuzz test. Test may pass while some issues are hidden

## [Trinity](https://github.com/kernelslacker/trinity)
*   Pros
    *   Generate fuzz data in a set of data type
    *   Support lots of architecture
*   Cons
    *   Generate random address instead of basic data type for most of pointers
    *   Takes too long to produce an issue and Takes much longer to re-produce and analyze it
    *   Do not support coverage(?)

???
Trinity is developed in a long time. It could randomize the parameter of syscall and run individual syscall standalone or parallel. When I do the long time parallel test(not for ILP32), it could report some bug, e.g. hang, panic. It is useful but it is indeed hard to debug because it usually fail after a long time running. I do not know what does it exactly do

## [Syzkaller](https://github.com/google/syzkaller)
![structure of syzkaller](../../public/images/syscall_unit_test/syzkaller-structure.png)

.footnote[.red[*] This [picture](https://github.com/google/syzkaller/blob/master/structure.png?raw=true) is belong to the syzkaller project]
???
The picture came from https://github.com/google/syzkaller

## Syzkaller(Cont.)
*   Pros
    *   Can recursively randomize base data type
    *   Can generate readable short testcases
    *   Can do the coverage
*   Cons
    *   Does not test C library

???
Compare with Trinity, syzkaller is quite different. Here is the comparision between syzkaller and our tools:
1.  Syzkaller could recursively randomize base date type in syscall which means it is possible generate more meaningfull syscall test. But it only test the syscall through syscall() function. It assume that the C library is correct and stable. But it is wrong if we are porting new ABI(such as ILP32) or architecture to glibc and kernel. We need to take C library into account. This is what my tools could do

2.  Syzkaller could generate the readable short testcases. Our tools could only test individual syscall and check the correctness of parameter and return value. I think it is enough for the unit test which tests syscall one by one

3.  Syzkaller could do the coverage. Our tools could not. I think it is useful for me. I plan to add the coverage later
The main function in syz-fuzzer/fuzzer.go will check whether kcov is enabled when noCover flag is not set.  Function triageInput is only used when noCover is not set. It will generate the score of coverage difference.  It seems that syz-fuzzer/fuzzer.go call BuildChoiceTable to generate the syscall list which is the input for syz-executor

## AFL and [Triforce](https://github.com/nccgroup/TriforceLinuxSyscallFuzzer)
*   Pros:
    *   Base on the [TriforceAFL](https://github.com/nccgroup/TriforceAFL)
    *   Do not need the coverage support in kernel
*   Cons
    *   Need special instruction in qemu

???
Project Triforce: Run AFL on Everything!
http://codemonkey.org.uk/2015/05/05/thoughts-feedback-loop-trinity/
quotes:
I awoke suddenly with a crazy idea: "Run AFL on the Linux Kernel."
Well, this isn't exactly a totally new idea. In fact, Google has had a very successfully feedback-driven Linux syscall fuzzer, syzkaller. Trinity 1, perhaps the most successful Linux system call fuzzer, briefly considered adding feedback support. Oracle recently showed some very intersting work on using AFL to fuzz Linux filesystem drivers.
Unlike syzkaller, kernels don't need to be built with coverage support. Any kernel will do. And, since we're capturing edge info (rather than coverage), we get the full benefits of AFL's feedback engine.
If the operating system uses any other resources besides memory, these resources will not be isolated between test cases. For this reason, its usually desirable to boot the operating system using an in-memory filesystem, such as a Linux ramdisk image.
The driver communicates with the virtual machine through a special instruction that was added to the QEMU x64 CPU that we call aflCall (0f 24).
Using TriforceAFL, we built a Linux syscall fuzzer (TriforceLinuxSyscallFuzzer). We'll have a whitepaper coming out soon detailing how we built it, how we generated test cases, how it works, and analyzing the bugs it found.

## What's missing?
*   No testsuite care about the porting of libc and kernel
*   No full unit test for syscall

???
*   The developer who do the port is care about both kernel and libc
*   There is no full unit test for syscall. These tools assume that the parameter passing is correct from userspace/libc to kernel. It may lead to strage issue for test which is not easy to debug

# Introduce syscall unit test

## The test flow of syscall unit test
![syscall unit test diagram](../../public/images/syscall_unit_test/syscall_unit_test_diagram.svg)

???
Dump the function                                 Dump the function
prototype from                                    prototype from C
vmlinux from the                                  library from the
sys_call_table                                    given list(posix
array in kernel.                                  interfaces or user
       |                                          defined)
       |                                                 |
       |                                                 |
      \|/                                               \|/
       `                                                 `
Generate jprobe        Modity Trinity to          Generate struct
hook according to      support run syscall        fuzz generator
prototype which        syscall from C             from the prototype
will recursively       libray instead             And add them of
print the syscall      syscall() function         to trinity. Trinity
value.                       |                    will recursively
       \                     |                    print the function
        \                    |                    parameter
         \                   |                           /
          -----------------------------------------------
                             |
                            \|/
                             `
              Run the trinity each syscall once
              and compare the function parameter
              printed in kernel and userspace
              If inconsistent, print specific
              information, such endian issue,
              32<->64-bit conversion issue and
              so on

### Dump the prototype of function and struct
*   Script base on [abi-dumper](https://github.com/lvc/abi-dumper.git)
*   Generate the fuzzer from json.

???
Including struct fuzzer and jprobe hook.
/*
function:
"get_compat_itimerval":[
    {"Param":{
        "o": "7022179",
        "i": "8184682"    }},
    {"Return": "432"}
],

type:
"7022179":[
    {"Name":"struct itimerval*"},
    {"BaseType":"6986882"},
    {"Type":"Pointer"}],
"6986882":[
    {"Name":"struct itimerval"},
    {"Type":"Struct"},
    {"Memb":{
        "it_interval": "1136139",
        "it_value": "1136139"    }}],
"1136139":[
    {"Name":"struct timeval"},
    {"Type":"Struct"},
    {"Memb":{
        "tv_sec": "532",
        "tv_usec": "1131789"    }}],
"532":[
    {"Name":"__kernel_time_t"},
    {"BaseType":"421"},
    {"Type":"Typedef"}],
"1131789":[
    {"Name":"__kernel_suseconds_t"},
    {"BaseType":"421"},
    {"Type":"Typedef"}],
"421":[
    {"Name":"__kernel_long_t"},
    {"BaseType":"432"},
    {"Type":"Typedef"}],
"432":[
    {"Name":"long"},
    {"Type":"Intrinsic"}],
*/

### The fuzzer for structs in userspace
```cpp
struct itimerspec *get_itimerspec()
{
    struct itimerspec *p = malloc(sizeof(struct itimerspec));

    p->it_interval.tv_sec = (unsigned long) rand64();
    p->it_interval.tv_nsec = (unsigned long) rand64();
    p->it_value.tv_sec = (unsigned long) rand64();
    p->it_value.tv_nsec = (unsigned long) rand64();

    //print all the value of this struct
    return p;
}
```

### The Jprobe hook in kernel module
```cpp
long JC_SyS_getitimer(int which, struct compat_itimerval *it)
{
    printk("parameter value:it<%u>, which<%u>", it, which);
    printk("it->it_interval.tv_sec<%u>, it->it_interval.tv_usec<%u>, it->it_value.tv_sec<%u>, it->it_value.tv_usec<%u>",
            it->it_interval.tv_sec, it->it_interval.tv_usec,
            it->it_value.tv_sec, it->it_value.tv_usec);
    jprobe_return();        /* Always end with a call to jprobe_return(). */
    return 0;
}

static struct jprobe my_jprobe = {
    .entry = JC_SyS_getitimer,
    .kp = {
    .    symbol_name = "compat_sys_getitimer",
    },
};
```
---
```cpp
static int __init jprobe_init(void)
{
    int ret;

    ret = register_jprobe(&my_jprobe);
    if (ret < 0) {
            printk(KERN_INFO "register_jprobe failed, returned %d\n", ret);
            return -1;
    }

    return 0;
}

static void __exit jprobe_exit(void)
{
    unregister_jprobe(&my_jprobe);
    printk(KERN_INFO "jprobe at %p unregistered\n", my_jprobe.kp.addr);
}
```

???
Step to generate generate-struct.c and jprobe hooks:
1.  Compile the kernel/libc/binary which include the functions you want to generate.
2.  Dump function and struct information through modified abi-dumper.pl, named them as symbolinfo and typeinfo. You may need add "--all" and/or "--dump-static" depends on your binaries.
3.  Generate the file through trinity/scripts/struct_extract.py.

### Modify trinity
*   Call syscall through C library
*   Add the missing struct in syscall
*   Add jprobe hooks for capturing the arguments of syscall
*   Add or Change some output message for script

???
There are some hacks and the original funtion of trinity may be broken. The main changes in trinity are as follows:
1.  Call syscall through c library via call_glibc_syscalls() instead of direct syscall via syscall().
2.  Add new file generate-struct.c including the missing data type mentioned in syscall. This file is generated by ./struct_extract.py with a little modification. It should be fully auto generated in future.
3.  Add more date types in fill_arg()(generate-args.c) and include/syscall.h.
4.  Modify the syscallentry struct in syscalls directory according to the newly added data types.
5.  Add or Change some output message for script.
6.  Add jprobe hooks in modules directory. Such hook will be inserted before trinity test and removed after test.

### Run it!
trinity/scripts/do_test_struct.sh

## Found two issues in a specific version
### readahead
```cpp
ssize_t readahead(int fd, off64_t offset, size_t count);
```

## Found two issues in a specific version
### sync_file_range
*   int sync_file_range(int fd, off64_t offset, off64_t nbytes, unsigned int flags);
*   int sync_file_range2(int fd, unsigned int flags, off64_t offset, off64_t nbytes);

???
readahead: pass off64_t error
sync_file_range: wrong order of parameter.

## The return value test of syscall
*   Random return value through kretprobe

???
Random return the value of syscall to userspace to in order to test whether userspace handle the return value/errno correctly

## TODO list
*   Support all the syscalls which are not wrapped by libc
*   Full automation in generating the fuzz code

## What is the future of syscall unit test?
Contribute to LTP and/or glibc testsuite?

Or keep it as a standalone testsuite?

## Code published in github
<https://github.com/bjzhang/trinity/tree/syscall_unittest>

<https://github.com/bjzhang/abi-dumper/tree/json_output>

# Thanks

