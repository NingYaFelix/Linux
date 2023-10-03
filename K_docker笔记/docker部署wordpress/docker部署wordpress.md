# docker部署wordpress

## 目录

-   [具体步骤](#具体步骤)

实验流程：编写mysql的环境变量→拉取并运行mysql镜像→拉取创建wordpress镜像→编写配置文件（如果没有引入环境变量则执行）→访问

## 具体步骤

编写mysql配置文件

```bash
MYSQL_ROOT_PASSWORD=123456  #超级用户root的密码
MYSQL_DATABASE=wordpress   #要创建的基本库，wordpress的库
MYSQL_USER=wordpress    #远程链接的用户默认%地址链接
MYSQL_PASSWORD=xiaoluozi   #远程用户连接的密码

```

数据库操作：`docker run --name mysql --env `/wordpress/mysql.env`  -v  `/my/custom:/etc/mysql/conf.d`  `-d`  mysql:8`

拉取并创建wordpress：`docker run --name wordpress -v `/wordpress/:/var/www/html`  -p  `8080:80`  -d   `wordpress:php8.0-apache

修改/wordpress/wp-config-sample.php文件：`mv /wordpresswp-config-sample.php /wordpresswp-config.php `

```bash
vim /wordpress/wp-config.php
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );  #远程数据库基本库的名称

/** MySQL database username */
define( 'DB_USER', 'wordpress' );  #远程数据库远程用户名

/** MySQL database password */
define( 'DB_PASSWORD', 'xiaoluozi' );  #远程用户的密码

/** MySQL hostname */
define( 'DB_HOST', '172.17.0.2' );  #远程数据库地址

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

```

使用主机ip:8080进行访问
