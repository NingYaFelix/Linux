# zabbix优化及Grafana

## 目录

-   [zabbix优化](#zabbix优化)
-   [Grafana](#Grafana)

## zabbix优化

拆分数据库

Zabbix属于写多读少的业务，所以需要针对zabbix的MySQL进行拆分；

调主被模式

将Zabbix-Agent被动监控模式，调整为主动监控模式

使用分布式

使用zabbix-proxy分布式监控，在大规模监控时用于缓解Zabbix-Server压力

删除无用监控项

去掉无用监控项, 增加监控项的取值间隔，减少历史数据保存周期(由housekeeper进程定时清理)
增大监控项取值间隔；60s 1h; 1d;

进程调优

针对Zabbix-server进程调优，将比较繁忙的进程数量进行调大，具体取决实际情况，不是越大越好

```bash
StartPollersUnreachable=50 占用率从百分之70直线下降到百分10
```

缓存调优

针对Zabbix-server缓存调优，将剩余内存较少的缓存值进行增大，通过(zabbix cache usage图表观察)

`CacheSize=128M`

检查延迟队列

关注管理->队列, 是否有被延迟执行的监控项

## Grafana

Grafana是一个图形展示工具，它本身并不存储任何数据，数据都是从配置的 “数据源” 获取的；Grafana支持从Zabbix中获取数据，然后进行图形展
示；

安装

```bash
#下载包
[root@zabbix zabbix]# wget https://dl.grafana.com/oss/release/grafana-8.2.1-1.x86_64.rpm
#安装本地资源包
[root@zabbix zabbix]# sudo yum localinstall -y grafana-8.2.1-1.x86_64.rpm
#将grafana加入开机自启动并启动
systemctl enable grafana-server
systemctl start grafana-server
使用浏览器访问grafana。默认监听3000，用户名和密码均为admin#直接解析hosts
```
