# ubuntu安装

## 目录

-   [使用官方安装脚本自动安装](#使用官方安装脚本自动安装)
-   [手动安装（较为麻烦）](#手动安装较为麻烦)
    -   [卸载旧版本](#卸载旧版本)
-   [使用Docker仓库进行安装](#使用Docker仓库进行安装)
    -   [设置仓库](#设置仓库)

安装主要有以下三种方式： 官方安装脚本自动安装、手动安装、脚本自动化安装

ubuntu修改IP地址网络

```bash
sudo vi /etc/netplan/00-installer-config.yaml

network:
 ethernets:
  ens33:   #配置的网卡的名称
   addresses: [192.168.31.215/24]  #配置的静态ip地址和掩码
   dhcp4: no  #关闭DHCP，如果需要打开DHCP则写yes
   optional: true
   gateway4: 192.168.31.1  #网关地址
   nameservers:
     addresses: [192.168.31.1,114.114.114.114]  #DNS服务器地址，多个DNS服务器地址需要用英文逗号分隔开
 version: 2
 renderer: networkd  #指定后端采用systemd-networkd或者Network Manager，可不填写则默认使用systemd-workd
#使配置生效
sudo netplan apply
 
```

## 使用官方安装脚本自动安装

```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun

#国内daocloud一键安装命令
curl -sSL https://get.daocloud.io/docker | sh

```

## 手动安装（较为麻烦）

安装主要可以分为以下几步

1.卸载旧版本（若未安装过可跳过该步骤）

2.设置仓库，使用docker仓库进行安装

3.安装docker引擎社区（engine-community）

### 卸载旧版本

docker旧版本称为docker，docker.io或docker-engine若已安装请卸载，若未安装可以跳过此步骤

```bash
$ sudo apt-get remove docker docker-engine docker.io containerd runc
```

## 使用Docker仓库进行安装

在新主机首次安装Docker engine-community之前，需要设置docker仓库，以后在进行安装只需要从仓库进行安装即可。

#### 设置仓库

```bash
#更新apt索引
sudo apt-get update
#安装apt依赖包，通过https进行获取仓库
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
#添加docker官方gpg密钥
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
#搜索密钥，验证是否有带指纹密钥
curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
#设置稳定版仓库
sudo add-apt-repository \
   "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ \
  $(lsb_release -cs) \
  stable"
#列出仓库可用版本
apt-cache madison docker-ce

```
