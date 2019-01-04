# LC3，我们来了！

一年一轮的linuxcon，明天在北京国际会议中心召开。Linuxcon之前每年都在北美日本欧洲各办一次，这是第一次在北京召开，也是近年来少有的在中国举办的开源盛会。细心的人可能发现会议名称居然不一样。北京的会议名称是LC3(Linuxcon + ContainerCon + Cloudopen)，其余地区是“Open Source Summit”。后者是linux foundation去年年底新推的会议，在LC3基础上增加了Open Community Conference。LC3围绕linux生态展开。我所在的部门专注于Linux内核和容器技术，多年来有持续的技术投入，部门去年在北美，欧洲做了四次演讲。今年亦有四个topic，欢迎关注：

*   容器资深maintainer黄强会介绍跨平台的容器管理工具containerd：[The New Container Engine from the New Containerd [E] - Qiang Huang, Huawei](https://lc3china2017.sched.com/event/AVBR/the-new-container-engine-from-the-new-containerd-e-qiang-huang-huawei)，黄强同学去年在柏林Linuxcon的topic是关于OCI的[OCI, Where Are We and Where Are We Going - Qiang Huang, Huawei](https://linuxconcontainerconeurope2016.sched.com/event/7oHv/oci-where-are-we-and-where-are-we-going-qiang-huang-huawei)

*   架构师刘春艳会介绍华为和Intel合作的安全的容器方案:[Secure Containers With EPT Isolation [E] - Chunyan Liu, Huawei & Jixing Gu, Intel](https://lc3china2017.sched.com/event/AV0F/secure-containers-with-ept-isolation-e-chunyan-liu-huawei-jixing-gu-intel)，去年部门也有一篇关于安全容器的topic：[VM-based Secure Container - Zhang Wei & Claudio Fontana, Huawei](https://linuxconcontainerconeurope2016.sched.com/event/7oIG/vm-based-secure-container-zhang-wei-claudio-fontana-huawei)

*   谢可杨和雷继棠会介绍OCI镜像技术：[Introduction to OCI Image Technologies Serving Container [C] - Keyang Xie & Jitang Lei, Huawei](https://lc3china2017.sched.com/event/AVBU/introduction-to-oci-image-technologies-serving-container-c-keyang-xie-jitang-lei-huawei)

*   内核团队师李彬会介绍arm64上热补丁技术： [Obstacles & Solutions for Livepatch Support on Arm64 Architecture [C] - Bin Li, Huawei](https://lc3china2017.sched.com/event/AVBC/obstacles-solutions-for-livepatch-support-on-arm64-architecture-c-bin-li-huawei)

*   来自我司操作系统实验室的马久跃介绍容器加速器方案： [Make Accelerator Pluggable for Container Engine [C] - Jiuyue Ma, Huawei](https://lc3china2017.sched.com/event/AVB7/make-accelerator-pluggable-for-container-engine-c-jiuyue-ma-huawei)

*   最后加点私货，本人去年在Linuxcon柏林的topic是[Efficient Unit Test and Fuzz Tools for Kernel/Libc Porting - Bamvor Jian Zhang, Huawei/Linaro](https://linuxconcontainerconeurope2016.sched.com/event/7o8q/efficient-unit-test-and-fuzz-tools-for-kernellibc-porting-bamvor-jian-zhang-huaweilinaro)，提供了一个易用可靠的系统调用单元测试框架，这其实是和社区一起推arm64 ILP32的“副产品”。

本文首发于本人公众号[敏达生活](https://mp.weixin.qq.com/s?__biz=MzI5MzcwODYxMQ==&mid=2247483669&idx=1&sn=252ecde48d0f2e58e26a2246bffbabdb&chksm=ec6cb739db1b3e2f8c2d5b8bc88f5b47376f7de4a09c1b43440c3c7434d31bf536d7e418c1ec#rd)，欢迎关注。题图是去年柏林Linuxcon的Tshirt。
