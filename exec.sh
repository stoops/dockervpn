#!/bin/bash

/usr/sbin/sshd

cat >/etc/sysctl.conf <<EOF
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.all.send_redirects=0
net.ipv4.conf.all.forwarding=1

net.ipv4.ip_local_port_range=31337 65535

net.ipv4.tcp_rfc1337=1
net.ipv4.tcp_tw_reuse=0
net.ipv4.tcp_adv_win_scale=-2
net.ipv4.tcp_synack_retries=3
net.ipv4.tcp_sack=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_keepalive_probes=5
net.ipv4.tcp_keepalive_intvl=15
net.ipv4.tcp_keepalive_time=45
net.ipv4.tcp_max_tw_buckets=8192
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_syn_retries=5
net.ipv4.tcp_fin_timeout=15

net.core.somaxconn=8192
net.core.optmem_max=65536

#net.netfilter.nf_conntrack_generic_timeout=95
net.netfilter.nf_conntrack_tcp_timeout_close=15
net.netfilter.nf_conntrack_tcp_timeout_close_wait=15
net.netfilter.nf_conntrack_tcp_timeout_established=300000
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=15
net.netfilter.nf_conntrack_tcp_timeout_time_wait=15
net.netfilter.nf_conntrack_tcp_timeout_last_ack=35
net.netfilter.nf_conntrack_tcp_timeout_syn_recv=55
net.netfilter.nf_conntrack_tcp_timeout_syn_sent=75
net.netfilter.nf_conntrack_tcp_timeout_max_retrans=95
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged=95
net.netfilter.nf_conntrack_udp_timeout=19
net.netfilter.nf_conntrack_udp_timeout_stream=19
EOF

sysctl -p /etc/sysctl.conf

cat >/etc/security/limits.d/all.conf <<EOF
*    - nofile 65536
root - nofile 65536
EOF

ulimit -n 65536

d=$((15 + 8))
v=$((95 + 12))
t=$((95 + 16))
w=$((350000 + 32))

export SKEY='0000ffff'

rl="rotatelogs -n 1"
rs="1M"
cc="/opt/soc"
op=" -f -zz "

$cc -m us -l "0.0.0.0:53953" -r "0.0.0.0:0" -t $d -c 512 $op 2>&1 | $rl /tmp/0.dns.log $rs >/dev/null 2>&1 &
$cc -m us -l "0.0.0.0:34599" -r "0.0.0.0:0" -t $v -c 768 $op 2>&1 | $rl /tmp/0.vpn.log $rs >/dev/null 2>&1 &

for x in `seq 1 4` ; do
	let y="$x + 4"
	$cc -m us -l "0.0.0.0:393${y}" -r "0.0.0.0:0" -t $t -c 2048 $op 2>&1 | $rl /tmp/${x}.udp.log $rs >/dev/null 2>&1 &
	$cc -m ts -l "0.0.0.0:393${x}" -r "0.0.0.0:0" -t $w -c 256 $op 2>&1 | $rl /tmp/${x}.tcp.log $rs >/dev/null 2>&1 &
done

while true ; do sleep 10 ; done
