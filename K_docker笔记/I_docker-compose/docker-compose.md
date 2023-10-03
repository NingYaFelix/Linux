# docker-compose

## 目录

-   [Docker-compose的好处](#Docker-compose的好处)
    -   [使用compose步骤](#使用compose步骤)

docker容器平台三大工具：

Machine：Docker Engine的部署工具

&#x20;Swarm：负责Docker容器的集群功能、资源管理和生命周期管理

Compose：容器编排工具，负责将多个容器放在一起基于单个逻辑运行整个应用、轻量、易用

docker compose

基于YAML文件定义服务

使用docker-compose命令基于docker-compose.yaml文件管理定义的服务

## Docker-compose的好处

快速简单的配置：借助 YAML 脚本和环境变量，用户可以轻松配置或修改应用服务

◼ 安全的内部通信：Compose 创建一个供所有服务共享的专用网络，从而为应用程序增加了额外的安全层，因为这些服务无法从外部访问

◼ 可移植性和 CI/CD 支持

◆所有服务都在 docker-compose 文件中定义，因此开发人员可以轻松访问和共享整个配置

◆通过拉取 YAML 文件和源代码，用户可以在几分钟内启动环境，因而有助于建立和启用高效的CI/CD管道

◼ 更高效地利用资源：Docker Compose 允许用户在一台主机上托管多个隔离的环境，而且它的功能使其能够缓存配置并重用现有容器，这也有助于提高资源效率

### 使用compose步骤

使用Dockerfile和依赖的文件定义应用程序的镜像构建环境

◼ 在docker-compose.yaml文件中配置服务，定义编排组件

◆服务、存储卷和网络等

◼ 使用docker-compose命令基于配置文件完成应用编排

使用docker compose得三个步骤

使用dockerfile和依赖的文件定义应用程序的镜像构建环境

再dockerfile-compose.yaml文件中配置服务，定义编排组件（服务、存储卷和网阔等）

使用docker-compose命令基于配置文件完成应用编排
