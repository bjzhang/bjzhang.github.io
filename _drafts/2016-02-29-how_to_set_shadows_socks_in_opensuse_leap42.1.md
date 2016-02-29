
10:51 2016-02-29
----------------
install privoxy
---------------
/etc/privoxy/config
forward-socks5   /               127.0.0.1:1080 .

bamvor@linux-5iys:~> sudo systemctl enable privoxy.service
bamvor@linux-5iys:~> sudo systemctl status privoxy.service
privoxy.service - Privoxy Web Proxy With Advanced Filtering Capabilities
   Loaded: loaded (/usr/lib/systemd/system/privoxy.service; enabled)
   Active: inactive (dead)

bamvor@linux-5iys:~> sudo systemctl start privoxy.service
bamvor@linux-5iys:~> sudo systemctl status privoxy.service
privoxy.service - Privoxy Web Proxy With Advanced Filtering Capabilities
   Loaded: loaded (/usr/lib/systemd/system/privoxy.service; enabled)
   Active: active (running) since Mon 2016-02-29 10:50:32 CST; 1s ago
  Process: 9106 ExecStart=/usr/sbin/privoxy --chroot --pidfile /run/privoxy.pid --user privoxy /etc/config (code=exited, status=0/SUCCESS)
  Process: 9103 ExecStartPre=/usr/bin/cp -upf /lib64/libresolv.so.2 /lib64/libnss_dns.so.2 /var/lib/privoxy/lib64/ (code=exited, status=0/SUCCESS)
  Process: 9101 ExecStartPre=/usr/bin/cp -upf /etc/resolv.conf /etc/host.conf /etc/hosts /etc/localtime /var/lib/privoxy/etc/ (code=exited, status=0/SUCCESS)
 Main PID: 9108 (privoxy)
   CGroup: /system.slice/privoxy.service
           └─9108 /usr/sbin/privoxy --chroot --pidfile /run/privoxy.pid --user privoxy /etc/config

