MAILSERVER_IP=10.0.0.1
GIT_IP=10.0.0.2
WEBSERVER_IP=10.0.0.42

ip netns add router
ip netns add webserver

ip link add \
	veth-internal netns router \
	type veth \
	peer name \
	veth-webserver netns webserver
ip link add \
	veth-external netns router \
	type veth \
	peer name \
	veth-www

# Make internet
ip link set dev veth-www up
ip addr add 192.168.0.1/24 dev veth-www

# Connect webserver
ip netns exec router bash -c "
	ip link set dev veth-webserver up
	ip addr add 10.0.0.42/24 dev veth-webserver
"

# Configure router
ip netns exec router bash -c "
	ip link set dev veth-internal up
	ip link set dev veth-external up

	ip addr add 10.0.0.1/24 dev veth-internal
	ip addr add 192.168.0.2/24 dev veth-external

	tc qdisc add dev veth-external root handle 1: htb default 3
	tc class add dev veth-external parent 1: classid 1:1 htb rate 100mbit prio 0
	tc class add dev veth-external parent 1: classid 1:2 htb rate 100mbit prio 1
	tc class add dev veth-external parent 1: classid 1:3 htb rate 100mbit prio 2
	tc class add dev veth-external parent 1: classid 1:4 htb rate 1mbit ceil 1mbit prio 2
"

# Mailserver bekommt höchste Priorität
tc -netns router filter add \
	dev veth-external \
	parent 1: \
	protocol ip \
	u32 match \
	ip src $MAILSERVER_IP/32 \
	flowid 1:1

# Gitserver bekommt mittlere Priorität
tc -netns router filter add \
	dev veth-external \
	parent 1: \
	protocol ip \
	u32 match \
	ip src $GIT_IP/32 \
	flowid 1:2

# Webserver bekommt keine Priorität und dazu noch Drosselung
tc -netns router filter add \
	dev veth-external \
	parent 1: \
	protocol ip \
	u32 match \
	ip src $WEBSERVER_IP/32 \
	flowid 1:4

ip -netns webserver route add default via 10.0.0.1
ip route add 10.0.0.0/24 via 192.168.0.2

# Aktivierung von IP-Forwarding im Router-Namespace
ip netns exec router sysctl -w net.ipv4.ip_forward=1

iperf -s
# ------------------------------------------------------------
# Server listening on TCP port 5001
# TCP window size:  128 KByte (default)
# ------------------------------------------------------------
# [  4] local 192.168.0.1 port 5001 connected with 10.20.30.42 port 60466
# [ ID] Interval       Transfer     Bandwidth
# [  4]  0.0-22.5 sec  2.50 MBytes   932 Kbits/sec

# >ip netns exec webserver iperf -c 192.168.0.1
# ------------------------------------------------------------
# Client connecting to 192.168.0.1, TCP port 5001
# TCP window size:  128 KByte (default)
# ------------------------------------------------------------
# [  3] local 10.20.30.42 port 60466 connected with 192.168.0.1 port 5001
# [ ID] Interval       Transfer     Bandwidth
# [  3]  0.0-10.9 sec  2.50 MBytes  1.93 Mbits/sec

