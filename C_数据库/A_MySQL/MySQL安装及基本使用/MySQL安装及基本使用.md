# MySQL安装及基本使用

## 目录

-   [数据库安装](#数据库安装)
    -   [二进制安装](#二进制安装)
-   [MySQL组成和常用工具](#MySQL组成和常用工具)
    -   [客户端程序](#客户端程序)
    -   [mysql命令格式](#mysql命令格式)
    -   [mycli](#mycli)
    -   [服务端配置](#服务端配置)
-   [SQL语言](#SQL语言)
    -   [语句构成](#语句构成)
    -   [字符集和排序](#字符集和排序)
    -   [管理数据库](#管理数据库)
        -   [创建数据库](#创建数据库)
        -   [修改数据库](#修改数据库)
        -   [删除数据库](#删除数据库)
        -   [查看数据库列表](#查看数据库列表)
-   [数据类型](#数据类型)
    -   [整数型](#整数型)
    -   [浮点型](#浮点型)
    -   [定点数](#定点数)
    -   [字符串](#字符串)
    -   [二进制数据BLOB](#二进制数据BLOB)
    -   [日期时间类型](#日期时间类型)
    -   [修饰符](#修饰符)

mysql官方地址：[https://www.mysql.com/](https://www.mysql.com/ "https://www.mysql.com/")[、http://mariadb.org](http://mariadb.org/ "、http://mariadb.org")、[https://www.percona.com](https://www.percona.com "https://www.percona.com")

特性：开源免费、插件式引擎、单进程，多线程、诸多扩展和新特性、提供很多测试组件

## 数据库安装

源安装

```bash
cat /.etc/yum.repos.d/mysql.repo
[mysql]
name=mysql5.7
baseurl=https://mirrors.tuna.tsinghua.edu.cn/mysql/yum/mysql-5.7-community-el7-
x86_64/
gpgcheck=0

yum install mysql-community-server
systemctl enable --now mysqld  #加入开机自启动并立即启动
5.7以上版本有初始密码，需要进入/var/log/mysql.log进行查看密码
#进入数据库进行修改密码
#修改简单密码不符合密码策略
mysql> alter user root@'localhost' identified by 'Magedu2021';
ERROR 1819 (HY000): Your password does not satisfy the current policy 
requirements

alter user root@'localhost' identified by 'Magedu0!'
#在数据库外进行修改初始密码
[root@centos7 ~]#mysqladmin -uroot -p'pe%b#S8ah)j-' password 'Magedu0!'
#对数据库进行初始化操作提高数据库安全性
file `which mysql_secure_installation`  #查找命令是否存在
mysql_secure_installation  #进行初始化操作


```

### 二进制安装

```bash
groupadd -r -g 306 mysql  #创建mysql组
useradd -r -g 306 -u 306 -d /data/mysql mysql  #创建mysql所属主
#准备二进制程序
tar xf mysql-VERSION-linux-x86_64.tar.gz -C /usr/local
cd /usr/loacl
ln -sv mysql-VERSION mysql #创建软连接
chown root.root /usr/local/mysql  #给mysql目录授权主组
#编写配置文件
cd /usr/local/mysql
cp -b support-files/my-default.cnf   /etc/my.cnf
vim /etc/my.cnf
#mysql语句块中添加以下三个选项
[mysqld]
datadir = /data/mysql
innodb_file_per_table = on #在mariadb5.5以上版的是默认值，可不加
skip_name_resolve = on    #禁止主机名解析，建议使用
#创建数据库文件
cd /usr/local/mysql/
./scripts/mysql_install_db --datadir=/data/mysql --user=mysql
ls /data/mysql -l  #查看设置的目录是都生成文件
#准备服务脚本，并启动服务
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld
service mysqld start

#如果有对应的service 文件可以执行下面
cp /usr/local/mysql/support-files/systemd/mariadb.service 
/usr/lib/systemd/system/
systemctl daemon-reload
systemctl enable --now mariadb
#将PATH路径写入文件
echo 'PATH=/usr/local/mysql/bin:$PATH' > /etc/profile.d/mysql.sh
. /etc/profile.d/mysql.sh
/usr/local/mysql/bin/mysql_secure_installation #进行安全初始化

```

一键安装脚本

docker安装mysql

```bash
docker run --name mysql -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 mysql:5.7.30
mysql -uroot -p123456 -h127.0.0.1
```

## MySQL组成和常用工具

### 客户端程序

mysql: 交互式或非交互式的CLI工具
mysqldump：备份工具，基于mysql协议向mysqld发起查询请求，并将查得的所有数据转换成
insert等写操作语句保存文本文件中
mysqladmin：基于mysql协议管理mysqld
mysqlimport：数据导入工具

### mysql命令格式

mysql \[OPTIONS]  \[database]

```bash
#常用选项
-A, --no-auto-rehash 禁止补全
-u, --user= 用户名,默认为root
-h, --host= 服务器主机,默认为localhost
-p, --passowrd= 用户密码,建议使用-p,默认为空密码
-P, --port= 服务器端口
-S, --socket= 指定连接socket文件路径
-D, --database= 指定默认数据库
-C, --compress 启用压缩
-e   "SQL" 执行SQL命令
-V, --version 显示版本
-v  --verbose 显示详细信息
--print-defaults 获取程序默认使用的配置
eg：
mysql>use mysql #切换数据库
mysql> select database();                   #查看当前数据库
mysql>select user(); #查看当前用户
mysql>SELECT User,Host,Password FROM user;
mysql>system clear #清屏
mysql> ^DBye       #ctrl+d 退出
#查看mysql版本
[root@centos8 ~]#mysql -V
mysql Ver 15.1 Distrib 10.3.11-MariaDB, for Linux (x86_64) using readline 5.1
#临时修改mysql提示符
[root@centos8 ~]#mysql -uroot -pcentos --prompt="\\r:\\m:\\s(\\u@\\h) [\\d]>\\_" 
#临时修改mysql提示符
[root@centos8 ~]#export MYSQL_PS1="\\r:\\m:\\s(\\u@\\h) [\\d]>\\_"  
#持久修改mysql提示符
[root@centos8 ~]#vim /etc/my.cnf.d/mysql-clients.cnf 
[mysql]
prompt="\\r:\\m:\\s(\\u@\\h) [\\d]>\\_"  
02:35:45(root@localhost) [(none)]>
#添加，MySQL客户端自动登录
vim /etc/my.cnf.d/client.cnf
[client]
user=wang
password=centos          
[mysql]
prompt=(\\u@\\h) [\\d]>\\_


```

mysqladmin命令

格式：mysqladmin \[OPTIONS] command command.....

```bash
#查看mysql服务是否正常，如果正常提示mysqld is alive
mysqladmin -uroot -pcentos   ping
#关闭mysql服务，但mysqladmin命令无法开启
mysqladmin -uroot -pcentos shutdown
#创建数据库testdb
mysqladmin -uroot -pcentos   create testdb 
#删除数据库testdb
mysqladmin -uroot -pcentos   drop testdb
#修改root密码
mysqladmin -uroot -pcentos password 'magedu'
#日志滚动,生成新文件/var/lib/mysql/mariadb-bin.00000N
mysqladmin -uroot -pcentos flush-logs
```

### mycli

MyCLI 是 MySQL，MariaDB 和 Percona 的命令行界面，具有自动完成和语法突出显示功能。安装

```bash
#centos8安装
yum install python3-pip -y
pip3 install mycli
#ubuntu安装
apt -y install mycli
[mycli -u root -S /var/run/mysqld/mysqld.sock


```

### 服务端配置

## SQL语言

-   常用组件

    数据库：database 表的集合，物理上表现为一个目录
    表：table，行：row 列：column
    索引：index
    视图：view，虚拟的表
    存储过程：procedure
    存储函数：function
    触发器：trigger
    事件调度器：event scheduler，任务计划
    用户：user
    权限：privilege
-   语言规范

    SQL 语句不区分大小写，建议用大写

    SQL语句可单行或多行书写，默认以 " ; " 结尾关键词不能跨多行或简写

    用空格和TAB 缩进来提高语句的可读性

    子句通常位于独立行，便于编辑，提高可读性

    注释标准：单行注释，注意空格：`-- 注释内容`

    \#多行注释：/\*注释内容
    注释内容
    注释内容\*/

    MySQL注释 #注释内容
-   命名规则

    必须以字母开头，后续可以包括字母,数字和三个特殊字符（# \_ \$）

    不要使用MySQL的保留字
-   数据库对象（组件）

    数据库、表、索引、视图、用户、存储过程、函数、触发器、事件调度器等
-   语句分类

    DDL: Data Defination Language 数据定义语言
    DML: Data Manipulation Language 数据操纵语言
    软件开发：CRUD

    DQL：Data Query Language 数据查询语言

    DCL：Data Control Language 数据控制语言

    TCL：Transaction Control Language 事务控制语言
    COMMIT，ROLLBACK，SAVEPOINT

### 语句构成

关键字keyword组成子句clause，多条clause组成语句

```bash
SELECT *  #select子句
FROM products  #FROM子句
WHERE price>666 #WHERE子句
HELP KEYWORD  #查看语句帮助
```

### 字符集和排序

```bash
#查看支持所有字符集
SHOW CHARACTION SET; #命令不区分大小写
SHOW CHARSET;
#查看支持所有排序的规则
SHOW COLLATION;
注意：
utf8_general_ci不区分大小写
utf8_bin 区分大小写
#查看当前使用的排序规则
show variables like 'collation%';
#设置服务器默认的字符集
vim /etc/my.cnf
[mysql]
character-set-server=utf8mb4
#设置mysql客户端默认的字符集
vim /etc/my.cnf
#针对mysql客户端
[mysql]
default-character-set=utf8mb4
#针对所有MySQL客户端
[client]
default-character-set=utf8mb4


```

### 管理数据库

#### 创建数据库

```bash
CREATE DATABASE|SCHEMA [IF NOT EXISTS] 'DB_NAME'  #创建数据库
CHARACTER SET 'character set name'  #设置字符类型
COLLATE 'collate name'  #是否区分字符大小写
select database();  #查看自己在那个库中

create database db1  #创建数据库db1
create database if not exists db2 character set 'utf8' #指定utf8字符集进行创建db2数据库
show  create database db_name; #查看已经创建过的数据库信息
create database test charset=utf8; #简写指定字符串进行创建数据库
create database zabbix character set utf8 collate utf8_bin; #手动创建一个字符集为utf8，不区分大小写的zabbix数据库
#通过容器启动并创建数据库
[root@centos8 ~]#docker run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -d mysql:5.7 \
      --character-set-server=utf8 --collation-server=utf8_bin
     
[root@centos8 ~]#docker run -d -p 3306:3306 --name mysql \ 
 -e MYSQL_ROOT_PASSWORD=123456 \
 -e MYSQL_DATABASE=jumpserver 
 -e MYSQL_USER=jumpserver 
 -e MYSQL_PASSWORD=123456  
 -v /data/mysql:/var/lib/mysql
 -v /etc/mysql/mysql.conf.d/mysqld.cnf:/etc/mysql/mysql.conf.d/mysqld.cnf \
 -v /etc/mysql/conf.d/mysql.cnf:/etc/mysql/conf.d/mysql.cnf   mysql:5.7.30

```

#### 修改数据库

```bash
ALTER DATEBASE DB_NAME character set utf8;
ALTER DATABASE db1 character set utf8 COLLATE utf8_bin; #修改数据库db1的字符集为不区分大小写
show create database db1;  #查看db1库的修改日志
创好的库在/var/lib/mysql/下能查到库 在其下.opt文件中可以看到修改日志

```

#### 删除数据库

```bash
DROP DATABASE|SCHEMA [IF EXISTS] 'DB_NAME'
删除以后在/var/lib/mysql同步删除用户文件夹
```

#### 查看数据库列表

```bash
SHOW DATABASES;  #查看库中的表
```

## 数据类型

数据类型有以下几种：数据型（整数型、小数型）、字符型、时间\日期型

![](image/image_jLR_jH-kPt.png)

选择正确数据的三大原则：

更小的通常更好，尽量使用正确存储数据的最下数据类型

简单最好，简单数据类型的操作需要更少的cpu周期

尽量避免null。包含null的列，对MySQL更难优化

### 整数型

tinyint(m) 1个字节 范围(-128\~127)

smallint(m) 2个字节 范围(-32768\~32767)

mediumint(m) 3个字节 范围(-8388608\~8388607)

int(m) 4个字节 范围(-2147483648\~2147483647)

bigint(m) 8个字节 范围(+-9.22\*10的18次方)

上述数据类型，如果加修饰符unsigned后，则最大值翻倍

如：tinyint unsigned的取值范围为(0\~255)

int(m)里的m是表示SELECT查询结果集中的显示宽度，并不影响实际的取值范围，规定了MySQL的一些交互工具（例如MySQL命令行客户端）用来显示字符的个数。对于存储和计算来说，Int(1)和Int(20)是相同的

BOOL，BOOLEAN：布尔型，是TINYINT(1)的同义词zero值被视为假，非zero值视为真

### 浮点型

float(m,d) 单精度浮点型 8位精度(4字节) m总个数，d小数位, 注意: 小数点不占用总个数

double(m,d) 双精度浮点型16位精度(8字节) m总个数，d小数位, 注意: 小数点不占用总个数

设一个字段定义为float(6,3)，如果插入一个数123.45678,实际数据库里存的是123.457，但总个数还以实际为准，即6位

### 定点数

浮点类型在存储同样范围的值时，通常比decimal使用更少的空间。float使用4个字节存储。double占用8个字节

因为需要额外的空间和计算开销，所以应该尽量只在对小数进行精确计算时才使用decimal，例如存储财务数据。但在数据量比较大的时候，可以考虑使用bigint代替decimal

### 字符串

char(n) 固定长度，最多255个字符,注意不是字节
varchar(n) 可变长度，最多65535个字符
tinytext 可变长度，最多255个字符
text 可变长度，最多65535个字符
mediumtext 可变长度，最多2的24次方-1个字符
longtext 可变长度，最多2的32次方-1个字符
BINARY(M) 固定长度，可存二进制或字符，长度为0-M字节
VARBINARY(M) 可变长度，可存二进制或字符，允许长度为0-M字节
内建类型：ENUM枚举, SET集合

char和varchar比较

1.char(n) 若存入字符数小于n，则以空格补于其后，查询之时再将空格去掉，所以char类型存储的字符串末尾不能有空格，varchar不限于此

2.char(n) 固定长度，char(4)不管是存入几个字符，都将占用4个字节，varchar是存入的实际字符数+1个字节（n< n>255)，所以varchar(4),存入3个字符将占用4个字节

3.char类型的字符串检索速度要比varchar类型的快

varchar和text

1.varchar可指定n，text不能指定，内部存储varchar是存入的实际字符数+1个字节（n< n>255)，text是实际字符数+2个字节。

2.text类型不能有默认值

3.varchar可直接创建索引，text创建索引要指定前多少个字符。varchar查询速度快于text

VARCHAR(50) 能存放几个 UTF8 编码的汉字？

```bash
存放的汉字个数与版本相关。
mysql 4.0以下版本，varchar(50) 指的是 50 字节，如果存放 UTF8 格式编码的汉字时（每个汉字3字节），只能存放16 个。
mysql 5.0以上版本，varchar(50) 指的是 50 字符，无论存放的是数字、字母还是 UTF8 编码的汉字，都可以存放 50 个。
```

### 二进制数据BLOB

BLOB和text存储方式不同，TEXT以文本方式存储，英文存储区分大小写，而Blob以二进制方式存储，不分大小写
BLOB存储的数据只能整体读出
TEXT可以指定字符集，BLOB不用指定字符集

### 日期时间类型

date 日期 '2008-12-2'
time 时间 '12:25:36'
datetime 日期时间 '2008-12-2 22:06:44'
timestamp 自动存储记录修改时间
YEAR(2), YEAR(4)：年份
timestamp 此字段里的时间数据会随其他字段修改的时候自动刷新，这个数据类型的字段可以存放这
条记录最后被修改的时间

### 修饰符

适用所有类型的修饰符：
NULL 数据列可包含NULL值，默认值
NOT NULL 数据列不允许包含NULL值，相当于网站注册表中的 \* 为必填选项
DEFAULT 默认值
PRIMARY KEY 主键，所有记录中此字段的值不能重复，且不能为NULL
UNIQUE KEY 唯一键，所有记录中此字段的值不能重复，但可以为NULL
CHARACTER SET name 指定一个字符集

适用数值型的修饰符：
AUTO\_INCREMENT 自动递增，适用于整数类型, 必须作用于某个 key 的字段,比如primary key
UNSIGNED 无符号

相关查询命令

```bash
create database test;  #创建一个基本库
use test; #进入基本库
create table t1(id int unsigned auto_increment primary key) auto_increment =4444444;   #给基本库创建一个表
show table status from test like "t1" \G  #查看基本库test中的t1详细信息
insert into t1 values(null);  #往t1中插入数据，插入两次插不进去
#上面表的数据类型无法存放所有数据,修改过数据类型实现
MariaDB [db1]> alter table t1 modify id bigint auto_increment ;
Query OK, 2 rows affected (0.023 sec)              
Records: 2 Duplicates: 0  Warnings: 0

```
