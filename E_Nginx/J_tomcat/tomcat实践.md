# tomcat实践

## 目录

-   [Tomcat 安装](#Tomcat-安装)
-   [Tomcat 配置](#Tomcat-配置)
    -   [Tomcat 配置文件解读(server.xml是tomcat的主配置文件)](#Tomcat-配置文件解读serverxml是tomcat的主配置文件)
        -   [每个标签的作用](#每个标签的作用)
        -   [Tomcat配置文件标签与nginx配置文件对比](#Tomcat配置文件标签与nginx配置文件对比)
    -   [增加一个虚拟主机](#增加一个虚拟主机)
    -   [添加Context的uri匹配（类似nginx的location的uri匹配）](#添加Context的uri匹配类似nginx的location的uri匹配)
    -   [Tomcat basic认证](#Tomcat-basic认证)
-   [单机部署zrlog博客](#单机部署zrlog博客)
-   [集群部署zrlog博客](#集群部署zrlog博客)
-   [Tomcat集群session基于redis实现测试](#Tomcat集群session基于redis实现测试)

&#x20;  tomcat是一种可以进行动态资源加载的软件，在使用tomcat往往需要搭配java进行使用  &#x20;

tomcat三个端口的使用：

8005：tomcat的通信端口

8080：tomcat访问web的接口

8009：tomcat负责和其他http服务器建立链接，在把Tomcat与其他HTTP服务器集成时，就需要用到这个连接器。

oraclejdk的安装方式：

```bash
wget   http://cdn.xuliangwei.com/jdk-8u281-linux-x64.rpm
```

***

***

# Tomcat 安装

-   Oracle Jdk安装

```bash
# rpm安装
[root@web01 ~]# wget http://cdn.xuliangwei.com/jdk-8u281-linux-x64.rpm
[root@web01 ~]# rpm -ivh jdk-8u281-linux-x64.rpm

# 二进制安装
[root@web01 ~]# wget http://cdn.xuliangwei.com/jdk-8u281-linux-x64.tar.gz
[root@web01 ~]# tar xf jdk-8u281-linux-x64.tar.gz -C /usr/local
[root@web01 ~]# ln -s /usr/local/jdk1.8.0_281/ /usr/local/jdk

# 二进制安装需要添加环境变量
[root@web01 ~]# vim /etc/profile.d/jdk.sh 
export JAVA_HOME=/usr/local/jdk
export PATH=$PATH:$JAVA_HOME/bin
export JRE_HOME=$JAVA_HOME/jre 
export CLASSPATH=$JAVA_HOME/lib/:$JRE_HOME/lib/
[root@web01 ~]# source /etc/profile

# 查看版本，测试是否安装成功
java -version
java version "1.8.0_281"
Java(TM) SE Runtime Environment (build 1.8.0_281-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.281-b09, mixed mode)

```

-   安装Tomcat

```bash
[root@web01 ~]# mkdir /soft && cd /soft
[root@web01 ~]# wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.53/bin/apache-tomcat-9.0.53.tar.gz
[root@web01 ~]# tar xf apache-tomcat-9.0.52.tar.gz -C /soft
[root@web01 ~]# ln -s /soft/apache-tomcat-9.0.52 /soft/tomcat
```

-   将Tomcat加入Systemd管理

```bash
# 可以使用systemctl cat 服务名 (查看已经安装的应用systemd管理配置文件)
[root@web01 ~]# vim /usr/lib/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
Environment=JAVA_HOME=/usr/local/jdk
Environment=CATALINA_HOME=/soft/tomcat
Environment=CATALINA_BASE=/soft/tomcat

ExecStart=/soft/tomcat/bin/startup.sh
ExecStop=/soft/tomcat/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

# Tomcat 配置

## Tomcat 配置文件解读(server.xml是tomcat的主配置文件)

```bash
[root@web03 soft]# cat /soft/tomcat/conf/server.xml
<?xml version="1.0" encoding="UTF-8"?>

<!--关闭tomcat的端口-->
<Server port="8005" shutdown="SHUTDOWN">

  <!--监听器 -->
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <!--全局资源限制-->
  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
  </GlobalNamingResources>

  <!--连接器-->
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />

    <!--引擎-->
    <Engine name="Catalina" defaultHost="localhost">

  <!--调用限制-->
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
               resourceName="UserDatabase"/>
      </Realm>

  <!--虚拟主机-->
      <Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>

```

### 每个标签的作用

```bash
server：  表示一个tomcat实例；
Listener：  监听器；
connector：  连接器，支持http、https、ajp等协议请求；
service：  将connector与engine关联的组件；
engine：  具体http、https的请求与响应； （Nginx中  http {}）
host：    与用户请求的Host字段进行比对；哪个Host匹配则哪个处理，如没有符合的则交给默认的defaultHost处理
```

### Tomcat配置文件标签与nginx配置文件对比

```bash
nginx中：
  http层：只能有一个；
  server：可以有多个，多个表示多个站点；
  location：一个站点的多个uri的路径匹配；
  
tomcat中：
  engine：只能有一个，也是负责请求与响应的；
  Host：  可以有多个，多个表示多个站点；
  context：用来定义用户请求的uri，将其调度到指定的目录中提取代码；
```

## 增加一个虚拟主机

```bash
<!--在server.xml里的Engine标签作用域内增加-->
    <!--tom01.oldshen.com-->
    <Host name="tom01.oldshen.com"  appBase="/code/tom01"
          unpackWARs="true" autoDeploy="true">
      <Valve className="org.apache.catalina.valves.AccessLogve" directory="logs"
             prefix="tom01_access_log" suffix=".txt"
             pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    </Host>

<!--创建相应的目录，并存放项目-->
    [root@web03 soft]# mkdir /code/tom1/ROOT -p
    [root@web03 soft]# echo "Tomcat Test Page" > /code/tom1/ROOT/index.html
<!--重启Tomcat-->
    [root@web03 ~]# systemctl stop tomcat
    [root@web03 ~]# systemctl start tomcat
```

## 添加Context的uri匹配（类似nginx的location的uri匹配）

```bash
tomcat Context：
    <!--tom01.oldshen.com-->
    <Host name="tom01.oldshen.com"  appBase="/code/tom01"
          unpackWARs="true" autoDeploy="true">
      <!--在相应的host里添加如下一行即可，path是匹配到的uri，docBase是替换的路径，类似nginx的alias别名-->
      <Context docBase="/code/zh" path="/zh" reloadable="true"/>
      <Valve className="org.apache.catalina.valves.AccessLogve" directory="logs"
             prefix="tom01_access_log" suffix=".txt"
             pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    </Host>

```

## Tomcat basic认证

-   这是tomcat webapps默认目录的相关配置
-   增加认证和后可以在tomcat默认weib中用鼠标进行增加虚拟主机等其他配置，或者查看java相关的内存资源

```bash
# 添加虚拟用户及密码
    [root@web03 ~]# vim /soft/tomcat/conf/tomcat-users.xml 
    <role rolename="manager-gui,admin-gui"/>
    <user username="tomcat" password="123456" roles="manager-gui,admin-gui"/>
# 修改第一个项目（如上截图中红框标注的Manager APP）
    [root@web03 ~]# vim /soft/tomcat/webapps/host-manager/META-INF/context.xml
    allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|10\.0\.0\.\d+" /> # 修改后（其实是在该行后面增加了一个网段，|10\.0\.0\.\d+），即允许该网段访问此项目
# 修改第二个项目
    [root@web03 ~]# vim  /soft/tomcat/webapps/manager/META-INF/context.xml
    allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|10\.0\.0\.\d+" /> # 修改后（其实是在该行后面增加了一个网段，|10\.0\.0\.\d+），即允许该网段访问此项目
# 最后重启tomcat并测试
  [root@web03 ~]# systemctl stop tomcat && systemctl start tomcat
```

# 单机部署zrlog博客

-   该博客是使用JAVA开发的，所以直接使用tomcat即可

```bash
# 1.准备虚拟主机：
      <!--zrlog.oldshen.com-->
    <Host name="zrlog.oldshen.com"  appBase="/code/zrlog"
       unpackWARs="true" autoDeploy="true">
      <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
          prefix="zrlog_access_log" suffix=".txt"
          pattern="%h %l %u %t &quot;%r&quot; %s %b" />
    </Host>
  mkdir -p /code/zrlog

# 2.准备项目代码(百度搜索zrlog官网下载war包)：，将war包拷贝到项目路径下并改名为ROOT.war，Tomcat会自动解压war包
    [root@web03 ~]# mv zrlog-2.2.0-5e8a51f-release.war /code/zrlog/ROOT.war
    [root@web03 ~]# ls /code/zrlog/
    ROOT.war
    [root@web03 ~]# systemctl stop tomcat && systemctl start tomcat

# 3.准备数据库的环境：(准备好后，web页面访问会有安装向导，需要数据库)
    # 注意：如果web改为集群，需要所有web节点都访问该数据库的库    
    MariaDB [(none)]> create database zrlog;
    MariaDB [(none)]> grant all privileges on *.* to 'app'@'172.16.1.%' identified by 'oldxu.net123';
    MariaDB [(none)]> flush privileges;
```

# 集群部署zrlog博客

-   安装JDK

```
此笔记上面有安装步骤

```

-   安装Tomcat和部署zrlog

```bash
# 1、需要先完成一次单机部署zrlog，而后打通数据库后，将该项目拷贝至其他web节点
# 1.1 拷贝zrlog项目到其他web节点
    [root@web03 ~]# scp -rp /code/* root@10.0.0.8:/code/
# 1.2 拷贝Tomcat到其他节点上
    [root@web03 ~]# scp -rp  /soft root@10.0.0.8:/
    [root@web03 ~]# scp /usr/lib/systemd/system/tomcat.service root@10.0.0.8:/usr/lib/systemd/system/tomcat.service
# 1.3 在新加入的节点上进行配置与启动
    [root@web02 ~]# systemctl daemon-reload
    [root@web02 ~]# rm -rf /soft/tomcat/
    [root@web02 ~]# ln -s /soft/apache-tomcat-9.0.52 /soft/tomcat
    [root@web02 ~]# systemctl start tomcat
```

-   接入负载均衡节点，且实现https访问：
    ```
    upstream zrlog {
        server 172.16.1.8:8080;
        server 172.16.1.9:8080;


    server {
        listen 443 ssl http2;
        server_name zrlog.oldxu.net;                    # 由于写该笔记时，使用的https是讲师oldxu本人的，所以需要域名和老师的一样。
        ssl_certificate ssl_key/6172853_zrlog.oldxu.net.pem;
        ssl_certificate_key ssl_key/6172853_zrlog.oldxu.net.key;

        location  / {
                proxy_pass http://zrlog;
                proxy_set_header Host zrlog.oldshen.com; # 这里将header重写成了zrlog.oldshen.com ,应为后端调度的tomcat虚拟主机域名是zrlog.oldshen.com，如果域名都统一，可以不用更改
        }


    server {
        listen 80;
        server_name  zrlog.oldxu.net;
        location / {
                return 302 https://zrlog.oldux.net;
        }

    ```
-   接入共享存储节点，NFS

```bash
# 1、安装配置启动
        [root@nfs ~]# yum install nfs-utils -y
        [root@nfs ~]# vim /etc/exports
        /data/zrlog 172.16.1.0/24(rw,all_squash,anonuid=666,anongid=666)
        
        [root@nfs ~]# groupadd -g 666 www
        [root@nfs ~]# useradd -u 666 -g 666 www
        
        [root@nfs ~]# mkdir /data/zrlog -p && chown -R www.www /data/zrlog/
        [root@nfs ~]# systemctl restart nfs-server
# 2、客户端挂载：（可以测试上传一个图片，然后按F12调试找到静态资源的uri路径，进行挂载即可）
        [root@web03 ~]# yum install nfs-utils -y
        [root@web03 ~]# mount -t nfs 172.16.1.32:/data/zrlog /code/zrlog/ROOT/attached/
        
        #如果web02节点没有该静态资源目录，所以自行创建
        [root@web02 ~]# mkdir /code/zrlog/ROOT/attached
        [root@web02 ~]# mount -t nfs 172.16.1.32:/data/zrlog /code/zrlog/ROOT/attached/
```

# Tomcat集群session基于redis实现测试

-   为所有的节点添加session相关的网页(虚拟主机)：

```bash
# 1、编辑server.xml配置文件，添加如下
       <!--session.oldxu.net-->
      <Host name="session.oldxu.net"  appBase="/code/session"
            unpackWARs="true" autoDeploy="true">
      </Host>
# 2、创建对应的网站目录，并且加入测试文件
    mkdir /code/session/ROOT -p
  cat  /code/session/ROOT/index.jsp
  <body>
  <%
  //HttpSession session = request.getSession(true);
  System.out.println(session.getCreationTime());
  out.println("<br> web01 SESSION ID:" + session.getId() + "<br>");   # 这一样的web01在多个web主机上需要不一样，方便区分
  out.println("Session created time is :" + session.getCreationTime()
  + "<br>");
  %>
  </body>

# 3、重启
    systemctl stop tomcat && systemctl start tomcat

```

-   接入负载均衡，测试检查，看看是否通过轮询调度，获取的session是不一致；

```bash
[root@proxy01 ~]# cat  /etc/nginx/conf.d/proxy_session.oldxu.net.conf
upstream session {
  server 172.16.1.8:8080;
  server 172.16.1.9:8080;
}

server {
  listen 80;
  server_name session.oldxu.net;

  location / {
    proxy_pass http://session;
    include proxy_params;
  }
}

[root@proxy01 ~]# nginx -t
[root@proxy01 ~]# systemctl reload nginx
```

-   \##### redis的方案来解决session会话保持
-   1、安装redis,配置redis

```bash
[root@redis-node1 ~]# yum install redis -y
[root@redis-node1 ~]# vim /etc/redis.conf
  bind 127.0.0.1 172.16.1.41
  requirepass 123456
[root@redis-node1 ~]# systemctl restart redis

# 检查redis是否正常能对外提供服务；
root@redis-node1 ~]# redis-cli -h 172.16.1.41 -a 123456
72.16.1.41:6379> 

```

-   2、tomcat要支持redis，需要模块（需要的是jar包）  所有的应用节点都需要配置

```bash
# 1、下载Tomcat需要支持Redis的jar包
    https://github.com/ran-jit/tomcat-cluster-redis-session-manager/releases/download/4.0/tomcat-cluster-redis-session-manager.zip
  
# 2、复制jar包到tomcat/lib目录中
    [root@web02 ~]# cp tomcat-cluster-redis-session-manager/lib/* /soft/tomcat/lib/

# 3、复制redis配置文件到tomcat/conf目录中。并更新它；
    [root@web02 ~]#  cp tomcat-cluster-redis-session-manager/conf/redis-data-cache.properties /soft/tomcat/conf/

# 4、修改redis配置信息
  [root@web02 ~]# vim /soft/tomcat/conf/redis-data-cache.properties
  #- redis hosts. ex: 127.0.0.1:6379, 127.0.0.2:6379, 127.0.0.2:6380, ....
  redis.hosts=172.16.1.41:6379

  #- redis password.
  redis.password=123456
  
# 5、添加两行配置文件在 tomcat/conf/context.xml (在<Context>标签里面添加)
    [root@web02 ~]# vim /soft/tomcat/conf/context.xml
      <Valve className="tomcat.request.session.redis.SessionHandlerValve" />
      <Manager className="tomcat.request.session.redis.SessionManager" />

# 6、[可选]：修改session过期时间，默认30m(如果添加后出现问题可以不用添加此步骤)
    <session-config>
      <session-timeout>60</session-timeout>
    </session-config>
      
    
[root@web02 ~]# systemctl stop tomcat && systemctl start tomcat 
```

查看tomcat 版本号。进入tomcat的bin目录下，运行version.sh脚本
