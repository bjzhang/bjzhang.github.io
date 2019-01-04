# Large File Support in Linux

问题描述
========
客户nfs client提示:
```
mmap index err: Value too large for defined data type
```
经过理论分析和实验测试，该错误与nfs协议无关是client侧文件系统限制造成，解决办法是编译时加入"-D_FILE_OFFSET_BITS=64"。

理论分析
========
同样测试用例在64位系统测试无问题（具体发行版版本。。。），32位系统测试有问题（具体发行版版本。。。）。系统中文件操作实际由gnu libc(以下简称glibc)提供，通过检索[glibc FAQ](https://www.gnu.org/software/coreutils/faq/coreutils-faq.html#Value-too-large-for-defined-data-type)文档得之需要加入编译参数"-D_FILE_OFFSET_BITS=64"：
<img alt="see the disks in finder" src="{{site.url}}/public/images/misc/GNU_Coreutils_FAQ__glibc__Value_too_large_for_defined_data_type.png" width="100%" align="center" style="margin: 0px 15px">

该宏定义在[glibc宏定义文档](https://www.gnu.org/software/libc/manual/html_node/Feature-Test-Macros.html)具体解释了由Large File Support extension (LFS)引入。[Linux中最早关于LFS的文档](http://users.suse.com/~aj/linux_lfs.html)指出最早支持该宏定义的glibc版本是"glibc 2.2.3"。glibc2.2.3在2001年4月推出：
```
commit fa39bea49e8023069711bded87d3d1398717bc1a (tag: glibc-2.2.3, tag: cvs/glibc-2_2_3)
Author: Ulrich Drepper <drepper@redhat.com>
Date:   Thu Apr 26 20:56:45 2001 +0000

    Update.

            * sysdeps/unix/sysv/linux/ia64/syscalls.list: Add getunwind.
```
Redhat Enterprise Linux 3开始支持LFS，参见[Large File Support (LFS) on RHEL 3](https://people.redhat.com/berrange/notes/largefile.html)

其它参考文档：[维基百科](https://en.wikipedia.org/wiki/Large_file_support)
