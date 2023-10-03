# shell函数和数组

## 目录

-   [shell函数](#shell函数)
    -   [函数的意义](#函数的意义)
    -   [基础语法](#基础语法)
    -   [函数传参](#函数传参)
    -   [函数实现计算器功能](#函数实现计算器功能)
    -   [nignx的启停脚本](#nignx的启停脚本)
    -   [函数状态返回值](#函数状态返回值)
        -   [return返回数值](#return返回数值)
    -   [函数示例](#函数示例)
        -   [实现系统工具箱脚本](#实现系统工具箱脚本)
        -   [实现跳板机功能](#实现跳板机功能)
-   [shell数组](#shell数组)
    -   [普通数组进行赋值](#普通数组进行赋值)
    -   [关联数组进行赋值](#关联数组进行赋值)
    -   [数组遍历及循环](#数组遍历及循环)
        -   [示例](#示例)

# shell函数

函数就是一堆命令的集合，用来完成特定功能的代码块

## 函数的意义

函数能减少代码冗余，增加代码的可读性，

必须先定义才可以调用，如果不定义则无法进行执行

## 基础语法

定义shell函数，可以通过如下两种当时进行定义

```bash
#方式1
name:(函数名){
    command 1
    command 2
    ....
    command n
    （填写执行的shell命令）
}

#方式2
function name（函数名）
{
  command 1
  command 2
  ....
  command n

}

#如何调用函数
直接调用，写函数名
```

## 函数传参

在函数内部可以使用参数\$1,\$2,...调用函数

```bash
#单个函数进行传参
fun() {
echo "hello,$1"; 
}
#多个函数进行传参
fun(){
echo hello "$1" "$2" "$3";
}
#函数中传递多个参数并接受所有的参数传递
fun(){
echo "hello,$*";
}

```

## 函数实现计算器功能

需求：写一个脚本，实现计算器功能

```bash
[root@jumserver63 hanshu]# sh jisuanqi.sh
  请输入一个数字2
  请输入要运算的方式 +|——|*|/+
  请输入要运算的数字3
  5
[root@jumserver63 hanshu]# cat jisuanqi.sh
  #!/usr/bin/env bash
  jisuaqi() {
    case $b in
    +)
      echo "$(expr $a + $c)"
      ;;
    -)
      echo "$(expr $a - $c)"
      ;;
    \*)
      echo "$(expr $a * $c)"
      ;;
    /)
      echo "$(expr $a / $c)"
    esac
  }
  read -p "请输入一个数字" a
  read -p "请输入要运算的方式 +|——|*|/" b
  read -p "请输入要运算的数字" c
  jisuaqi $a $b $c
```

## nignx的启停脚本

```bash
[root@jumserver63 hanshu]# cat status.sh
#!/usr/bin/env bash
source /etc/init.d/functions
nginx_when() {
  if [ $? -eq 0 ];then
    action "nginx $1 is ok" /bin/true
  else
    action "nginx $1 is er" /bin/false
  fi
}
case $1 in
  start)
    nginx
    nignx_when $1
    ;;
  stop)
    nignx -s stop
    nginx_when $1
    ;;
  reload)
    nginx -s reload
    nginx_when $1
    ;;
  *)
    echo "USAGE: $0 { start|stop|reload }"
esac
```

## 函数状态返回值

shell的函数返回值只有两种方式：echo 、return

return返回值：只能返回1-255的整数，函数使用return返回值，通常只是用来供其他地方调用获取状态，0成功，1失败

echo返回值：使用echo可以返回任何字符串结果，通常用来返回数据，比如一个字符串值或者列表值

### return返回数值

```bash
#判断服务是否正常启动
#！/usr/bin/bash
server_runing(函数名)（）{
  systemctl status $1 &> /dev/null
  if [ $? -eq 0 ];then
    return 0  #如果服务已经启动返回状态值0
  else 
    return 1 #没有启动返回状态值1

}
```

## 函数示例

### 实现系统工具箱脚本

```bash
[root@jumserver63 hanshu]# sh tools.sh
 ---------------------
        tools
    h 显示帮助
    p 显示进程
 ---------------------
请输入你要执行的操作 h|p(退出e): e
[root@jumserver63 hanshu]# cat tools.sh
#!/usr/bin/env bash
candan () {
 cat <<-EOF
 ---------------------
        tools
    h 显示帮助
    p 显示进程
 ---------------------
EOF
}
  candan
while true
do
   read -p "请输入你要执行的操作 h|p(退出e): "  a
   case $a in
    h)
      help
      ;;
    p)
      ps
      ;;
    e)
      exit
   esac


done
```

### 实现跳板机功能

思路：创建一个菜单，判断用户要链接的主机，使用case加循环，ssh进行链接，该脚本无法直接退出

```bash
#创建菜单，在菜单里写上可以远程链接的主机ip
#使用case判断用户输入的选项进行ssh链接

```

# shell数组

数组其实也是变量，传统的变量只能存储一个值，但数组能存储多个

数组主要分两种：普通数组和关联数组

普通数组只能使用整数作为数组索引

关联数组可以使用字符串作为数组索引

### 普通数组进行赋值

方式一：数组名\[索引]=变量值

方式2：数值名=（多个变量值）

```bash
array2=（tom jack alice）
```

-   进行访问

    数组名加索引即可访问数组中元素

    echo \${array\[ \*]} :访问数组中所有数据

    获取数组中的索引。在数据遍历时候有用：echo  \${!array\[@]}

    统计数组个数：echo \${#array\[@]}

### 关联数组进行赋值

关联数组能使用字符串的方式作为索引

首先必须先声明这是一个关联数组：`declare -A info`

进行赋值：

其次对关联数组进行赋值（数组名\[索引]=变量值）

`info[index]=pear`&#x20;

赋值（数组名=（\[索引1]=变量2 \[索引2=变量值2]））

```bash
root@oldxu ~]# info2=([index1]=linux [index2]=nginx [index3]=docker [index4]='bash shell')
```

查看关联数组

declare -A

## 数组遍历及循环

数组遍历其实就是使用对数组进行批量赋值，然后通过循环方式批量取出数组的值

遍历的意义在于统计某个字段出现的次数，主要通过数组的索引进行遍历

### 示例

准备一个文本文件

```bash
jack m
alice f
tom m
rose f
robin m
oldxu m
gdx x
```

```bash
[root@jumserver63 hanshu]# cat found.sh
#!/usr/bin/env bash
declare -A sex
#对数组进行赋值
while read line
do
  #列出第二列的内容
  type=$(echo $line|awk '{print $2}')
  #定义一个关联数组，让数组的值不断自增
  let sex[$type]++

done < name.txt
#遍历数组
for i in ${!sex[@]}
do
  echo "$i ${sex[$i]}"
done
```
