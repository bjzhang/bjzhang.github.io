kiwi免安装选择
--------------
kiwi安装时需要选择磁盘（如果磁盘有多块），还需要确认格式化，如果我确定这些信息，可以去掉这些选项。

kiwi调试
--------
日志位于: "$HOME/works/software/kiwi/build/image-root.log"
构建镜像生成的根文件系统: "$HOME/works/software/kiwi/build/image-root"

kiwi部署
--------
### 物理机
物理机支持pxe，光盘启动，硬盘直接dd。
### 虚拟机
除了前面的virt-install安装。如果是服务器，不方便安装GUI，还可以通过笔者的脚本/Users/bamvor/works/source/small_tools_c
llection/appliance_helper/install.sh安装，服务器端有vnc server即可。
### 云
google cloud 感觉没空做。
要不要和suse studio ams镜像结合一起说？
