# nginx的rewrite模块

## 目录

-   [rewrite基本概述](#rewrite基本概述)
    -   [应用场景](#应用场景)
    -   [重写原理](#重写原理)
-   [重写模块](#重写模块)
    -   [if条件判断指令](#if条件判断指令)
    -   [set设定变量指令](#set设定变量指令)
    -   [return返回数据指令](#return返回数据指令)
-   [rewrite](#rewrite)
    -   [redirect与permanent区别](#redirect与permanent区别)
-   [Rewrite生产案例实践](#Rewrite生产案例实践)
    -   [跳转示例1](#跳转示例1)
    -   [跳转示例2](#跳转示例2)
    -   [跳转示例3](#跳转示例3)
    -   [跳转示例4](#跳转示例4)
    -   [跳转示例5](#跳转示例5)
    -   [跳转示例6](#跳转示例6)
    -   [跳转示例7](#跳转示例7)
    -   [跳转示例8](#跳转示例8)
    -   [跳转示例9](#跳转示例9)
    -   [跳转示例10](#跳转示例10)
    -   [跳转示例11](#跳转示例11)

# rewrite基本概述

主要实现url地址重写以及跳转。就是将用户请求web服务器的url地址重新修改为其他url地址的过程

## 应用场景

1.地址跳转：用户访问www\.jd.com这个URL时，将其定向至一个新的域名m.jd.com

2.协议跳转，将用户通过http的请求协议重新跳转至https协议（实现https的主要手段）

3.URL静态化，将动态URL地址显示为静态URL的一种技术，减少URL对外暴露过多参数

## 重写原理

![](image/image_FFEr5G0HyQ.png)

# 重写模块

set：设置变量  if：语句判断  return：返回值或url  rewrite：重定向url

## if条件判断指令

示例：语法：if （condition） {...}  \~模糊匹配  \~\*不区分大小写的匹配   ！\~不匹配   =精准匹配

```bash
#匹配nginx请求中包含id=2356的，然后代理到10.16.3.5的8080端口
vim url.oldxu.net.conf
server {
  listen 80;
    server_name url.oldxu.net;
    default_type application/json;
    root /code;
  location / {
   index index.html;
   if ($request_uri ~* 'id=\d{4}') #\d表示数字，{4}表示4次，{4，8}表示数字出现次数为4到8次，gid=12345678就符合条件。
   {
   proxy_pass http://10.16.3.5:8080;
   }
  }
}
#测试
curl -L test.oldcxu.net/?id=2356                                                                                           
```

## set设定变量指令

语法：set \$variable value;

```bash
#需求:通过user_agent (Header）拦截压测测试工具
#user_agent:
#chrome ,firefox，cur1/7.29.0
#1.确认来请求的用户是使用的cur1命令，如果是则做一标记，设置为1;
#2.判断标记，如果标记的值假设为1，我们就拒绝，如果为1则不处理;
server {
    listen 80;
    server_name set.oldxu.net;
    root /code;
    index index.html;
    location / {
    if ($http_user_agent ~*"wget|ApacheBench") {
    set $deny_user_agent 1;
}
    if ($deny_user_agent = 1){
      return 403;
    }
}
模拟压测工具访问
curl -A "Yisouspider" -I URL
curl -A "ApacheBench" -I URL
curl -A "wget" -I URL

```

## return返回数据指令

```bash
[root@web01]# cat ur1.oldxu.net.conf
server {
    listen 80;
    server_name ur1.oldxu . net;root /code;
    location / {
    index index.html ;
    default_type text/htm7;
    if ( $http_user_agent ~* "MSIE|firefox") 
    {
    return 200 "change browser";#返回字符串
    return 500;#返回状态码
    return 302
    https://www.xuliangwei.com#返回URL，进行跳转
   }
   } 
```

# rewrite

```bash
#rewrite表达式可以应用在server , 1ocation，if标签下
#flag
last   #本条规则匹配完成后，继续向下匹配新的
location URI规则
break   #本条规则匹配完成即终止，不再匹配后面的任何规则
redirect   #返回302临时重定向,地址栏会显示跳转后的地址
permanent   #返回301永久重定向,地址栏会显示跳转后的地址

###测试代码准备###
server {
    listen 80;
    server_name url.oldxu.net;
    root /code;
    location / {
    rewrite /1.htm1 /2.html;rewrite /2.htm1 /3.html;
}
    location /2.html {
    rewrite /2.htm1 /a.html ;
}
      location /3.html {
      rewrite /3.html /b.html;
}
}
准备以上所需代码。
```

break和last：如果loaction内部遇到break本location及后面的指令都不在执行直接执行break本行内容。last遇见以后，本location后续指令不执行

### redirect与permanent区别

| flag      | 跳转   | 状态码 | 排名情况             |
| --------- | ---- | --- | ---------------- |
| redirect  | 临时跳转 | 302 | 对旧网站无影响，新网战会有排名  |
| permanent | 永久跳转 | 301 | 新跳转网站有排名，旧网站会被清空 |

# Rewrite生产案例实践

## 跳转示例1

```bash
#根据用户浏览器请求中携带的语言调度到不同界面
server {
listen 80;
    server_name url.o1dxu.net;
    root /code;
      if ($http_accept_1anguage ~* "zh-CN|zh") 
      {
      set $language /zh;
}
      if ($http_accept_1anguage ~*"en") {
      set $language /en;
}
        rewrite ^/$ /$language;#根据语言跳转对应的站点
        location / {
        index index.htm1;
}

```

## 跳转示例2

```bash
#用户通过手机设备访问url.oldxu.net,跳转至url.oldxu.net/m
vim /etc/nginx/conf.d/oldxu.net.conf
server {
      listen 80;
      server_name url.o7dxu.net;
      root /code;
      if ($http_user_agent *"android |iphone lipad") 
      {
      rewrite ^/$/m;
}
}
```

## 跳转示例3

```bash
#用户通过手机访问url.oldxu.net跳转至m.oldxu.net
vim /etc/nginx/conf.d/url.oldxu.net.conf
server {
      listen 80;
      server_name url.o7dxu.net;
      root /code;
      if ($http_user_agent *"android |iphone lipad") 
      {
      rewrite ^/$ http://m.oldxu.net;
}
}
server {
      1isten 80;
      server_name m.oldxu.net;
      root /data/m;
      location / {
        index index.html ;
}
}

```

## 跳转示例4

```bash
#用户通过http协议请求，能自动跳转至https协议
vim /etc/nginx/conf.d/url.oldxu.net
server {
      listen 80;
      server_name ur1.oldxu.net;
      rewrite ^(.*)$ https://$server_name$1redirect;
      #return 302
      https://$server_name$request_uri ;
}
      server {
      listen 443;
      server_name url.oldxu.net;
      ssl on;
}
```

## 跳转示例5

```bash
#网站在维护过程中，希望用户访问所有网站重定向至一个维护页面
vim /etc/nginx/conf.d/url.net.conf
server {
  listen 80;
  server_name url.oldxu.net;
  root /code;
    rewrite ^(.*)$ /wh.html break;
    location / {
      index index.html;
}
}

```

## 跳转示例6

```bash
#当服务器遇到403、404、502等错误时，自动跳转到临时维护的静态页
vim /etc/nginx/conf.d/url.net.conf
server  {
    listen 80;
     server_name url.oldxu.net;
     root /code;
     location / {
     index index.html;
     }
     error_page 404 403 502 = @tempdown;
     location @tempdown {
     rewrite ^(.*)$ /wh.html break;
     }
}
```

## 跳转示例7

```bash
#公司网站在停机时，指定的IP能够正常访问，其他的ip跳转到维护页
vim  /etc/nginx/conf.d/wh.conf
server {
listen 80;
server_name ur1.o1dxu.net;
root /code;
#1.在server层下设定ip变量值为0
set $ip 0;
#2.如果来源IP是10.0.0.101 102则设定变量为ip变量为1。
if ($remote_addr ="10.0.0.101|10.0.0.102") {
    set $ip 1;
}
#3.如果来源工P不是10.0.0.101 102、则跳转至/code/wh.html这个页面,否则不做任何处理
      if ($ip = 0) {
      rewrite ^(.*)$ /wh.htm1 break;
      }
#―->如果想针对某个1ocation进行操作，则将如上配置写入location中即可
            location / {
            index index.htm1;
}
}
```

## 跳转示例8

```bash
#公司网站后台/admin，只允许公司的出口公网IP可以访问，其他的IP访问全部返回500，或直接跳转至首页
location /admin {
    set $ip 0;
    if ($remote_addr = "61.149.186.152 |139.226.172.254”) 
    {
      set $ip 1;
}
      if ($ip = 0){
  return 500;
  #rewrite /(.*)$ https://ur1.oldxu.net redirect;
}
}

```

## 跳转示例9

![](image/image_f60PU6h9ES.png)

```bash
server {
listen 80;
server_name url.oldxu.net;
#匹配域名，然后将第一个字段赋值给domain
if ( $host ~*(.*)\.(.*)\.(.*)\.(.*) ) 
{
#if ($host ~*(.*)\..* ) 
{
set $domain $1;
}
rewrite N/(.*) http://demo:27610/$domain/$1 last;


```

## 跳转示例10

```bash
#现有两台服务器，想要实现http://console.oldxu .net/index. php?r=sur/index/sid/613192/1ang/zh-Hans
#若访问资源为/index.php?r=survey...则跳转到http://sur.o1dxu.net/index.php?r=survey /index / sid/613192/ 1ang/zh-Hans
#请求的域名: http://url.oldxu.net/index.php?r=survey/index/sid/613192/lang/zh-Hans
#替换后域名: http:/lsur.oldxu.net/index.php?r=survey/index/sid/613192/lang/zh-Hans
server {
listen 80;
server_name console.oldxu.net;
    root /code;
    index index.htm1;
    location / {
    if ($args ~ r=survey) {
    rewrite ^/(.*)
    http://sur.o1dxu.net$request_uri? redirect;
}
}
}
测试
# curl -I -HHost:tou.o1dxu.nethttp://10.0.0.7/index.php?
r=survey /index/sid/613192 /1ang/zh-HansHTTP/1.1 302 Moved Temporarily
server: nginx/1.18.0
Date: wed，18 Aug 2021 09:58:18 GMT
content-Type: text/html
content-Length : 145
connection: keep-alive
Location: http://sur.o1dxu.net/index.php?r=survey/index/sid/613192 /lang/zh-Hans

```

## 跳转示例11

```bash
需求:将用户请求http://ur1.o1dxu.net/?id=2，替换为http://ur1.o1dxu.net/id/2.htm1
1.必须是请求id?判断用户请求的是id这个关键参数;⒉.提取整个uri中的两个字段，将左边的做成一个变量，将右边的做成一个变量;
3.如果来源为id成立的话，则执行rewirte;
server {
  listen 80;
  server_name ur1.oldxu.net;root /code;
  location / {
  if ($args ~* "id") {
  set $oK1;
}
    if($args ~*(.*)\=(.*) ){
    set $id $1;
    set $number $2 ;
}
    if ( $oK = "1") {
    #?这个尾缀，重定向的目标地址结尾处如果加了?号，则不会再转发传递过来原地址问号内容
    rewrite A(.*)$
    http://${server_name}/${id}/${number}.html? last;
}
}
}

```
