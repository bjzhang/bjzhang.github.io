
class: center, middle

#An efficient unit test and fuzz tools for kernel/libc porting

Bamvor Jian Zhang

Huawei

.date[Oct, 6, 2016]

???
cmd: markdown-to-slides --style remark-template.css --l template.html -d ILP32_syscall_unit_test_linuxcon_europe.md -o ILP32_syscall_unit_test_linuxcon_europe.html

The idea is:
1.  Share the experience of development of ILP32 which show the lack of syscall unit test.
2.  Compare the exist testsuite for kernel and glibc. The shortage.
3.  Introduce our syscall unit test which based on trinity.

# Self introduction
*   Kernel developer from Huawei
*   Linaro kernel working group assignee
*   Focus on migration 32bit application from arm 32bit hardware to 64bit hardware
*   Interested in in memory management

# aarch64 ILP32 overview.
???
ILP32 is one of three ABIs existing on arm64. Which provide a software migration path from arm 32bit hardware to 64bit hardware.

## What is ILP32?
### Data model
![data model](../../public/images/syscall_unit_test/data_model.png)

### arm architecture
![arm architechture](../../public/images/syscall_unit_test/arm_architecture.jpg)

### Migrate 32bit application to 64bit hardware
![migrate](../../public/images/syscall_unit_test/migrate_32bit_app_to_64bit_hardware.svg)

### ILP32 enablement
![enablement](../../public/images/syscall_unit_test/aarch64_ilp32_architecture.png)

## Why we need unit test for ILP32?
### There are actually lots of choices for a new api.
*   The definition of basic type in userspace, such as time_t, off_t(file relative types) and so on.
*   Argument passing.
*   Sanitize register contents.

## Lots of ABI changes.
During developemnt of ILP32, there are four big changes in ILP32 which lead to lots of duplicate verfication work.

### Version A
*   Most of syscall is compat syscall.
*   time_t and off_t is 32bit

### Version B
*   Most of syscall is as same as 64bit syscall.
*   time_t and off_t is 64bit. But in POSIX, time_t should be 32bit for 32bit application.
???
Glibc community think that time_t must be 32bit.

### Version C
Came back to verion A

*   Most of syscall is compat syscall.
*   time_t and off_t is 32bit
*   Pass 64bit variable through one 64bit register.
*   Do the sign extend when enter into kernel.
???
It is hard to maintain the code of glibc because of the arguments passing and delouse.

### Version D
*   Most of syscall is compat syscall.
*   time_t is 32bit and **off_t is 64bit**(only affect the userspace interface!)
*   Pass 64bit variable through two 32bit register instead of one 64bit register
*   Clear the top-havies of of all the registers of syscall when enter kernel.
???
Current version. Glibc community is re-organzie the code for a generic new api.

## How many issues found by trinity when LTP syscall fails is < 20?

## 0

# Compare the exist kernel/glibc test tools
*   Whether easy to reproduce the failure.
*   Whether support coverage
*   Whether support libc test
*   Whether generate the full random data to basic data type

## LTP and glibc testsuite
*   The tridition testsuite for kernel and glibc.
*   No fuzz test. Test pass may hide some issue.

## Trinity
*   Generate the fuzz data in a set of data type
*   Generate the random address instead of basic data type for most of pointers.
*   Support lots of architecture
*   Takes too long to produce an issue and takes more and more to re-produce and analysis it
*   Is going to add the coverage support(?)

???
Trinity is developed in a long time. It could randomize the parameter of syscall and run individual syscall standalone or parallel. When I do the long time parallel test(not for ILP32), it could report some bug, e.g. hang, panic. It is useful but it is indeed hard to debug because it usually fail after a long time running. I do not know what does it exactly do.

## Syzkaller
![structure of syzkaller](../../public/images/syscall_unit_test/syzkaller-structure.png)

.footnote[.red[*] The original [picture](https://github.com/google/syzkaller/blob/master/structure.png?raw=true) is belong to the syzkaller project)]
???
The picture came from https://github.com/google/syzkaller

## Syzkaller(Cont.)
1.  Syzkaller could recursively randomize base data type
2.  Syzkaller could generate the readable short testcases
3.  Syzkaller could do the coverage
4.  Syzkaller do not test glibc

???
Compare with Trinity, syzkaller is quite different. Here is the comparision between syzkaller and our tools:
1.  Syzkaller could recursively randomize base date type in syscall which means it is possible generate more meaningfull syscall test. But it only test the syscall through syscall() function. It assume that the c library is correct and stable. But it is wrong if we are porting new ABI(such as ILP32) or architecture to glibc and kernel. We need to take c library into account. This is what my tools could do.

2.  Syzkaller could generate the readable short testcases. Our tools could only test individual syscall and check the correctness of parameter and return value. I think it is enough for the unit test which tests syscall one by one.

3.  Syzkaller could do the coverage. Our tools could not. I think it is useful for me. I plan to add the coverage later.
The main function in syz-fuzzer/fuzzer.go will check whether kcov is enabled when noCover flag is not set.  Function triageInput is only used when noCover is not set. It will generate the score of coverage difference.  It seems that syz-fuzzer/fuzzer.go call BuildChoiceTable to generate the syscall list which is the input for syz-executor.

## AFL and triforce
*   Do not need the coverage support in kernel.
    Cool for the old kernel
*   Need special instrucion in qemu.

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
*   There is no testsuite care about the porting of libc and kernel.
*   There is no full unit test for syscall.

???
*   The developer who do the port is care about both kernel and libc.
*   There is no full unit test for syscall. These tools assume that the parameter passing is correct from userspace/libc to kernel. It may lead to strage issue for test which is not easy to debug.

# Introduce syscall unit test

## The test flow of syscall unit test
![syscall unit test diagram](../../public/images/syscall_unit_test/syscall_unit_test_diagram.svg)

???
Dump the function                                 Dump the function
prototype from                                    prototype from c
vmlinux from the                                  library from the
sys_call_table                                    given list(posix
array in kernel.                                  interfaces or user
       |                                          defined).
       |                                                 |
       |                                                 |
      \|/                                               \|/
       `                                                 `
Generate jprobe        Modity Trinity to          Generate struct
hook according to      support run syscall        fuzz generator
prototype which        syscall from c             from the prototype.
will recursively       libray instead             And add them of
print the syscall      syscall() function         to trinity. Trinity
value.                       |                    will recursively
       \                     |                    print the function
        \                    |                    parameter.
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
              32<->64bit conversion issue and
              so on.

## Found two issues with our tools in a specific version
*   readahead
*   sync_file_range

## What is the future of syscall unit test?
Contribution to LTP and/or glibc testsuite?
Or keep it as a standalone test case?

## The return value test of syscall
Random return the value of syscall to userspace to in order to test whether userspace handle the return value/errno correctly.
# TODO list
*   Support all the syscalls which are not wrapped by libc.
*   Full automation in generating the fuzz code.

## Code published in github
<https://github.com/bjzhang/trinity>

# Q & A

