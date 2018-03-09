
内核测试一个很大的话题，各个发行版，芯片公司，做产品的公司都会有自己的测试用例集合和测试方法。这里并不打算列出所有情况。只是一个内核开发的角度，大致描述下思路。

从测试角度，基本考虑三方面的测试，一个是快速的regression测试，用于测试每个提交有无问题；一个是比较完整的测试用于测试每日构建；第三个是长稳测试用于测试长期稳定性。

快速的regression测试
--------------------
这个测试一直是缺失的，社区从2012年才开始做。目前已经比较稳定了。社区推荐所有开发者提交补丁之前都运行这个测试。测试用例在"linux/tools/testing/selftests/"，使用文档在"linux/Documentation/dev-tools/kselftest.rst"。笔者原来做linaro assign负责修复过支持arm体系结构的一些问题，有问题欢迎一起讨论。

适合每日运行的用例
------------------
1.  这里最重要的可能就是LTP了。LTP覆盖范围比较广。每日测试中除了LTP中的长期测试都可以跑。LTP用例很多，如果出了问题，可以和golden内核比较（例如最新的upstream内核，某个发行版的稳定内核），如果都有同样的问题，可以作为低优先级处理。
2.  每次测试还需要文件系统，网络等重要子系统的测试，参考最后的测试用例集合。
3.  由于保证一个大家可用的内核基线非常重要，所以致力于构建arm生态环境的组织linaro一直在做一个[kernelci](https://kernelci.org/)的项目。kernel ci目前围绕构建和启动测试，测试了主要的stable kernel，master和next分支，主页上可以看到测试状态。未来也考虑增加更多的测试用例。有需求的话可以直接给linaro提需求。

长稳测试， fuzz测试
-------------------
传统的长稳测试是trinity。trinity通过完全随机的系统调用模拟系统长期运行时的可能出现的问题。笔者之前在华为工作时曾经借用过trinity代码使其更更好的测试系统调用接口，参考"https://www.linux.com/news/improving-fuzzing-tools-more-efficient-kernel-testing"。
trinity有个问题是发现的问题并不会提供复现方法，所以比较难复现。所以很多人致力于改进trinity。例如google开始做的syzkaller，能够根据测试的“深度”选择更有效的系统调用测试集合，并在出错时给出当时的测试过程，使问题更容易复现和解决。

哪里去找测试用例？
------------------
Intel国内的同学一直在维护一个测试项目[LKP](https://01.org/zh/lkp?langredirect=1)，里面有[常见的测试用例和使用方法](https://github.com/intel/lkp-tests/tree/master/tests)。另一个可以参考的地方是buildroot里面收集的测试用例。

