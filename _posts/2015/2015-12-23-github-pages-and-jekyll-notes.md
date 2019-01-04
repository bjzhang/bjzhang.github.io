# 使用github/gitcafe和jekyll搭建自己的博客

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
我的评论使用disqus，参考：
<https://help.disqus.com/customer/portal/articles/472138-jekyll-installation-instructions>
<http://hobodave.com/2010/01/08/moving-to-jekyll-disqus/>

补充5：搜索引擎
----------------
 参考[zhenyu的博客](http://zyzhang.github.io/blog/2012/09/03/blog-with-github-pages-and-jekyll-seo/)在google和baidu注册。

baidu站长验证有三种方式：网站根目录文件验证，主页html标签验证和cname验证。根目录文件不知道怎么加，cname验证貌似需要dns解析服务器帮忙解析域名。看到自己代码里面有index.html，想先试下这个，但是index.html明显不是html格式文档啊啊啊，咋办？

回忆下之前看jekyll的资料，jekyll使用[YAML Front Matter](http://jekyllrb.com/docs/frontmatter/)作为文件头。其中网页的模板由layout指定。例如我的index.html里面"layout: page"，会去找_layouts/page.html,  _layout/page.html又指定layout是default，这个default.html是html文档。所以我的html标签验证内容应该插入到default.html里面。

```
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
    <meta name="author" content="{{ site.author }}" />
    <!-- for Baidu: http://zhanzhang.baidu.com -->
    <meta name="baidu-site-verification" content="XXXXXXXXXX" />
    <!-- ... -->
  </head>
  ```

我用的是js的自动提交，在_layout/post.html插入即可。

折腾之后发现原来作者定义了sitemap，也上传了bjzhang.github.io/sitemap.xml。sitemap.xml原始文件如下

```
---
layout: nil
---
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  {% for post in site.posts %}
  <url>
    <loc>{{ site.url }}{{ post.url }}</loc>
    {% if post.lastmod == null %}
    <lastmod>{{ post.date | date_to_xmlschema }}</lastmod>
    {% else %}
    <lastmod>{{ post.lastmod | date_to_xmlschema }}</lastmod>
    {% endif %}
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  {% endfor %}
  {% for page in site.pages %}
  {% if page.sitemap != null and page.sitemap != empty %}
  <url>
    <loc>{{ site.url }}{{ page.url }}</loc>
    <lastmod>{{ page.sitemap.lastmod | date_to_xmlschema }}</lastmod>
    <changefreq>{{ page.sitemap.changefreq }}</changefreq>
    <priority>{{ page.sitemap.priority }}</priority>
  </url>
  {% endif %}
  {% endfor %}
</urlset>
```

生成的结果文件如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd" xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://bjzhang.github.io/2015/12/hackweek-hikey-and-sensor-kit/</loc>
    <lastmod>2015-12-31T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>http://bjzhang.github.io/2015/12/github-pages-and-jekyll-notes/</loc>
    <lastmod>2015-12-23T00:00:00+00:00</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
```

2016年1月4日更新
---------------

补充6：dns解析
--------------
之前有很多[博客](http://beiyuu.com/github-pages/)说github dns解析需要添加一条A(ALIAS)记录，但是这个方法已经是[github禁止的方法](https://github.com/blog/1917-github-pages-legacy-ip-deprecation)。正确的方法是添加一条CNAME记录，指向自己的域名。貌似对于dnspod.cn来说需要加"xxx.github.io."。完整方法在[这里](https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/)。
gitcafe绑定自定义域名可以在”自定义域名“里面设置，同样需要在dns服务商添加CNAME，详见<https://gitcafe.com/GitCafe/Help/wiki/Pages-%E7%9B%B8%E5%85%B3%E5%B8%AE%E5%8A%A9#wiki>

可以用dig判断dns解析是否正确，国内网络：
```
> dig aarch64.me +nostats +nocomments +nocmd

; <<>> DiG 9.9.6-P1 <<>> aarch64.me +nostats +nocomments +nocmd
;; global options: +cmd
;aarch64.me.                    IN      A
aarch64.me.             545     IN      CNAME   gitcafe.io.
gitcafe.io.             545     IN      A       119.81.161.100

```

之前百度解析sitemap.xml总是提示403，dns分流后，百度也可以自动正确得到sitemap了:)


