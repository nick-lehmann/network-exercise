ip netns add host1
ip netns add host2
ip link add veth1 type veth peer name veth2
ip link set dev veth1 netns host1
ip link set dev veth2 netns host2

ip netns exec host1 ip address add 192.168.1.1/24 dev veth1
ip netns exec host2 ip address add 192.168.1.2/24 dev veth2

ip netns exec host1 ip link set dev veth1 up
ip netns exec host2 ip link set dev veth2 up