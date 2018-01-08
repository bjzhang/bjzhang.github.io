---
layout: post
title: 我的macbook技巧
categories: [Software]
tags: [os x, macbook]
---

1. 快捷键：
    1. 锁屏：Ctrl+Shift+Power。
    2. 显示菜单栏：Ctrl + F2
    3. 菜单栏搜索：显示菜单栏之后，Command +  ?
    4. 插入日期和时间。一直希望有快捷键在印象笔记里面自动插入日期和时间。一直去找os x提供的功能。后来发现印象笔记自己有这个功能。Command+Shift+D插入日期，Command+Option+D插入时间。印象笔记会继承系统的日期和时间格斯，可以选择os x中提供的四种日期格式中的一种。os x日期和时间的格式通过系统偏好设置->日期与时间->语言与地区 可以选择12小时或24小时。->高级手动修改为自己需要的格式：例如2017-10-01。
    5. 应用强制退出：Choose Force Quit from the Apple () menu, or press Command-Option-Esc.
    6. 应用移动快捷键：spectacle。
    7. 刷新web页面：Comand+r：http://www.mac-forums.com/switcher-hangout/22686-shortcut-refresh-webpage.html
2. 锁屏后立刻要求输入密码（默认5分钟后）：系统偏好，安全性与隐私。
3. 命令行用得到代理信息：https://superuser.com/questions/48480/how-can-i-get-mac-os-xs-proxy-information-in-a-bash-script，下面这个没有测试：https://dmorgan.info/posts/mac-network-proxy-terminal/
4. tmux和剪贴板
    1. [优雅地使用命令行：Tmux 终端复用](http://harttle.com/2015/11/06/tmux-startup.html)
    2. https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
5. 代理
    1. google drive需要用http代理，shadowsocks NG默认只在系统配置了socks5代理。需要手动添加http/https代理。
        1. [ ] 似乎使用pac文件时更好的做法
    2. 给手机共享代理。最近手机自己连接科学上网经常断开，感觉是手机上科学上网软件受到手机性能限制不容易很可靠。于是想用mac共享代理。
        1. 上网搜了搜，下面方法可以通过wifi共享openvpn。https://www.expressvpn.com/support/vpn-setup/share-vpn-connection-mac/
        2. 但是我没有openvpn，不过这个方法可以教我怎么共享wifi网络。
        3. 也搜了搜其它办法，后来想到直接在手机wifi连接时配置proxy，但是mac默认的代理只允许本地地址（127.0.0.1）访问。
            1. 找了找。没找到蓝灯怎么允许远端连接。
            2. 想直接用shadowsocks-NG的privoxy，但是修改它的config发现被覆盖。
            3. 最后用了brew安装的privoxy，添加wifi共享的ip地址：
                1. 修改privoxy config: /usr/local/Cellar/privoxy/3.0.26/.bottle/etc/privoxy/config
                    1. listen-address  192.168.2.1:8118
                2. 启动参数：
                    1. BamvordeMacBook-Pro:~ bamvor$ /usr/local/Cellar/privoxy/3.0.26/sbin/privoxy --no-daemon /usr/local/Cellar/privoxy/3.0.26/.bottle/etc/privoxy/config
                    2. 2017-11-15 15:05:01.894 7fffa806d Info: Privoxy version 3.0.26
                    3. 2017-11-15 15:05:01.895 7fffa806d Info: Program name: /usr/local/Cellar/privoxy/3.0.26/sbin/privoxy
6. 日历提醒
    1. 修改google calendar默认按照事件发生时提醒。
        1. https://productforums.google.com/forum/#!msg/calendar/8SOz33YZ3sc/Bq0JsDgtf2MJ
        2. “Go to "settings" on the left under "my calendars" in the main view. Click on the "notifications" link. Select your preference in the drop down menus in “Event Reminders”.“
7. 同时向多个terminal发送同样命令。
    1. http://iterm2.com/
8. Spotlight（聚焦）跳过一些文件：<http://osxdaily.com/2011/12/30/exclude-drives-or-folders-from-spotlight-index-mac-os-x/>
    <img alt="qemu" src="{{site.url}}/public/images/os_x_ios/os_x_Spotlight_skip_indexing.png" width="100%" align="center" style="margin: 0px 15px">
