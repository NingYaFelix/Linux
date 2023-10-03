#!/usr/bin/bash

# 集群节点
web_cluster="172.16.1.6 172.16.1.7 172.16.1.8"

# lb节点IP
lb_server="172.16.1.5"

# 集群资源池名称
cluster="webservers"


# 节点的代码路径
webdir=/proxy

for host in ${web_cluster}
do
	# 1.登录负载均衡,动态摘掉节点
	ssh root@${lb_server} "echo 'disable server ${cluster}/${host}' | socat stdio /var/lib/haproxy/stats"
	

	# 2.更新节点的代码
	scp ./index.html.${host} root@${host}:${webdir}/index.html
	sleep 2

	# 3.登录负载均衡，动态加入节
	ssh root@${lb_server} "echo 'enable server ${cluster}/${host}' | socat stdio /var/lib/haproxy/stats"


	# 4.等待一会在继续下一台
	sleep 5
done
