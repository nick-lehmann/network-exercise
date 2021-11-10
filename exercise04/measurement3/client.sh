ip netns exec host2 bash
tc qdisc add dev veth2 root netem delay 30ms
iperf3 --client 192.168.1.1