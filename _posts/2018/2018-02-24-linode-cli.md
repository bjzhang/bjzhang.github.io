---
layout: post
title: 使用linode命令行工具创建和管理虚拟机(Linode cli getting started)
categories: [Software]
tags: [Linux, vm, ssh]
---

准备工作
--------
Linode最新的api是API V4，[新的beta api安装和使用说明](https://github.com/linode/linode-cli)与原来api类似，可以参考[原来的文档](https://www.linode.com/docs/platform/linode-cli/#using-the-cli)

1.	linode测速, 不考虑新加坡和日本容易被墙都地址，使用[Linode官方测试数据](https://www.linode.com/speedtest)的测试结果：
    1.	US East newark ~10k
    1.	US South atlanta ~20k
    1.	US Central dallas ~10k
    1.	US West fremont ~300k
    1.	Frankfurt ~200k
    1.	London ~200k

2.  从下面链接得到Personal access token: <https://cloud.linode.com/profile/tokens>，是一个64位的16进制数字。
<img alt="linode__persona_access_token.png" src="{{site.url}}/public/images/misc/linode__persona_access_token.png" width="100%" align="center" style="margin: 0px 15px">

3.  选择自己所需要的默认[服务器配置](https://www.linode.com/pricing)，我一直用Linode 1GB(注意这个类型的名称是nanode不是standard 1)，一个月5$。

install and configure
---------------------
测试环境os x 10.13.3, 对于Linux系统除了Home目录不同，其余应该一样。

1.  安装`pip3 install linode-cli`
    安装后有linode-beta和linode-cli两个命令，官方建议用linode-cli
    ```
    $ linode-beta
    ┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
    │ WARNING                                                                                                                           │
    ├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
    │ The 'linode-beta' command has been deprecated and renamed to 'linode-cli'.  Please invoke with that command to hide this warning. │
    └───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    usage: linode-beta [-h] [-t TOKEN] [-u USERNAME] [--raw]
                       [--separator SEPARATOR]
                       TYPE CMD
    linode-beta: error: the following arguments are required: TYPE, CMD
    ```

2.  首次运行需要执行"linode-cli configure"，填入上面的personal access token(64位16进制数字), 默认区域(5 - eu-west-1a)，默认服务器类型(9 - g5-nanode-1)，默认操作系统(16 - linode/opensuse42.3)。
    ```
    $ linode-cli configure
    Welcome to the Linode CLI.  This will walk you through some
    initial setup.

    First, we need a Personal Access Token.  To get one, please visit
    https://cloud.linode.com/profile/integrations/tokens and click
    "Create a Personal Access Token".  The CLI needs access to everything
    on your account to work correctly.

    Personal Access Token: (paste your personal access token)

    Default Region for deploying Linodes.  Choices are:
     1 - us-south-1a
     2 - us-west-1a
     3 - us-southeast-1a
     4 - us-east-1a
     5 - eu-west-1a
     6 - ap-south-1a
     7 - eu-central-1a
     8 - ap-northeast-1b
     9 - ap-northeast-1a

    Default Datacenter (Optional): 5

    Default type of Linode to deploy.  Choices are:
     1 - g5-standard-1
     2 - g5-standard-2
     3 - g5-standard-4
     4 - g5-standard-6
     5 - g5-standard-8
     6 - g5-standard-12
     7 - g5-standard-16
     8 - g5-standard-20
     9 - g5-nanode-1
     10 - g5-highmem-1
     11 - g5-highmem-2
     12 - g5-highmem-4
     13 - g5-highmem-8
     14 - g5-highmem-16

    Default type of Linode (Optional): 9

    Default Image to deploy to new Linodes.  Choices are:
     1 - linode/slackware13.37
     2 - linode/slackware14.1
     3 - linode/ubuntu14.04lts
     4 - linode/centos6.8
     5 - linode/centos7
     6 - linode/debian7
     7 - linode/debian8
     8 - linode/ubuntu16.04lts
     9 - linode/arch
     10 - linode/slackware14.2
     11 - linode/gentoo2018.01.15
     12 - linode/opensuseleap42.2
     13 - linode/containerlinux
     14 - linode/debian9
     15 - linode/fedora26
     16 - linode/opensuse42.3
     17 - linode/ubuntu17.10
     18 - linode/fedora27

    Default Image (Optional): 16

    Path to SSH public key to deploy to new Linodes (Optional): $HOME/.ssh/id_rsa.pub

    Config written to /path/to/your_home/.linode-cli
    ```

创建和管理虚拟机
----------------
1.	在默认区域，使用默认配置，默认发行版建立虚拟机（见上节说明）(linode-cli后面跟type(linode, domain, volume等)和cmd，不加type默认是linode)：
	```
	$ linode-cli create -P <your_root_password> -l linode1
	```
2.	创建后可以`linode-cli linode list`看到刚创建的linode1虚拟机逐步创建启动中，status是running就可以正常使用了，根据网页上显示的时间，我这次创建用了30s；
    ```
	$ linode-cli list
	Linode
	┌─────────┬──────────────┬────────────┬─────────┬───────┬────────┐
	│ label   │ status       │ location   │ backups │ disk  │ memory │
	├─────────┼──────────────┼────────────┼─────────┼───────┼────────┤
	│ linode1 │ provisioning │ eu-west-1a │ no      │ 20480 │ 1024   │
	└─────────┴──────────────┴────────────┴─────────┴───────┴────────┘
	$ linode-cli list
	Linode
	┌─────────┬─────────┬────────────┬─────────┬───────┬────────┐
	│ label   │ status  │ location   │ backups │ disk  │ memory │
	├─────────┼─────────┼────────────┼─────────┼───────┼────────┤
	│ linode1 │ booting │ eu-west-1a │ no      │ 20480 │ 1024   │
	└─────────┴─────────┴────────────┴─────────┴───────┴────────┘
	$ linode-cli list
	Linode
	┌─────────┬─────────┬────────────┬─────────┬───────┬────────┐
	│ label   │ status  │ location   │ backups │ disk  │ memory │
	├─────────┼─────────┼────────────┼─────────┼───────┼────────┤
	│ linode1 │ running │ eu-west-1a │ no      │ 20480 │ 1024   │
	└─────────┴─────────┴────────────┴─────────┴───────┴────────┘
    ```
    也可以登录<https://manager.linode.com/linodes>查看
    <img alt="linode__list_nodes.png" src="{{site.url}}/public/images/misc/linode__list_nodes.png" width="100%" align="center" style="margin: 0px 15px">

3.	节点管理：
	```
	linode-cli restart <your_vm_name>
	linode-cli stop <your_vm_name>
	linode-cli delete <your_vm_name>
	```

ssh连接
-------
1.	得到ip地址
    ```
    $ linode-cli linode show linode1
       label: linode1
      status: running
    location: eu-west-1a
     backups: no
        disk: 20480
      memory: 1024
         ips: xxx.xxx.xxx.xxx
    ```
2.  ssh连接。前面linode-configure时已经设置了默认的ssh public key，从同一台机器访问linode节点不需要密码：
    ```
    $ ssh root@xxx.xxx.xxx.xxx
    The authenticity of host 'xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx)' can't be established.
    ECDSA key fingerprint is SHA256:dm3Bqb7yJIc2iWXEj2cHXhvFtBAj7RnESuhgyAzqsSU.
    Are you sure you want to continue connecting (yes/no)? yes
    Warning: Permanently added 'xxx.xxx.xxx.xxx' (ECDSA) to the list of known hosts.
    Have a lot of fun...
    linux:~ #
    ```

本文原载于本人公众号“敏达生活”欢迎关注。

