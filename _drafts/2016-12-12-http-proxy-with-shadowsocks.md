
Access the blocked site through my baidu vm
-------------------------------------------
Edit the sslocal.json:
```
{
    "server": "xxx",		//server ip in shadowsocks server
    "server_port": 12345,	//port for shadowsocks server
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "xxx",		//password for shadowsocks.
    "timeout": 300,
    "method": "aes-256-cfb",
    "fast_open": false
}
```

Run it through "sslocal -c sslocal.json -d start --pid-file /var/run/shadowsocks.pid --log-file ss.log"

Reference <https://www.loyalsoldier.me/fuck-the-gfw-with-my-own-shadowsocks-server/>

Run privoxy
-----------
Reference [my previous blog](http://aarch64.me/2016/05/how-to-use-shadowsocks-in-PC-and-chromebook/) for how to use privoxy.

The difference is I need to monitor http request from outside and localhost. And keep in mind that use the ip shown in baidu vm(ip addr or whatever) instead of the public ip baidu provided to you.

```
listen-address  127.0.0.1:8118
listen-address  172.xxx.xxx.xxx:8118
#listen-address  182.xxx.xxx.xxx:8118
```

Setup SwitchyOmega
------------------

![setup proxy in chrome browser](setup_proxy_in_chrome.png)


TODO
----
Use [cow](https://github.com/cyfdecyf/cow) to identify the blocked website automatically.

bamvor is not in the sudoers file.  This incident will be reported.

