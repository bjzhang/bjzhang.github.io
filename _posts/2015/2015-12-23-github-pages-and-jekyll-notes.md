---
layout: post
title: 使用github/gitcafe和jekyll搭建自己的博客
categories: [Tools]
tags: [jekyll, github, git, markdown]
---

<img alt="Github" src="{{site.url}}/public/images/github-octocat.png" width="100%" align="center" style="margin: 0px 15px">

参考资料
--------
[扫盲帖](https://pages.github.com/)

[github官方使用jekyll文档](https://help.github.com/articles/using-jekyll-with-pages/)，虽然我没有看懂:p

[主要参考了God-Mode的写作环境搭建](http://site.douban.com/196781/widget/notes/12161495/note/264946576/)

[Jekyll tempelate](https://github.com/jekyll/jekyll/wiki/sites)

###其他参考资料###

<http://blog.devtang.com/blog/2014/06/02/use-gitcafe-to-host-blog/>

<http://blog.devtang.com/blog/2012/02/10/setup-blog-based-on-github/>

[gitcafe pages HOWTO](https://gitcafe.com/GitCafe/Help/wiki/Pages-%E7%9B%B8%E5%85%B3%E5%B8%AE%E5%8A%A9#wiki)

补充1: 安装ruby-devel包
----------------------
在openSUSE13.2安装`gem install jekyll`提示找不到头文件`/usr/include/ruby-2.1.0/ruby/ruby.h`，安装ruby-devel和ruby2.1-devel后解决:

`zypper in ruby-devel ruby2.1-devel`

`gem install jekyll`之后，我的包列表：

```
> gem list

*** LOCAL GEMS ***

bigdecimal (1.2.4)
colorator (0.1)
fast_gettext (0.8.1)
ffi (1.9.10)
gem2rpm (0.10.1)
io-console (0.4.3)
jekyll (3.0.1)
jekyll-sass-converter (1.3.0)
jekyll-watch (1.3.0)
json (1.8.1)
kramdown (1.9.0)
liquid (3.0.6)
listen (3.0.5)
mercenary (0.3.5)
minitest (4.7.5)
psych (2.0.5)
rake (10.1.0)
rb-fsevent (0.9.6)
rb-inotify (0.9.5)
rdoc (4.1.0)
rouge (1.10.1)
ruby (0.1.0)
ruby-dbus (0.11.0)
rubygems-update (2.5.1)
safe_yaml (1.0.4)
sass (3.4.20)
test-unit (2.1.7.0)
```

补充2: 注册google analysis帐号
------------------------------
<kejinlu.github.io>的README.md提到要修改`_layouts / default.html`中 google analytics的标识`_gaq.push(['_setAccount', 'UA-xxxxxxxx-x']);`。反复尝试搜索内容，搜索"_setAccount ua"可以搜索到:
[google analysis说明和注册链接](https://developer.chrome.com/extensions/tut_analytics)

补充3: 微信
-----------
### 如何转发到朋友圈
用微信发布包含网址的文字信息，然后用微信自带的浏览器打开这个网址，选择分享到朋友圈即可。
[参考](http://jingyan.baidu.com/article/0eb457e5017fda03f1a90539.html)

### 朋友圈缩略图
缩略图会使用第一张尺寸大约300x300的图片.
[参考](http://www.zhihu.com/question/21668601), 通过`site.url`（原文是`site.baseurl`不知道为什么我的baseurl不行）得到路径：
`<img alt="Github" src="\{\{site.url\}\}/public/images/github-octocat.png" width="100%" align="center" style="margin: 0px 15px">`

从[这里](http://vrepin.org/vr/CopyrightedMonumentsFinland/), [源码](https://raw.githubusercontent.com/vitalyrepin/vrepinblog/master/_posts/2015-09-18-CopyrightedMonumentsFinland.md)找到了设置图片的方法.

补充4: 评论
-----------
我的评论使用disqus.

