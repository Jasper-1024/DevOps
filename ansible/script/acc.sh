#!/bin/bash

set -x

sudo -S tee -a /etc/security/limits.conf << EOF
* soft nofile 51200
* hard nofile 51200
EOF

sudo -S tee -a /etc/sysctl.conf << EOF
# 系统所有进程一共可以打开的文件数量， 每个套接字也占用一个文件描述字
fs.file-max = 1491124

# 增大内核 backlog 参数，使得系统能够保持更多的尚未完成 TCP 三次握手的套接字。
net.ipv4.tcp_max_syn_backlog = 1048576
net.core.netdev_max_backlog = 1048576
net.core.somaxconn = 1048576

# 表示用于向外连接的端口范围
net.ipv4.ip_local_port_range = 4096 65000
# 预留端口
net.ipv4.ip_local_reserved_ports = 3000,3306,6379,27017,27018

#系统中最多有多少个TCP套接字不被关联到任何一个用户文件句柄上。这个限制仅仅是为了防止简单的DoS攻击，不能过分依靠它或者人为地减小这个值，更应该增加这个值(如果增加了内存之后)
net.ipv4.tcp_max_orphans = 131072

# 启用 TIME_WAIT 复用，使得结束 TIEM_WAIT 状态的套接字的端口可以立刻被其他套接字使用
net.ipv4.tcp_tw_reuse = 1
# 表示系统同时保持TIME_WAIT的最大数量
net.ipv4.tcp_max_tw_buckets = 55000

# 优化 nf_conntrack 参数，防止服务器出现大量短链接的时候出现丢包
net.netfilter.nf_conntrack_max=1048576
net.nf_conntrack_max=1048576
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.netfilter.nf_conntrack_tcp_timeout_close_wait=15
net.netfilter.nf_conntrack_tcp_timeout_established=300

# 缩短套接字处于 TIME_WAIT 的时间， 60s -> 15s
net.ipv4.tcp_fin_timeout = 15

# 减小 tcp keepalive 探测次数，可以即时释放长链接
net.ipv4.tcp_keepalive_probes = 3
# 缩短 tcp keepalive 探测间隔时间，同上
net.ipv4.tcp_keepalive_intvl = 15
# 修改 tcp keepalive 默认超时时间
net.ipv4.tcp_keepalive_time=1200

# 关闭慢启动重启(Slow-Start Restart), SSR 对于会出现突发空闲的长周期 TLS 连接有很大的负面影响
net.ipv4.tcp_slow_start_after_idle = 0

# 启用 MTU 探测，在链路上存在 ICMP 黑洞时候有用（大多数情况是这样）
net.ipv4.tcp_mtu_probing = 1

# 表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭
net.ipv4.tcp_syncookies = 1

# 当某个节点可用内存不足时, 系统会倾向于从其他节点分配内存。对 Mongo/Redis 类 cache 服务器友好
vm.zone_reclaim_mode = 0

# 当内存使用率不足10%（默认值60%）时使用 swap，尽量避免使用 swap，减少唤醒软中断进程
vm.swappiness = 10

# 内核执行无内存过量使用处理。使用这个设置会增大内存超载的可能性，但也可以增强大量使用内存任务 Mongo/Redis 的性能。
vm.overcommit_memory = 1

# 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭 为了对NAT设备更友好，建议设置为0。
net.ipv4.tcp_tw_recycle = 0


# 启用 tcp fast open
net.ipv4.tcp_fastopen = 3

# 剩余内存 > 300m
net.core.rmem_default = 174760
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.ipv4.tcp_rmem = 4096 174760 67108864

net.core.wmem_default = 131072
net.core.wmem_max = 2097152
net.ipv4.tcp_wmem = 4096 131072 67108864

net.ipv4.tcp_mem = 131072 262144 524288

# 启用 bbr
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# ipv6 转发
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.default.forwarding=1
# 处理 ra
net.ipv6.conf.all.accept_ra=2
net.ipv6.conf.default.accept_ra=2
# ipv6 隐私拓展
# net.ipv6.conf.all.use_tempaddr=2
# net.ipv6.conf.default.use_tempaddr=2

#END OF LINE
EOF

sudo -S sysctl -p

echo 'acc complete!'
