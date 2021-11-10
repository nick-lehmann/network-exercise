ip netns exec host2 bash
tc qdisc add dev veth2 root netem delay 30ms
tc qdisc change dev veth2 root netem loss 1%
iperf3 --client 192.168.1.1