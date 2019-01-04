# k8s学习笔记

k8s基础知识
-----------
1.  网络
    1.  vxlan
        1.  有封包，解包损耗。有些intel网卡支持offload，可以相当于90%网络性能。
    2.  overlay
    3.  callico: bgp协议。
2.  components
    1.  <https://kubernetes.io/docs/concepts/overview/components/>
    2.  cAdvisor: 容器监控。
    3.  Pods k8s最小调度单元。一个pods可以包含多个容器。
    4.  api server：k8s没有用消息队列。api server直接和etcd交互。通过watch监控事件。
    5.  Relication Controller: 管理Pod副本。
3.  目前公司镜像仓库用的是[Harber](https://github.com/vmware/harbor): "Project Harbor is an enterprise-class registry server that stores and distributes Docker images. "
4.  `kubectl exec -it pod_name`: 通过k8s api server调用kubelet返回容器的console。
5.  k8s最新进展
    1.  service mesh
        1.  linkerd -> conduit
        2.  istio: google, IBM
6.  k8s package manager: [helm](https://github.com/kubernetes/helm)

k8s使用例子
-----------
"[vitess](https://github.com/vitessio/vitess)is a database clustering system for horizontal scaling of MySQL." 随手记录自己在google cloud engine（GCE）上部署vitess并测试的过程。参考文档的入口是vitess自己的[上手指南](http://vitess.io/getting-started/)

### 安装gcloud并初始化
参考[google mac文档](https://cloud.google.com/sdk/docs/quickstart-mac-os-x)
*   gcloud init
    *   gcloud init会检查网络长时间无响应，我用shadowsocks-NG配置了http_proxy, https_proxys，gcloud立刻说网络不通。gcloud自己支持用http，socks5等方案，我直接选择了socks5。
    *   根据[这篇文章](https://github.com/kaiye/kaiye.github.com/issues/9)的测试和[谷歌的对所有区域的介绍](https://cloud.google.com/compute/docs/regions-zones/)。我暂时选择了asia-east1-3。
    *   `gcloud config list`可以看到当前的配置：
        ```
        bogon:~ bamvor$ gcloud config list
        [compute]
        region = asia-east1
        zone = asia-east1-c
        [core]
        account = xxx@gmail.com
        disable_usage_reporting = False
        project = vitess-on-kubernetes-xxxxxx
        [proxy]
        address = 127.0.0.1
        port = 1086
        type = socks5
        ```
*   打开google container engine API
    *   我看到的菜单和文档不太一样。左边有个"API & services"，进入后，选择"ENABLE APIS AND SERVICES"，在里面搜索"google container engine API"，并选择"ENABLE"。

### 启动GCE和vitess
*   文档选择了"n1-standard-4"，可以通过`gcloud compute machine-types list`得到。

后续参考上述文档即可。

