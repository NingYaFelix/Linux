# 安装Jumpserver

## 目录

-   [安装Jumpserver](#安装Jumpserver)
    -   [2.1 基础环境准备](#21-基础环境准备)
    -   [2.2 安装Mariadb](#22-安装Mariadb)
    -   [2.3 安装Redis](#23-安装Redis)
    -   [2.4 安装Jumpserver](#24-安装Jumpserver)
        -   [2.4.1 安装依赖及Python](#241-安装依赖及Python)
        -   [2.4.1 下载Core源码包](#241-下载Core源码包)
        -   [2.4.2 安装Python依赖](#242-安装Python依赖)
        -   [2.4.3 修改配置文件](#243-修改配置文件)
        -   [2.4.4 启动Core程序](#244-启动Core程序)
    -   [2.5 安装Lina](#25-安装Lina)
        -   [2.5.1 下载源码](#251-下载源码)
        -   [2.5.1 安装Node](#251-安装Node)
        -   [2.5.2 安装依赖](#252-安装依赖)
        -   [2.5.3 修改配置](#253-修改配置)
        -   [2.5.4 运行Lina](#254-运行Lina)
        -   [2.5.5 构建Lina](#255-构建Lina)
        -   [2.5.6 站点测试（可略过）](#256-站点测试可略过)
    -   [2.6 安装Luna](#26-安装Luna)
        -   [2.6.1 下载源码](#261-下载源码)
        -   [2.6.2 安装依赖](#262-安装依赖)
        -   [2.6.3 修改配置文件](#263-修改配置文件)
        -   [2.6.5 构建luna](#265-构建luna)
    -   [2.7 安装KoKo](#27-安装KoKo)
        -   [2.7.1 安装Go](#271-安装Go)
        -   [2.7.2 下载源码](#272-下载源码)
        -   [2.7.3 编译程序](#273-编译程序)
        -   [2.7.4 修改配置](#274-修改配置)
        -   [2.7.5 启动KoKo](#275-启动KoKo)
    -   [2.8 安装Lion](#28-安装Lion)
        -   [2.8.1 构建 Guacd](#281-构建-Guacd)
        -   [2.8.2 启动 Guacd](#282-启动-Guacd)
        -   [2.8.3 下载Lion](#283-下载Lion)
        -   [2.8.4 修改配置](#284-修改配置)
        -   [2.8.5 启动Lion](#285-启动Lion)
    -   [2.9 安装Nginx](#29-安装Nginx)
        -   [2.9.1 安装nginx](#291-安装nginx)
        -   [2.9.2 整合jumpserver](#292-整合jumpserver)
        -   [配置https](#配置https)
    -   [迁移数据库至远程](#迁移数据库至远程)
-   [需要启动的服务](#需要启动的服务)

## 安装Jumpserver

### 2.1 基础环境准备

| 服务器公网IP   | 服务器私网IP     | 提供应用       | 软件版本   |
| --------- | ----------- | ---------- | ------ |
| 10.0.0.61 | 172.16.1.61 | jumpserver | 2.13.2 |
| 10.0.0.63 | 172.16.1.63 | mariadb    | 10.2   |
| 10.0.0.64 | 172.16.1.64 | redis      | 6.0    |

### 2.2 安装Mariadb

1.准备mariadb yum源地址&#x20;

[mariadb官方网站](https://downloads.mariadb.org/mariadb/repositories/ "mariadb官方网站")

```bash
# 国外官方源（下载非常慢）
[root@jumpserver ~]# cat >> /etc/yum.repos.d/mariadb.repo <<-EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.6/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF 

# 国内加速器
[root@jumpserver ~]# cat > /etc/yum.repos.d/mariadb.repo <<-EOF
[mariadb]
name = MariaDB
baseurl = https://mirrors.ustc.edu.cn/mariadb/yum/10.2/centos7-amd64
gpgkey=https://mirrors.ustc.edu.cn/mariadb/yum/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
```

2.安装maraidb，并检查版本是否

`>=10.2`

```bash
# yum install MariaDB-server MariaDB-client MariaDB-devel MariaDB-shared -y
# mysql --version
```

3.启动mariadb，然后配置本地

`root`

登录密码

```bash
# systemctl enable mariadb
# systemctl start mariadb
# mysqladmin password oldxu.net123
```

4.创建数据库

```bash
MariaDB [(none)]> create database jumpserver default charset 'utf8';
MariaDB [(none)]> grant all privileges on jumpserver.* to jumpserver@'localhost' identified by 'oldxu.net123';
```

### 2.3 安装Redis

1.安装yum源，获取最新的redis版本

```bash
# yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
# yum --enablerepo=remi install redis -y
# redis-server --version
```

2.配置并启动

`redis`

```bash
[root@jumpserver ~]# systemctl start redis
[root@jumpserver ~]# systemctl enable redis
```

### 2.4 安装Jumpserver

#### 2.4.1 安装依赖及Python

1.安装基础依赖环境

```bash
# yum install gcc gcc-c++ make epel-release openldap-devel MariaDB-devel MariaDB-shared libffi-devel sshpass -y
```

2.安装Python3环境

```bash
yum install python36 python36-devel -y
```

#### 2.4.1 下载Core源码包

```bash
# cd /opt
# wget -O /opt/jumpserver-v2.13.2.tar.gz https://github.com/jumpserver/jumpserver/archive/refs/tags/v2.13.2.tar.gz
# tar xf jumpserver-v2.13.2.tar.gz
# cd jumpserver-2.13.2/
```

#### 2.4.2 安装Python依赖

1.为 JumpServer 项目单独创建 python3 虚拟环境，每次运行项目都需要先执行&#x20;

`source /opt/py3/bin/activate`

&#x20;载入此环境。

```bash
[root@jumpserver jumpserver-2.13.2]# python3 -m venv /opt/py3
[root@jumpserver jumpserver-2.13.2]# source /opt/py3/bin/activate
(py3) # 
deactivate  #退出虚拟环境

```

2.安装

`jumpserver`

相关依赖软件

```bash
(py3) # pip install -r requirements/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/
```

#### 2.4.3 修改配置文件

1.创建相关秘钥

```bash
# 加密秘钥 生产环境中请修改为随机字符串，请勿外泄, 可使用命令生成 
# cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 49;echo

# 预共享Token koko 和 lion 用来注册服务账号，不在使用原来的注册接受机制
# cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 24;echo
```

2.修改配置文件

```bash
(py3) # cp config_example.yml config.yml

# 修改后的配置文件
(py3) # grep "^[a-Z]" config.yml 
SECRET_KEY: BpjpU68Z08SmUgr9HMHbdcGgTkSkDKmz8o6aLt5mJo2kgkNoH  # 必须有
BOOTSTRAP_TOKEN: 1gaKWv09fjmip6IISbHX0Ggl    # 必须有
SESSION_EXPIRE_AT_BROWSER_CLOSE: true
DB_ENGINE: mysql
DB_HOST: 127.0.0.1
DB_PORT: 3306
DB_USER: jumpserver
DB_PASSWORD: oldxu.net123
DB_NAME: jumpserver
HTTP_BIND_HOST: 0.0.0.0
HTTP_LISTEN_PORT: 8080
WS_LISTEN_PORT: 8070
REDIS_HOST: 127.0.0.1
REDIS_PORT: 6379
```

#### 2.4.4 启动Core程序

1.前台运行测试

```bash
# ./jms start
```

2.测试没有问题后可以通过

`-d`

选项放入后台

```bash
# ./jms start -d
```

### 2.5 安装Lina

#### 2.5.1 下载源码

```bash
# cd /opt
# wget -O /opt/lina-v2.13.2.tar.gz https://github.com/jumpserver/lina/archive/refs/tags/v2.13.2.tar.gz
# tar -xf lina-v2.13.2.tar.gz
# cd lina-2.13.2
```

#### 2.5.1 安装Node

1.安装

`node 10版本`

```bash
# 执行命令后会有提示，否则没安装成功
# curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash
# curl -sL https://rpm.nodesource.com/setup_12.x | bash -
# yum makecache
# yum install nodejs -y
```

2.配置node下载站点为国内，加速下载

```bash
# npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass
# npm config set registry https://registry.npm.taobao.org
```

#### 2.5.2 安装依赖

```bash
# npm install -g yarn
# yarn config set registry https://registry.npm.taobao.org
# yarn install
```

#### 2.5.3 修改配置

```bash
# vim  .env.development 

# 全局环境变量 请勿随意改动
ENV = 'development'

# base api
VUE_APP_BASE_API = ''
VUE_APP_PUBLIC_PATH = '/ui/'
VUE_CLI_BABEL_TRANSPILE_MODULES = true

# External auth
VUE_APP_LOGIN_PATH = '/core/auth/login/'
VUE_APP_LOGOUT_PATH = '/core/auth/logout/'

# Dev server for core proxy
VUE_APP_CORE_HOST = 'http://localhost:8080'
VUE_APP_CORE_WS = 'ws://localhost:8070'
VUE_APP_ENV = 'development'
```

#### 2.5.4 运行Lina

```bash
# yarn serve

# 确保能正常访问
```

#### 2.5.5 构建Lina

```bash
# yarn build:prod

# 拷贝静态资源至该目录，后续可以使用nginx调用
# cp -rp lina/ /opt/
```

#### 2.5.6 站点测试（可略过）

```bash
server {
  listen       80;
  server_name  _;

  location /ui/ {
    try_files $uri / /ui/index.html;
    alias /jumpserver/lina/;
  }

  location / {
      rewrite ^/(.*)$ /ui/$1 last;
  }
  
  location /core/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  # Core data 静态资源
  location /media/replay/ {
    add_header Content-Encoding gzip;
    root /opt/jumpserver-2.13.2/data/;
  }

  location /media/ {
    root /opt/jumpserver-2.13.2/data/;
  }

  location /static/ {
    root /opt/jumpserver-2.13.2/data/;
  }
}
```

### 2.6 安装Luna

#### 2.6.1 下载源码

```bash
# cd /opt
# wget -O /opt/luna-v2.13.2.tar.gz https://github.com/jumpserver/luna/archive/refs/tags/v2.13.2.tar.gz
# tar -xf luna-v2.13.2.tar.gz 
# cd luna-v2.13.2
```

#### 2.6.2 安装依赖

```bash
# npm config set registry https://mirrors.huaweicloud.com/repository/npm/
# npm install
# npm rebuild node-sass
```

#### 2.6.3 修改配置文件

```bash
# vi proxy.conf.json
{
  "/koko": {
    "target": "http://localhost:5000",  # KoKo 地址
    "secure": false,
    "ws": true
  },
  "/media/": {
    "target": "http://localhost:8080",  # Core 地址
    "secure": false,
    "changeOrigin": true
  },
  "/api/": {
    "target": "http://localhost:8080",  # Core 地址
    "secure": false,                    # https ssl 需要开启
    "changeOrigin": true
  },
  "/core": {
    "target": "http://localhost:8080",  # Core 地址
    "secure": false,
    "changeOrigin": true
  },
  "/static": {
    "target": "http://localhost:8080",  # Core 地址
    "secure": false,
    "changeOrigin": true
  },
  "/lion": {
    "target": "http://localhost:9529",  # Lion 地址
    "secure": false,
    "pathRewrite": {
      "^/lion/monitor": "/monitor"
    },
    "ws": true,
    "changeOrigin": true
  },
  "/omnidb": {
    "target": "http://localhost:8082",
    "secure": false,
    "ws": true,
    "changeOrigin": true
  }
}
```

#### 2.6.5 构建luna

```bash
# npm run-script build
# cp -rp luna/ /opt/
```

### 2.7 安装KoKo

-   Koko 是 Go 版本的 coco，重构了 coco 的 SSH/SFTP 服务和 Web Terminal 服务。

#### 2.7.1 安装Go

```bash
# yum install go

# go version
go version go 2.15.14 linux/amd64
```

#### 2.7.2 下载源码

```bash
# cd /opt 
# wget -O /opt/koko-v2.13.2.tar.gz https://github.com/jumpserver/koko/archive/refs/tags/v2.13.2.tar.gz
# tar -xf koko-v2.13.2.tar.gz
# cd koko-2.13.2
```

#### 2.7.3 编译程序

```bash
# go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/
# make

# 编译完成后在build目录
# cd build/
# tar xf koko---linux-amd64.tar.gz 
# cd koko---linux-amd64
```

#### 2.7.4 修改配置

```bash
# cp config_example.yml config.yml
# vim config.yml 

# 项目名称, 会用来向Jumpserver注册, 识别而已, 不能重复
# NAME: {{ Hostname }}

# Jumpserver项目的url, api请求注册会使用
CORE_HOST: http://127.0.0.1:8080

# Bootstrap Token, 预共享秘钥, 用来注册coco使用的service account和terminal
# 请和jumpserver 配置文件中保持一致，注册完成后可以删除
BOOTSTRAP_TOKEN: 1gaKWv09fjmip6IISbHX0Ggl

# 启动时绑定的ip, 默认 0.0.0.0
BIND_HOST: 0.0.0.0

# 监听的SSH端口号, 默认2222
SSHD_PORT: 2222

# 监听的HTTP/WS端口号，默认5000
HTTPD_PORT: 5000

# 设置日志级别 [DEBUG, INFO, WARN, ERROR, FATAL, CRITICAL]
LOG_LEVEL: INFO

# SSH连接超时时间 (default 15 seconds)
SSH_TIMEOUT: 15

# 语言 [en,zh]
LANGUAGE_CODE: zh

# SFTP是否显示隐藏文件
# SFTP_SHOW_HIDDEN_FILE: false

# 是否复用和用户后端资产已建立的连接(用户不会复用其他用户的连接)
# REUSE_CONNECTION: true

# 资产加载策略, 可根据资产规模自行调整. 默认异步加载资产, 异步搜索分页; 如果为all, 则资产全部加载, 本地搜索分页.
# ASSET_LOAD_POLICY:

# zip压缩的最大额度 (单位: M)
# ZIP_MAX_SIZE: 1024M

# zip压缩存放的临时目录 /tmp
# ZIP_TMP_PATH: /tmp

# 向 SSH Client 连接发送心跳的时间间隔 (单位: 秒)，默认为30, 0则表示不发送
# CLIENT_ALIVE_INTERVAL: 30

# 向资产发送心跳包的重试次数，默认为3
# RETRY_ALIVE_COUNT_MAX: 3

# 会话共享使用的类型 [local, redis], 默认local
# SHARE_ROOM_TYPE: local

# Redis配置
# REDIS_HOST: 127.0.0.1
# REDIS_PORT: 6379
# REDIS_PASSWORD:
# REDIS_CLUSTERS:
# REDIS_DB_ROOM:

# 是否开启本地转发 (目前仅对 vscode remote ssh 有效果)
# ENABLE_LOCAL_PORT_FORWARD: false

# 是否开启 针对 vscode 的 remote-ssh 远程开发支持 (前置条件: 必须开启 ENABLE_LOCAL_PORT_FORWARD )
# ENABLE_VSCODE_SUPPORT: false
```

#### 2.7.5 启动KoKo

```bash
# ./koko -d 
# netstat -lntp |grep koko
tcp6       0      0 :::5000         :::*              LISTEN      21470/./koko       
tcp6       0      0 :::2222         :::*              LISTEN      21470/./koko 
```

### 2.8 安装Lion

[Lion](https://github.com/jumpserver/lion-release "Lion")使用了 [Apache](http://www.apache.org/ "Apache")软件基金会的开源项目 [Guacamole](http://guacamole.apache.org/ "Guacamole")，JumpServer 使用 Golang 和 Vue 重构了 Guacamole 实现 RDP/VNC 协议跳板机功能。

#### 2.8.1 构建 Guacd

```bash
# yum install libpng-devel libjpeg-devel cairo-devel uuid-devel -y

# 安装插件，否则会提供不支持rdp等协议：guacd: Support for protocol "rdp" is not installed
# yum install libtelnet-devel libvncserver-devel pulseaudio-libs-devel openssl-devel freerdp-devel pango-devel libssh2-devel  libtelnet-devel 

# 下载
# cd /opt
# wget http://download.jumpserver.org/public/guacamole-server-2.3.0.tar.gz
# cd guacamole-server-2.3.0/

# 构建
# ./configure --with-init-dir=/etc/init.d
# make && make install
# ldconfig
```

#### 2.8.2 启动 Guacd

```bash
# /etc/init.d/guacd start
```

#### 2.8.3 下载Lion

```bash
# cd /opt
# wget https://github.com/jumpserver/lion-release/releases/download/v2.13.2/lion-v2.13.2-linux-amd64.tar.gz
# tar -xf lion-v2.13.2-linux-amd64.tar.gz
# cd lion-v2.13.2-linux-amd64
```

#### 2.8.4 修改配置

```bash
# cp config_example.yml config.yml
# vi config.yml


# 项目名称, 会用来向Jumpserver注册, 识别而已, 不能重复
# NAME: {{ Hostname }}

# Jumpserver项目的url, api请求注册会使用
CORE_HOST: http://127.0.0.1:8080

# Bootstrap Token, 预共享秘钥, 用来注册使用的service account和terminal
# 请和jumpserver 配置文件中保持一致，注册完成后可以删除
BOOTSTRAP_TOKEN: 1gaKWv09fjmip6IISbHX0Ggl

# 启动时绑定的ip, 默认 0.0.0.0
BIND_HOST: 0.0.0.0

# 监听的HTTP/WS端口号，默认8081
HTTPD_PORT: 8081

# 设置日志级别 [DEBUG, INFO, WARN, ERROR, FATAL, CRITICAL]
LOG_LEVEL: INFO

# Guacamole Server ip， 默认127.0.0.1
# GUA_HOST: 127.0.0.1

# Guacamole Server 端口号，默认4822
# GUA_PORT: 4822

# 会话共享使用的类型 [local, redis], 默认local
# SHARE_ROOM_TYPE: local

# Redis配置
# REDIS_HOST: 127.0.0.1
# REDIS_PORT: 6379
# REDIS_PASSWORD:
# REDIS_DB_ROOM:
```

#### 2.8.5 启动Lion

```bash
# ./lion 
```

### 2.9 安装Nginx

#### 2.9.1 安装nginx

```bash
# yum install nginx -y
# systemctl enable nginx
```

#### 2.9.2 整合jumpserver

```bash
server {
  listen 80;
  server_name jumpserver.oldxu.net;
  client_max_body_size 5000m;

  # Luna 配置
  location /luna/ {
    try_files $uri / /index.html;
    alias /opt/luna/;
  }

  # Core data 静态资源
  location /media/replay/ {
    add_header Content-Encoding gzip;
    root /opt/jumpserver-2.13.2/data/;
  }

  location /media/ {
    root /opt/jumpserver-2.13.2/data/;
  }

  location /static/ {
    root /opt/jumpserver-2.13.2/data/;
  }

  # KoKo Lion 配置
  location /koko/ {
    proxy_pass       http://localhost:5000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_http_version 2.1;
    proxy_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  # lion 配置
  location /lion/ {
    proxy_pass http://localhost:8081;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_ignore_client_abort on;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 6000;
  }

  # Core 配置
  location /ws/ {
    proxy_pass http://localhost:8070;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  location /api/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location /core/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  # 前端 Lina
  location /ui/ {
    try_files $uri / /ui/index.html;
    alias /opt/lina/;
  }
  location / {
    rewrite ^/(.*)$ /ui/$1 last;
  }
}
```

#### 配置https

```bash
server {
  
  listen 443 ssl;
  server_name jumpserver.lyjjhh.top;
  ssl_certificate  ssl/jumpserver.lyjjhh.top.pem;
  ssl_certificate_key  ssl/2_jumpserver.lyjjhh.top.key;
  client_max_body_size 5000m;

  # Luna 配置
  location /luna/ {
    try_files $uri / /index.html;
    alias /opt/luna/;
  }

  # Core data 静态资源
  location /media/replay/ {
    add_header Content-Encoding gzip;
    root /opt/jumpserver-2.13.2/data/;
  }

  location /media/ {
    root /opt/jumpserver-2.13.2/data/;
  }

  location /static/ {
    root /opt/jumpserver-2.13.2/data/;
  }

  # KoKo Lion 配置
  location /koko/ {
    proxy_pass       http://localhost:5000;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_http_version 2.1;
    proxy_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  # lion 配置
  location /lion/ {
    proxy_pass http://localhost:8081;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    proxy_ignore_client_abort on;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
    proxy_read_timeout 600;
    send_timeout 6000;
  }

  # Core 配置
  location /ws/ {
    proxy_pass http://localhost:8070;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_http_version 1.1;
    proxy_buffering off;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  }

  location /api/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  location /core/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  }

  # 前端 Lina
  location /ui/ {
    try_files $uri / /ui/index.html;
    alias /opt/lina/;
  }
  location / {
    rewrite ^/(.*)$ /ui/$1 last;
  }
}

server {
        listen 80;
        server_name jumpserver.lyjjhh.top;
        return 302  https://$server_name$request_uri;


}

```

### 迁移数据库至远程

```bash
#停止jms
  source /opt/py3/bin/activate
  cd /opt/jumpserver-2.13.2/
  ./jms stop
#备份数据库
  mysqldump -uroot -pxiaoluozi -B jumpserver > /tmp/jms.sq1
#迁移数据库
  scp /tmp/jms.sql root@172.16.1.63:~
#独立数据库节点对数据进行恢复
  mysql < /root/jms.sql
#修改jms配置
  source /opt/py3/bin/activate 
  cd /opt/jumpserver-2.13.2/
  vim config.yml
    DB_ENGINE: mysql
    DB_HOST: 172.16.1.63
    DB_PORT: 3306
    DB_USER: jumpserver
 #启动jms
   ./jms start -d

```

# 需要启动的服务

```bash
systemctl start mariadb   #启动数据库 
systemctl start redis  #启动redis
python3 -m venv /opt/py3   #搭建虚拟python环境
source /opt/py3/bin/activate  #进入虚拟环境，进入环境之前需要先搭建环境
deactivate #退出虚拟python环境
./jms start|stop -d   #启动停止core程序（8080|8070端口）并放入后台，需在jumpserver文件夹和py虚拟环境进行运行
yarn serve  #运行lina确保正常访问，需在lina文件夹并在python虚拟环境进行操作
yarn build:prod   #构建lina，需在lina文件夹并在python虚拟环境进行操作

./koko -d  #启动koko放入后台
./configure --with-init-dir=/etc/init.d  #构建guard
/etc/init.d/guacd start   #运行guard
./lion   #运行lion-d放入后台
systemctl start  nginx #启动nginx



```
