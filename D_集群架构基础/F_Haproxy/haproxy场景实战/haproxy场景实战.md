# haproxy场景实战

## 目录

-   [配置mysql代理](#配置mysql代理)
-   [https配置](#https配置)
-   [haproxy高可用](#haproxy高可用)

## 配置mysql代理

```bash
[root@proxy01 ~]# cat /etc/haproxy/conf.d/mysql.cfg 

frontend mysql
  bind *:3366
  mode tcp
  use_backend mysql_read_servers
  
  #acl access_user src 10.0.0.1
  #tcp-request connection reject if !access_user

backend mysql_read_servers
  mode tcp
  server 172.16.1.7 172.16.1.7:3306 check port 3306
  server 172.16.1.8 172.16.1.8:3306 check port 3306

```

## https配置

```bash
#准备证书
    [root@proxy01 ~]# cat /etc/nginx/ssl_key/6152893_blog.oldxu.net.pem > /ssl/blog_key.pem
    [root@proxy01 ~]# cat /etc/nginx/ssl_key/6152893_blog.oldxu.net.key >> /ssl/blog_key.pem

#配置单个域名https
    frontend web
      bind *:80
      bind *:443 ssl crt /ssl/blog_key.pem
      mode http
    
      # acl 规则将blog 调度到blog_cluster 
      acl blog_domain hdr(host) -i blog.oldxu.net
      redirect scheme https code 301 if !{ ssl_fc } blog_domain
      use_backend blog_cluster if blog_domain
    
    
      # zh
      acl zh_domain hdr(host) -i zh.oldxu.net
      use_backend zh_cluster if zh_domain


    backend blog_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ blog.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 80 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 80 inter 3s rise 2 fall 3
    
    backend zh_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ zh.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 8080 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 8080 inter 3s rise 2 fall 3


#多域名多证书
    frontend web
      bind *:80
      bind *:443 ssl crt /ssl/blog_key.pem crt /ssl/zh_key.pem
      mode http
    
      # acl 规则将blog 调度到blog_cluster 
      acl blog_domain hdr(host) -i blog.oldxu.net
      use_backend blog_cluster if blog_domain
    
    
      # zh
      acl zh_domain hdr(host) -i zh.oldxu.net
      use_backend zh_cluster if zh_domain
      
      # 全部都跳转https
      redirect scheme https code 301 if !{ ssl_fc } 

    backend blog_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ blog.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 80 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 80 inter 3s rise 2 fall 3
    
    backend zh_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ zh.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 8080 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 8080 inter 3s rise 2 fall 3

#配置多域名，部分uri走https
    frontend web
      bind *:80
      bind *:443 ssl crt /ssl/blog_key.pem crt /ssl/zh_key.pem
      mode http
    
      # acl 规则将blog 调度到blog_cluster 
      acl blog_domain hdr(host) -i blog.oldxu.net
      acl blog_ssl_path path_beg -i /login /pay
      # 请求域名为 blog.oldxu.net 并且不是https协议，并且请求的是 /login 则全部跳https协议
          redirect scheme https code 301 if !{ ssl_fc } blog_domain blog_ssl_path
      # 请求域名为 blog.oldxu.net 并且是https协议，但不是 /login 则全部跳转至http协议
          redirect scheme http code 301 if { ssl_fc }   blog_domain !blog_ssl_path
      use_backend blog_cluster if blog_domain
    
      # zh
      acl zh_domain hdr(host) -i zh.oldxu.net
      use_backend zh_cluster if zh_domain
      redirect scheme https code 301 if !{ ssl_fc } zh_domain
      
  # 全部都跳转https
  #redirect scheme https code 301 if !{ ssl_fc } 

    backend blog_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ blog.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 80 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 80 inter 3s rise 2 fall 3
    
    backend zh_cluster
      balance roundrobin
      option httpchk HEAD / HTTP/1.1\r\nHost:\ zh.oldxu.net
      server 172.16.1.7 172.16.1.7:80 check port 8080 inter 3s rise 2 fall 3
      server 172.16.1.8 172.16.1.8:80 check port 8080 inter 3s rise 2 fall 3
```

## haproxy高可用

```bash
#保证两台节点配置一样且可用
  #在172.16.1.5节点上进行操作
    scp haproxy22.rpm.tar.gz root@10.0.0.6:~
    scp /etc/haproxy/haproxy.cfg root@172.16.1.6:/etc/haproxy/haproxy.cfg
    scp -rp /ssl root@172.16.1.6:/
    
    systemctl start haproxy
    systemctl start keepalived
   #在6节点上进行操作
     yum localinstall haproxy/*.rpm -y
    systemctl start haproxy
    systemctl start keepalived
    
#在后端节点进行操作
    [root@oldxu ~]# vim /etc/sysct.conf
        # tcp优化
        net.ipv4.ip_local_port_range = 1024 65000
        net.ipv4.tcp_tw_reuse = 1           # 端口复用
        net.ipv4.tcp_max_tw_buckets = 5000  # TIME-WAIT最大数量
        
        net.ipv4.tcp_syncookies = 1         # 防止SYN Flood攻击，开启后max_syn_backlog理论上没有最大值
        net.ipv4.tcp_max_syn_backlog = 8192 # SYN半连接队列可存储的最大值
        net.core.somaxconn = 65535          # SYN全连接队列可存储的最大值
        
        # 修改TCP TIME-WAIT超时时间 https://help.aliyun.com/document_detail/155470.html
        net.ipv4.tcp_tw_timeout = 5
        net.core.netdev_max_backlog = 2000000 # 调网卡缓存队列，默认为1000
        
        # 重试
        net.ipv4.tcp_syn_retries=2          # 发送SYN包重试次数，默认6
        net.ipv4.tcp_synack_retries = 2     # 返回syn+ack重试次数，默认5
        
        
        # 系统中允许存在文件句柄最大数目（系统级）
        fs.file-max = 204800
        vm.swappiness = 0                   # 最大限度使用物理内存
 
 [root@oldxu ~]# tail /etc/security/limits.conf
# max user processes
* soft nproc 60000
* hard nproc 60000

# open files
* soft nofile 100000
* hard nofile 100000

```
