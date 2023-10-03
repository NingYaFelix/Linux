# OpenVPN虚拟网络实战

## 目录

-   [03 OpenVPN虚拟网络实战](#03-OpenVPN虚拟网络实战)
    -   [1.VPN基本介绍](#1VPN基本介绍)
        -   [1.1 什么是VPN](#11-什么是VPN)
        -   [1.2 VPN应用场景](#12-VPN应用场景)
            -   [1.2.1 点对点连接](#121-点对点连接)
            -   [1.2.2 站点对站点](#122-站点对站点)
            -   [1.2.3 远程访问](#123-远程访问)
    -   [2.OpenVPN基本介绍](#2OpenVPN基本介绍)
        -   [2.1 什么是OpenVPN](#21-什么是OpenVPN)
        -   [2.2 OpenVPN应用场景](#22-OpenVPN应用场景)
        -   [2.3 OpenVPN实现场景](#23-OpenVPN实现场景)
    -   [3.OpenVPN证书配置](#3OpenVPN证书配置)
        -   [3.1 安装easy-rsa](#31-安装easy-rsa)
        -   [3.2 创建证书文件](#32-创建证书文件)
            -   [3.2.1 初始化PKI](#321-初始化PKI)
            -   [3.2.2 创建CA机构](#322-创建CA机构)
            -   [3.2.3 签发服务端证书](#323-签发服务端证书)
            -   [3.2.4 创建DH密钥](#324-创建DH密钥)
            -   [3.2.5 签发客户端证书](#325-签发客户端证书)
    -   [4.OpenVPN服务安装](#4OpenVPN服务安装)
        -   [4.1 安装Openvpn服务](#41-安装Openvpn服务)
        -   [4.2 配置openvpn服务](#42-配置openvpn服务)
        -   [4.3 拷贝服务端证书文件](#43-拷贝服务端证书文件)
        -   [4.4 开启内核转发参数](#44-开启内核转发参数)
        -   [4.5 启动openvpn服务](#45-启动openvpn服务)
    -   [5.OpenVPN客户端](#5OpenVPN客户端)
        -   [5.1 客户端连接Linux](#51-客户端连接Linux)
        -   [5.2 客户端连接Windows](#52-客户端连接Windows)
        -   [5.3 客户端接入MACOS](#53-客户端接入MACOS)
    -   [6.OpenVPN访问内部网段](#6OpenVPN访问内部网段)
        -   [6.1 内部节点无法正常访问](#61-内部节点无法正常访问)
        -   [6.2 在节点上添加主机路由](#62-在节点上添加主机路由)
        -   [6.2 配置路由器路由条目（公有云）](#62-配置路由器路由条目公有云)
        -   [6.3 配置NAT地址替换（虚拟机）](#63-配置NAT地址替换虚拟机)
    -   [7.OpenVPN基于用户密码认证](#7OpenVPN基于用户密码认证)
        -   [7.1 为何需要用户密码](#71-为何需要用户密码)
        -   [7.2 OpenVPN服务端配置](#72-OpenVPN服务端配置)
            -   [7.2.1 修改服务端配置](#721-修改服务端配置)
            -   [7.2.2 创建自定义脚本](#722-创建自定义脚本)
            -   [7.2.3 创建用户密码文件](#723-创建用户密码文件)
            -   [7.2.4 重启OpenVPN服务](#724-重启OpenVPN服务)
    -   [7.3 OpenVPN客户端配置](#73-OpenVPN客户端配置)
        -   [7.3.1 修改客户端配置](#731-修改客户端配置)
        -   [7.3.2 客户端重新登陆](#732-客户端重新登陆)

# 03 OpenVPN虚拟网络实战

## 1.VPN基本介绍

### 1.1 什么是VPN

-   `VPN（Virtual Private Network）` 翻译过来就是虚拟专用网络，那虚拟专用网提供什么功能
-   1、将两个或多个“不同地域“的网络通过一条虚拟隧道的方式连接起来，实现互通；
-   2、在不安全的线路上提供安全的数据传输；

### 1.2 VPN应用场景

#### 1.2.1 点对点连接

-   `Peer-to-Peer VPN` (点对点连接)，将 `Internet`两台机器（公网地址）使用VPN连接起来，比如上海服务器和北京服务器的之间的数据需要相互调用，但是数据又比较敏感，直接通过http公共网络传输，容易被窃取。如果拉一条专线成本又太高。
-   所以我们可以通过`VPN`将两台主机逻辑上捆绑在一个虚拟网络中，这样既保证了数据传输安全，同时又节省了成本。

![-c500](http://cdn.xuliangwei.com/15485693815620.jpg "-c500")

#### 1.2.2 站点对站点

-   `SIte-to-Site VPN` (站点对站点连接) ，用于连接两个或者多个地域上不同的局域网`LAN`，每个`LAN`有一台`OpenVPN`服务器作为接入点，组成虚拟专用网络，使得不同`LAN`里面的主机和服务器都能够相互通讯。（比如国内公司与海外公司分公司的连接）

![-c500](http://cdn.xuliangwei.com/15485692927934.jpg "-c500")

#### 1.2.3 远程访问

-   `Remote AccessVPN`（远程访问），应用于外网用户访问内部资源。在这个场景中远程访问者一般通过公网`IP`连接`VPN`服务，然后通过分配后的内网地址与其内网网段进行通信。

![-c500](http://cdn.xuliangwei.com/15485692005440.jpg "-c500")

## 2.OpenVPN基本介绍

### 2.1 什么是OpenVPN

-   `OpenVPN`就像它的名字一样，是一个开源的软件，且提供 `VPN` 虚拟专用网络功能；
    -   1、支持 `SSL/TLS`协议，使得数据传输更安全；
    -   2、支持`TCP、UDP`隧道；
    -   3、支持动态分配虚拟 `IP` 地址；
    -   4、支持数百甚至数千用户同时使用；
    -   5、支持大多数主流操作系统平台（windows、linux、macos）；
-   `OpenVPN`官网：`https://openvpn.net`
-   `GitHub`地址：`https://github.com/OpenVPN/openvpn`

### 2.2 OpenVPN应用场景

-   场景1：拨入`OpenVPN`，然后连接内部服务器；
-   场景2：实现两个不同地域主机、且两个地域主机IP不固定，互连互通；

### 2.3 OpenVPN实现场景

![](http://cdn.xuliangwei.com/16231233066531.jpg)

做地址替换，由vpn来实现；

做路由转发，最终数据包怎么回去的，和vpn的关系不大；

## 3.OpenVPN证书配置

### 3.1 安装easy-rsa

1.为了保证 `OpenVPN`数据传输安全，所以需要证书，可以通过 `easy-rsa`工具创建相关证书

```bash
[root@vpn ~]# yum install easy-rsa -y
```

2.创建证书前，需要拷贝配置文件，以及 `vars`文件，定义证书相关的属性

```bash
[root@open ~]# mkdir /opt/easy-rsa
[root@open ~]# cd /opt/easy-rsa/
[root@vpn easy-rsa]# cp -a /usr/share/easy-rsa/3/* ./
[root@vpn easy-rsa]# cp -a /usr/share/doc/easy-rsa-*/vars.example ./vars
```

3.修改 `vars` 文件

```bash
[root@vpn easy-rsa]# cat vars
if [ -z "$EASYRSA_CALLER" ]; then
        echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
        echo "This is no longer necessary and is disallowed. See the section called" >&2
        echo "'How to use this file' near the top comments for more details." >&2
        return 1
fi
set_var EASYRSA_CA_EXPIRE 3650                      #证书有效期
set_var EASYRSA_CERT_EXPIRE 3650                    # 服务端证书有效期，默为825天
set_var EASYRSA_DN  "cn_only"
set_var EASYRSA_REQ_COUNTRY "CN"                    #所在的国家
set_var EASYRSA_REQ_PROVINCE "Beijing"              #所在的省份
set_var EASYRSA_REQ_CITY "Beijing"                 #所在的城市
set_var EASYRSA_REQ_ORG "oldxu"                     #所在的组织
set_var EASYRSA_REQ_EMAIL "xuliangwei@foxmail.com"  #邮箱的地址
set_var EASYRSA_NS_SUPPORT "yes"
```

### 3.2 创建证书文件

#### 3.2.1 初始化PKI

```bash
# 初始化，在当前目录创建PKI目录，用于存储证书
[root@vpn easy-rsa]# ./easyrsa init-pki
```

#### 3.2.2 创建CA机构

```bash
# 创建ca证书，主要对后续创建的server、client证书进行签名；会提示设置密码，其他可默认
[root@vpn easy-rsa]# ./easyrsa build-ca
```

#### 3.2.3 签发服务端证书

1.创建 `server`端证书，`nopass`表示不加密私钥文件，其他可默认

```bash
[root@vpn easy-rsa]# ./easyrsa gen-req server nopass

Keypair and certificate request completed. Your files are:
req: /opt/easy-rsa/pki/reqs/server.req          # 请求文件
key: /opt/easy-rsa/pki/private/server.key       # 私钥
```

2.给 `server`端证书签名，首先是对信息的确认，可以输入`yes`，然后输入创建`ca`根证书时设置的密码

```bash
# 第一个server是类型
# 第二个server是req请求文件名称
[root@open easy-rsa]# ./easyrsa sign server server

Certificate created at: /opt/easy-rsa/pki/issued/server.crt     # 公钥
```

#### 3.2.4 创建DH密钥

`Diffie-Hellman`是一种安全协议；让双方在完全没有对方任何信息情况下通过不安全信道建立一个密钥；
这个密钥一般作为 “对称加密” 的密钥而被双方在后续数据传输中使用；

```bash
[root@vpn easy-rsa]# ./easyrsa gen-dh

DH parameters of size 2048 created at /opt/easy-rsa/pki/dh.pem
```

#### 3.2.5 签发客户端证书

1.创建`client`端私钥文件，`nopass`表示不加密私钥文件，其他可默认

```bash
[root@open easy-rsa]# ./easyrsa gen-req client nopass

Keypair and certificate request completed. Your files are:
req: /opt/easy-rsa/pki/reqs/client.req      # 请求文件
key: /opt/easy-rsa/pki/private/client.key   # 私钥文件
```

2.给 `client`端证书签名，首先是对信息的确认，可以输入yes，然后创建ca根证书时设置的密码

```bash
# 第一个client是类型
# 第二个client是req请求文件名称
[root@open easy-rsa]# ./easyrsa sign client client

Certificate created at: /opt/easy-rsa/pki/issued/client.crt     # 客户端公钥
```

## 4.OpenVPN服务安装

### 4.1 安装Openvpn服务

```bash
[root@vpn ~]# ntpdate time.windows.com      # 一定要同步时间
[root@vpn ~]# yum install ntpdate openvpn -y
```

### 4.2 配置openvpn服务

```bash
[root@vpn ~]# vim /etc/openvpn/server.conf
port 1194                               #端口
proto tcp                               #协议
dev tun                                 #采用路由隧道模式tun
ca ca.crt                               #ca证书文件位置
cert server.crt                         #服务端公钥名称
key server.key                          #服务端私钥名称
dh dh.pem                               #交换证书
server 10.8.0.0 255.255.255.0           #给客户端分配地址池，注意：不能和VPN服务器内网网段有相同
push "route 172.16.1.0 255.255.255.0"   #允许客户端访问内网172.16.1.0网段

# push "redirect-gateway def1"
# push "dhcp-option DNS 8.8.8.8"

ifconfig-pool-persist ipp.txt           #地址池记录文件位置
keepalive 10 120                        #存活时间，10秒ping一次,120 如未收到响应则视为断线
max-clients 100                         #最多允许100个客户端连接
status openvpn-status.log               #日志记录位置
verb 3                                  #openvpn版本
client-to-client                        #客户端与客户端之间支持通信
log /var/log/openvpn.log                #openvpn日志记录位置
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys。
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
duplicate-cn
```

### 4.3 拷贝服务端证书文件

```bash
# 将服务端证书拷贝至 `/etc/openvpn` 目录下
[root@vpn ~]# cp /opt/easy-rsa/pki/ca.crt /etc/openvpn/
[root@vpn ~]# cp /opt/easy-rsa/pki/dh.pem /etc/openvpn/
[root@vpn ~]# cp /opt/easy-rsa/pki/issued/server.crt /etc/openvpn/
[root@vpn ~]# cp /opt/easy-rsa/pki/private/server.key /etc/openvpn/
```

### 4.4 开启内核转发参数

```bash
# 必须开启内核转发功能
[root@open ~]# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
[root@vpn ~]# sysctl -p
```

### 4.5 启动openvpn服务

```bash
[root@vpn ~]# systemctl enable openvpn@server
[root@vpn ~]# systemctl start openvpn@server
```

## 5.OpenVPN客户端

### 5.1 客户端连接Linux

1.端安装 `openvpn`

```bash
[root@openvpn-client ~]# yum install openvpn -y
```

2.下载客户端公钥与私钥以及Ca证书至客户端

```bash
[root@openvpn-client ~]# cd /etc/openvpn/
[root@openvpn-client openvpn]# scp root@172.16.1.60:/opt/easy-rsa/pki/ca.crt ./
[root@openvpn-client openvpn]# scp root@172.16.1.60:/opt/easy-rsa/pki/issued/client.crt ./
[root@openvpn-client openvpn]# scp root@172.16.1.60:/opt/easy-rsa/pki/private/client.key ./
```

3.客户端有了公钥和私钥后，还需要准备对应的客户端配置文件

```bash
[root@openvpn-client ~]# cat /etc/openvpn/client.ovpn
client                  #指定当前VPN是客户端
dev tun                 #使用tun隧道传输协议
proto tcp               #使用udp协议传输数据
remote 10.0.0.60 1194   #openvpn服务器IP地址端口号
resolv-retry infinite   #断线自动重新连接，在网络不稳定的情况下非常有用
nobind                  #不绑定本地特定的端口号
ca ca.crt               #指定CA证书的文件路径
cert client.crt         #指定当前客户端的证书文件路径
key client.key          #指定当前客户端的私钥文件路径
verb 3                  #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
```

4.启动 `openvpn`客户端

```bash
openvpn --cd /etc/openvpn/ --config /etc/openvpn/client.ovpn 

[root@openvpn-client ~]# openvpn --daemon --cd /etc/openvpn --config client.ovpn --log-append /var/log/openvpn.log

# --daemon：openvpn以daemon方式启动。
# --cd dir：配置文件的目录，openvpn初始化前，先切换到此目录。
# --config file：客户端配置文件的路径。
# --log-append file：日志文件路径，如果文件不存在会自动创建。
```

### 5.2 客户端连接Windows

`openvpn for windows`[客户端下载地址](https://openvpn.net/community-downloads/ "客户端下载地址")

1.下载服务端准备的客户端密钥文件和ca文件至 `C:\Program Files\OpenVPN\config`目录中

```bash
[root@openvpn ~]# sz /opt/easy-rsa/pki/ca.crt
[root@openvpn ~]# sz /opt/easy-rsa/pki/issued/client.crt
[root@openvpn ~]# sz /opt/easy-rsa/pki/private/client.key
```

2.在 `C:\Program Files\OpenVPN\config`创建一个客户端配置文件，名称叫`client.ovpn`

```bash
client                  #指定当前VPN是客户端
dev tun                 #使用tun隧道传输协议
proto tcp               #使用udp协议传输数据
remote 10.0.0.60 1194   #openvpn服务器IP地址端口号
resolv-retry infinite   #断线自动重新连接，在网络不稳定的情况下非常有用
nobind                  #不绑定本地特定的端口号
ca ca.crt               #指定CA证书的文件路径
cert client.crt         #指定当前客户端的证书文件路径
key client.key          #指定当前客户端的私钥文件路径
verb 3                  #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
```

3.最终 `windows`的目录中配置文件如下

![](http://cdn.xuliangwei.com/15478956758272.jpg)

4.登陆成功后，通过 `windows`查看 `openvpn`服务推送过来的路由信息；

```bash
# windows查看推送过来的路由信息
# route print -4
```

### 5.3 客户端接入MACOS

`openvpn for MacOS`

[客户端下载地址](https://tunnelblick.net/downloads.html "客户端下载地址")

1.下载服务端准备的客户端密钥文件和ca文件至本地

```bash
[root@openvpn ~]# sz /opt/easy-rsa/pki/ca.crt
[root@openvpn ~]# sz /opt/easy-rsa/pki/issued/client.crt
[root@openvpn ~]# sz /opt/easy-rsa/pki/private/client.key
```

2.创建一个客户端配置文件，名称叫`client.ovpn`

```bash
client                  #指定当前VPN是客户端
dev tun                 #使用tun隧道传输协议
proto tcp               #使用udp协议传输数据
remote 10.0.0.60 1194   #openvpn服务器IP地址端口号
resolv-retry infinite   #断线自动重新连接，在网络不稳定的情况下非常有用
nobind                  #不绑定本地特定的端口号
ca ca.crt               #指定CA证书的文件路径
cert client.crt         #指定当前客户端的证书文件路径
key client.key          #指定当前客户端的私钥文件路径
verb 3                  #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
```

3.将所有文件存储到一个文件夹中，并命名后缀为`tblk`格式，效果如下图所示：

![-c500](http://cdn.xuliangwei.com/16231381221111.jpg "-c500")

## 6.OpenVPN访问内部网段

### 6.1 内部节点无法正常访问

-   抓包分析数据包能抵达 `openvpn` 的内网地址，但无法与OpenVPN服务同内网网段主机进行通信；
-   因为后端主机没有去往 `10.8.0.0` 网段的路由，所以数据包无法原路返回，最终造成无法 `ping` 通

```bash
[root@windows ~]# ping 172.16.1.7
Request timeout for icmp_seq 0
Request timeout for icmp_seq 1

#在后端的主机上抓包分析，发现能接收到数据包，但没有回去的路由所以无法通信
[root@web01 ~]# tcpdump -i eth1 -nn -p icmp
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
    10.8.0.6 > 172.16.1.7: ICMP echo request, id 3437, seq 3, length 64
    10.8.0.6 > 172.16.1.7: ICMP echo request, id 3437, seq 4, length 64
    10.8.0.6 > 172.16.1.7: ICMP echo request, id 3437, seq 5, length 64
```

-   解决此问题有如下几种方式：
    -   方式1：在每台节点添加一条路由，下一跳为 `Openvpn` 节点；
    -   方式2：在所有内网主机的默认路由器上添加一条路由，下一跳为 `Openvpn` 节点；
    -   方式3：配置`iptables、firewalld`的`NAT`规则

### 6.2 在节点上添加主机路由

1、在后端主机添加抵达去往 `10.8.0.0/24`网段的走 `openvpn`的内网地址进行路由（原理如下图）

```bash
[root@web01 ~]# route add -net 10.8.0.0/24 gw 172.16.1.60
[root@web01 ~]# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
10.8.0.0        172.16.1.60      255.255.255.0   UG    0      0        0 eth1
```

2、添加完路由后，继续 `ping`该节点，在抓包查看

```bash
[root@web01 ~]# tcpdump -i eth1 -nn -p icmp
17:51:36.053959 IP 172.16.1.7 > 10.8.0.6: ICMP echo reply, id 1, seq 420, length 40
17:51:37.057545 IP 10.8.0.6 > 172.16.1.7: ICMP echo request, id 1, seq 421, length 40
```

3、通过`vpn`连接内网服务器，检查内网服务器与哪个IP建立连接（会发现是真实的VPN客户端节点）；

```bash
[root@web01 ~]# netstat -an | grep -i estab
Active Internet connections (servers and established)
tcp        0      0 172.16.1.91:22          10.8.0.6:63380          ESTABLISHED
```

### 6.2 配置路由器路由条目（公有云）

如上的配置需要在所有后端主机添加，如果机器量过多，那么添加起来非常的麻烦；

1.建议使用在出口路由器上添加该路由规则条目；

2.验证结果

### 6.3 配置NAT地址替换（虚拟机）

如上的配置需要在所有后端主机添加，如果机器量过多，那么添加起来非常的麻烦；

1.可以在`VPN`节点上增加防火墙规则配置；

```bash
# Iptables
[root@vpn ~]# iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth1 -j SNAT --to 172.16.1.60

# Firewalld
[root@open ~]# systemctl start firewalld
[root@open ~]# firewall-cmd --add-service=openvpn --permanent
[root@open ~]# firewall-cmd --add-masquerade --permanent
[root@open ~]# firewall-cmd --reload
```

2.通过`vpn`连接内网服务器，检查内网服务器与哪个IP建立连接（会发现是SNAT后的内网IP）；

```bash
[root@web01 ~]# netstat -an |grep -i established
Active Internet connections (servers and established)
tcp        0      0 172.16.1.7:22          172.16.1.60:64852        ESTABLISHED
```

## 7.OpenVPN基于用户密码认证

### 7.1 为何需要用户密码

我们目前使用密钥进行加密传输，可以说已经很安全了，为什么还要需要用户名秘密呢。

-   1、首先管理这些秘钥和证书比较麻烦，如果用户比较多，单独为每个用户都创建一套秘钥比较麻烦；
-   2、其次多人使用同一秘钥又不具有唯一性，比如说有用户不在需要VPN的时候，我们就需要吊销证书，如果多人使用一个秘钥的情况下，吊销证书会造成其他用户也无法正常登录。

所以就需要秘钥加用户名密码，这样就可以实现多个用户使用同一个证书，使用不同的用户名和密码；
当有新用户加入时，只需要添加一个用户名和密码即可，如果不需要使用，则删除用户名和密码即可；

### 7.2 OpenVPN服务端配置

#### 7.2.1 修改服务端配置

```bash
# 添加如下三行代码，使其服务端支持密码认证方式

[root@web01 ~]# vim /etc/openvpn/server.conf
script-security 3       # 允许使用自定义脚本
auth-user-pass-verify /etc/openvpn/check.sh via-env # 自定义脚本路径
username-as-common-name # 用户密码登陆方式验证
```

#### 7.2.2 创建自定义脚本

```bash
# 粘贴如下配置

[root@open ~]# vim /etc/openvpn/check.sh
#!/bin/sh
###########################################################
PASSFILE="/etc/openvpn/openvpnfile"
LOG_FILE="/var/log/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`

if [ ! -r "${PASSFILE}" ]; then
    echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
    exit 1
fi

CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

if [ "${CORRECT_PASSWORD}" = "" ]; then
    echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
    exit 1
fi
if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
    echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
    exit 0
fi
echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1


# 为脚本增加执行权限
[root@open ~]# chmod +x /etc/openvpn/check.sh
```

#### 7.2.3 创建用户密码文件

```bash
# 创建 `check.sh` 脚本中定义 `openvpn` 使用的用户和密码认证文件

[root@open ~]# cat > /etc/openvpn/openvpnfile <<EOF
oldxu 123456     # 前面是用户名称，后面是密码
EOF
```

#### 7.2.4 重启OpenVPN服务

```bash
[root@open ~]# systemctl restart openvpn@server
```

## 7.3 OpenVPN客户端配置

#### 7.3.1 修改客户端配置

```bash
# 修改客户端配置文件，增加如下代码，使其支持用户名/密码与服务器进行身份验证；
auth-user-pass  #用户密码认证
```

#### 7.3.2 客户端重新登陆

![-c500](http://cdn.xuliangwei.com/16231428887232.jpg "-c500")
