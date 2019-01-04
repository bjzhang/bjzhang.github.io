# "Hackweek: Hikey with sensor kit"

什么是hackweek？
----------------
<img alt="Calendar for Hackweek13" src="{{site.url}}/public/images/hackweek13/Hackweek_calendar.jpg" width="50%" align="left" style="margin: 0px 15px">
[hackweek](https://hackweek.suse.com/)是suse的传统，一年一到两次。至今已举办13界。hackweek的时候大家都可以放下手中的工作，做一些自己想做的事情。如果有临时紧急工作影响了hackweek，可以后面单独做自己的hackweek。hackweek是即是hacking for fun，也是suse产品创意的来源之一。
停下来想一想，有什么小改进能提高自己的工作效率，或者学些什么东西开阔自己的视野，哪怕就是读一本书，都可以作为hackweek的项目。

像[opensuse的构建系统](https://build.opensuse.org/)[open build service(obs)](http://openbuildservice.org/)和suse的[城域集群高可用系统(Geo Clustering)](https://www.suse.com/products/highavailability/geo-clustering/)都诞生于hackweek。

本次hackweek项目
----------------
本次北京共有来自suse和社区的28个项目。其中既有能解决工作中实际问题的小hacking。也有个人一直持续开发的开源项目。 社区主要来源是blug(Beijing Linux User Group)和高校学生。

![Project: suse game]({{site.url}}/public/images/hackweek13/Project_suse_game.jpg)
suse游戏：是suse三国杀之后又一个suse游戏项目，使用teambuild技能后全员满血。

虚拟化是suse北京的重要方向，这次hackweek相关项目有:
*   [X86_64 platform system program](https://hackweek.suse.com/13/projects/1104): 目标是做为x86平台的hypervisor, 可以在[这里](https://github.com/wjn740/hypervisor_last)找到代码。
*   [Research on COLO - the HA solution for virtualization](https://hackweek.suse.com/13/projects/1118)
[kindle highlights management tool](https://hackweek.suse.com/13/projects/1138): Kindle笔记管理软件。
*   Deploy HA stack with docker
*   Docker, Kubernetes research.

porting CDE to modern Linux distribution: Linux老兵怀念CDE，尝试移植CDE到ubuntu和opensuse.

我的项目
--------
![Hikey with relay]({{site.url}}/public/images/hackweek13/Hikey_with_relay.jpg)

这次是我离开suse后第一次参加hackweek，带来的是提高自己工作效率的小工程。
最近一直使用hikey开发，烧写内核时需要插拔跳线和usb otg host线(otg和uhost不能同时使用)，很是影响效率和心情，想一想如果将来合入补丁除了问题需要git bisect，那不是要死人么:p

hikey介绍参见lemaker hikey开箱。
我这次是通过hikey的（usb转）串口控制继电器，通过继电器控制otg和usb host线的插拔。同时通过继电器控制板子的跳线（通过fastboot命令烧写系统，需要一个跳线短接，烧写后需要断开）。

交流
----
blug社区的负责人之一对于hikey应用与嵌入式很感兴趣。并欢迎我司捐赠给blug社区。

suse北京的研发老大sunny一直在思考开源中的女性能做些什么，看到hikey，希望能通过hikey把开源操作系统和传感器连接起来。
